-- Top 20 queries by total CPU
SELECT TOP 20
    DB_NAME(CONVERT(int, pa.value)) AS DatabaseName,
    qs.total_worker_time / 1000 AS TotalCPU_ms,
    qs.total_elapsed_time / 1000 AS TotalTime_ms,
    qs.execution_count,
    SUBSTRING(qt.text, (qs.statement_start_offset/2)+1, 
              ((CASE qs.statement_end_offset
                    WHEN -1 THEN DATALENGTH(qt.text)
                    ELSE qs.statement_end_offset END
               - qs.statement_start_offset)/2)+1) AS QueryText
FROM sys.dm_exec_query_stats qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) qt
CROSS APPLY (
    SELECT CONVERT(int, value) AS value
    FROM sys.dm_exec_plan_attributes(qs.plan_handle)
    WHERE attribute = 'dbid'
) pa
WHERE DB_NAME(CONVERT(int, pa.value)) = 'DEV_BAZ_PARENT_2025'  -- 🔍 Replace with your actual DB name
ORDER BY TotalCPU_ms DESC;


