WITH Objects_DB1 AS (
    SELECT name, type_desc, 'DB1' AS SourceDB, type
    FROM [DEV_BAZ_PARENT_2025].sys.objects
    WHERE is_ms_shipped = 0 AND type IN ('P', 'FN', 'IF', 'TF', 'V', 'TR')
),
Objects_DB2 AS (
    SELECT name, type_desc, 'DB2' AS SourceDB, type
    FROM [UAT_BAZ_PARENT_2025].sys.objects
    WHERE is_ms_shipped = 0 AND type IN ('P', 'FN', 'IF', 'TF', 'V', 'TR')
),
Combined AS (
    SELECT name, type_desc, SourceDB, type FROM Objects_DB1
    UNION ALL
    SELECT name, type_desc, SourceDB, type FROM Objects_DB2
)
SELECT 
    name,
    type_desc,
    MAX(CASE WHEN SourceDB = 'DB1' THEN '✔️ Present' ELSE '❌ Missing' END) AS In_DB1,
    MAX(CASE WHEN SourceDB = 'DB2' THEN '✔️ Present' ELSE '❌ Missing' END) AS In_DB2,
    type
FROM Combined
GROUP BY name, type_desc, type
HAVING 
    COUNT(DISTINCT SourceDB) = 1 -- Only present in one DB
ORDER BY type_desc, name;
