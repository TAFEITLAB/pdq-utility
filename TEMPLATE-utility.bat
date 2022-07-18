@echo off

:: =============================================
:: NAME
:: =============================================
:: Purpose: 
:: Requirements:
:: Author: 
:: Organisation: 

:: ================
:: VERSION HISTORY
:: ================ 
:: -- YYYY-MM-DD --
:: 
:: ----------------

:: ===============================
:: PREPARE ENVIRONMENT FOR SCRIPT
:: ===============================

:: Set location of batch file as current working directory
:: NB: Breakdown of %~dp0:
::     % = start variable
::     ~ = remove surrounding quotes
::     0 = filepath of script
::     d = Expand 0 to drive letter only
::     p = expand 0 to path only
::     Therefore %~dp0 = 
::        Get current filepath of script (drive letter and path only)
::        No quote marks.
pushd "%~dp0"

:: Clear screen.
cls

:: Get date info in ISO 8601 standard date format (yyyy-mm-dd)
:: NB: The SET function below works as follows:
::     VARIABLENAME:~STARTPOSITION,NUMBEROFCHARACTERS
::     Therefore in the string "20190327082654.880000+660"
::     ~0,4 translates to 2019
:: NB: Carat (Escape character "^") needed to ensure pipe is processed as part of WMIC command instead of as part of the "for" loop
for /f %%a in ('WMIC OS GET LocalDateTime ^| find "."') do set DTS=%%a
set LOGDATE=%DTS:~0,4%-%DTS:~4,2%-%DTS:~6,2%
set LOGTIME=%DTS:~8,2%:%DTS:~10,2%:%DTS:~12,2%

:: Logfile
:: - Set log directory
set LOGPATH=%SYSTEMDRIVE%\Logs
:: NB: %0 = Full file path of script
::     %~n0% = Script file name, no file extension
::     %~n0~x0 = Script file name, with file extension
:: - Set log file name
::   - Include log path to ensure it is saved in the correct location.
set LOGFILE=

:: Create log directory if does not exist
IF NOT EXIST %LOGPATH% MKDIR %LOGPATH%

:: Log location and name. Do not use trailing slashes (\)
set LOGPATH=%SystemDrive%\Logs
set LOGFILE=

:: ======
:: TASKS
:: ======


:: ============================
:: CLEAR ENVIRONMENT and EXIT
:: ============================

:: Reset current working directory
popd

:: Exit and return exit code to PDQ Deploy
exit /B %EXIT_CODE%