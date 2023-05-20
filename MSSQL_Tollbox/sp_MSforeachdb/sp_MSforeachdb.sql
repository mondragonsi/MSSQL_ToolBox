If sys.fn_hadr_is_primary_replica ( 'myDB' ) = 1
BEGIN
-- PRI  
		PRINT'Job running on PRIMARY'
    -- mylims
DECLARE @command VARCHAR(MAX)
SELECT  @command = 'IF ''?'' LIKE ''myDB%'' 
BEGIN
USE [?]

PRINT ''?''
------

END'

EXEC sp_MSforeachdb @command
PRINT @command
END