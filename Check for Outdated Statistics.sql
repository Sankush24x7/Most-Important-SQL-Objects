-- Tables with stats last updated > 30 days
SELECT 
    t.name AS TableName,
    s.name AS StatsName,
    STATS_DATE(s.object_id, s.stats_id) AS LastUpdated
FROM sys.stats s
JOIN sys.tables t ON s.object_id = t.object_id
WHERE STATS_DATE(s.object_id, s.stats_id) < DATEADD(DAY, -30, GETDATE())
ORDER BY LastUpdated ASC;
