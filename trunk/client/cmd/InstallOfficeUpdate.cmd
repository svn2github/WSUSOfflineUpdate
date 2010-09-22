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

:EvalParams
if "%2"=="" goto NoMoreParams
if /i "%2"=="/selectoptions" (
  set SELECT_OPTIONS=1
  shift /2
  goto EvalParams
)
if /i "%2"=="/nobackup" (
  set BACKUP_FILES=0
  shift /2
  goto EvalParams
)
if /i "%2"=="/verify" (
  set VERIFY_FILES=1
  shift /2
  goto EvalParams
)
if /i "%2"=="/errorsaswarnings" (
  set ERRORS_AS_WARNINGS=1
  shift /2
  goto EvalParams
)
if /i "%2"=="/ignoreerrors" (
  set IGNORE_ERRORS=1
  shift /2
  goto EvalParams
)

:NoMoreParams
if "%VERIFY_FILES%" NEQ "1" goto SkipVerification
if not exist ..\bin\hashdeep.exe (
  echo Warning: Hash computing/auditing utility ..\bin\hashdeep.exe not found.
  echo %DATE% %TIME% - Warning: Hash computing/auditing utility ..\bin\hashdeep.exe not found >>%UPDATE_LOGFILE%
  goto SkipVerification
)
echo Verifying integrity of %1...
for /F "tokens=2,3 delims=\" %%i in ("%1") do (
  if exist ..\md\hashes-%%i-%%j.txt (
    %SystemRoot%\system32\findstr.exe /C:%% /C:## /C:%1 ..\md\hashes-%%i-%%j.txt >"%TEMP%\hash-%%i-%%j.txt"
    ..\bin\hashdeep.exe -a -l -k "%TEMP%\hash-%%i-%%j.txt" %1
    if errorlevel 1 (
      if exist "%TEMP%\hash-%%i-%%j.txt" del "%TEMP%\hash-%%i-%%j.txt"
      goto IntegrityError
    )
    if exist "%TEMP%\hash-%%i-%%j.txt" del "%TEMP%\hash-%%i-%%j.txt"
    goto SkipVerification
  )
  echo Warning: Hash file ..\md\hashes-%%i-%%j.txt not found.
  echo %DATE% %TIME% - Warning: Hash file ..\md\hashes-%%i-%%j.txt not found >>%UPDATE_LOGFILE%
)
:SkipVerification
rem *** Check proper Office version ***
for %%i in (ofc oxp o2k3 o2k7 o2k7-x64) do (
  echo %1 | %SystemRoot%\system32\find.exe /I "\%%i\" >nul 2>&1
  if not errorlevel 1 goto %%i
)
goto UnsupVersion

:ofc
:oxp
:o2k3
if "%SELECT_OPTIONS%"=="1" (
  for /F %%i in (..\opt\OptionList-qn.txt) do (
    echo %1 | %SystemRoot%\system32\find.exe /I "%%i" >nul 2>&1
    if not errorlevel 1 goto o2k7
  )
)
for /F "tokens=3 delims=\." %%i in ("%1") do (
  echo Installing %1...
  call SafeRmDir.cmd "%TEMP%\%%i"
  %1 /T:"%TEMP%\%%i" /C /Q
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
      goto UnsupType
    )
  )
)
set ERR_LEVEL=%errorlevel%
call SafeRmDir.cmd "%TEMP%\%%i"
if "%IGNORE_ERRORS%"=="1" goto InstSuccess
for %%i in (0 1641 3010 3011) do if %ERR_LEVEL% EQU %%i goto InstSuccess
goto InstFailure

:o2k7
:o2k7-x64
echo Installing %1...
echo %1 | %SystemRoot%\system32\find.exe /I "sp" >nul 2>&1
if errorlevel 1 (%1 /quiet /norestart) else (%1 /passive /norestart)
set ERR_LEVEL=%errorlevel%
if "%IGNORE_ERRORS%"=="1" goto InstSuccess
for %%i in (0 1641 3010 3011) do if %ERR_LEVEL% EQU %%i goto InstSuccess
goto InstFailure

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

:UnsupVersion
echo ERROR: Unsupported Office version.
echo %DATE% %TIME% - Error: Unsupported Office version >>%UPDATE_LOGFILE%
goto Error

:UnsupType
echo ERROR: Unsupported file type (file: %1).
echo %DATE% %TIME% - Error: Unsupported file type (file: %1) >>%UPDATE_LOGFILE%
goto InstFailure

:IntegrityError
echo ERROR: File hash does not match stored value (file: %1).
echo %DATE% %TIME% - Error: File hash does not match stored value (file: %1) >>%UPDATE_LOGFILE%
goto InstFailure

:InstSuccess
echo %DATE% %TIME% - Info: Installed %1 >>%UPDATE_LOGFILE%
goto EoF

:InstFailure
if "%ERRORS_AS_WARNINGS%"=="1" (goto InstWarning) else (goto InstError)

:InstWarning
echo Warning: Installation of %1 failed (errorlevel: %ERR_LEVEL%).
echo %DATE% %TIME% - Warning: Installation of %1 failed (errorlevel: %ERR_LEVEL%) >>%UPDATE_LOGFILE%
goto EoF

:InstError
echo ERROR: Installation of %1 failed (errorlevel: %ERR_LEVEL%).
echo %DATE% %TIME% - Error: Installation of %1 failed (errorlevel: %ERR_LEVEL%) >>%UPDATE_LOGFILE%
goto Error

:Error
endlocal
exit /b 1

:EoF
endlocal
exit /b 0
