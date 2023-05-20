USE [master]
GO

/****** Object:  StoredProcedure [dbo].[Maint_IX_GetListOfDB_NAMES_BY_Size]    Script Date: 20/05/2023 15:27:00 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[Maint_IX_GetListOfDB_NAMES_BY_Size] 
    @SizeGB_Low_PARM INT, 
    @SizeGB_High_PARM INT, 
    @Result VARCHAR(MAX) OUTPUT
AS
BEGIN

DECLARE @SizeGB_Low    INT = @SizeGB_Low_PARM;
DECLARE @SizeGB_High   INT = @SizeGB_High_PARM; 

DROP TABLE IF EXISTS #DBListNameSize;

--CREATES A TEMPORARY TABLE
CREATE TABLE #DBListNameSize
(Id INT IDENTITY, name NVARCHAR(100), sizeInTemp decimal(10,2));

--QUERY ALL USER DATABASES AND THEIR SIZE
WITH ListDBS_CTE
AS (
   SELECT d.NAME
    ,(SUM(CAST(mf.size AS decimal(10,2))) * 8.0 / 1024) / 1024 AS Size_GBs
FROM sys.master_files mf
INNER JOIN sys.databases d ON d.database_id = mf.database_id
WHERE d.database_id > 4 -- Skip system databases
GROUP BY d.NAME)


INSERT INTO #DBListNameSize
SELECT *
FROM ListDBS_CTE
WHERE Size_GBs BETWEEN @SizeGB_Low AND @SizeGB_High;          ----DEFINE RANGE OF DBS by SIZE

DECLARE @Counter INT;
DECLARE @MaxId   INT; 
DECLARE @DBName NVARCHAR(100);
DECLARE @Size             DECIMAL(10,2) = 0.00;
DECLARE @SizeAcumulated   DECIMAL(10,2) = 0.00;

SELECT @Counter = min(Id), 
       @MaxId   = max(Id) 
FROM #DBListNameSize;

WHILE(@Counter IS NOT NULL
      AND @Counter <= @MaxId)
BEGIN
   SELECT 
   @DBName = name,
   @Size = sizeInTemp  
   FROM #DBListNameSize
   WHERE Id = @Counter;

   SET @SizeAcumulated = @SizeAcumulated + @Size;
   SET @Result = @Result + @DBName + ',';
    
   PRINT 'Concataning: ' + @DBName + '------- SIZE: ' + CAST(@Size AS NVARCHAR(50)) + ' ACUMMULATED: ' + CAST(@SizeAcumulated AS NVARCHAR(50)) ;
   SET @Counter  = @Counter  + 1;      
END

IF @Result <> ''
    SET @Result = LEFT(@Result, LEN(@Result) - 1);
ELSE
    SET @Result = 'NO DATABASES WERE RETURNED. NOTHING TO PROCESS!';

--SELECT @Result AS MyList;
--RETURN @Result;

END
GO

