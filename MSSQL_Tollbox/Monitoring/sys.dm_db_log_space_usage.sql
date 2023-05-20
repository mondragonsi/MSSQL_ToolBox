use [myDB]
GO

select 
@@SERVERNAME,
DB_NAME(),
total_log_size_in_bytes / 1024 / 1024 as total_log_size_MB,
used_log_space_in_bytes / 1024 /1024  as used_log_space_MB,
used_log_space_in_percent,
log_space_in_bytes_since_last_backup / 1024 /1024 as log_space_in_MB_since_last_backup
 FROM sys.dm_db_log_space_usage
 GO
