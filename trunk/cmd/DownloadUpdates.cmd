@echo off
rem *** Author: T. Wittrock, RZ Uni Kiel ***

verify other 2>nul
setlocal enableextensions
if errorlevel 1 goto NoExtensions

if "%DIRCMD%" NEQ "" set DIRCMD=

%~d0
cd "%~p0"

set WSUSUPDATE_VERSION=6.2a (r22)
set DOWNLOAD_LOGFILE=..\log\download.log
title %~n0 %1 %2
echo Starting WSUS Offline Update download (v. %WSUSUPDATE_VERSION%) for %1 %2...
if exist %DOWNLOAD_LOGFILE% (
  echo. >>%DOWNLOAD_LOGFILE%
  echo -------------------------------------------------------------------------------- >>%DOWNLOAD_LOGFILE%
  echo. >>%DOWNLOAD_LOGFILE%
)
echo %DATE% %TIME% - Info: Starting download (v. %WSUSUPDATE_VERSION%) for %1 %2 >>%DOWNLOAD_LOGFILE%

for %%i in (w2k wxp w2k3 w2k3-x64 o2k oxp o2k3 o2k7 o2k7-x64) do (
  if /i "%1"=="%%i" (
    for %%j in (enu fra esn jpn kor rus ptg ptb deu nld ita chs cht plk hun csy sve trk ell ara heb dan nor fin) do (if /i "%2"=="%%j" goto EvalParams)
  )
)
for %%i in (w60 w60-x64) do (
  if /i "%1"=="%%i" (
    if /i "%2"=="glb" goto EvalParams
  )
)
goto InvalidParams

:EvalParams
if "%3"=="" goto NoMoreParams
for %%i in (/excludesp /excludestatics /includedotnet /nocleanup /verify /exitonerror /skipmkisofs /proxy /wsus) do (
  if /i "%3"=="%%i" echo %DATE% %TIME% - Info: Option %%i detected >>%DOWNLOAD_LOGFILE%
)
if /i "%3"=="/excludesp" set EXCLUDE_SP=1
if /i "%3"=="/excludestatics" set EXCLUDE_STATICS=1
if /i "%3"=="/includedotnet" set INCLUDE_DOTNET=1
if /i "%3"=="/nocleanup" set CLEANUP_DOWNLOADS=0
if /i "%3"=="/verify" set VERIFY_DOWNLOADS=1
if /i "%3"=="/exitonerror" set EXIT_ON_ERROR=1
if /i "%3"=="/skipmkisofs" set SKIP_MKISOFS=1
if /i "%3"=="/proxy" (
  set http_proxy=%4
  shift /3
)
if /i "%3"=="/wsus" (
  set HTTP_WSUS=%4
  shift /3
)
shift /3
goto EvalParams

:NoMoreParams
echo %1 | %SystemRoot%\system32\find.exe /I "x64" >nul 2>&1
if errorlevel 1 (set TARGET_ARCHITECTURE=x86) else (set TARGET_ARCHITECTURE=x64)

if "%TEMP%"=="" goto NoTemp
pushd "%TEMP%"
if errorlevel 1 goto NoTempDir
popd

set CSCRIPT_PATH=%SystemRoot%\system32\cscript.exe
if not exist %CSCRIPT_PATH% goto NoCScript
set REG_PATH=%SystemRoot%\system32\reg.exe
set WGET_PATH=..\bin\wget.exe
if not exist %WGET_PATH% goto NoWGet

title Downloading...

