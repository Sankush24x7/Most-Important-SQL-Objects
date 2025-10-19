-- Detect fragmented indexes > 30%
-- Index fragmentation report with DB name filter, status, page count, and scan count
-- Detect fragmented indexes > 30% with DB name filter, status, page count, and access stats
WITH FragmentedIndexes AS (
    SELECT 
        ps.object_id,
        ps.index_id,
        s.name AS SchemaName,
        t.name AS TableName,
        i.name AS IndexName,
        ps.avg_fragmentation_in_percent AS FragmentationPercent,
        ps.page_count AS PageCount,
        ISNULL(us.user_seeks, 0) + ISNULL(us.user_scans, 0) + ISNULL(us.user_lookups, 0) AS TotalAccessCount,
        CASE 
            WHEN ps.avg_fragmentation_in_percent > 30 THEN 'Bad'
            ELSE 'Good'
        END AS FragmentationStatus
    FROM sys.dm_db_index_physical_stats(DB_ID('DEV_BAZ_PARENT_2025'), NULL, NULL, NULL, 'LIMITED') AS ps
    INNER JOIN sys.tables t ON ps.object_id = t.object_id
    INNER JOIN sys.schemas s ON t.schema_id = s.schema_id
    INNER JOIN sys.indexes i ON ps.object_id = i.object_id AND ps.index_id = i.index_id
    LEFT JOIN sys.dm_db_index_usage_stats us 
           ON us.database_id = DB_ID('DEV_BAZ_PARENT_2025') 
           AND ps.object_id = us.object_id 
           AND ps.index_id = us.index_id
    WHERE ps.avg_fragmentation_in_percent > 30
)
SELECT 
    DB_NAME(DB_ID('DEV_BAZ_PARENT_2025')) AS DatabaseName,
    fi.SchemaName,
    fi.TableName,
    fi.IndexName,
    fi.FragmentationPercent,
    fi.PageCount,
    fi.TotalAccessCount,
    fi.FragmentationStatus,
    o.name AS ReferencingObject,
    o.type_desc AS ObjectType,
    d.referenced_entity_name AS ReferencedEntity
FROM FragmentedIndexes fi
LEFT JOIN sys.sql_expression_dependencies d ON fi.object_id = d.referenced_id
LEFT JOIN sys.objects o ON d.referencing_id = o.object_id
ORDER BY fi.FragmentationPercent DESC, fi.TableName, o.name;



