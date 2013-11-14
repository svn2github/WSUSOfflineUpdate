@echo off
rem *** Author: T. Wittrock, Kiel ***

verify other 2>nul
setlocal enableextensions
if errorlevel 1 goto NoExtensions

if "%UPDATE_LOGFILE%"=="" set UPDATE_LOGFILE=%SystemRoot%\wsusofflineupdate.log

if "%TEMP%"=="" goto NoTemp
pushd "%TEMP%"
if errorlevel 1 goto NoTempDir
popd
if "%OS_NAME%"=="" goto NoOSName
if "%OS_LANG%"=="" goto NoOSLang
if "%OS_ARCH%"=="" goto NoOSArch

:EvalParams
if "%1"=="" goto NoMoreParams
if /i "%1"=="/excludestatics" set EXC_STATICS=1
if /i "%1"=="/ignoreblacklist" set IGNORE_BL=1
shift /1
goto EvalParams

:EvalStatics
if exist %1 (
  if exist "%TEMP%\InstalledUpdateIds.txt" (
    %SystemRoot%\System32\findstr.exe /L /I /V /G:"%TEMP%\InstalledUpdateIds.txt" %1 >>"%TEMP%\MissingUpdateIds.txt"
  ) else (
    type %1 >>"%TEMP%\MissingUpdateIds.txt"
  )
)
goto :eof

:NoMoreParams
rem *** Add statically defined update ids ***
if "%EXC_STATICS%"=="1" goto ListFiles
if exist ..\static\StaticUpdateIds-%OS_NAME%-%OS_ARCH%.txt call :EvalStatics ..\static\StaticUpdateIds-%OS_NAME%-%OS_ARCH%.txt
if exist ..\static\custom\StaticUpdateIds-%OS_NAME%-%OS_ARCH%.txt call :EvalStatics ..\static\custom\StaticUpdateIds-%OS_NAME%-%OS_ARCH%.txt
if "%O2K3_VER_MAJOR%" NEQ "" (
  if exist ..\static\StaticUpdateIds-o2k3.txt call :EvalStatics ..\static\StaticUpdateIds-o2k3.txt
  if exist ..\static\custom\StaticUpdateIds-o2k3.txt call :EvalStatics ..\static\custom\StaticUpdateIds-o2k3.txt
)
if "%O2K7_VER_MAJOR%" NEQ "" (
  if exist ..\static\StaticUpdateIds-o2k7.txt call :EvalStatics ..\static\StaticUpdateIds-o2k7.txt
  if exist ..\static\custom\StaticUpdateIds-o2k7.txt call :EvalStatics ..\static\custom\StaticUpdateIds-o2k7.txt
)
if "%O2K10_VER_MAJOR%" NEQ "" (
  if exist ..\static\StaticUpdateIds-o2k10.txt call :EvalStatics ..\static\StaticUpdateIds-o2k10.txt
  if exist ..\static\custom\StaticUpdateIds-o2k10.txt call :EvalStatics ..\static\custom\StaticUpdateIds-o2k10.txt
)
if "%O2K13_VER_MAJOR%" NEQ "" (
  if exist ..\static\StaticUpdateIds-o2k13.txt call :EvalStatics ..\static\StaticUpdateIds-o2k13.txt
  if exist ..\static\custom\StaticUpdateIds-o2k13.txt call :EvalStatics ..\static\custom\StaticUpdateIds-o2k13.txt
)

