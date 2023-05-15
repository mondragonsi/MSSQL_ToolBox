--write an sql script to check if any Drive is full
--if any drive is full, send an email to the DBA team
--if no drive is full, do nothing

--declare variables
declare @Drive varchar(1)
declare @DriveSpace int
declare @DriveSpaceThreshold int
declare @EmailSubject varchar(100)
declare @EmailBody varchar(1000)

--set variables
set @DriveSpaceThreshold = 10000
set @EmailSubject = 'Drive Full Alert'
set @EmailBody = 'The following drive(s) are full: '

--create a temp table to store the results
create table #DriveSpace
(
Drive varchar(1),
DriveSpace int
)

--insert the results into the temp table
insert into #DriveSpace
exec master..xp_fixeddrives

--loop through the temp table and send an email if any drive is full
declare DriveCursor cursor for
select Drive, DriveSpace from #DriveSpace
open DriveCursor
fetch next from DriveCursor into @Drive, @DriveSpace
while @@FETCH_STATUS = 0
begin
if @DriveSpace < @DriveSpaceThreshold
begin
set @EmailBody = @EmailBody + @Drive + ' '
end
fetch next from DriveCursor into @Drive, @DriveSpace
end
close DriveCursor
deallocate DriveCursor

--send an email if any drive is full
if @EmailBody <> 'The following drive(s) are full: '
begin
exec msdb..sp_send_dbmail
@profile_name = 'dba_profile', -- tem que estar criado no teu servidor :)
@recipients = 'dbaFodao@empresa.com.br',
@subject = @EmailSubject,
@body = @EmailBody
end

--drop the temp table
drop table #DriveSpace

--end of script

