-- 🔴 Live long-running queries
SELECT 
    'Live' AS QueryType,
    DB_NAME(r.database_id) AS DatabaseName,
    OBJECT_NAME(t.objectid, r.database_id) AS SqlObjectName,
    s.login_name AS ExecutedBy,
    s.host_name AS HostName,
    r.cpu_time / 1000.0 AS CPU_ms,
    r.total_elapsed_time / 1000.0 AS Duration_ms,
    r.status,
    r.command,
    SUBSTRING(t.text, r.statement_start_offset / 2 + 1,
        (CASE r.statement_end_offset
            WHEN -1 THEN LEN(CONVERT(NVARCHAR(MAX), t.text)) * 2
            ELSE r.statement_end_offset END - r.statement_start_offset) / 2 + 1) AS QueryText
FROM sys.dm_exec_requests r
JOIN sys.dm_exec_sessions s ON r.session_id = s.session_id
CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) t
WHERE r.total_elapsed_time > 10000

UNION ALL

-- 🟡 Historical top queries by average CPU
SELECT 
    'Historical' AS QueryType,
    DB_NAME(qt.dbid) AS DatabaseName,
    OBJECT_NAME(qt.objectid, qt.dbid) AS SqlObjectName,
    NULL AS ExecutedBy,
    NULL AS HostName,
    qs.total_worker_time / qs.execution_count / 1000.0 AS CPU_ms,
    qs.total_elapsed_time / qs.execution_count / 1000.0 AS Duration_ms,
    NULL AS status,
    NULL AS command,
    SUBSTRING(qt.text, (qs.statement_start_offset / 2) + 1,
        ((CASE qs.statement_end_offset
            WHEN -1 THEN DATALENGTH(qt.text)
            ELSE qs.statement_end_offset END - qs.statement_start_offset) / 2) + 1) AS QueryText
FROM sys.dm_exec_query_stats qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) qt
WHERE qs.execution_count > 0
ORDER BY CPU_ms DESC;
