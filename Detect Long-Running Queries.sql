-- Queries running currently more than 10 seconds
-- Queries currently running for more than 10 seconds, filtered by database name
SELECT 
    r.session_id,
    r.status,
    r.start_time,
    DB_NAME(r.database_id) AS DatabaseName,
    r.total_elapsed_time / 1000 AS ElapsedSeconds,
    SUBSTRING(t.text, r.statement_start_offset / 2 + 1,
              (CASE r.statement_end_offset
                 WHEN -1 THEN LEN(CONVERT(NVARCHAR(MAX), t.text)) * 2
                 ELSE r.statement_end_offset END - r.statement_start_offset) / 2) AS RunningQuery
FROM sys.dm_exec_requests r
CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) t
WHERE r.total_elapsed_time > 10000
  AND DB_NAME(r.database_id) = 'DEV_BAZ_PARENT_2025'  -- 🔍 Replace with your target DB name
ORDER BY r.total_elapsed_time DESC;

