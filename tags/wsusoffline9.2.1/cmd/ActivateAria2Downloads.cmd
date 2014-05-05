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
if exist ..\bin\aria2c-x64.exe goto DLx86
if /i "%PROCESSOR_ARCHITECTURE%"=="AMD64" goto DLx64
if /i "%PROCESSOR_ARCHITEW6432%"=="AMD64" goto DLx64
goto DLx86
:DLx64
echo Downloading most recent version of Aria2 (x64)...
for /F %%i in ('%SystemRoot%\System32\findstr.exe /I "64bit" ..\static\StaticDownloadLinks-aria2.txt') do (
  %WGET_PATH% -N -P ..\bin %%i
  if errorlevel 1 goto DownloadError
  echo %DATE% %TIME% - Info: Downloaded most recent version of Aria2 ^(x64^)>>%DOWNLOAD_LOGFILE%
  echo Unpacking aria2c.exe from ..\bin\%%~nxi to ..\bin\aria2c-x64.exe...
  ..\bin\unzip.exe -p ..\bin\%%~nxi */aria2c.exe >..\bin\aria2c-x64.exe
  echo %DATE% %TIME% - Info: Unpacked aria2c.exe ..\bin\%%~nxi to ..\bin\aria2c-x64.exe>>%DOWNLOAD_LOGFILE%
  del ..\bin\%%~nxi
  echo %DATE% %TIME% - Info: Deleted %%~nxi>>%DOWNLOAD_LOGFILE%
)
:DLx86
if exist ..\bin\aria2c-x86.exe goto Activate
echo Downloading most recent version of Aria2 (x86)...
for /F %%i in ('%SystemRoot%\System32\findstr.exe /I "32bit" ..\static\StaticDownloadLinks-aria2.txt') do (
  %WGET_PATH% -N -P ..\bin %%i
  if errorlevel 1 goto DownloadError
  echo %DATE% %TIME% - Info: Downloaded most recent version of Aria2 ^(x86^)>>%DOWNLOAD_LOGFILE%
  echo Unpacking aria2c.exe from ..\bin\%%~nxi to ..\bin\aria2c-x86.exe...
  ..\bin\unzip.exe -p ..\bin\%%~nxi */aria2c.exe >..\bin\aria2c-x86.exe
  echo %DATE% %TIME% - Info: Unpacked aria2c.exe ..\bin\%%~nxi to ..\bin\aria2c-x86.exe>>%DOWNLOAD_LOGFILE%
  del ..\bin\%%~nxi
  echo %DATE% %TIME% - Info: Deleted %%~nxi>>%DOWNLOAD_LOGFILE%
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
echo set DLDR_COPT=--conditional-get=true --allow-overwrite=true --file-allocation=none -x10 -j10 -s10 -k1M -R>>custom\SetAria2EnvVars.cmd
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