rem *** Clean up existing directories ***
echo Cleaning up existing directories...
if exist ..\fciv\dummy.txt del ..\fciv\dummy.txt
if exist ..\iso\dummy.txt del ..\iso\dummy.txt
if exist ..\log\dummy.txt del ..\log\dummy.txt
if exist ..\client\msi\nul (
  if exist ..\client\msi\WindowsInstaller-KB893803-v2-x86.exe (
    if not exist ..\client\w2k\glb\nul md ..\client\w2k\glb
    move /Y ..\client\msi\WindowsInstaller-KB893803-v2-x86.exe ..\client\w2k\glb >nul
  )
  call ..\client\cmd\SafeRmDir.cmd ..\client\msi
)
for %%i in (enu fra esn jpn kor rus ptg ptb deu nld ita chs cht plk hun csy sve trk ell ara heb dan nor fin) do (
  dir /B ..\client\o2k7\%%i\compatibilitypacksp1-kb940289-*.exe >nul 2>&1
  if not errorlevel 1 (
    for /F %%j in ('dir /B ..\client\o2k7\%%i\compatibilitypacksp1-kb940289-*.exe') do (
      if not exist ..\client\ofc\%%i\nul md ..\client\ofc\%%i
      move /Y ..\client\o2k7\%%i\%%j ..\client\ofc\%%i >nul
    )
  )
)
if exist ..\client\static\StaticUpdateIds-o2k7.txt (
  if exist ..\client\static\StaticUpdateIds-o2k7-x86.txt del ..\client\static\StaticUpdateIds-o2k7-x86.txt
  ren ..\client\static\StaticUpdateIds-o2k7.txt StaticUpdateIds-o2k7-x86.txt
)
if exist ..\exclude\ExcludeList-o2k7.txt (
  if exist ..\exclude\ExcludeList-o2k7-x86.txt del ..\exclude\ExcludeList-o2k7-x86.txt
  ren ..\exclude\ExcludeList-o2k7.txt ExcludeList-o2k7-x86.txt
)
if exist ..\xslt\ExtractExpiredIds-o2k7.xsl del ..\xslt\ExtractExpiredIds-o2k7.xsl
if exist ..\xslt\ExtractValidIds-o2k7.xsl del ..\xslt\ExtractValidIds-o2k7.xsl
if exist ..\bin\cygiconv-2.dll (
  if exist ..\bin\mkisofs.exe del ..\bin\mkisofs.exe
  del ..\bin\cygiconv-2.dll 
) 
if exist ..\bin\cygintl-8.dll (
  if exist ..\bin\mkisofs.exe del ..\bin\mkisofs.exe
  del ..\bin\cygintl-8.dll 
) 
if exist ..\bin\cygwin1.dll (
  if exist ..\bin\mkisofs.exe del ..\bin\mkisofs.exe
  del ..\bin\cygwin1.dll 
)
if exist ..\static\StaticDownloadLinks-mkisofs.txt del ..\static\StaticDownloadLinks-mkisofs.txt

rem *** Determine state of automatic daylight time setting ***
echo Determining state of automatic daylight time setting...
%CSCRIPT_PATH% //Nologo //E:vbs DetermineAutoDaylightTimeSet.vbs
if exist "%TEMP%\SetAutoDTS.cmd" (
  call "%TEMP%\SetAutoDTS.cmd"
  del "%TEMP%\SetAutoDTS.cmd"
)

rem *** Check whether Microsoft registry console tool is present - only required for w2k ***
if /i "%1" NEQ "w2k" goto SkipRegExe
if exist ..\client\bin\reg.exe goto SkipRegExe

rem *** Determine Microsoft registry console tool version ***
echo Determining Microsoft registry console tool version...
if not exist %REG_PATH% goto NoRegExe
%CSCRIPT_PATH% //Nologo //E:vbs DetermineRegVersion.vbs
if not exist "%TEMP%\SetRegVersion.cmd" goto NoRegVersion
call "%TEMP%\SetRegVersion.cmd"
del "%TEMP%\SetRegVersion.cmd"

rem *** Copy Microsoft registry console tool ***
echo Copying Microsoft registry console tool...
if /i %REG_VERSION_MAJOR% GTR 5 goto InvalidRegExe
if /i %REG_VERSION_MAJOR% LSS 2 goto InvalidRegExe
if /i %REG_VERSION_MAJOR% EQU 5 (
  if /i %REG_VERSION_MINOR% GTR 1 goto InvalidRegExe
)
if not exist ..\client\bin\nul md ..\client\bin
copy %REG_PATH% ..\client\bin >nul
:SkipRegExe

rem *** Disable automatic daylight time setting ***
if "%OS_AUTODTS%"=="1" (
  echo Disabling automatic daylight time setting...
  %REG_PATH% ADD HKLM\System\CurrentControlSet\Control\TimeZoneInformation /v DisableAutoDaylightTimeSet /t REG_DWORD /d 1 /f >nul 2>&1
  if errorlevel 1 (
    echo Warning: Disabling of automatic daylight time setting failed.
    echo %DATE% %TIME% - Warning: Disabling of automatic daylight time setting failed >>%DOWNLOAD_LOGFILE%
  ) else (
    echo %DATE% %TIME% - Info: Disabled automatic daylight time setting >>%DOWNLOAD_LOGFILE%
  )
)

rem *** Download Microsoft extract tool ***
if exist ..\bin\extract.exe goto SkipExtract
echo Downloading Microsoft extract tool...
%WGET_PATH% -N -i ..\static\StaticDownloadLink-extract.txt -P "%TEMP%\extract"
if errorlevel 1 goto DownloadError
echo %DATE% %TIME% - Info: Downloaded Microsoft extract tool >>%DOWNLOAD_LOGFILE%
ren "%TEMP%\extract\extract_setup.exe" extract_s.exe
"%TEMP%\extract\extract_s.exe" /T:"%TEMP%\extract" /C
%SystemRoot%\system32\msiexec.exe /a "%TEMP%\extract\extract.msi" /qn TARGETDIR="%TEMP%\extract\exe"
move "%TEMP%\extract\exe\extract.exe" ..\bin >nul
call ..\client\cmd\SafeRmDir.cmd "%TEMP%\extract"
:SkipExtract

