-- Tables with large row counts, no clustered index
SELECT 
    t.name AS TableName,
    SUM(p.rows) AS TotalRows,
    CASE WHEN i.object_id IS NULL THEN 'No Clustered Index' ELSE 'Has Clustered Index' END AS ClusteredIndexStatus
FROM sys.tables t
JOIN sys.partitions p ON t.object_id = p.object_id
LEFT JOIN sys.indexes i ON t.object_id = i.object_id AND i.type = 1
WHERE p.index_id IN (0,1)
GROUP BY t.name, i.object_id
ORDER BY TotalRows DESC;
