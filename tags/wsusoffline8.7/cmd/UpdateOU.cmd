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
echo %DATE% %TIME% - Info: Starting WSUS Offline Update self update>>%DOWNLOAD_LOGFILE%

set WGET_PATH=..\bin\wget.exe
if not exist %WGET_PATH% goto NoWGet
if not exist ..\bin\unzip.exe goto NoUnZip
if /i "%PROCESSOR_ARCHITECTURE%"=="AMD64" (set HASHDEEP_EXE=hashdeep64.exe) else (
  if /i "%PROCESSOR_ARCHITEW6432%"=="AMD64" (set HASHDEEP_EXE=hashdeep64.exe) else (set HASHDEEP_EXE=hashdeep.exe)
)
if not exist ..\client\bin\%HASHDEEP_EXE% goto NoHashDeep

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
for /F %%i in (..\static\StaticDownloadLink-recent.txt) do (
  %WGET_PATH% -N -P .. %%i
  if errorlevel 1 goto DownloadError
  echo %DATE% %TIME% - Info: Downloaded most recent released version of WSUS Offline Update>>%DOWNLOAD_LOGFILE%
  for /F "tokens=1-3 delims=/" %%j in ("%%i") do (
    %WGET_PATH% -N -P .. %%j//%%k/%%~nl_hashes.txt
    if errorlevel 1 goto DownloadError
    echo %DATE% %TIME% - Info: Downloaded hash file of most recent WSUS Offline Update version>>%DOWNLOAD_LOGFILE%
  )
  pushd ..
  echo Verifying integrity of %%~nxi...
  .\client\bin\%HASHDEEP_EXE% -a -l -vv -k %%~ni_hashes.txt %%~nxi
  if errorlevel 1 (
    popd
    goto IntegrityError
  )
  popd
  echo %DATE% %TIME% - Info: Verified integrity of %%~nxi>>%DOWNLOAD_LOGFILE%
  echo Unpacking %%~nxi...
  if exist ..\wsusoffline\nul rd /S /Q ..\wsusoffline
  ..\bin\unzip.exe -uq ..\%%~nxi -d ..
  echo %DATE% %TIME% - Info: Unpacked %%~nxi>>%DOWNLOAD_LOGFILE%
  del ..\%%~nxi
  echo %DATE% %TIME% - Info: Deleted %%~nxi>>%DOWNLOAD_LOGFILE%
  del ..\%%~ni_hashes.txt
  echo %DATE% %TIME% - Info: Deleted %%~ni_hashes.txt>>%DOWNLOAD_LOGFILE%
)
echo Updating WSUS Offline Update...
%SystemRoot%\System32\xcopy.exe ..\wsusoffline .. /S /Q /Y
rd /S /Q ..\wsusoffline
echo %DATE% %TIME% - Info: Updated WSUS Offline Update>>%DOWNLOAD_LOGFILE%
if "%RESTART_GENERATOR%"=="1" (
  echo %DATE% %TIME% - Info: Ending WSUS Offline Update self update>>%DOWNLOAD_LOGFILE%
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
echo %DATE% %TIME% - Error: Download utility %WGET_PATH% not found>>%DOWNLOAD_LOGFILE%
echo.
goto EoF

:NoUnZip
echo.
echo ERROR: Utility ..\bin\unzip.exe not found.
echo %DATE% %TIME% - Error: Utility ..\bin\unzip.exe not found>>%DOWNLOAD_LOGFILE%
echo.
goto EoF

:NoHashDeep
echo.
echo ERROR: Hash computing/auditing utility ..\client\bin\%HASHDEEP_EXE% not found.
echo %DATE% %TIME% - Error: Hash computing/auditing utility ..\client\bin\%HASHDEEP_EXE% not found>>%DOWNLOAD_LOGFILE%
echo.
goto EoF

:NoNewVersion
echo.
echo Info: No new version of WSUS Offline Update found.
echo %DATE% %TIME% - Info: No new version of WSUS Offline Update found>>%DOWNLOAD_LOGFILE%
echo.
goto EoF

:DownloadError
echo.
echo ERROR: Download of most recent released version of WSUS Offline Update failed.
echo %DATE% %TIME% - Error: Download of most recent released version of WSUS Offline Update failed>>%DOWNLOAD_LOGFILE%
echo.
goto EoF

:IntegrityError
echo.
echo ERROR: File integrity verification of most recent released version of WSUS Offline Update failed.
echo %DATE% %TIME% - Error: File integrity verification of most recent released version of WSUS Offline Update failed>>%DOWNLOAD_LOGFILE%
echo.
goto EoF

:EoF
echo %DATE% %TIME% - Info: Ending WSUS Offline Update self update>>%DOWNLOAD_LOGFILE%
title %ComSpec%
endlocal