rem *** Download Microsoft XSL processor frontend ***
if exist ..\client\bin\msxsl.exe goto SkipMSXSL
echo Downloading/validating Microsoft XSL processor frontend...
%WGET_PATH% -N -i ..\static\StaticDownloadLink-msxsl.txt -P ..\client\bin
if errorlevel 1 goto DownloadError
echo %DATE% %TIME% - Info: Downloaded/validated Microsoft XSL processor frontend >>%DOWNLOAD_LOGFILE%
:SkipMSXSL

rem *** Download unzip tool ***
if exist ..\bin\unzip.exe goto SkipUnzip
echo Downloading unzip tool...
%WGET_PATH% -N -i ..\static\StaticDownloadLink-unzip.txt -P ..\bin
if errorlevel 1 goto DownloadError
echo %DATE% %TIME% - Info: Downloaded unzip tool >>%DOWNLOAD_LOGFILE%
pushd ..\bin
unz600xn.exe unzip.exe
del unz600xn.exe
popd
:SkipUnzip

rem *** Download mkisofs tool ***
if "%SKIP_MKISOFS%"=="1" goto SkipMkIsoFs
if exist ..\bin\mkisofs.exe goto SkipMkIsoFs
echo Downloading mkisofs tool...
%WGET_PATH% -N -i ..\static\StaticDownloadLink-mkisofs.txt -P ..\bin
if errorlevel 1 goto DownloadError
echo %DATE% %TIME% - Info: Downloaded mkisofs tool >>%DOWNLOAD_LOGFILE%
pushd ..\bin
for /F %%i in ('dir /B cdrtools*.zip') do unzip.exe %%i mkisofs.exe
del /Q cdrtools*.zip
popd
:SkipMkIsoFs

rem *** Download Microsoft file checksum integrity verifier tool ***
if "%VERIFY_DOWNLOADS%" NEQ "1" goto SkipFCIV
if exist ..\bin\fciv.exe goto SkipFCIV
echo Downloading Microsoft file checksum integrity verifier tool...
%WGET_PATH% -N -i ..\static\StaticDownloadLink-fciv.txt -P "%TEMP%\fciv"
if errorlevel 1 goto DownloadError
echo %DATE% %TIME% - Info: Downloaded Microsoft file checksum integrity verifier tool >>%DOWNLOAD_LOGFILE%
"%TEMP%\fciv\windows-kb841290-x86-enu.exe" /T:"%TEMP%\fciv" /C /Q
move "%TEMP%\fciv\fciv.exe" ..\bin >nul
call ..\client\cmd\SafeRmDir.cmd "%TEMP%\fciv"
:SkipFCIV

rem *** Download most recent files for WSUS functionality ***
echo Downloading/validating most recent files for WSUS functionality...
%WGET_PATH% -N -i ..\static\StaticDownloadLinks-wsus.txt -P ..\client\wsus
if errorlevel 1 goto DownloadError
echo %DATE% %TIME% - Info: Downloaded/validated most recent files for WSUS functionality >>%DOWNLOAD_LOGFILE%

rem *** Extract Windows Update Agent catalog file wuredist.xml ***
if exist ..\client\wsus\wuredist.xml del ..\client\wsus\wuredist.xml
if not exist ..\bin\extract.exe goto NoExtract
..\bin\extract.exe /L ..\client\wsus ..\client\wsus\wuredist.cab wuredist.xml >nul
del ..\client\wsus\wuredist.cab

rem *** Determine update urls for Windows Update Agent ***
echo Determining update urls for Windows Update Agent...
if not exist ..\client\bin\msxsl.exe goto NoMSXSL
..\client\bin\msxsl.exe ..\client\wsus\wuredist.xml ..\xslt\ExtractDownloadLinks-wua-%TARGET_ARCHITECTURE%.xsl -o "%TEMP%\DownloadLinks-wua.txt"
if errorlevel 1 goto DownloadError
del ..\client\wsus\wuredist.xml

rem *** Download most recent Windows Update Agent ***
echo Downloading/validating most recent Windows Update Agent...
%WGET_PATH% -N -i "%TEMP%\DownloadLinks-wua.txt" -P ..\client\wsus
if errorlevel 1 goto DownloadError
echo %DATE% %TIME% - Info: Downloaded/validated most recent Windows Update Agent >>%DOWNLOAD_LOGFILE%
del "%TEMP%\DownloadLinks-wua.txt"

rem *** Download installation files for IE6 %2 - only required for w2k ***
if /i "%1" NEQ "w2k" goto SkipIE6
echo Downloading/validating installation files for IE6 %2...
%WGET_PATH% -nv -N -i ..\static\StaticDownloadLinks-ie6-%2.txt -P ..\client\win\%2\ie6setup -a %DOWNLOAD_LOGFILE%
if errorlevel 1 goto DownloadError
call FixIE6SetupDir.cmd %2
if errorlevel 1 goto DownloadError
echo %DATE% %TIME% - Info: Downloaded/validated installation files for IE6 %2 >>%DOWNLOAD_LOGFILE%
:SkipIE6

