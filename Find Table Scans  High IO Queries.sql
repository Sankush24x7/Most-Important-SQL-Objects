-- Detect queries with most logical reads
-- Top 20 queries by total logical reads, with database name and filter
SELECT TOP 20
    DB_NAME(CONVERT(int, pa.value)) AS DatabaseName,
    qs.total_logical_reads AS TotalLogicalReads,
    qs.execution_count,
    SUBSTRING(qt.text, (qs.statement_start_offset / 2) + 1,
              ((CASE qs.statement_end_offset
                    WHEN -1 THEN DATALENGTH(qt.text)
                    ELSE qs.statement_end_offset END
               - qs.statement_start_offset) / 2) + 1) AS QueryText
FROM sys.dm_exec_query_stats qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) qt
CROSS APPLY (
    SELECT CONVERT(int, value) AS value
    FROM sys.dm_exec_plan_attributes(qs.plan_handle)
    WHERE attribute = 'dbid'
) pa
WHERE DB_NAME(CONVERT(int, pa.value)) = 'DEV_BAZ_PARENT_2025'  -- 🔍 Replace with your target DB name
ORDER BY TotalLogicalReads DESC;

