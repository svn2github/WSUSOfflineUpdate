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
title Checking Trusted Root Certificates' version...
echo Checking Trusted Root Certificates' version...
%SystemRoot%\system32\reg.exe QUERY "HKLM\Software\Wow6432Node\Microsoft\Active Setup\Installed Components\{EF289A85-8E57-408d-BE47-73B55609861A}" /v Version >nul 2>&1
if errorlevel 1 (
  %SystemRoot%\system32\reg.exe QUERY "HKLM\Software\Microsoft\Active Setup\Installed Components\{EF289A85-8E57-408d-BE47-73B55609861A}" /v Version >nul 2>&1
  if errorlevel 1 (
    for /F "tokens=1-4 delims=," %%j in ("0,0,0,0") do (
      set TRCERTS_VER_MAJOR=%%j
      set TRCERTS_VER_MINOR=%%k
      set TRCERTS_VER_BUILD=%%l
      set TRCERTS_VER_REVIS=%%m
    )
  ) else (
    for /F "tokens=3" %%i in ('%SystemRoot%\system32\reg.exe QUERY "HKLM\Software\Microsoft\Active Setup\Installed Components\{EF289A85-8E57-408d-BE47-73B55609861A}" /v Version ^| %SystemRoot%\system32\find.exe /I "Version"') do (
      for /F "tokens=1-4 delims=," %%j in ("%%i") do (
        set TRCERTS_VER_MAJOR=%%j
        set TRCERTS_VER_MINOR=%%k
        set TRCERTS_VER_BUILD=%%l
        set TRCERTS_VER_REVIS=%%m
      )
    )
  )
) else (
  for /F "tokens=3" %%i in ('%SystemRoot%\system32\reg.exe QUERY "HKLM\Software\Wow6432Node\Microsoft\Active Setup\Installed Components\{EF289A85-8E57-408d-BE47-73B55609861A}" /v Version ^| %SystemRoot%\system32\find.exe /I "Version"') do (
    for /F "tokens=1-4 delims=," %%j in ("%%i") do (
      set TRCERTS_VER_MAJOR=%%j
      set TRCERTS_VER_MINOR=%%k
      set TRCERTS_VER_BUILD=%%l
      set TRCERTS_VER_REVIS=%%m
    )
  )
)
set TRCERTS_FILENAME=..\client\win\glb\rootsupd.exe
if not exist %TRCERTS_FILENAME% (
  %WGET_PATH% -P ..\client\win\glb http://www.download.windowsupdate.com/msdownload/update/v3/static/trustedr/en/rootsupd.exe
  if errorlevel 1 goto DownloadError
)
if not exist %TRCERTS_FILENAME% goto DownloadError
goto UseStaticVersion 

%TRCERTS_FILENAME% /T:"%TEMP%\rootsupd" /C /Q
for /F "tokens=2 delims== " %%i in ('%SystemRoot%\system32\findstr.exe /B /L /I "Version" "%TEMP%\rootsupd\rootsupd.inf"') do (
  call ..\client\cmd\SafeRmDir.cmd "%TEMP%\rootsupd"
  for /F "tokens=1-4 delims=," %%j in (%%i) do (
    if %TRCERTS_VER_MAJOR% LSS %%j goto InstallTRCerts
    if %TRCERTS_VER_MAJOR% GTR %%j goto SkipTRCertsInst
    if %TRCERTS_VER_MINOR% LSS %%k goto InstallTRCerts
    if %TRCERTS_VER_MINOR% GTR %%k goto SkipTRCertsInst
    if %TRCERTS_VER_BUILD% LSS %%l goto InstallTRCerts
    if %TRCERTS_VER_BUILD% GTR %%l goto SkipTRCertsInst
    if %TRCERTS_VER_REVIS% GEQ %%m goto SkipTRCertsInst
  )
)
goto InstallTRCerts

:UseStaticVersion
for /F "tokens=1-4 delims=," %%j in ("37,0,2195,0") do (
  if %TRCERTS_VER_MAJOR% LSS %%j goto InstallTRCerts
  if %TRCERTS_VER_MAJOR% GTR %%j goto SkipTRCertsInst
  if %TRCERTS_VER_MINOR% LSS %%k goto InstallTRCerts
  if %TRCERTS_VER_MINOR% GTR %%k goto SkipTRCertsInst
  if %TRCERTS_VER_BUILD% LSS %%l goto InstallTRCerts
  if %TRCERTS_VER_BUILD% GTR %%l goto SkipTRCertsInst
  if %TRCERTS_VER_REVIS% GEQ %%m goto SkipTRCertsInst
)
:InstallTRCerts
goto CompError
:SkipTRCertsInst
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
echo ERROR: Download failure for http://www.download.windowsupdate.com/msdownload/update/v3/static/trustedr/en/rootsupd.exe.
echo.
goto EoF

:CompError
echo.
echo Warning: Most recent version of rootsupd.exe is not installed.
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