rem *** Download .NET Framework 3.5 SP1 - not required for w2k ***
if /i "%1"=="w2k" goto SkipDotNet
if "%INCLUDE_DOTNET%" NEQ "1" goto SkipDotNet
echo Downloading/validating installation files for .NET Framework 3.5 SP1...
%WGET_PATH% -N -i ..\static\StaticDownloadLink-dotnet.txt -P ..\client\dotnet
if errorlevel 1 goto DownloadError
echo %DATE% %TIME% - Info: Downloaded/validated installation files for .NET Framework 3.5 SP1 >>%DOWNLOAD_LOGFILE%
:SkipDotNet

for %%i in (w2k wxp w2k3) do (
  if /i "%1"=="%%i" (
    call :DownloadCore win glb
    if errorlevel 1 goto Error
    call :DownloadCore win %2
    if errorlevel 1 goto Error
  )
)
for %%i in (o2k oxp o2k3) do (
  if /i "%1"=="%%i" (
    call :DownloadCore ofc glb
    if errorlevel 1 goto Error
    call :DownloadCore ofc %2
    if errorlevel 1 goto Error
  )
)
for %%i in (w2k wxp w2k3 w2k3-x64 o2k oxp o2k3 o2k7 o2k7-x64) do (
  if /i "%1"=="%%i" (
    call :DownloadCore %1 glb
    if errorlevel 1 goto Error
    call :DownloadCore %1 %2
    if errorlevel 1 goto Error
  )
)
for %%i in (w60 w60-x64) do (
  if /i "%1"=="%%i" (
    call :DownloadCore %1 %2
    if errorlevel 1 goto Error
  )
)
goto RemindDate

:DownloadCore
rem *** Determine update urls for %1 %2 ***
echo.
echo Determining update urls for %1 %2...
if exist "%TEMP%\ValidStaticLinks-%1-%2.txt" del "%TEMP%\ValidStaticLinks-%1-%2.txt"
if exist "%TEMP%\ValidDownloadLinks-%1-%2.txt" del "%TEMP%\ValidDownloadLinks-%1-%2.txt"

if "%EXCLUDE_STATICS%"=="1" goto SkipStatics
if exist ..\static\StaticDownloadLinks-%1-%2.txt (
  if "%EXCLUDE_SP%"=="1" (
    %SystemRoot%\system32\findstr.exe /I /V /G:..\exclude\ExcludeList-SPs.txt ..\static\StaticDownloadLinks-%1-%2.txt >>"%TEMP%\ValidStaticLinks-%1-%2.txt"
  ) else (
    for /F %%i in (..\static\StaticDownloadLinks-%1-%2.txt) do echo %%i>>"%TEMP%\ValidStaticLinks-%1-%2.txt"
  ) 
)
if exist ..\static\StaticDownloadLinks-%1-%TARGET_ARCHITECTURE%-%2.txt (
  if "%EXCLUDE_SP%"=="1" (
    %SystemRoot%\system32\findstr.exe /I /V /G:..\exclude\ExcludeList-SPs.txt ..\static\StaticDownloadLinks-%1-%TARGET_ARCHITECTURE%-%2.txt >>"%TEMP%\ValidStaticLinks-%1-%2.txt"
  ) else (
    for /F %%i in (..\static\StaticDownloadLinks-%1-%TARGET_ARCHITECTURE%-%2.txt) do echo %%i>>"%TEMP%\ValidStaticLinks-%1-%2.txt"
  ) 
)
:SkipStatics
if not exist ..\client\bin\msxsl.exe goto NoMSXSL
for %%i in (win w2k wxp w2k3 w2k3-x64 w60 w60-x64) do (if /i "%1"=="%%i" goto DetermineWindows)
for %%i in (ofc o2k oxp o2k3 o2k7 o2k7-x64) do (if /i "%1"=="%%i" goto DetermineOffice)
goto DoDownload

:DetermineWindows
rem *** Extract Windows update catalog file package.xml ***
if exist "%TEMP%\package.cab" del "%TEMP%\package.cab"
if exist "%TEMP%\package.xml" del "%TEMP%\package.xml"
if not exist ..\bin\extract.exe goto NoExtract
..\bin\extract.exe /L "%TEMP%" ..\client\wsus\wsusscn2.cab package.cab >nul
..\bin\extract.exe /L "%TEMP%" "%TEMP%\package.cab" package.xml >nul
del "%TEMP%\package.cab"

