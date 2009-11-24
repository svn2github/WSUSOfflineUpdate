@echo off
rem *** Author: T. Wittrock, RZ Uni Kiel ***

verify other 2>nul
setlocal enableextensions
if errorlevel 1 goto NoExtensions

if "%UPDATE_LOGFILE%"=="" set UPDATE_LOGFILE=%SystemRoot%\wsusofflineupdate.log

if "%1"=="" goto NoParam
if not exist %1 goto InvalidParam

if "%TEMP%"=="" goto NoTemp
pushd "%TEMP%"
if errorlevel 1 goto NoTempDir
popd

if "%CSCRIPT_PATH%"=="" set CSCRIPT_PATH=%SystemRoot%\system32\cscript.exe
if not exist %CSCRIPT_PATH% goto NoCScript

:EvalParam
if /i "%2"=="/errorsaswarnings" (
  set ERRORS_AS_WARNINGS=1
  shift /2
  goto EvalParam
)

rem *** Check proper Office version ***
for %%i in (ofc oxp o2k3 o2k7 o2k7-x64) do (
  echo %1 | %SystemRoot%\system32\find.exe /I "\%%i\" >nul 2>&1
  if not errorlevel 1 goto %%i
)
goto UnsupVersion

:oxp
:o2k3
for /F "tokens=3 delims=\." %%i in ("%1") do (
  echo Installing %1...
  call SafeRmDir.cmd "%TEMP%\%%i"
  %1 /T:"%TEMP%\%%i" /C /Q
  if errorlevel 1 (
    call SafeRmDir.cmd "%TEMP%\%%i"
    goto InstFailure
  )
  if exist "%TEMP%\%%i\ohotfix.exe" (
    for /F "usebackq eol=; tokens=1,2 delims==" %%j in ("%TEMP%\%%i\ohotfix.ini") do (
      if /i "%%j"=="ShowSuccessDialog" echo %%j=0 >"%TEMP%\%%i\ohotfix.1"
      if /i "%%j"=="UpgradeMsi" echo %%j=0 >"%TEMP%\%%i\ohotfix.1"
      if /i "%%j"=="OHotfixUILevel" echo %%j=q >"%TEMP%\%%i\ohotfix.1"
      if /i "%%j"=="MsiUILevel" echo %%j=n >"%TEMP%\%%i\ohotfix.1"
      if exist "%TEMP%\%%i\ohotfix.1" (
        for /F "usebackq" %%l in ("%TEMP%\%%i\ohotfix.1") do (
          echo %%l >>"%TEMP%\%%i\ohotfix.new"
        )
        del "%TEMP%\%%i\ohotfix.1"
      ) else (
        echo %%j=%%k >>"%TEMP%\%%i\ohotfix.new"
      )
    )
    del "%TEMP%\%%i\ohotfix.ini"
    ren "%TEMP%\%%i\ohotfix.new" ohotfix.ini
    "%TEMP%\%%i\ohotfix.exe"
  ) else (
    if exist "%TEMP%\%%i\setup.exe" (
      "%TEMP%\%%i\setup.exe" /QB
    ) else (
      call SafeRmDir.cmd "%TEMP%\%%i"
      goto InstFailure
    )
  )
  call SafeRmDir.cmd "%TEMP%\%%i"
  goto InstSuccess
)
goto EoF

:ofc
:o2k7
:o2k7-x64
echo Installing %1...
echo %1 | %SystemRoot%\system32\find.exe /I "sp" >nul 2>&1
if errorlevel 1 (%1 /quiet /norestart) else (%1 /passive /norestart)
goto InstSuccess

:NoExtensions
echo ERROR: No command extensions available.
goto Error

:NoParam
echo ERROR: Invalid parameter. Usage: %~n0 ^<filename^> [/errorsaswarnings]
echo %DATE% %TIME% - Error: Invalid parameter. Usage: %~n0 ^<filename^> [/errorsaswarnings] >>%UPDATE_LOGFILE%
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

:UnsupVersion
echo ERROR: Unsupported Office version.
echo %DATE% %TIME% - Error: Unsupported Office version >>%UPDATE_LOGFILE%
goto Error

:InstSuccess
echo %DATE% %TIME% - Info: Installed %1 >>%UPDATE_LOGFILE%
goto EoF

:InstFailure
if "%ERRORS_AS_WARNINGS%"=="1" (goto InstWarning) else (goto InstError)

:InstWarning
echo Warning: Installation of %1 failed (errorlevel: %errorlevel%).
echo %DATE% %TIME% - Warning: Installation of %1 failed (errorlevel: %errorlevel%) >>%UPDATE_LOGFILE%
goto EoF

:InstError
echo ERROR: Installation of %1 failed (errorlevel: %errorlevel%).
echo %DATE% %TIME% - Error: Installation of %1 failed (errorlevel: %errorlevel%) >>%UPDATE_LOGFILE%
goto Error

:Error
endlocal
exit /b 1

:EoF
endlocal
exit /b 0