:ListFiles
rem *** List update files ***
if exist "%TEMP%\InstalledUpdateIds.txt" del "%TEMP%\InstalledUpdateIds.txt"
if not exist "%TEMP%\MissingUpdateIds.txt" goto EoF
if exist "%TEMP%\UpdatesToInstall.txt" del "%TEMP%\UpdatesToInstall.txt"
echo.>"%TEMP%\ExcludeList.txt"
if "%IGNORE_BL%"=="1" goto IgnoreBL
if exist ..\exclude\ExcludeList.txt (
  type ..\exclude\ExcludeList.txt >"%TEMP%\ExcludeList.txt"
)
if exist ..\exclude\custom\ExcludeList.txt (
  type ..\exclude\custom\ExcludeList.txt >>"%TEMP%\ExcludeList.txt"
)
:IgnoreBL
if "%OS_ARCH%"=="x64" (set OS_SEARCH_DIRS=%OS_NAME%-%OS_ARCH%) else (set OS_SEARCH_DIRS=%OS_NAME% win)
for /F "usebackq tokens=1,2 delims=," %%i in ("%TEMP%\MissingUpdateIds.txt") do (
  if exist "%TEMP%\Update.txt" del "%TEMP%\Update.txt"
  %SystemRoot%\System32\find.exe /I "%%i" "%TEMP%\ExcludeList.txt" >nul 2>&1
  if errorlevel 1 (
    for %%k in (%OS_SEARCH_DIRS%) do (
      for %%l in (%OS_LANG% glb) do (
        if %IE_VER_MAJOR%%IE_VER_MINOR%0 GEQ 9100 (
          call ListUpdateFile.cmd ie%IE_VER_MINOR%-*%%i ..\%%k\%%l
        ) else (
          call ListUpdateFile.cmd ie%IE_VER_MAJOR%-*%%i ..\%%k\%%l
        )
        call ListUpdateFile.cmd windowsmedia%WMP_VER_MAJOR%-*%%i ..\%%k\%%l
        call ListUpdateFile.cmd windowsmedia-*%%i ..\%%k\%%l
        call ListUpdateFile.cmd mdac%MDAC_VER_MAJOR%%MDAC_VER_MINOR%-*%%i ..\%%k\%%l
        call ListUpdateFile.cmd windowsxp*%%i ..\%%k\%%l /searchleftmost
        call ListUpdateFile.cmd windowsserver2003*%%i ..\%%k\%%l /searchleftmost
        call ListUpdateFile.cmd windows6*%%i ..\%%k\%%l /searchleftmost
        call ListUpdateFile.cmd windows*%%i ..\%%k\%%l /searchleftmost
        call ListUpdateFile.cmd %%i ..\%%k\%%l
      )
    )
    call ListUpdateFile.cmd ndp*%%i*-%OS_ARCH% ..\dotnet\%OS_ARCH%-glb /searchleftmost
    if not exist "%TEMP%\Update.txt" (
      for %%k in (%OFC_NAME% ofc o2k3 o2k7 o2k10 o2k13) do (
        for %%l in (%OFC_LANG% %OS_LANG% glb) do (
          call ListUpdateFile.cmd %%i*%OFC_ARCH% ..\%%k\%%l
          call ListUpdateFile.cmd %%i ..\%%k\%%l
        )
      )
    )
    for %%k in (%OFC_LANG% %OS_LANG% glb) do (
      if exist ..\ofc\UpdateTable-ofc-%%k.csv (
        if not exist "%TEMP%\Update.txt" (
          for /F "tokens=1,2 delims=," %%l in (..\ofc\UpdateTable-ofc-%%k.csv) do (
            if "%%l"=="%%j" (
              if exist "%TEMP%\Update.txt" del "%TEMP%\Update.txt"
              call ListUpdateFile.cmd %%m ..\ofc\%%k /searchleftmost
            )
          )
        )
      )
    )
    if exist "%TEMP%\Update.txt" (
      del "%TEMP%\Update.txt"
    ) else (
      if "%%j"=="" (
        echo Warning: Update kb%%i not found.
        echo %DATE% %TIME% - Warning: Update kb%%i not found>>%UPDATE_LOGFILE%
      ) else (
        echo Warning: Update kb%%i ^(id: %%j^) not found.
        echo %DATE% %TIME% - Warning: Update kb%%i ^(id: %%j^) not found>>%UPDATE_LOGFILE%
      )
    )
  ) else (
    for /F "tokens=1* delims=,;" %%k in ('%SystemRoot%\System32\findstr.exe /I "%%i" "%TEMP%\ExcludeList.txt"') do (
      if "%%l"=="" (
        echo Info: Skipping update %%k due to matching black list entry.
        echo %DATE% %TIME% - Info: Skipped update %%k due to matching black list entry>>%UPDATE_LOGFILE%
      ) else (
        echo Info: Skipping update %%k ^(%%l^) due to matching black list entry.
        echo %DATE% %TIME% - Info: Skipped update %%k ^(%%l^) due to matching black list entry>>%UPDATE_LOGFILE%
      )
    )
  )
)
del "%TEMP%\MissingUpdateIds.txt"
del "%TEMP%\ExcludeList.txt"
goto EoF

:NoExtensions
echo ERROR: No command extensions available.
goto Error

:NoTemp
echo ERROR: Environment variable TEMP not set.
echo %DATE% %TIME% - Error: Environment variable TEMP not set>>%UPDATE_LOGFILE%
goto Error

:NoTempDir
echo ERROR: Directory "%TEMP%" not found.
echo %DATE% %TIME% - Error: Directory "%TEMP%" not found>>%UPDATE_LOGFILE%
goto Error

:NoOSName
echo ERROR: Environment variable OS_NAME not set.
echo %DATE% %TIME% - Error: Environment variable OS_NAME not set>>%UPDATE_LOGFILE%
goto Error

:NoOSLang
echo ERROR: Environment variable OS_LANG not set.
echo %DATE% %TIME% - Error: Environment variable OS_LANG not set>>%UPDATE_LOGFILE%
goto Error

:NoOSArch
echo ERROR: Environment variable OS_ARCH not set.
echo %DATE% %TIME% - Error: Environment variable OS_ARCH not set>>%UPDATE_LOGFILE%
goto Error

:Error
endlocal
exit /b 1

:EoF
endlocal