if exist ..\xslt\ExtractDownloadLinks-%1-%2.xsl (
  ..\client\bin\msxsl.exe "%TEMP%\package.xml" ..\xslt\ExtractDownloadLinks-%1-%2.xsl -o "%TEMP%\DownloadLinks-%1-%2.txt"
  if errorlevel 1 goto DownloadError
)
if exist ..\xslt\ExtractDownloadLinks-%1-%TARGET_ARCHITECTURE%-%2.xsl (
  ..\client\bin\msxsl.exe "%TEMP%\package.xml" ..\xslt\ExtractDownloadLinks-%1-%TARGET_ARCHITECTURE%-%2.xsl -o "%TEMP%\DownloadLinks-%1-%2.txt"
  if errorlevel 1 goto DownloadError
)
del "%TEMP%\package.xml"

if not exist "%TEMP%\DownloadLinks-%1-%2.txt" goto DoDownload
if exist ..\exclude\ExcludeList-%1.txt (
  %SystemRoot%\system32\findstr.exe /I /V /G:..\exclude\ExcludeList-%1.txt "%TEMP%\DownloadLinks-%1-%2.txt" >>"%TEMP%\ValidDownloadLinks-%1-%2.txt"
)
if exist ..\exclude\ExcludeList-%1-%TARGET_ARCHITECTURE%.txt (
  %SystemRoot%\system32\findstr.exe /I /V /G:..\exclude\ExcludeList-%1-%TARGET_ARCHITECTURE%.txt "%TEMP%\DownloadLinks-%1-%2.txt" >>"%TEMP%\ValidDownloadLinks-%1-%2.txt"
)
if not exist "%TEMP%\ValidDownloadLinks-%1-%2.txt" ren "%TEMP%\DownloadLinks-%1-%2.txt" ValidDownloadLinks-%1-%2.txt
if exist "%TEMP%\DownloadLinks-%1-%2.txt" del "%TEMP%\DownloadLinks-%1-%2.txt"
goto DoDownload

:DetermineOffice
rem *** Download most recent files for Office inventory functionality ***
echo Downloading/validating most recent files for Office inventory functionality...
%WGET_PATH% -N -i ..\static\StaticDownloadLinks-inventory.txt -P ..\client\wsus
if errorlevel 1 goto DownloadError
echo %DATE% %TIME% - Info: Downloaded/validated most recent files for Office inventory functionality >>%DOWNLOAD_LOGFILE%

rem *** Extract Office update catalog file patchdata.xml ***
..\client\wsus\invcif.exe /T:"%TEMP%\inventory" /C /Q
pushd "%TEMP%\inventory"
move /Y patchdata.xml .. >nul
popd
call ..\client\cmd\SafeRmDir.cmd "%TEMP%\inventory"

if exist ..\xslt\ExtractDownloadLinks-%1-%2.xsl (
  ..\client\bin\msxsl.exe "%TEMP%\patchdata.xml" ..\xslt\ExtractDownloadLinks-%1-%2.xsl -o "%TEMP%\DownloadLinks-%1-%2.txt"
  if errorlevel 1 goto DownloadError
)
if exist ..\xslt\ExtractDownloadLinks-%1-%TARGET_ARCHITECTURE%-%2.xsl (
  ..\client\bin\msxsl.exe "%TEMP%\patchdata.xml" ..\xslt\ExtractDownloadLinks-%1-%TARGET_ARCHITECTURE%-%2.xsl -o "%TEMP%\DownloadLinks-%1-%2.txt"
  if errorlevel 1 goto DownloadError
)
if not exist "%TEMP%\DownloadLinks-%1-%2.txt" (
  del "%TEMP%\patchdata.xml"
  goto DoDownload
)
if exist ..\xslt\ExtractValidIds-%1-%TARGET_ARCHITECTURE%.xsl (
  ..\client\bin\msxsl.exe "%TEMP%\patchdata.xml" ..\xslt\ExtractValidIds-%1-%TARGET_ARCHITECTURE%.xsl -o "%TEMP%\ValidIds-%1.txt"
) else (
  ..\client\bin\msxsl.exe "%TEMP%\patchdata.xml" ..\xslt\ExtractValidIds-%1.xsl -o "%TEMP%\ValidIds-%1.txt"
)
if errorlevel 1 goto DownloadError
if exist ..\xslt\ExtractExpiredIds-%1-%TARGET_ARCHITECTURE%.xsl (
  ..\client\bin\msxsl.exe "%TEMP%\patchdata.xml" ..\xslt\ExtractExpiredIds-%1-%TARGET_ARCHITECTURE%.xsl -o "%TEMP%\ExpiredIds-%1.txt"
) else (
  ..\client\bin\msxsl.exe "%TEMP%\patchdata.xml" ..\xslt\ExtractExpiredIds-%1.xsl -o "%TEMP%\ExpiredIds-%1.txt"
)
if errorlevel 1 goto DownloadError
del "%TEMP%\patchdata.xml"

%SystemRoot%\system32\findstr.exe /I /V /G:"%TEMP%\ValidIds-%1.txt" "%TEMP%\ExpiredIds-%1.txt" >"%TEMP%\InvalidIds-%1.txt"
del "%TEMP%\ValidIds-%1.txt"
del "%TEMP%\ExpiredIds-%1.txt"

