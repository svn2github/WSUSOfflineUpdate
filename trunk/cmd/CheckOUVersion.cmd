@echo off
rem *** Author: T. Wittrock, RZ Uni Kiel ***

verify other 2>nul
setlocal enableextensions
if errorlevel 1 goto NoExtensions

%~d0
cd "%~p0"

set WGET_PATH=..\bin\wget.exe
if not exist %WGET_PATH% goto NoWGet

:EvalParams
if "%1"=="" goto NoMoreParams
if /i "%1"=="/proxy" (
  set http_proxy=%2
  shift /1
)
shift /1
goto EvalParams

:NoMoreParams
rem *** Check WSUS Offline Update version ***
title Checking WSUS Offline Update version...
echo Checking WSUS Offline Update version...
%WGET_PATH% -N -P ..\static http://download.wsusoffline.net/StaticDownloadLink-recent.txt
if errorlevel 1 goto DownloadError
echo n | comp ..\static\StaticDownloadLink-this.txt ..\static\StaticDownloadLink-recent.txt /a /l /n=1 /c >nul 2>&1
if errorlevel 1 goto CompError
goto EoF

:NoExtensions
echo.
echo ERROR: No command extensions available.
echo.
exit /b 1

:NoWGet
echo.
echo ERROR: Utility %WGET_PATH% not found.
echo.
goto Error

:DownloadError
echo.
echo ERROR: Download failure for http://download.wsusoffline.net/StaticDownloadLink-recent.txt.
echo.
goto Error

:CompError
echo.
echo Warning: File ..\static\StaticDownloadLink-this.txt differs from file ..\static\StaticDownloadLink-recent.txt.
echo.
goto Error

:Error
title %ComSpec%
endlocal
verify other 2>nul
exit

:EoF
title %ComSpec%
endlocal
