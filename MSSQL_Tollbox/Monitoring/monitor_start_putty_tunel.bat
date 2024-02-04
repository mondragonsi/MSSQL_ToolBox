@echo off
setlocal

:: Set variables
set "SESSION_NAME=name_of_sessions_in_putty"
set "LOG_FILE_PATH=putty.log"
set "PUTTY_PATH=putty.exe"
set "PUTTY_EXE_NAME=putty.exe"
set "HOST_TO_CHECK=bruno@111.222.90.109"  :: Change this to your actual host
set "RETRY_INTERVAL=5"

:loop
echo Monitoring...
:: Check if PuTTY is running
tasklist /FI "IMAGENAME eq %PUTTY_EXE_NAME%" | find /I "%PUTTY_EXE_NAME%" > nul
if errorlevel 1 (
    echo PuTTY is not running. Attempting to start session...
    goto start_session
) else (
    :: Check network connectivity to the host (simple connectivity check, replace with actual logic if needed)
    ping -n 1 %HOST_TO_CHECK% > nul
    if errorlevel 1 (
        echo Network error or session might be down. Attempting to restart session...
        :: Attempt to close PuTTY gracefully
        taskkill /IM "%PUTTY_EXE_NAME%" /F > nul
        goto start_session
    ) else (
        echo PuTTY and network session appear to be active.
    )
)

:: Wait for specified interval before checking again
timeout /t %RETRY_INTERVAL% /nobreak > nul
echo Monitoring...
goto loop

:start_session
:: Delete the existing log file to ensure it's overwritten
if exist "%LOG_FILE_PATH%" del /F /Q "%LOG_FILE_PATH%"

:: Start the Putty session
%PUTTY_PATH% -load "%SESSION_NAME%" -pw "change_here"  :: BEST TO STORE IN A VARIABLE ETC
echo Session "%SESSION_NAME%" started or attempted to start.
goto loop

endlocal