if exist ..\exclude\ExcludeList-%1.txt (
  for /F %%i in (..\exclude\ExcludeList-%1.txt) do echo %%i>>"%TEMP%\InvalidIds-%1.txt"
)
if exist ..\exclude\ExcludeList-%1-%TARGET_ARCHITECTURE%.txt (
  for /F %%i in (..\exclude\ExcludeList-%1-%TARGET_ARCHITECTURE%.txt) do echo %%i>>"%TEMP%\InvalidIds-%1.txt"
)
%SystemRoot%\system32\findstr.exe /I /V /G:"%TEMP%\InvalidIds-%1.txt" "%TEMP%\DownloadLinks-%1-%2.txt" >>"%TEMP%\ValidDownloadLinks-%1-%2.txt" 
del "%TEMP%\InvalidIds-%1.txt"
del "%TEMP%\DownloadLinks-%1-%2.txt"

:DoDownload
rem *** Verify integrity of existing updates for %1 %2 ***
if "%VERIFY_DOWNLOADS%" NEQ "1" goto SkipVerification
if not exist ..\bin\fciv.exe goto NoFCIV
if exist ..\fciv\sha1-%1-%2.xml (
  echo Verifying integrity of existing updates for %1 %2...
  ..\bin\fciv.exe -v -sha1 -xml ..\fciv\sha1-%1-%2.xml >>%DOWNLOAD_LOGFILE%
  if errorlevel 1 (
    if exist fciv.err del fciv.err
    goto IntegrityError
  )
  if exist fciv.err del fciv.err
  del ..\fciv\sha1-%1-%2.xml
  echo %DATE% %TIME% - Info: Verified integrity of existing updates for %1 %2 >>%DOWNLOAD_LOGFILE%
) else (
  echo Warning: Integrity database ..\fciv\sha1-%1-%2.xml not found.
  echo %DATE% %TIME% - Warning: Integrity database ..\fciv\sha1-%1-%2.xml not found >>%DOWNLOAD_LOGFILE%
)
:SkipVerification

rem *** Download updates for %1 %2 ***
if not exist "%TEMP%\ValidStaticLinks-%1-%2.txt" goto DownloadDynamicUpdates
echo Downloading/validating statically defined updates for %1 %2...
for /F "delims=: tokens=1*" %%i in ('%SystemRoot%\system32\findstr.exe /N $ "%TEMP%\ValidStaticLinks-%1-%2.txt"') do set LINES_COUNT=%%i
for /F "delims=: tokens=1*" %%i in ('%SystemRoot%\system32\findstr.exe /N $ "%TEMP%\ValidStaticLinks-%1-%2.txt"') do (
  echo Downloading/validating update %%i of %LINES_COUNT%...
  %WGET_PATH% -N -P ..\client\%1\%2 %%j
  if errorlevel 1 (
    echo Warning: Download of %%j failed.
    echo %DATE% %TIME% - Warning: Download of %%j failed >>%DOWNLOAD_LOGFILE%
  )
)
echo %DATE% %TIME% - Info: Downloaded/validated %LINES_COUNT% statically defined updates for %1 %2 >>%DOWNLOAD_LOGFILE%

