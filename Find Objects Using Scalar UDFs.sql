-- Find which procs/views/functions reference scalar UDFs
SELECT DISTINCT
    OBJECT_SCHEMA_NAME(d.referencing_id) AS ObjectSchema,
    OBJECT_NAME(d.referencing_id) AS ObjectName,
    o.type_desc AS ObjectType,
    d.referenced_entity_name AS FunctionUsed
FROM sys.sql_expression_dependencies d
JOIN sys.objects o ON d.referencing_id = o.object_id
WHERE d.referenced_class_desc = 'OBJECT_OR_COLUMN'
  AND d.referenced_entity_name IN (
      SELECT name
      FROM sys.objects
      WHERE type = 'FN'
  )
ORDER BY ObjectSchema, ObjectName;

