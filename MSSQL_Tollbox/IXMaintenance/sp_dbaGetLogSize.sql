USE [master]
GO

/****** Object:  StoredProcedure [dbo].[sp_dbaGetLogSize]    Script Date: 20/05/2023 15:33:29 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


create procedure [dbo].[sp_dbaGetLogSize] @outSize INT OUTPUT  
AS

declare @sizeLog INT = 0

SELECT @sizeLog = MIN (CONVERT(INT,available_bytes/1073741824.0))

FROM sys.master_files 
CROSS APPLY sys.dm_os_volume_stats(database_id, file_id)
where logical_volume_name = 'log'

SET @outSize = @sizeLog

GO

