-- List all scalar UDFs
SELECT 
    SCHEMA_NAME(o.schema_id) AS SchemaName,
    o.name AS FunctionName,
    o.create_date,
    o.modify_date
FROM sys.objects o
WHERE o.type = 'FN'  -- scalar functions
ORDER BY o.modify_date DESC;
