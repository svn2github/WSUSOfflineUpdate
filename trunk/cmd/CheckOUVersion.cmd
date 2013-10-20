@echo off
rem *** Author: T. Wittrock, Kiel ***

verify other 2>nul
setlocal enableextensions
if errorlevel 1 goto NoExtensions

cd /D "%~dp0"

set WGET_PATH=..\bin\wget.exe
if not exist %WGET_PATH% goto NoWGet

:EvalParams
if "%1"=="" goto NoMoreParams
if /i "%1"=="/exitonerror" set EXIT_ERR=1
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
if exist UpdateOU.new (
  if exist UpdateOU.cmd del UpdateOU.cmd
  ren UpdateOU.new UpdateOU.cmd
)
%WGET_PATH% -N -P ..\static http://download.wsusoffline.net/StaticDownloadLink-recent.txt
if errorlevel 1 goto DownloadError
if exist ..\static\StaticDownloadLink-recent.txt (
  echo n | %SystemRoot%\System32\comp.exe ..\static\StaticDownloadLink-this.txt ..\static\StaticDownloadLink-recent.txt /A /L /N=1 /C >nul 2>&1
  if errorlevel 1 goto CompError
)
goto EoF

:NoExtensions
echo.
echo ERROR: No command extensions available.
echo.
exit

:NoWGet
echo.
echo ERROR: Utility %WGET_PATH% not found.
echo.
goto EoF

:DownloadError
echo.
echo ERROR: Download failure for http://download.wsusoffline.net/StaticDownloadLink-recent.txt.
echo.
goto EoF

:CompError
echo.
echo Warning: File ..\static\StaticDownloadLink-this.txt differs from file ..\static\StaticDownloadLink-recent.txt.
echo.
goto Error

:Error
if "%EXIT_ERR%"=="1" (
  endlocal
  verify other 2>nul
  exit
) else (
  title %ComSpec%
  endlocal
  verify other 2>nul
  goto :eof
)

:EoF
title %ComSpec%
endlocal
