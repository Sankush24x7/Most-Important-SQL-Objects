-- Declare DB list
DECLARE @Databases TABLE (DBName SYSNAME)
INSERT INTO @Databases (DBName)
VALUES ('DEV_BAZ_PARENT_2025'), ('UAT_BAZ_PARENT_2025')

DECLARE @ReferenceDB SYSNAME = 'DEV_BAZ_PARENT_2025'

-- Get list of base tables from reference DB
IF OBJECT_ID('tempdb..#Tables') IS NOT NULL DROP TABLE #Tables
CREATE TABLE #Tables (TableName NVARCHAR(128))

DECLARE @SQL NVARCHAR(MAX)
SET @SQL = '
    INSERT INTO #Tables (TableName)
    SELECT name 
    FROM [' + @ReferenceDB + '].sys.tables 
    WHERE name NOT LIKE ''%_History'' AND name NOT LIKE ''%_ZArchive''
'
EXEC (@SQL)

-- Create a wide result table to hold existence status for each DB
IF OBJECT_ID('tempdb..#ExistenceMatrix') IS NOT NULL DROP TABLE #ExistenceMatrix
CREATE TABLE #ExistenceMatrix (
    TableName NVARCHAR(128)
    -- We'll dynamically add columns later for each DB
)

-- Dynamically build ALTER TABLE to add columns for each DB
DECLARE @ColSQL NVARCHAR(MAX) = ''
SELECT @ColSQL = @ColSQL + '
    ALTER TABLE #ExistenceMatrix ADD [' + DBName + '] VARCHAR(10);'
FROM @Databases
EXEC sp_executesql @ColSQL

-- Insert table names
INSERT INTO #ExistenceMatrix (TableName)
SELECT DISTINCT TableName FROM #Tables

-- Now loop through each DB and check for existence of each table
DECLARE @DBName SYSNAME, @TableName NVARCHAR(128)

DECLARE db_cursor CURSOR LOCAL FOR SELECT DBName FROM @Databases
OPEN db_cursor
FETCH NEXT FROM db_cursor INTO @DBName

WHILE @@FETCH_STATUS = 0
BEGIN
    DECLARE table_cursor CURSOR LOCAL FOR SELECT TableName FROM #Tables
    OPEN table_cursor
    FETCH NEXT FROM table_cursor INTO @TableName

    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @SQL = '
            DECLARE @Exists VARCHAR(10) = ''Not Exist''
            IF EXISTS (SELECT 1 FROM [' + @DBName + '].sys.tables WHERE name = ''' + @TableName + ''')
                SET @Exists = ''Exist''

            UPDATE #ExistenceMatrix
            SET [' + @DBName + '] = @Exists
            WHERE TableName = ''' + @TableName + '''
        '
        EXEC (@SQL)
        FETCH NEXT FROM table_cursor INTO @TableName
    END

    CLOSE table_cursor
    DEALLOCATE table_cursor

    FETCH NEXT FROM db_cursor INTO @DBName
END

CLOSE db_cursor
DEALLOCATE db_cursor

-- Show final matrix
SELECT * FROM #ExistenceMatrix
ORDER BY TableName
