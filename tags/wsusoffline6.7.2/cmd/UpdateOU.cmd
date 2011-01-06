@echo off
rem *** Author: T. Wittrock, RZ Uni Kiel ***

verify other 2>nul
setlocal enableextensions
if errorlevel 1 goto NoExtensions

if "%DIRCMD%" NEQ "" set DIRCMD=

%~d0
cd "%~p0"

set DOWNLOAD_LOGFILE=..\log\download.log
if exist %DOWNLOAD_LOGFILE% (
  echo. >>%DOWNLOAD_LOGFILE%
  echo -------------------------------------------------------------------------------- >>%DOWNLOAD_LOGFILE%
  echo. >>%DOWNLOAD_LOGFILE%
)
echo %DATE% %TIME% - Info: Starting WSUS Offline Update self update >>%DOWNLOAD_LOGFILE%

set WGET_PATH=..\bin\wget.exe
if not exist %WGET_PATH% goto NoWGet
if not exist ..\bin\unzip.exe goto NoUnZip

:EvalParams
if "%1"=="" goto NoMoreParams
if /i "%1"=="/restartgenerator" set RESTART_GENERATOR=1
if /i "%1"=="/proxy" (
  set http_proxy=%2
  shift /1
)
shift /1
goto EvalParams

:NoMoreParams
rem *** Update WSUS Offline Update ***
title Updating WSUS Offline Update...
call CheckOUVersion.cmd
if not errorlevel 1 goto NoNewVersion 
echo Downloading most recent released version of WSUS Offline Update...
%WGET_PATH% -N -i ..\static\StaticDownloadLink-recent.txt -P ..
if errorlevel 1 goto DownloadError
echo %DATE% %TIME% - Info: Downloaded most recent released version of WSUS Offline Update >>%DOWNLOAD_LOGFILE%
if exist ..\wsusoffline\nul rd /S /Q ..\wsusoffline
for /F %%i in ('dir /B ..\wsusoffline*.zip') do (
  echo Unpacking %%i...
  ..\bin\unzip.exe -uq ..\%%i -d ..
  echo %DATE% %TIME% - Info: Unpacked %%i >>%DOWNLOAD_LOGFILE%
  del ..\%%i
  echo %DATE% %TIME% - Info: Deleted %%i >>%DOWNLOAD_LOGFILE%
)
echo Updating WSUS Offline Update...
%SystemRoot%\system32\xcopy.exe ..\wsusoffline .. /S /Q /Y
rd /S /Q ..\wsusoffline
echo %DATE% %TIME% - Info: Updated WSUS Offline Update >>%DOWNLOAD_LOGFILE%
if "%RESTART_GENERATOR%"=="1" (
  echo %DATE% %TIME% - Info: Ending WSUS Offline Update self update >>%DOWNLOAD_LOGFILE%
  cd ..
  start UpdateGenerator.exe
  start http://www.wsusoffline.net/donate.html
  exit
)
goto EoF

:NoExtensions
echo.
echo ERROR: No command extensions available.
echo.
exit

:NoWGet
echo.
echo ERROR: Download utility %WGET_PATH% not found.
echo %DATE% %TIME% - Error: Download utility %WGET_PATH% not found >>%DOWNLOAD_LOGFILE%
echo.
goto EoF

:NoUnZip
echo.
echo ERROR: Utility ..\bin\unzip.exe not found.
echo %DATE% %TIME% - Error: Utility ..\bin\unzip.exe not found >>%DOWNLOAD_LOGFILE%
echo.
goto EoF

:NoNewVersion
echo.
echo Info: No new version of WSUS Offline Update found.
echo %DATE% %TIME% - Info: No new version of WSUS Offline Update found >>%DOWNLOAD_LOGFILE%
echo.
goto EoF

:DownloadError
echo.
echo ERROR: Download of most recent released version of WSUS Offline Update failed.
echo %DATE% %TIME% - Error: Download of most recent released version of WSUS Offline Update failed >>%DOWNLOAD_LOGFILE%
echo.
goto EoF

:EoF
echo %DATE% %TIME% - Info: Ending WSUS Offline Update self update >>%DOWNLOAD_LOGFILE%
title %ComSpec%
endlocal
