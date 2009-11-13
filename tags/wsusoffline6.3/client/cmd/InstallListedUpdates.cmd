@echo off
rem *** Author: T. Wittrock, RZ Uni Kiel ***

verify other 2>nul
setlocal enableextensions
if errorlevel 1 goto NoExtensions

if "%UPDATE_LOGFILE%"=="" set UPDATE_LOGFILE=%SystemRoot%\ctupdate.log

if "%TEMP%"=="" goto NoTemp
pushd "%TEMP%"
if errorlevel 1 goto NoTempDir
popd

if "%OS_NAME%"=="" goto NoOSName
if not exist "%TEMP%\UpdatesToInstall.txt" goto NoUpdates

for /F "delims=: tokens=1*" %%i in ('%SystemRoot%\system32\findstr.exe /N $ "%TEMP%\UpdatesToInstall.txt"') do set LINES_COUNT=%%i
for /F "delims=: tokens=1*" %%i in ('%SystemRoot%\system32\findstr.exe /N $ "%TEMP%\UpdatesToInstall.txt"') do (
  for %%k in (ofc oxp o2k3 o2k7 o2k7-x64) do (
    echo %%j | %SystemRoot%\system32\find.exe /I "\%%k\" >nul 2>&1
    if not errorlevel 1 (
      echo Installing update %%i of %LINES_COUNT%...
      call InstallOfficeUpdate.cmd %%j %*
      if errorlevel 1 goto InstError
    )
  )
  for %%k in (%OS_NAME%-%OS_ARCHITECTURE% %OS_NAME% win) do (
    echo %%j | %SystemRoot%\system32\find.exe /I "\%%k\" >nul 2>&1
    if not errorlevel 1 (
      echo Installing update %%i of %LINES_COUNT%...
      call InstallOSUpdate.cmd %%j %*
      if errorlevel 1 goto InstError
    )
  )
)
echo %DATE% %TIME% - Info: Installed %LINES_COUNT% updates >>%UPDATE_LOGFILE%
del "%TEMP%\UpdatesToInstall.txt"
goto EoF

:NoExtensions
echo ERROR: No command extensions available.
goto Error

:NoTemp
echo ERROR: Environment variable TEMP not set.
echo %DATE% %TIME% - Error: Environment variable TEMP not set >>%UPDATE_LOGFILE%
goto Error

:NoTempDir
echo ERROR: Directory "%TEMP%" not found.
echo %DATE% %TIME% - Error: Directory "%TEMP%" not found >>%UPDATE_LOGFILE%
goto Error

:NoOSName
echo ERROR: Environment variable OS_NAME not set.
echo %DATE% %TIME% - Error: Environment variable OS_NAME not set >>%UPDATE_LOGFILE%
goto Error

:NoUpdates
echo ERROR: File "%TEMP%\UpdatesToInstall.txt" not found.
echo %DATE% %TIME% - Error: File "%TEMP%\UpdatesToInstall.txt" not found >>%UPDATE_LOGFILE%
goto Error

:InstError
if exist "%TEMP%\UpdatesToInstall.txt" del "%TEMP%\UpdatesToInstall.txt"
goto Error

:Error
exit /b 1

:EoF
