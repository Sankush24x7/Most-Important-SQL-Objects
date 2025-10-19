DECLARE @TraceFile NVARCHAR(500);
 
-- Get default trace path
SELECT TOP 1 @TraceFile = path
FROM sys.traces
WHERE is_default = 1;
 
-- Read the trace
SELECT 
    te.name AS EventName,
    t.DatabaseName,
    t.ObjectName,
    t.ObjectType,
    t.HostName,
    t.ApplicationName,
    t.LoginName,
    t.StartTime
FROM fn_trace_gettable(@TraceFile, DEFAULT) t
JOIN sys.trace_events te ON t.EventClass = te.trace_event_id
WHERE 
te.name IN ('Object:Created', 'Object:Deleted', 'Object:Altered')
and 
t.ObjectName = 'Access_Log'
ORDER BY t.StartTime DESC;