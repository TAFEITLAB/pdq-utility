@echo off

REM | =======================
REM | NTP: SYNC CLIENT TO PDC
REM | =======================
REM | Purpose: Synchronise client time to primary domain controller
REM | Requirements:
REM | - None
REM | Author: Tim Dunn
REM | Organisation: TAFEITLAB

REM | ================
REM | VERSION HISTORY
REM | ================ 
REM | -- 2019-03-11 --
REM | Created script to replace similar utility
REM | ----------------
REM | -- 2019-03-27--
REM |  - Reinstated REM comments
REM |  - Added additional comments to explain code
REM |  - Rewrote "Get date info" to be more efficient 
REM | ----------------

REM | ===============================
REM | PREPARE ENVIRONMENT FOR SCRIPT
REM | ===============================

REM | Set location to SYSTEM32
cd %SystemDrive%\Windows\System32
setLocal EnableDelayedExpansion

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

REM | Adjust Windows Time configuration: Sync from Primary Domakin Controller.
w32tm /config /syncfromflags:domhier /update 

REM | Stop and restart Windows Time Service Tool
net stop w32time && net start w32time

REM | ============================
REM | CLEAR ENVIRONMENT and EXIT
REM | ============================

REM | Exit and return exit code to PDQ Deploy
exit /B %EXIT_CODE%