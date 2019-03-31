@echo off

REM | =============================================
REM | CHECK ACTIVATION STATUS - WINDOWS AND OFFICE
REM | BACKEND SCRIPT
REM | =============================================
REM | Purpose: 
REM | - Check for activation status of the following products:
REM | -- Microsoft Windows
REM | -- Microsoft Office 2016, including
REM | --- Microsoft Project 2016
REM | --- Microsoft Visio 2016
REM | - Output results to PDQ Deploy deployment log.
REM | Requirements:
REM | - None
REM | Author: Unknown, Tim Dunn
REM | Organisation: TAFEITLAB

REM | ================
REM | VERSION HISTORY
REM | ================ 
REM | -- 2019-03-11 --
REM | Created script to replace prior similar utility. 
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

REM | Set display colours
color 1F

REM | Set location and system paths
setLocal EnableDelayedExpansion
if exist "%Windir%\Sysnative\sppsvc.exe" set SysPath=%Windir%\Sysnative
if exist "%Windir%\System32\sppsvc.exe"  set SysPath=%Windir%\System32

REM | ======
REM | TASKS
REM | ======

REM | Echo time and date
echo %YYYY%-%MM%-%DD% at %HH%:%NN%
echo.

::Echo Windows activation status
echo Windows Status:
echo ===============
ver
cscript //nologo %SysPath%\slmgr.vbs /dli
cscript //nologo %SysPath%\slmgr.vbs /xpr

REM | Echo Office 2016 activation status
echo.
echo.
echo Office 2016 Status:
echo ===================
set office=
set installed=0
FOR /F "tokens=2*" %%a IN ('reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Office\16.0\Common\InstallRoot" /v "Path" 2^>nul') do (SET office=%%b)
if exist "%office%\OSPP.VBS" (
	set installed=1
	cd /d "%office%"
	cscript //nologo ospp.vbs /dstatus
	cd /d %~dp0
)
set office=
FOR /F "tokens=2*" %%a IN ('reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\Office\16.0\Common\InstallRoot" /v "Path" 2^>nul') do (SET office=%%b)
if exist "%office%\OSPP.VBS" (
	set installed=1
	cd /d "%office%"
	cscript //nologo ospp.vbs /dstatus
	cd /d %~dp0
)
if %installed%==1 goto end2016
if exist "C:\Program Files\Microsoft Office\Office16\OSPP.VBS" (
	set installed=1
	cd /d "C:\Program Files\Microsoft Office\Office16"
	cscript //nologo ospp.vbs /dstatus
	cd /d %~dp0
)
if exist "C:\Program Files (x86)\Microsoft Office\Office16\OSPP.VBS" (
	set installed=1
	cd /d "C:\Program Files (x86)\Microsoft Office\Office16"
	cscript //nologo ospp.vbs /dstatus
	cd /d %~dp0
)
:end2016
if %installed%==0 echo Not installed

echo.

REM | ============================
REM | CLEAR ENVIRONMENT and EXIT
REM | ============================

REM | Reset current working directory
popd

REM | Exit and return exit code to PDQ Deploy
exit /B %EXIT_CODE%
