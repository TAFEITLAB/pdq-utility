@echo off

REM | =======================
REM | CHECK WINDOWS VERSION
REM | =======================
REM | Purpose: Check Windows verison, output to PDQ Deploy log
REM | Requirements:
REM | - None
REM | Author: Tim Dunn
REM | Organisation: TAFEITLAB

REM | ================
REM | VERSION HISTORY
REM | ================ 
REM | -- 2019-03-11 --
REM | Created script to replace similar utility
REM | -- 2019-03-25 --
REM | Rewrote script to use WMIC to:
REM |  - Find version number
REM |  - Compare to desired version number specified as PDQ Deploy package argument
REM |  - Create logfile with headings
REM |  - Output name to logfile only if not matching desired version number
REM | ----------------
REM | -- 2019-03-27--
REM |  - Reinstated REM comments
REM |  - Added additional comments to explain code
REM |  - Rewrote "Get date info" to be more efficient 
REM | ----------------

REM | ===============================
REM | PREPARE ENVIRONMENT FOR SCRIPT
REM | ===============================

REM | Set location of batch file as current working directory
REM | NB: Breakdown of %~dp0:
REM |     % = start variable
REM |     ~ = remove surrounding quotes
REM |     0 = filepath of script
REM |     d = Expand 0 to drive letter only
REM |     p = expand 0 to path only
REM |     Therefore %~dp0 = 
REM |        Get current filepath of script (drive letter and path only)
REM |        No quote marks.
pushd "%~dp0"

REM | Clear screen.
cls

REM | Get date info in ISO 8601 standard date format (yyyy-mm-dd)
REM | NB: The SET function below works as follows:
REM |     VARIABLENAME:~STARTPOSITION,NUMBEROFCHARACTERS
REM |     Therefore in the string "20190327082654.880000+660"
REM |     ~0,4 translates to 2019
REM | NB: Carat (Escape character "^") needed to ensure pipe is processed as part of WMIC command instead of as part of the "for" loop
for /f %%a in ('WMIC OS GET LocalDateTime ^| find "."') do set DTS=%%a
set LOGDATE=%DTS:~0,4%-%DTS:~4,2%-%DTS:~6,2%
set LOGTIME=%DTS:~8,2%:%DTS:~10,2%:%DTS:~12,2%

REM | Logfile
REM | - Set log directory
set LOGPATH=%SYSTEMDRIVE%\Logs
REM | NB: %0 = Full file path of script
REM |     %~n0% = Script file name, no file extension
REM |     %~n0~x0 = Script file name, with file extension
REM | - Set log file name
REM |   - Include log path to ensure it is saved in the correct location.
set LOGFILE=%LOGPATH%\%~n0_%LOGDATE%.csv

REM | Create log directory if does not exist
IF NOT EXIST %LOGPATH% MKDIR %LOGPATH%

REM | Create logfile if does not exist, insert headings
REM | IF NOT EXIST %LOGPATH%\%LOGFILE% (
::	DIR %LOGPATH%\%LOGFILE%
::	@echo ComputerName,Version > %LOGFILE%
::	)
IF NOT EXIST %LOGFILE% @echo ComputerName,Version > %LOGFILE%

REM | Set target Windows VERSION
SET TARGETWINVER=%1

REM | ======
REM | TASKS
REM | ======

REM | Check WMIC for operating system name and version number
REM | - Compare to desired version number
for /F "skip=1" %%E in ('
    wmic os get version
') do for /F %%F in ("%%E") do set "FF=%%F"
if %FF% equ %TARGETWINVER% (
    goto finished
) else (
    @echo %COMPUTERNAME%,%FF% >> %LOGFILE%
)
goto finished

:finished
REM | ============================
REM | CLEAR ENVIRONMENT and EXIT
REM | ============================

REM | Reset current working directory
popd

REM | Exit and return exit code to PDQ Deploy
exit /B %EXIT_CODE%