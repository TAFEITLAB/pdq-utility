@echo off

REM | =============================================
REM | Create Shorcut for All Users
REM | =============================================
REM | Purpose: Create shortcut on the Public Desktop for all users
REM | Requirements:
REM |   - Script must be in same folder as nircmd.exe
REM |   - "Include Entire Directory" option is ticked in PDQ Deploy package. 
REM |   - Two arguments included in PDQ Deploy package, enclosed in quote marks, separated by a space
REM |   -- Argument one: Target file, folder, or share
REM |   -- Argument two: Desired shortcut name
REM |   --- e.g. "%SYSTEMDRIVE%\Logs" "Log Folder"
REM | Author: Tim Dunn
REM | Organisation: TAFEITLAB

REM | ================
REM | VERSION HISTORY
REM | ================ 
REM | -- 2019-03-25 --
REM | Created first verison.
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
set LOGFILE=

REM | Create log directory if does not exist
IF NOT EXIST %LOGPATH% MKDIR %LOGPATH%

REM | Log location and name. Do not use trailing slashes (\)
set LOGPATH=%SystemDrive%\Logs
set LOGFILE=

REM | Set shortcut creation location
SET TARGETFOLDER=%PUBLIC%\Desktop 

REM | ======
REM | TASKS
REM | ======

REM | Create URl shortcut using NirCMD
REM | - Check if links exist
IF EXIST "%TARGETFOLDER%\%2.lnk" (
	echo.A shortcut with that name already exists.
	goto finished
	)
IF EXIST "%TARGETFOLDER%\Desktop"\%2.url" (
	echo.A URL shortcut with that name already exists.
	goto finished
	)
REM | Use nircmd to create shortcut
nircmd.exe shortcut %1 "%TARGETFOLDER%" %2

:finished
REM | ============================
REM | CLEAR ENVIRONMENT and EXIT
REM | ============================

REM | Reset current working directory
popd

REM | Exit and return exit code to PDQ Deploy
exit /B %EXIT_CODE%