:DownloadDynamicUpdates
if not exist "%TEMP%\ValidDownloadLinks-%1-%2.txt" goto CleanupDownload
echo Downloading/validating dynamically determined updates for %1 %2...
for /F "delims=: tokens=1*" %%i in ('%SystemRoot%\system32\findstr.exe /N $ "%TEMP%\ValidDownloadLinks-%1-%2.txt"') do set LINES_COUNT=%%i
if "%HTTP_WSUS%"=="" (
  for /F "delims=: tokens=1*" %%i in ('%SystemRoot%\system32\findstr.exe /N $ "%TEMP%\ValidDownloadLinks-%1-%2.txt"') do (
    echo Downloading/validating update %%i of %LINES_COUNT%...
    %WGET_PATH% -nv -N -P ..\client\%1\%2 -a %DOWNLOAD_LOGFILE% %%j
    if errorlevel 1 (
      echo Warning: Download of %%j failed.
      echo %DATE% %TIME% - Warning: Download of %%j failed >>%DOWNLOAD_LOGFILE%
    )
  )
) else (
  echo Creating WSUS download table for %1 %2...
  %CSCRIPT_PATH% //Nologo //E:vbs CreateDownloadTable.vbs "%TEMP%\ValidDownloadLinks-%1-%2.txt" %HTTP_WSUS%
  if errorlevel 1 goto DownloadError
  echo %DATE% %TIME% - Info: Created WSUS download table for %1 %2 >>%DOWNLOAD_LOGFILE%
  for /F "delims=: tokens=1*" %%i in ('%SystemRoot%\system32\findstr.exe /N $ "%TEMP%\ValidDownloadLinks-%1-%2.csv"') do (
    echo Downloading/validating update %%i of %LINES_COUNT%...
    for /F "delims=, tokens=1-3" %%k in ("%%j") do (
      if "%%m"=="" (
        %WGET_PATH% -nv -N -P ..\client\%1\%2 -a %DOWNLOAD_LOGFILE% %%l
        if errorlevel 1 (
          echo Warning: Download of %%j failed.
          echo %DATE% %TIME% - Warning: Download of %%j failed >>%DOWNLOAD_LOGFILE%
        )
      ) else (
        if exist ..\client\%1\%2\%%k ren ..\client\%1\%2\%%k _%%k
        %WGET_PATH% -nv --no-proxy -O ..\client\%1\%2\%%k -a %DOWNLOAD_LOGFILE% %%l
        if errorlevel 1 (
          if exist ..\client\%1\%2\%%k del ..\client\%1\%2\%%k
          if exist ..\client\%1\%2\_%%k ren ..\client\%1\%2\_%%k %%k
          %WGET_PATH% -nv -N -P ..\client\%1\%2 -a %DOWNLOAD_LOGFILE% %%m
          if errorlevel 1 (
            echo Warning: Download of %%m failed.
            echo %DATE% %TIME% - Warning: Download of %%m failed >>%DOWNLOAD_LOGFILE%
          )
        ) else (
          if exist ..\client\%1\%2\_%%k del ..\client\%1\%2\_%%k
        )
      )
    )
  )
)
echo %DATE% %TIME% - Info: Downloaded/validated %LINES_COUNT% dynamically determined updates for %1 %2 >>%DOWNLOAD_LOGFILE%

:CleanupDownload
rem *** Clean up client directory for %1 %2 ***
if "%CLEANUP_DOWNLOADS%"=="0" goto EndDownload
echo Cleaning up client directory for %1 %2...
for /F %%i in ('dir /A:-D /B ..\client\%1\%2\*.*') do (
  %SystemRoot%\system32\find.exe /I "%%i" "%TEMP%\ValidDownloadLinks-%1-%2.txt" >nul 2>&1
  if errorlevel 1 (
    %SystemRoot%\system32\find.exe /I "%%i" "%TEMP%\ValidStaticLinks-%1-%2.txt" >nul 2>&1
    if errorlevel 1 (
      del ..\client\%1\%2\%%i
      echo %DATE% %TIME% - Info: Deleted ..\client\%1\%2\%%i >>%DOWNLOAD_LOGFILE%
    )
  )
)
echo %DATE% %TIME% - Info: Cleaned up client directory for %1 %2 >>%DOWNLOAD_LOGFILE%

:EndDownload
rem *** Create integrity database for %1 %2 ***
if "%VERIFY_DOWNLOADS%"=="1" (
  if not exist ..\bin\fciv.exe goto NoFCIV
  echo Creating integrity database for %1 %2...
  ..\bin\fciv.exe ..\client\%1\%2 -r -type *.exe -type *.cab -sha1 -xml ..\fciv\sha1-%1-%2.xml >nul 2>&1
  if exist fciv.err del fciv.err
  echo %DATE% %TIME% - Info: Created integrity database for %1 %2 >>%DOWNLOAD_LOGFILE%
)
if exist "%TEMP%\ValidStaticLinks-%1-%2.txt" del "%TEMP%\ValidStaticLinks-%1-%2.txt"
if exist "%TEMP%\ValidDownloadLinks-%1-%2.txt" del "%TEMP%\ValidDownloadLinks-%1-%2.txt"
if exist "%TEMP%\ValidDownloadLinks-%1-%2.csv" del "%TEMP%\ValidDownloadLinks-%1-%2.csv"
goto :eof

:RemindDate
rem *** Remind build date ***
echo Reminding build date...
date /T >..\client\builddate.txt

rem *** Enable automatic daylight time setting ***
if "%OS_AUTODTS%"=="1" (
  echo Enabling automatic daylight time setting...
  %REG_PATH% DELETE HKLM\System\CurrentControlSet\Control\TimeZoneInformation /v DisableAutoDaylightTimeSet /f >nul 2>&1
  if errorlevel 1 (
    echo Warning: Enabling of automatic daylight time setting failed.
    echo %DATE% %TIME% - Warning: Enabling of automatic daylight time setting failed >>%DOWNLOAD_LOGFILE%
  ) else (
    echo %DATE% %TIME% - Info: Enabled automatic daylight time setting >>%DOWNLOAD_LOGFILE%
  )
)
goto EoF

:NoExtensions
echo.
echo ERROR: No command extensions available.
echo.
exit /b 1

