@echo off
rem *** Author: T. Wittrock, RZ Uni Kiel ***

verify other 2>nul
setlocal enableextensions
if errorlevel 1 goto NoExtensions

if "%DIRCMD%" NEQ "" set DIRCMD=
if "%UPDATE_LOGFILE%"=="" set UPDATE_LOGFILE=%SystemRoot%\ctupdate.log

if "%1"=="" goto NoParam
if not exist %1 goto InvalidParam

if "%TEMP%"=="" goto NoTemp
pushd "%TEMP%"
if errorlevel 1 goto NoTempDir
popd

if "%CSCRIPT_PATH%"=="" set CSCRIPT_PATH=%SystemRoot%\system32\cscript.exe
if not exist %CSCRIPT_PATH% goto NoCScript

:EvalParam
if /i "%2"=="/selectoptions" (
  set SELECT_OPTIONS=1
  shift /2
  goto EvalParam
)
if /i "%2"=="/nobackup" (
  set BACKUP_FILES=0
  shift /2
  goto EvalParam
)
if /i "%2"=="/errorsaswarnings" (
  set ERRORS_AS_WARNINGS=1
  shift /2
  goto EvalParam
)

echo %1 | %SystemRoot%\system32\find.exe /I ".exe" >nul 2>&1
if not errorlevel 1 goto InstExe
if /i "%OS_NAME%" NEQ "w60" goto UnsupType
echo %1 | %SystemRoot%\system32\find.exe /I ".cab" >nul 2>&1
if not errorlevel 1 goto InstCabMsu
echo %1 | %SystemRoot%\system32\find.exe /I ".msu" >nul 2>&1
if not errorlevel 1 (
  set MSU=1
  goto InstCabMsu
)
goto UnsupType

:InstExe
if "%SELECT_OPTIONS%"=="" set INSTALL_SWITCHES=%2 %3 %4 %5 %6 %7 %8 %9
if "%INSTALL_SWITCHES%"=="" (
  for /F %%i in (..\opt\OptionList-Q.txt) do (
    echo %1 | %SystemRoot%\system32\find.exe /I "%%i" >nul 2>&1
    if not errorlevel 1 set INSTALL_SWITCHES=/Q
  )
)
if "%INSTALL_SWITCHES%"=="" (
  for /F %%i in (..\opt\OptionList-qn.txt) do (
    echo %1 | %SystemRoot%\system32\find.exe /I "%%i" >nul 2>&1
    if not errorlevel 1 set INSTALL_SWITCHES=/quiet /norestart
  )
)
if "%INSTALL_SWITCHES%"=="" (
  echo %1 | %SystemRoot%\system32\find.exe /I "823718" >nul 2>&1
  if errorlevel 1 (
    if "%BACKUP_FILES%"=="0" (set INSTALL_SWITCHES=/q /n /z) else (set INSTALL_SWITCHES=/q /z)
  ) else (
    set INSTALL_SWITCHES=/C:"dahotfix.exe /q /n" /Q
  )
)
echo Installing %1...
%1 %INSTALL_SWITCHES%
for %%i in (0 1641 3010 3011) do if %errorlevel% EQU %%i goto InstSuccess
goto InstFailure

:InstCabMsu
echo Installing %1...
if "%OS_ARCHITECTURE%"=="x64" (set TOKEN_KB=3) else (set TOKEN_KB=2)
for /F "tokens=%TOKEN_KB% delims=-" %%i in ("%1") do (
  call SafeRmDir.cmd "%TEMP%\%%i"
  md "%TEMP%\%%i"
  if "%MSU%"=="1" (
    %SystemRoot%\system32\expand.exe %1 -F:* "%TEMP%\%%i" >nul
    for /F %%j in ('dir /A:-D /B "%TEMP%\%%i\*%%i*.cab"') do (
      move /Y "%TEMP%\%%i\%%j" "%TEMP%" >nul
      del /Q "%TEMP%\%%i\*.*"
      %SystemRoot%\system32\expand.exe "%TEMP%\%%j" -F:* "%TEMP%\%%i" >nul
      del "%TEMP%\%%j"
    )
  ) else (
    %SystemRoot%\system32\expand.exe %1 -F:* "%TEMP%\%%i" >nul
  )
  %SystemRoot%\system32\pkgmgr.exe /ip /m:"%TEMP%\%%i" /quiet /norestart
  for %%j in (0 1641 3010 3011) do (
    if %errorlevel% EQU %%j (
      call SafeRmDir.cmd "%TEMP%\%%i"
      goto InstSuccess
    )
  )
  call SafeRmDir.cmd "%TEMP%\%%i"
  goto InstFailure
)

:NoExtensions
echo ERROR: No command extensions available.
goto Error

:NoParam
echo ERROR: Invalid parameter. Usage: %~n0 ^<filename^> [/selectoptions [/nobackup]] [/errorsaswarnings] [switches]
echo %DATE% %TIME% - Error: Invalid parameter. Usage: %~n0 ^<filename^> [/selectoptions [/nobackup]] [/errorsaswarnings] [switches] >>%UPDATE_LOGFILE%
goto Error

:InvalidParam
echo ERROR: File %1 not found.
echo %DATE% %TIME% - Error: File %1 not found >>%UPDATE_LOGFILE%
goto Error

:NoTemp
echo ERROR: Environment variable TEMP not set.
echo %DATE% %TIME% - Error: Environment variable TEMP not set >>%UPDATE_LOGFILE%
goto Error

:NoTempDir
echo ERROR: Directory "%TEMP%" not found.
echo %DATE% %TIME% - Error: Directory "%TEMP%" not found >>%UPDATE_LOGFILE%
goto Error

:NoCScript
echo ERROR: VBScript interpreter %CSCRIPT_PATH% not found.
echo %DATE% %TIME% - Error: VBScript interpreter %CSCRIPT_PATH% not found >>%UPDATE_LOGFILE%
goto Error

:UnsupType
echo ERROR: Unsupported file type (file: %1).
echo %DATE% %TIME% - Error: Unsupported file type (file: %1) >>%UPDATE_LOGFILE%
goto Error

:InstSuccess
echo %DATE% %TIME% - Info: Installed %1 >>%UPDATE_LOGFILE%
goto EoF

:InstFailure
if "%ERRORS_AS_WARNINGS%"=="1" (goto InstWarning) else (goto InstError)

:InstWarning
echo Warning: Installation of %1 failed (errorlevel: %errorlevel%).
echo %DATE% %TIME% - Warning: Installation of %1 %INSTALL_SWITCHES% failed (errorlevel: %errorlevel%) >>%UPDATE_LOGFILE%
goto EoF

:InstError
echo ERROR: Installation of %1 failed (errorlevel: %errorlevel%).
echo %DATE% %TIME% - Error: Installation of %1 %INSTALL_SWITCHES% failed (errorlevel: %errorlevel%) >>%UPDATE_LOGFILE%
goto Error

:Error
endlocal
exit /b 1

:EoF
endlocal
exit /b 0
