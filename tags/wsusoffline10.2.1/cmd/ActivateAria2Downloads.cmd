@echo off
rem *** Author: T. Wittrock, Kiel ***

verify other 2>nul
setlocal enableextensions
if errorlevel 1 goto NoExtensions

if "%DIRCMD%" NEQ "" set DIRCMD=

cd /D "%~dp0"

set DOWNLOAD_LOGFILE=..\log\download.log
if exist %DOWNLOAD_LOGFILE% (
  echo.>>%DOWNLOAD_LOGFILE%
  echo -------------------------------------------------------------------------------->>%DOWNLOAD_LOGFILE%
  echo.>>%DOWNLOAD_LOGFILE%
)
echo %DATE% %TIME% - Info: Activating Aria2 downloads>>%DOWNLOAD_LOGFILE%

set WGET_PATH=..\bin\wget.exe
if not exist %WGET_PATH% goto NoWGet
if not exist ..\bin\unzip.exe goto NoUnZip

:EvalParams
if "%1"=="" goto NoMoreParams
if /i "%1"=="/proxy" (
  set http_proxy=%2
  shift /1
)
shift /1
goto EvalParams

:NoMoreParams
rem *** Activate Aria2 downloads ***
title Activating Aria2 downloads...
if /i "%PROCESSOR_ARCHITECTURE%"=="AMD64" goto DLx64
if /i "%PROCESSOR_ARCHITEW6432%"=="AMD64" goto DLx64
goto DLx86
:DLx64
if exist ..\bin\aria2c-x64.exe goto DLx86
echo Downloading most recent version of Aria2 (x64)...
for /F %%i in ('%SystemRoot%\System32\findstr.exe /I "x64" ..\static\StaticDownloadLinks-aria2.txt') do (
  %WGET_PATH% -N -P ..\bin %%i
  if errorlevel 1 goto DownloadError
  ..\bin\streams.exe /accepteula -d ..\bin\aria2*.exe >nul 2>&1
  echo %DATE% %TIME% - Info: Downloaded most recent version of Aria2 ^(x64^)>>%DOWNLOAD_LOGFILE%
)
:DLx86
if exist ..\bin\aria2c-x86.exe goto Activate
echo Downloading most recent version of Aria2 (x86)...
for /F %%i in ('%SystemRoot%\System32\findstr.exe /I "x86" ..\static\StaticDownloadLinks-aria2.txt') do (
  %WGET_PATH% -N -P ..\bin %%i
  if errorlevel 1 goto DownloadError
  ..\bin\streams.exe /accepteula -d ..\bin\aria2*.exe >nul 2>&1
  echo %DATE% %TIME% - Info: Downloaded most recent version of Aria2 ^(x86^)>>%DOWNLOAD_LOGFILE%
)
:Activate
echo if /i "%%PROCESSOR_ARCHITECTURE%%"=="AMD64" goto x64>custom\SetAria2EnvVars.cmd
echo if /i "%%PROCESSOR_ARCHITEW6432%%"=="AMD64" goto x64>>custom\SetAria2EnvVars.cmd
echo goto x86>>custom\SetAria2EnvVars.cmd
echo.>>custom\SetAria2EnvVars.cmd
echo :x64>>custom\SetAria2EnvVars.cmd
echo if exist ..\bin\aria2c-x64.exe (set DLDR_PATH=..\bin\aria2c-x64.exe) else (goto x86)>>custom\SetAria2EnvVars.cmd 
echo goto SetParams>>custom\SetAria2EnvVars.cmd
echo.>>custom\SetAria2EnvVars.cmd
echo :x86>>custom\SetAria2EnvVars.cmd
echo set DLDR_PATH=..\bin\aria2c-x86.exe>>custom\SetAria2EnvVars.cmd 
echo.>>custom\SetAria2EnvVars.cmd
echo :SetParams>>custom\SetAria2EnvVars.cmd
echo set DLDR_COPT=--conditional-get=true --allow-overwrite=true --file-allocation=none --always-resume=false --max-resume-failure-tries=0 --max-tries=10 --retry-wait=10 --timeout=60 --remote-time=true -x10 -j10 -s10 -k1M -R>>custom\SetAria2EnvVars.cmd
echo set DLDR_LOPT=--log-level=notice -l %%DOWNLOAD_LOGFILE%%>>custom\SetAria2EnvVars.cmd
echo set DLDR_IOPT=-i>>custom\SetAria2EnvVars.cmd 
echo set DLDR_POPT=-d>>custom\SetAria2EnvVars.cmd 
echo set DLDR_NVOPT=--console-log-level=warn>>custom\SetAria2EnvVars.cmd 
goto EoF

:NoExtensions
echo.
echo ERROR: No command extensions available.
echo.
exit

:NoWGet
echo.
echo ERROR: Download utility %WGET_PATH% not found.
echo %DATE% %TIME% - Error: Download utility %WGET_PATH% not found>>%DOWNLOAD_LOGFILE%
echo.
goto EoF

:NoUnZip
echo.
echo ERROR: Utility ..\bin\unzip.exe not found.
echo %DATE% %TIME% - Error: Utility ..\bin\unzip.exe not found>>%DOWNLOAD_LOGFILE%
echo.
goto EoF

:DownloadError
echo.
echo ERROR: Download of most recent version of Aria2 failed.
echo %DATE% %TIME% - Error: Download of most recent version of Aria2 failed>>%DOWNLOAD_LOGFILE%
echo.
goto EoF

:EoF
echo %DATE% %TIME% - Info: Activated Aria2 downloads>>%DOWNLOAD_LOGFILE%
title %ComSpec%
endlocal