:InvalidParams
echo.
echo ERROR: Invalid parameter: %1 %2 %3 %4
echo Usage1: %~n0 {w2k ^| wxp ^| w2k3 ^| w2k3-x64 ^| o2k ^| oxp ^| o2k3 ^| o2k7 ^| o2k7-x64} {enu ^| fra ^| esn ^| jpn ^| kor ^| rus ^| ptg ^| ptb ^| deu ^| nld ^| ita ^| chs ^| cht ^| plk ^| hun ^| csy ^| sve ^| trk ^| ell ^| ara ^| heb ^| dan ^| nor ^| fin} [/excludesp ^| /excludestatics] [/includedotnet] [/nocleanup] [/verify] [/proxy http://[username:password@]^<server^>:^<port^>] [/wsus http://^<server^>]
echo Usage2: %~n0 {w60 ^| w60-x64} {glb} [/excludesp ^| /excludestatics] [/includedotnet] [/nocleanup] [/verify] [/proxy http://[username:password@]^<server^>:^<port^>] [/wsus http://^<server^>]
echo %DATE% %TIME% - Error: Invalid parameter: %1 %2 %3 %4 >>%DOWNLOAD_LOGFILE%
echo.
goto Error

:NoTemp
echo.
echo ERROR: Environment variable TEMP not set.
echo %DATE% %TIME% - Error: Environment variable TEMP not set >>%DOWNLOAD_LOGFILE%
echo.
goto Error

:NoTempDir
echo.
echo ERROR: Directory "%TEMP%" not found.
echo %DATE% %TIME% - Error: Directory "%TEMP%" not found >>%DOWNLOAD_LOGFILE%
echo.
goto Error

:NoCScript
echo.
echo ERROR: VBScript interpreter %CSCRIPT_PATH% not found.
echo %DATE% %TIME% - Error: VBScript interpreter %CSCRIPT_PATH% not found >>%DOWNLOAD_LOGFILE%
echo.
goto Error

:NoWGet
echo.
echo ERROR: Utility %WGET_PATH% not found.
echo %DATE% %TIME% - Error: Utility %WGET_PATH% not found >>%DOWNLOAD_LOGFILE%
echo.
goto Error

:NoRegExe
echo.
echo ERROR: File %REG_PATH% not found.
echo If you run Windows 2000, please manually extract that file out of
echo the \SUPPORT\TOOLS\SUPPORT.CAB file on your installation CD and
echo copy it to the directory ..\client\bin.
echo %DATE% %TIME% - Error: File %REG_PATH% not found >>%DOWNLOAD_LOGFILE%
echo.
goto Error

:NoRegVersion
echo.
echo ERROR: Determination of Microsoft registry console tool version failed.
echo %DATE% %TIME% - Error: Determination of Microsoft registry console tool version failed >>%DOWNLOAD_LOGFILE%
echo.
goto Error

:InvalidRegExe
echo.
echo ERROR: File %REG_PATH% has version %REG_VERSION_MAJOR%.%REG_VERSION_MINOR%,
echo which is incompatible with Windows 2000 target systems.
echo Please manually copy that file from a Windows 2000 or XP system
echo to the directory ..\client\bin.
echo %DATE% %TIME% - Error: File %REG_PATH% has incompatible version %REG_VERSION_MAJOR%.%REG_VERSION_MINOR% >>%DOWNLOAD_LOGFILE%
echo.
goto Error

:NoExtract
echo.
echo ERROR: Utility ..\bin\extract.exe not found.
echo %DATE% %TIME% - Error: Utility ..\bin\extract.exe not found >>%DOWNLOAD_LOGFILE%
echo.
goto Error

:NoMSXSL
echo.
echo ERROR: Microsoft XSL processor frontend ..\client\bin\msxsl.exe not found.
echo %DATE% %TIME% - Error: Microsoft XSL processor frontend ..\client\bin\msxsl.exe not found >>%DOWNLOAD_LOGFILE%
echo.
goto Error

:NoFCIV
echo.
echo ERROR: Microsoft file checksum integrity verifier ..\bin\fciv.exe not found.
echo %DATE% %TIME% - Error: Microsoft file checksum integrity verifier ..\bin\fciv.exe not found >>%DOWNLOAD_LOGFILE%
echo.
goto Error

:DownloadError
echo.
echo ERROR: Download failure for %1 %2.
echo %DATE% %TIME% - Error: Download failure for %1 %2 >>%DOWNLOAD_LOGFILE%
echo.
goto Error

:IntegrityError
echo.
echo ERROR: File integrity verification failure.
echo %DATE% %TIME% - Error: File integrity verification failure >>%DOWNLOAD_LOGFILE%
echo.
goto Error

:Error
if "%EXIT_ON_ERROR%"=="1" (
  endlocal
  pause
  verify other 2>nul
  exit
) else (
  title %ComSpec%
  endlocal
  verify other 2>nul
  goto :eof
)

:EoF
echo Done.
echo %DATE% %TIME% - Info: Ending download for %1 %2 >>%DOWNLOAD_LOGFILE%
title %ComSpec%
endlocal
