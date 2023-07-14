
BEGIN

DECLARE @command VARCHAR(MAX)
SELECT  @command = 'IF ''?'' LIKE ''BPM%'' 
BEGIN
USE [?]

PRINT ''?''
------


DROP USER [AM\bruno]


CREATE USER [AM\bruno] FOR LOGIN [AM\bruno] WITH DEFAULT_SCHEMA=[dbo]


END'

EXEC sp_MSforeachdb @command
PRINT @command
END
