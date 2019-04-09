@echo off

REM | =============================================
REM | Disable Google Chrome updates
REM | =============================================
REM | Purpose: Disable all iterations of Google Update services
REM | Requirements: Same directory
REM |   - Same directory as Tweak_Disable_Chrome_Auto-Update.reg
REM |   - "Include Entire Directory" option ticked in PDQ Deploy.
REM | Author: Tim Dunn
REM | Organisation: TAFEITLAB

REM | ================
REM | VERSION HISTORY
REM | ================ 
REM | -- 2019-04-08 --
REM | Created script.
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

REM | ======
REM | TASKS
REM | ======

REM | Import registry key to disable auto-update
regedit /s disable_chrome_updates.reg

REM | Delete auto-update tasks
del /f /q %WINDIR%\Tasks\GoogleUpdate*
del /f /q %WINDIR%\System32\Tasks\GoogleUpdate*
del /f /q %WINDIR%\System32\Tasks_Migrated\GoogleUpdate*
schtasks /delete /F /TN "\GoogleUpdateTaskMachineCore"
schtasks /delete /F /TN "\GoogleUpdateTaskMachineUA"

REM | Stop Google Update services
net stop gupdatem 2>NUL
net stop gupdate 2>NUL

REM | Delete Google Update services
sc delete gupdatem 2>NUL
sc delete gupdate 2>NUL

REM | Remove Google Update directory
if exist "%PROGRAMFILES(x86)%\Google\Update" rmdir /s /q "%PROGRAMFILES(x86)%\Google\Update"
if exist "%PROGRAMFILES%\Google\Update" rmdir /s /q "%PROGRAMFILES%\Google\Update"

REM | ============================
REM | CLEAR ENVIRONMENT and EXIT
REM | ============================

REM | Reset current working directory
popd

REM | Exit and return exit code to PDQ Deploy
exit /B %EXIT_CODE%