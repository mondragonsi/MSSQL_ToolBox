
SET NOCOUNT ON;

DECLARE @retention INT = 1,
        @destination_table VARCHAR(500) = 'WhoIsActive',
        @destination_database sysname = 'DBA',
        @schema VARCHAR(MAX),
        @SQL NVARCHAR(4000),
        @parameters NVARCHAR(500),
        @exists BIT;

SET @destination_table = @destination_database + '.dbo.' + @destination_table;

--delete from rebuildDBS
delete from WhoIsActive


--collect activity into logging table
EXEC master.dbo.sp_WhoIsActive @get_transaction_info = 1,
                        @get_outer_command = 1,
                        @get_plans = 1,
                        @destination_table = @destination_table;

INSERT INTO rebuildDBS 
SELECT DISTINCT database_name
FROM [DBA].dbo.WhoIsActive w
WHERE CAST(w.sql_text AS NVARCHAR(MAX)) LIKE '%REBUILD%';


select * from rebuildDBS


