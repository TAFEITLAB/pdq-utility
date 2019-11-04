@echo off

REM | ===================
REM | Disable updates for MOZILLA FIREFOX
REM | ===================
REM | Purpose: Disable automatic updates for Mozilla Firefox
REM | Requirements: 
REM |   - N/A
REM | Author: Tim Dunn
REM | Organisation: TAFEITLAB

REM | ================
REM | VERSION HISTORY
REM | ================ 
REM | -- 2019-10-21 --
REM | Created script.
REM | ----------------

REM | ================================
REM | PREPARE ENVIRONMENT FOR INSTALL
REM | ================================

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

REM | ========
REM | DISABLE UPDATES
REM | ========

REM |Remove Mozilla Maintenance Service
IF EXIST "%PROGRAMFILES(X86)%\Mozilla Maintenance Service\uninstall.exe" (
START "%PROGRAMFILES(X86)%\Mozilla Maintenance Service\uninstall.exe" /S
)
IF EXIST "%PROGRAMFILES%\Mozilla Maintenance Service\uninstall.exe" (
START "%PROGRAMFILES%\Mozilla Maintenance Service\uninstall.exe" /S
)
IF EXIST "%PROGRAMFILES(X86)%\Mozilla Firefox\maintenanceservice.exe" (
DEL /F "%PROGRAMFILES(X86)%\Mozilla Firefox\maintenanceservice.exe"
)
IF EXIST "%PROGRAMFILES%\Mozilla Firefox\maintenanceservice.exe" (
DEL /F "%PROGRAMFILES%\Mozilla Firefox\maintenanceservice.exe"
)
REM | Remove Mozilla Minatenance Service Installer
IF EXIST "%PROGRAMFILES(X86)%\Mozilla Firefox\maintenanceservice_installer.exe" (
DEL /F "%PROGRAMFILES(X86)%\Mozilla Firefox\maintenanceservice_installer.exe"
)
IF EXIST "%PROGRAMFILES%\Mozilla Firefox\maintenanceservice_installer.exe" (
DEL /F "%PROGRAMFILES%\Mozilla Firefox\maintenanceservice_installer.exe"
)
REM | Remove Updater.exe
IF EXIST "%PROGRAMFILES(X86)%\Mozilla Firefox\updater.exe" (
DEL /F "%PROGRAMFILES(X86)%\Mozilla Firefox\updater.exe"
)
IF EXIST "%PROGRAMFILES%\Mozilla Firefox\updater.exe" (
DEL /F "%PROGRAMFILES%\Mozilla Firefox\updater.exe"
)

REM | ============================
REM | CLEAR ENVIRONMENT and EXIT
REM | ============================

REM | Reset current working directory.
popd

REM | Return exit code to PDQ Deploy.
exit /B %EXIT_CODE%