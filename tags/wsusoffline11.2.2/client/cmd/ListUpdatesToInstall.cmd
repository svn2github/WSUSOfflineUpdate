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
if /i "%1"=="/seconly" set SECONLY=1
if /i "%1"=="/excludestatics" set EXC_STATICS=1
if /i "%1"=="/ignoreblacklist" set IGNORE_BL=1
shift /1
goto EvalParams

:EvalStatics
if not exist %1 goto :eof
if exist "%TEMP%\StaticUpdateIds.txt" del "%TEMP%\StaticUpdateIds.txt"
for /F "tokens=1* delims=kbKB,;" %%i in (%1) do (
  if exist "%TEMP%\MissingUpdateIds.txt" (
    %SystemRoot%\System32\find.exe /I "%%i" "%TEMP%\MissingUpdateIds.txt" >nul 2>&1
    if errorlevel 1 echo %%i>>"%TEMP%\StaticUpdateIds.txt"
  ) else (
    echo %%i>>"%TEMP%\StaticUpdateIds.txt"
  )
)
if not exist "%TEMP%\StaticUpdateIds.txt" goto :eof
if exist "%TEMP%\InstalledUpdateIds.txt" (
  %SystemRoot%\System32\findstr.exe /L /I /V /G:"%TEMP%\InstalledUpdateIds.txt" "%TEMP%\StaticUpdateIds.txt" >>"%TEMP%\MissingUpdateIds.txt"
) else (
  type "%TEMP%\StaticUpdateIds.txt" >>"%TEMP%\MissingUpdateIds.txt"
)
del "%TEMP%\StaticUpdateIds.txt"
goto :eof

:NoMoreParams
rem *** Add statically defined update ids ***
if "%EXC_STATICS%"=="1" goto ListFiles
if "%OS_NAME%"=="w100" (
  call :EvalStatics ..\static\custom\StaticUpdateIds-%OS_NAME%-%OS_VER_BUILD%-%OS_ARCH%.txt
  call :EvalStatics ..\static\StaticUpdateIds-%OS_NAME%-%OS_VER_BUILD%-%OS_ARCH%.txt
) else (
  call :EvalStatics ..\static\custom\StaticUpdateIds-%OS_NAME%-%OS_ARCH%.txt
  call :EvalStatics ..\static\StaticUpdateIds-%OS_NAME%-%OS_ARCH%.txt
)
if "%SECONLY%"=="1" (
  call :EvalStatics ..\static\custom\StaticUpdateIds-%OS_NAME%-seconly.txt
  call :EvalStatics ..\static\StaticUpdateIds-%OS_NAME%-seconly.txt
  call :EvalStatics ..\static\custom\StaticUpdateIds-%OS_NAME%-dotnet%DOTNET35_VER_MAJOR%%DOTNET35_VER_MINOR%-seconly.txt
  call :EvalStatics ..\static\StaticUpdateIds-%OS_NAME%-dotnet%DOTNET35_VER_MAJOR%%DOTNET35_VER_MINOR%-seconly.txt
  call :EvalStatics ..\static\custom\StaticUpdateIds-%OS_NAME%-dotnet4-%DOTNET4_RELEASE%-seconly.txt
  call :EvalStatics ..\static\StaticUpdateIds-%OS_NAME%-dotnet4-%DOTNET4_RELEASE%-seconly.txt
) else (
  call :EvalStatics ..\static\custom\StaticUpdateIds-%OS_NAME%-dotnet%DOTNET35_VER_MAJOR%%DOTNET35_VER_MINOR%.txt
  call :EvalStatics ..\static\StaticUpdateIds-%OS_NAME%-dotnet%DOTNET35_VER_MAJOR%%DOTNET35_VER_MINOR%.txt
  call :EvalStatics ..\static\custom\StaticUpdateIds-%OS_NAME%-dotnet4-%DOTNET4_RELEASE%.txt
  call :EvalStatics ..\static\StaticUpdateIds-%OS_NAME%-dotnet4-%DOTNET4_RELEASE%.txt
)
if "%O2K10_VER_MAJOR%" NEQ "" (
  call :EvalStatics ..\static\custom\StaticUpdateIds-o2k10.txt
  call :EvalStatics ..\static\StaticUpdateIds-o2k10.txt
)
if "%O2K13_VER_MAJOR%" NEQ "" (
  call :EvalStatics ..\static\custom\StaticUpdateIds-o2k13.txt
  call :EvalStatics ..\static\StaticUpdateIds-o2k13.txt
)
if "%O2K16_VER_MAJOR%" NEQ "" (
  call :EvalStatics ..\static\custom\StaticUpdateIds-o2k16.txt
  call :EvalStatics ..\static\StaticUpdateIds-o2k16.txt
)

:ListFiles
rem *** List update files ***
if exist "%TEMP%\InstalledUpdateIds.txt" del "%TEMP%\InstalledUpdateIds.txt"
if exist "%TEMP%\UpdatesToInstall.txt" del "%TEMP%\UpdatesToInstall.txt"
for %%i in ("%TEMP%\MissingUpdateIds.txt") do if %%~zi==0 del %%i
if not exist "%TEMP%\MissingUpdateIds.txt" goto EoF
echo.>"%TEMP%\ExcludeList.txt"
if "%IGNORE_BL%"=="1" goto IgnoreBL
if exist ..\exclude\ExcludeList.txt (
  type ..\exclude\ExcludeList.txt >"%TEMP%\ExcludeList.txt"
)
if exist ..\exclude\custom\ExcludeList.txt (
  type ..\exclude\custom\ExcludeList.txt >>"%TEMP%\ExcludeList.txt"
)
:IgnoreBL
if "%OS_ARCH%"=="x64" (set OS_SEARCH_DIR=%OS_NAME%-%OS_ARCH%) else (set OS_SEARCH_DIR=%OS_NAME%)
for /F "usebackq tokens=1,2 delims=," %%i in ("%TEMP%\MissingUpdateIds.txt") do (
  if exist "%TEMP%\Update.txt" del "%TEMP%\Update.txt"
  %SystemRoot%\System32\find.exe /I "%%i" "%TEMP%\ExcludeList.txt" >nul 2>&1
  if errorlevel 1 (
    for %%k in (%OS_SEARCH_DIR%) do (
      for %%l in (%OS_LANG% glb) do (
        if %IE_VER_MAJOR%%IE_VER_MINOR%0 GEQ 9100 (
          call ListUpdateFile.cmd ie%IE_VER_MINOR%-*%%i ..\%%k\%%l
        ) else (
          call ListUpdateFile.cmd ie%IE_VER_MAJOR%-*%%i ..\%%k\%%l
        )
        call ListUpdateFile.cmd windows*%%i ..\%%k\%%l /searchleftmost
        call ListUpdateFile.cmd %%i ..\%%k\%%l
      )
    )
    call ListUpdateFile.cmd ndp*%%i*-%OS_ARCH% ..\dotnet\%OS_ARCH%-glb /searchleftmost
    if not exist "%TEMP%\Update.txt" (
      for %%k in (%OFC_NAME% ofc o2k10 o2k13 o2k16) do (
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