@echo off
rem *** Author: T. Wittrock, RZ Uni Kiel ***

verify other 2>nul
setlocal enableextensions
if errorlevel 1 goto NoExtensions

if "%DIRCMD%" NEQ "" set DIRCMD=

%~d0
cd "%~p0"

set WSUSOFFLINE_VERSION=6.6.4+ (r159)
set DOWNLOAD_LOGFILE=..\log\download.log
title %~n0 %1 %2
echo Starting WSUS Offline Update download (v. %WSUSOFFLINE_VERSION%) for %1 %2...
if exist %DOWNLOAD_LOGFILE% (
  echo. >>%DOWNLOAD_LOGFILE%
  echo -------------------------------------------------------------------------------- >>%DOWNLOAD_LOGFILE%
  echo. >>%DOWNLOAD_LOGFILE%
)
echo %DATE% %TIME% - Info: Starting download (v. %WSUSOFFLINE_VERSION%) for %1 %2 >>%DOWNLOAD_LOGFILE%

for %%i in (w2k wxp w2k3 w2k3-x64 oxp o2k3 o2k7 o2k7-x64) do (
  if /i "%1"=="%%i" (
    for %%j in (enu fra esn jpn kor rus ptg ptb deu nld ita chs cht plk hun csy sve trk ell ara heb dan nor fin) do (if /i "%2"=="%%j" goto EvalParams)
  )
)
for %%i in (w60 w60-x64 w61 w61-x64) do (
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
if /i "%3"=="/includemsse" set INCLUDE_MSSE=1
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
if errorlevel 1 (set TARGET_ARCH=x86) else (set TARGET_ARCH=x64)

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
if exist ..\iso\dummy.txt del ..\iso\dummy.txt
if exist ..\log\dummy.txt del ..\log\dummy.txt
if exist ..\exclude\custom\dummy.txt del ..\exclude\custom\dummy.txt
if exist ..\static\custom\dummy.txt del ..\static\custom\dummy.txt
if exist ..\client\exclude\custom\dummy.txt del ..\client\exclude\custom\dummy.txt
if exist ..\client\static\custom\dummy.txt del ..\client\static\custom\dummy.txt
if exist ..\client\msi\nul (
  if exist ..\client\msi\WindowsInstaller-KB893803-v2-x86.exe (
    if not exist ..\client\w2k\glb\nul md ..\client\w2k\glb
    move /Y ..\client\msi\WindowsInstaller-KB893803-v2-x86.exe ..\client\w2k\glb >nul
  )
  call ..\client\cmd\SafeRmDir.cmd ..\client\msi
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
if exist ..\client\cmd\Reboot.vbs del ..\client\cmd\Reboot.vbs
if exist ..\client\bin\msxsl.exe move /Y ..\client\bin\msxsl.exe ..\bin >nul
if exist ..\client\xslt\nul rd /S /Q ..\client\xslt
if exist ..\client\static\StaticUpdateIds-o2k.txt del ..\client\static\StaticUpdateIds-o2k.txt
if exist ..\exclude\ExcludeList-o2k.txt del ..\exclude\ExcludeList-o2k.txt
if exist ..\exclude\ExcludeListISO-o2k.txt del ..\exclude\ExcludeListISO-o2k.txt
if exist ..\exclude\ExcludeListUSB-o2k.txt del ..\exclude\ExcludeListUSB-o2k.txt
del /Q ..\static\*o2k-*.* >nul 2>&1
del /Q ..\xslt\*o2k-*.* >nul 2>&1
if exist ..\xslt\ExtractExpiredIds-o2k.xsl del ..\xslt\ExtractExpiredIds-o2k.xsl
if exist ..\xslt\ExtractValidIds-o2k.xsl del ..\xslt\ExtractValidIds-o2k.xsl
if exist ..\static\StaticDownloadLink-unzip.txt del ..\static\StaticDownloadLink-unzip.txt
if exist ..\client\o2k3\glb\office2003-KB974882-FullFile-ENU.exe (
  if not exist ..\client\ofc\glb\nul md ..\client\ofc\glb
  move /Y ..\client\o2k3\glb\office2003-KB974882-FullFile-ENU.exe ..\client\ofc\glb >nul
)
if exist ..\client\win\glb\ndp*.* (
  if not exist ..\client\dotnet\x86-glb\nul md ..\client\dotnet\x86-glb
  move /Y ..\client\win\glb\ndp*.* ..\client\dotnet\x86-glb >nul
)
if exist ..\client\w2k3-x64\glb\ndp*.* (
  if not exist ..\client\dotnet\x64-glb\nul md ..\client\dotnet\x64-glb
  move /Y ..\client\w2k3-x64\glb\ndp*.* ..\client\dotnet\x64-glb >nul
)
if exist ..\xslt\ExtractDownloadLinks-dotnet-glb.xsl del ..\xslt\ExtractDownloadLinks-dotnet-glb.xsl
if exist ..\client\dotnet\glb\nul (
  if not exist ..\client\dotnet\x64-glb\nul md ..\client\dotnet\x64-glb
  move /Y ..\client\dotnet\glb\*-x64_*.* ..\client\dotnet\x64-glb >nul
  if not exist ..\client\dotnet\x86-glb\nul md ..\client\dotnet\x86-glb
  move /Y ..\client\dotnet\glb\*-x86_*.* ..\client\dotnet\x86-glb >nul
  rd /S /Q ..\client\dotnet\glb
)

if exist ..\bin\fciv.exe del ..\bin\fciv.exe
if exist ..\fciv\nul rd /S /Q ..\fciv
if exist ..\static\StaticDownloadLink-fciv.txt del ..\static\StaticDownloadLink-fciv.txt
if exist ..\xslt\ExtractDownloadLinks-wua-x86.xsl del ..\xslt\ExtractDownloadLinks-wua-x86.xsl
if exist ..\xslt\ExtractDownloadLinks-wua-x64.xsl del ..\xslt\ExtractDownloadLinks-wua-x64.xsl
if exist ..\static\StaticDownloadLink-dotnet.txt del ..\static\StaticDownloadLink-dotnet.txt
if exist DetermineRegVersion.vbs del DetermineRegVersion.vbs
if exist DetermineAutoDaylightTimeSet.vbs del DetermineAutoDaylightTimeSet.vbs
if exist ..\static\StaticDownloadLink-mssedefs-x64.txt del ..\static\StaticDownloadLink-mssedefs-x64.txt
if exist ..\static\StaticDownloadLink-mssedefs-x86.txt del ..\static\StaticDownloadLink-mssedefs-x86.txt
if exist ..\client\mssedefs\x64\nul (
  if not exist ..\client\mssedefs\x64-glb\nul md ..\client\mssedefs\x64-glb
  move /Y ..\client\mssedefs\x64\*.* ..\client\mssedefs\x64-glb >nul
  rd /S /Q ..\client\mssedefs\x64
  if exist ..\client\md\hashes-mssedefs.txt del ..\client\md\hashes-mssedefs.txt
)
if exist ..\client\mssedefs\x86\nul (
  if not exist ..\client\mssedefs\x86-glb\nul md ..\client\mssedefs\x86-glb
  move /Y ..\client\mssedefs\x86\*.* ..\client\mssedefs\x86-glb >nul
  rd /S /Q ..\client\mssedefs\x86
  if exist ..\client\md\hashes-mssedefs.txt del ..\client\md\hashes-mssedefs.txt
)
if exist ..\doc\faq.txt del ..\doc\faq.txt
if exist ..\bin\Streams.zip del ..\bin\Streams.zip 

rem *** Execute custom initialization hook ***
if exist .\custom\InitializationHook.cmd (
  echo Executing custom initialization hook...
  call .\custom\InitializationHook.cmd
  echo %DATE% %TIME% - Info: Executed custom initialization hook >>%DOWNLOAD_LOGFILE%
)

rem *** Check whether Microsoft registry console tool is present - only required for w2k ***
if /i "%1" NEQ "w2k" goto SkipRegExe
if exist ..\client\bin\reg.exe goto SkipRegExe

rem *** Determine Microsoft registry console tool version ***
echo Determining Microsoft registry console tool version...
if not exist %REG_PATH% goto NoRegExe
%CSCRIPT_PATH% //Nologo //E:vbs ..\client\cmd\DetermineFileVersion.vbs %REG_PATH% REG_VER
if not exist "%TEMP%\SetFileVersion.cmd" goto NoRegVersion
call "%TEMP%\SetFileVersion.cmd"
del "%TEMP%\SetFileVersion.cmd"

rem *** Copy Microsoft registry console tool ***
echo Copying Microsoft registry console tool...
if /i %REG_VER_MAJOR% GTR 5 goto InvalidRegExe
if /i %REG_VER_MAJOR% LSS 2 goto InvalidRegExe
if /i %REG_VER_MAJOR% EQU 5 (
  if /i %REG_VER_MINOR% GTR 1 goto InvalidRegExe
)
if not exist ..\client\bin\nul md ..\client\bin
copy %REG_PATH% ..\client\bin >nul
:SkipRegExe

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
if exist ..\bin\msxsl.exe goto SkipMSXSL
echo Downloading/validating Microsoft XSL processor frontend...
%WGET_PATH% -N -i ..\static\StaticDownloadLink-msxsl.txt -P ..\bin
if errorlevel 1 goto DownloadError
echo %DATE% %TIME% - Info: Downloaded/validated Microsoft XSL processor frontend >>%DOWNLOAD_LOGFILE%
:SkipMSXSL

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

rem *** Download Sysinternals' digital file signature verification tool ***
if "%VERIFY_DOWNLOADS%" NEQ "1" goto SkipSigCheck
if exist ..\bin\sigcheck.exe goto SkipSigCheck
echo Downloading Sysinternals' digital file signature verification tool...
%WGET_PATH% -N -i ..\static\StaticDownloadLink-sigcheck.txt -P ..\bin
if errorlevel 1 goto DownloadError
echo %DATE% %TIME% - Info: Downloaded Sysinternals' digital file signature verification tool >>%DOWNLOAD_LOGFILE%
pushd ..\bin
unzip.exe Sigcheck.zip sigcheck.exe
del Sigcheck.zip
popd
:SkipSigCheck

rem *** Download Sysinternals' NTFS alternate data stream handling tool ***
if exist ..\bin\streams.exe goto SkipStreams
echo Downloading Sysinternals' NTFS alternate data stream handling tool...
%WGET_PATH% -N -i ..\static\StaticDownloadLink-streams.txt -P ..\bin
if errorlevel 1 goto DownloadError
echo %DATE% %TIME% - Info: Downloaded Sysinternals' NTFS alternate data stream handling tool >>%DOWNLOAD_LOGFILE%
pushd ..\bin
unzip.exe Streams.zip streams.exe
del Streams.zip
popd
:SkipStreams

rem *** Download most recent Windows Update Agent and catalog file ***
if "%VERIFY_DOWNLOADS%" NEQ "1" goto DownloadWSUS
if not exist ..\client\wsus\nul goto DownloadWSUS
if not exist ..\client\bin\hashdeep.exe goto NoHashDeep
if exist ..\client\md\hashes-wsus.txt (
  echo Verifying integrity of Windows Update Agent and catalog file...
  pushd ..\client\md
  ..\bin\hashdeep.exe -a -l -vv -k hashes-wsus.txt -r ..\wsus
  if errorlevel 1 (
    popd
    goto IntegrityError
  )
  popd
  echo %DATE% %TIME% - Info: Verified integrity of Windows Update Agent and catalog file >>%DOWNLOAD_LOGFILE%
) else (
  echo Warning: Integrity database ..\client\md\hashes-wsus.txt not found.
  echo %DATE% %TIME% - Warning: Integrity database ..\client\md\hashes-wsus.txt not found >>%DOWNLOAD_LOGFILE%
)
:DownloadWSUS
echo Downloading/validating most recent Windows Update Agent and catalog file...
%WGET_PATH% -N -i ..\static\StaticDownloadLinks-wsus.txt -P ..\client\wsus
if errorlevel 1 goto DownloadError
echo %DATE% %TIME% - Info: Downloaded/validated most recent Windows Update Agent and catalog file >>%DOWNLOAD_LOGFILE%
if "%VERIFY_DOWNLOADS%"=="1" (
  if not exist ..\client\bin\hashdeep.exe goto NoHashDeep
  echo Creating integrity database for Windows Update Agent and catalog file...
  if not exist ..\client\md\nul md ..\client\md
  pushd ..\client\md
  ..\bin\hashdeep.exe -c md5,sha256 -l -r ..\wsus >hashes-wsus.txt
  if errorlevel 1 (
    popd
    echo Warning: Error creating integrity database ..\client\md\hashes-wsus.txt.
    echo %DATE% %TIME% - Warning: Error creating integrity database ..\client\md\hashes-wsus.txt >>%DOWNLOAD_LOGFILE%
  ) else (
    popd
    echo %DATE% %TIME% - Info: Created integrity database for Windows Update Agent and catalog file >>%DOWNLOAD_LOGFILE%
  )
) else (
  if exist ..\client\md\hashes-wsus.txt (
    del ..\client\md\hashes-wsus.txt 
    echo %DATE% %TIME% - Info: Deleted integrity database for Windows Update Agent and catalog file >>%DOWNLOAD_LOGFILE%
  )
)

rem *** Download installation files for IE6 %2 - only required for w2k ***
if /i "%1" NEQ "w2k" goto SkipIE6
echo Downloading/validating installation files for IE6 %2...
%WGET_PATH% -nv -N -i ..\static\StaticDownloadLinks-ie6-%2.txt -P ..\client\win\%2\ie6setup -a %DOWNLOAD_LOGFILE%
if errorlevel 1 goto DownloadError
call FixIE6SetupDir.cmd %2
if errorlevel 1 goto DownloadError
echo %DATE% %TIME% - Info: Downloaded/validated installation files for IE6 %2 >>%DOWNLOAD_LOGFILE%
:SkipIE6

rem *** Download installation files for .NET Framework 3.5 SP1 and 4 - not required for w2k ***
if /i "%1"=="w2k" goto SkipDotNet
if "%INCLUDE_DOTNET%" NEQ "1" goto SkipDotNet
set DOTNET35_FILENAME=..\dotnet\dotnetfx35.exe
set DOTNET4_FILENAME=..\dotnet\dotNetFx40_Full_x86_x64.exe
if "%VERIFY_DOWNLOADS%" NEQ "1" goto DownloadDotNet
if not exist ..\client\dotnet\nul goto DownloadDotNet
if not exist ..\client\bin\hashdeep.exe goto NoHashDeep
if exist ..\client\md\hashes-dotnet.txt (
  echo Verifying integrity of .NET Framework installation files...
  pushd ..\client\md
  if exist %DOTNET4_FILENAME% (
    ..\bin\hashdeep.exe -a -l -vv -k hashes-dotnet.txt %DOTNET35_FILENAME% %DOTNET4_FILENAME%
  ) else (
    rem *** Compatibility line ***
    ..\bin\hashdeep.exe -a -l -vv -k hashes-dotnet.txt %DOTNET35_FILENAME%
  )
  if errorlevel 1 (
    popd
    goto IntegrityError
  )
  popd
  echo %DATE% %TIME% - Info: Verified integrity of .NET Framework installation files >>%DOWNLOAD_LOGFILE%
) else (
  echo Warning: Integrity database ..\client\md\hashes-dotnet.txt not found.
  echo %DATE% %TIME% - Warning: Integrity database ..\client\md\hashes-dotnet.txt not found >>%DOWNLOAD_LOGFILE%
)
:DownloadDotNet
echo Downloading/validating installation files for .NET Framework 3.5 SP1 and 4...
%WGET_PATH% -N -i ..\static\StaticDownloadLinks-dotnet.txt -P ..\client\dotnet
if errorlevel 1 goto DownloadError
echo %DATE% %TIME% - Info: Downloaded/validated installation files for .NET Framework 3.5 SP1 and 4 >>%DOWNLOAD_LOGFILE%
if "%VERIFY_DOWNLOADS%"=="1" (
  if not exist ..\client\bin\hashdeep.exe goto NoHashDeep
  echo Creating integrity database for .NET Framework installation files...
  if not exist ..\client\md\nul md ..\client\md
  pushd ..\client\md
  ..\bin\hashdeep.exe -c md5,sha256 -l %DOTNET35_FILENAME% %DOTNET4_FILENAME% >hashes-dotnet.txt
  if errorlevel 1 (
    popd
    echo Warning: Error creating integrity database ..\client\md\hashes-dotnet.txt.
    echo %DATE% %TIME% - Warning: Error creating integrity database ..\client\md\hashes-dotnet.txt >>%DOWNLOAD_LOGFILE%
  ) else (
    popd
    echo %DATE% %TIME% - Info: Created integrity database for .NET Framework installation files >>%DOWNLOAD_LOGFILE%
  )
) else (
  if exist ..\client\md\hashes-dotnet.txt (
    del ..\client\md\hashes-dotnet.txt 
    echo %DATE% %TIME% - Info: Deleted integrity database for .NET Framework installation files >>%DOWNLOAD_LOGFILE%
  )
)
call :DownloadCore dotnet %TARGET_ARCH%-glb
if errorlevel 1 goto Error
:SkipDotNet

rem *** Download definition files for Microsoft Security Essentials - not required for w2k and w2k3 ***
if /i "%1"=="w2k" goto SkipMSSE
if /i "%1"=="w2k3" goto SkipMSSE
if /i "%1"=="w2k3-x64" goto SkipMSSE
if "%INCLUDE_MSSE%" NEQ "1" goto SkipMSSE
if "%VERIFY_DOWNLOADS%" NEQ "1" goto DownloadMSSE
if not exist ..\client\mssedefs\nul goto DownloadMSSE
if not exist ..\client\bin\hashdeep.exe goto NoHashDeep
if exist ..\client\md\hashes-mssedefs.txt (
  echo Verifying integrity of Microsoft Security Essentials definition files...
  pushd ..\client\md
  ..\bin\hashdeep.exe -a -l -vv -k hashes-mssedefs.txt -r ..\mssedefs
  if errorlevel 1 (
    popd
    goto IntegrityError
  )
  popd
  echo %DATE% %TIME% - Info: Verified integrity of Microsoft Security Essentials definition files >>%DOWNLOAD_LOGFILE%
) else (
  echo Warning: Integrity database ..\client\md\hashes-mssedefs.txt not found.
  echo %DATE% %TIME% - Warning: Integrity database ..\client\md\hashes-mssedefs.txt not found >>%DOWNLOAD_LOGFILE%
)
:DownloadMSSE
echo Downloading/validating definition files for Microsoft Security Essentials...
%WGET_PATH% -N -i ..\static\StaticDownloadLink-mssedefs-%TARGET_ARCH%-glb.txt -P ..\client\mssedefs\%TARGET_ARCH%-glb
if errorlevel 1 goto DownloadError
echo %DATE% %TIME% - Info: Downloaded/validated definition files for Microsoft Security Essentials >>%DOWNLOAD_LOGFILE%
if "%VERIFY_DOWNLOADS%"=="1" (
  if not exist ..\client\bin\hashdeep.exe goto NoHashDeep
  echo Creating integrity database for Microsoft Security Essentials definition files...
  if not exist ..\client\md\nul md ..\client\md
  pushd ..\client\md
  ..\bin\hashdeep.exe -c md5,sha256 -l -r ..\mssedefs >hashes-mssedefs.txt
  if errorlevel 1 (
    popd
    echo Warning: Error creating integrity database ..\client\md\hashes-mssedefs.txt.
    echo %DATE% %TIME% - Warning: Error creating integrity database ..\client\md\hashes-mssedefs.txt >>%DOWNLOAD_LOGFILE%
  ) else (
    popd
    echo %DATE% %TIME% - Info: Created integrity database for Microsoft Security Essentials definition files >>%DOWNLOAD_LOGFILE%
  )
) else (
  if exist ..\client\md\hashes-mssedefs.txt (
    del ..\client\md\hashes-mssedefs.txt 
    echo %DATE% %TIME% - Info: Deleted integrity database for Microsoft Security Essentials definition files >>%DOWNLOAD_LOGFILE%
  )
)
:SkipMSSE

rem *** Download the platform specific patches ***
for %%i in (w2k wxp w2k3) do (
  if /i "%1"=="%%i" (
    call :DownloadCore win glb
    if errorlevel 1 goto Error
    call :DownloadCore win %2
    if errorlevel 1 goto Error
  )
)
for %%i in (oxp o2k3 o2k7 o2k7-x64) do (
  if /i "%1"=="%%i" (
    call :DownloadCore ofc glb
    if errorlevel 1 goto Error
    call :DownloadCore ofc %2
    if errorlevel 1 goto Error
  )
)
for %%i in (w2k wxp w2k3 w2k3-x64 oxp o2k3 o2k7 o2k7-x64) do (
  if /i "%1"=="%%i" (
    call :DownloadCore %1 glb
    if errorlevel 1 goto Error
    call :DownloadCore %1 %2
    if errorlevel 1 goto Error
  )
)
for %%i in (w60 w60-x64 w61 w61-x64) do (
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
if exist "%TEMP%\StaticDownloadLinks-%1-%2.txt" del "%TEMP%\StaticDownloadLinks-%1-%2.txt"
if exist "%TEMP%\ValidStaticLinks-%1-%2.txt" del "%TEMP%\ValidStaticLinks-%1-%2.txt"
if exist "%TEMP%\ValidDownloadLinks-%1-%2.txt" del "%TEMP%\ValidDownloadLinks-%1-%2.txt"

if "%EXCLUDE_STATICS%"=="1" goto SkipStatics
if exist ..\static\StaticDownloadLinks-%1-%2.txt (
  copy /Y ..\static\StaticDownloadLinks-%1-%2.txt "%TEMP%\StaticDownloadLinks-%1-%2.txt" >nul
  if exist ..\static\custom\StaticDownloadLinks-%1-%2.txt (
    for /F %%i in (..\static\custom\StaticDownloadLinks-%1-%2.txt) do echo %%i>>"%TEMP%\StaticDownloadLinks-%1-%2.txt"
  )
  goto EvalStatics
)
if exist ..\static\StaticDownloadLinks-%1-%TARGET_ARCH%-%2.txt (
  copy /Y ..\static\StaticDownloadLinks-%1-%TARGET_ARCH%-%2.txt "%TEMP%\StaticDownloadLinks-%1-%2.txt" >nul
  if exist ..\static\custom\StaticDownloadLinks-%1-%TARGET_ARCH%-%2.txt (
    for /F %%i in (..\static\custom\StaticDownloadLinks-%1-%TARGET_ARCH%-%2.txt) do echo %%i>>"%TEMP%\StaticDownloadLinks-%1-%2.txt"
  )
  goto EvalStatics
)
goto SkipStatics

:EvalStatics
if "%EXCLUDE_SP%"=="1" (
  %SystemRoot%\system32\findstr.exe /I /V /G:..\exclude\ExcludeList-SPs.txt "%TEMP%\StaticDownloadLinks-%1-%2.txt" >>"%TEMP%\ValidStaticLinks-%1-%2.txt"
  del "%TEMP%\StaticDownloadLinks-%1-%2.txt"
) else (
  ren "%TEMP%\StaticDownloadLinks-%1-%2.txt" ValidStaticLinks-%1-%2.txt
)

:SkipStatics
if not exist ..\bin\msxsl.exe goto NoMSXSL
for %%i in (dotnet win w2k wxp w2k3 w2k3-x64 w60 w60-x64 w61 w61-x64) do (if /i "%1"=="%%i" goto DetermineWindows)
for %%i in (ofc oxp o2k3 o2k7 o2k7-x64) do (if /i "%1"=="%%i" goto DetermineOffice)
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
  ..\bin\msxsl.exe "%TEMP%\package.xml" ..\xslt\ExtractDownloadLinks-%1-%2.xsl -o "%TEMP%\DownloadLinks-%1-%2.txt"
  if errorlevel 1 goto DownloadError
)
if exist ..\xslt\ExtractDownloadLinks-%1-%TARGET_ARCH%-%2.xsl (
  ..\bin\msxsl.exe "%TEMP%\package.xml" ..\xslt\ExtractDownloadLinks-%1-%TARGET_ARCH%-%2.xsl -o "%TEMP%\DownloadLinks-%1-%2.txt"
  if errorlevel 1 goto DownloadError
)
del "%TEMP%\package.xml"

if not exist "%TEMP%\DownloadLinks-%1-%2.txt" goto DoDownload

if exist "%TEMP%\ExcludeList-%1.txt" del "%TEMP%\ExcludeList-%1.txt"
if exist ..\exclude\ExcludeList-%1.txt (
  copy /Y ..\exclude\ExcludeList-%1.txt "%TEMP%\ExcludeList-%1.txt" >nul
  if exist ..\exclude\custom\ExcludeList-%1.txt (
    for /F %%i in (..\exclude\custom\ExcludeList-%1.txt) do echo %%i>>"%TEMP%\ExcludeList-%1.txt"
  )
  goto ExcludeWindows
)
if exist ..\exclude\ExcludeList-%1-%TARGET_ARCH%.txt (
  copy /Y ..\exclude\ExcludeList-%1-%TARGET_ARCH%.txt "%TEMP%\ExcludeList-%1.txt" >nul
  if exist ..\exclude\custom\ExcludeList-%1-%TARGET_ARCH%.txt (
    for /F %%i in (..\exclude\custom\ExcludeList-%1-%TARGET_ARCH%.txt) do echo %%i>>"%TEMP%\ExcludeList-%1.txt"
  )
)

:ExcludeWindows
%SystemRoot%\system32\findstr.exe /I /V /G:"%TEMP%\ExcludeList-%1.txt" "%TEMP%\DownloadLinks-%1-%2.txt" >>"%TEMP%\ValidDownloadLinks-%1-%2.txt"
if not exist "%TEMP%\ValidDownloadLinks-%1-%2.txt" ren "%TEMP%\DownloadLinks-%1-%2.txt" ValidDownloadLinks-%1-%2.txt
if exist "%TEMP%\ExcludeList-%1.txt" del "%TEMP%\ExcludeList-%1.txt"
if exist "%TEMP%\DownloadLinks-%1-%2.txt" del "%TEMP%\DownloadLinks-%1-%2.txt"
goto DoDownload

:DetermineOffice
rem *** Download most recent files for Office inventory functionality ***
echo Downloading/validating most recent files for Office inventory functionality...
%WGET_PATH% -N -i ..\static\StaticDownloadLinks-inventory.txt -P ..\client\wsus
if errorlevel 1 goto DownloadError
echo %DATE% %TIME% - Info: Downloaded/validated most recent files for Office inventory functionality >>%DOWNLOAD_LOGFILE%
if "%VERIFY_DOWNLOADS%"=="1" (
  if not exist ..\client\bin\hashdeep.exe goto NoHashDeep
  echo Creating integrity database for Windows Update Agent and catalog file...
  if not exist ..\client\md\nul md ..\client\md
  pushd ..\client\md
  ..\bin\hashdeep.exe -c md5,sha256 -l -r ..\wsus >hashes-wsus.txt
  if errorlevel 1 (
    popd
    echo Warning: Error creating integrity database ..\client\md\hashes-wsus.txt.
    echo %DATE% %TIME% - Warning: Error creating integrity database ..\client\md\hashes-wsus.txt >>%DOWNLOAD_LOGFILE%
  ) else (
    popd
    echo %DATE% %TIME% - Info: Created integrity database for Windows Update Agent and catalog file >>%DOWNLOAD_LOGFILE%
  )
) else (
  if exist ..\client\md\hashes-wsus.txt (
    del ..\client\md\hashes-wsus.txt 
    echo %DATE% %TIME% - Info: Deleted integrity database for Windows Update Agent and catalog file >>%DOWNLOAD_LOGFILE%
  )
)

rem *** Extract Office update catalog file patchdata.xml ***
..\client\wsus\invcif.exe /T:"%TEMP%\inventory" /C /Q
pushd "%TEMP%\inventory"
move /Y patchdata.xml .. >nul
popd
call ..\client\cmd\SafeRmDir.cmd "%TEMP%\inventory"

if exist ..\xslt\ExtractDownloadLinks-%1-%2.xsl (
  ..\bin\msxsl.exe "%TEMP%\patchdata.xml" ..\xslt\ExtractDownloadLinks-%1-%2.xsl -o "%TEMP%\DownloadLinks-%1-%2.txt"
  if errorlevel 1 goto DownloadError
)
if exist ..\xslt\ExtractDownloadLinks-%1-%TARGET_ARCH%-%2.xsl (
  ..\bin\msxsl.exe "%TEMP%\patchdata.xml" ..\xslt\ExtractDownloadLinks-%1-%TARGET_ARCH%-%2.xsl -o "%TEMP%\DownloadLinks-%1-%2.txt"
  if errorlevel 1 goto DownloadError
)
if not exist "%TEMP%\DownloadLinks-%1-%2.txt" (
  del "%TEMP%\patchdata.xml"
  goto DoDownload
)
if exist ..\xslt\ExtractValidIds-%1-%TARGET_ARCH%.xsl (
  ..\bin\msxsl.exe "%TEMP%\patchdata.xml" ..\xslt\ExtractValidIds-%1-%TARGET_ARCH%.xsl -o "%TEMP%\ValidIds-%1.txt"
) else (
  ..\bin\msxsl.exe "%TEMP%\patchdata.xml" ..\xslt\ExtractValidIds-%1.xsl -o "%TEMP%\ValidIds-%1.txt"
)
if errorlevel 1 goto DownloadError
if exist ..\xslt\ExtractExpiredIds-%1-%TARGET_ARCH%.xsl (
  ..\bin\msxsl.exe "%TEMP%\patchdata.xml" ..\xslt\ExtractExpiredIds-%1-%TARGET_ARCH%.xsl -o "%TEMP%\ExpiredIds-%1.txt"
) else (
  ..\bin\msxsl.exe "%TEMP%\patchdata.xml" ..\xslt\ExtractExpiredIds-%1.xsl -o "%TEMP%\ExpiredIds-%1.txt"
)
if errorlevel 1 goto DownloadError
del "%TEMP%\patchdata.xml"

%SystemRoot%\system32\findstr.exe /I /V /G:"%TEMP%\ValidIds-%1.txt" "%TEMP%\ExpiredIds-%1.txt" >"%TEMP%\InvalidIds-%1.txt"
del "%TEMP%\ValidIds-%1.txt"
del "%TEMP%\ExpiredIds-%1.txt"

if exist "%TEMP%\ExcludeList-%1.txt" del "%TEMP%\ExcludeList-%1.txt"
if exist ..\exclude\ExcludeList-%1.txt (
  copy /Y ..\exclude\ExcludeList-%1.txt "%TEMP%\ExcludeList-%1.txt" >nul
  if exist ..\exclude\custom\ExcludeList-%1.txt (
    for /F %%i in (..\exclude\custom\ExcludeList-%1.txt) do echo %%i>>"%TEMP%\ExcludeList-%1.txt"
  )
  goto ExcludeOffice
)
if exist ..\exclude\ExcludeList-%1-%TARGET_ARCH%.txt (
  copy /Y ..\exclude\ExcludeList-%1-%TARGET_ARCH%.txt "%TEMP%\ExcludeList-%1.txt" >nul
  if exist ..\exclude\custom\ExcludeList-%1-%TARGET_ARCH%.txt (
    for /F %%i in (..\exclude\custom\ExcludeList-%1-%TARGET_ARCH%.txt) do echo %%i>>"%TEMP%\ExcludeList-%1.txt"
  )
)

:ExcludeOffice
for /F "usebackq" %%i in ("%TEMP%\ExcludeList-%1.txt") do echo %%i>>"%TEMP%\InvalidIds-%1.txt"
%SystemRoot%\system32\findstr.exe /I /V /G:"%TEMP%\InvalidIds-%1.txt" "%TEMP%\DownloadLinks-%1-%2.txt" >>"%TEMP%\ValidDownloadLinks-%1-%2.txt" 
if exist "%TEMP%\ExcludeList-%1.txt" del "%TEMP%\ExcludeList-%1.txt"
del "%TEMP%\InvalidIds-%1.txt"
del "%TEMP%\DownloadLinks-%1-%2.txt"

:DoDownload
rem *** Verify integrity of existing updates for %1 %2 ***
if "%VERIFY_DOWNLOADS%" NEQ "1" goto SkipVerification
if not exist ..\client\%1\%2\nul goto SkipVerification
if not exist ..\client\bin\hashdeep.exe goto NoHashDeep
for %%i in (..\client\md\hashes-%1-%2.txt) do (if %%~zi==0 del %%i)
if exist ..\client\md\hashes-%1-%2.txt (
  echo Verifying integrity of existing updates for %1 %2...
  pushd ..\client\md
  ..\bin\hashdeep.exe -a -l -vv -k hashes-%1-%2.txt -r ..\%1\%2
  if errorlevel 1 (
    popd
    goto IntegrityError
  )
  popd
  echo %DATE% %TIME% - Info: Verified integrity of existing updates for %1 %2 >>%DOWNLOAD_LOGFILE%
) else (
  echo Warning: Integrity database ..\client\md\hashes-%1-%2.txt not found.
  echo %DATE% %TIME% - Warning: Integrity database ..\client\md\hashes-%1-%2.txt not found >>%DOWNLOAD_LOGFILE%
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
if "%CLEANUP_DOWNLOADS%"=="0" goto VerifyDownload
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

:VerifyDownload
if not exist ..\client\%1\%2\nul goto EndDownload
dir ..\client\%1\%2 /A:-D >nul 2>&1
if errorlevel 1 goto EndDownload
rem *** Delete alternate data streams for %1 %2 ***
if exist ..\bin\streams.exe (
  echo Deleting alternate data streams for %1 %2...
  ..\bin\streams.exe -accepteula -s -d ..\client\%1\%2\*.* >nul 2>&1
  if errorlevel 1 (
    echo Warning: Unable to delete alternate data streams for %1 %2.
    echo %DATE% %TIME% - Warning: Unable to delete alternate data streams for %1 %2 >>%DOWNLOAD_LOGFILE%
  ) else (
    echo %DATE% %TIME% - Info: Deleted alternate data streams for %1 %2 >>%DOWNLOAD_LOGFILE%
  )
) else (
  echo Warning: Sysinternals' NTFS alternate data stream handling tool ..\bin\streams.exe not found.
  echo %DATE% %TIME% - Warning: Sysinternals' NTFS alternate data stream handling tool ..\bin\streams.exe not found >>%DOWNLOAD_LOGFILE%
)
if "%VERIFY_DOWNLOADS%"=="1" (
  rem *** Verifying digital file signatures for %1 %2 ***
  if not exist ..\bin\sigcheck.exe goto NoSigCheck
  echo Verifying digital file signatures for %1 %2...
  ..\bin\sigcheck.exe -accepteula -q -s -u -v ..\client\%1\%2 >"%TEMP%\sigcheck-%1-%2.txt"
  for /F "usebackq eol=N skip=1 tokens=1 delims=," %%i in ("%TEMP%\sigcheck-%1-%2.txt") do (
    echo Warning: File %%i is unsigned.
    echo %DATE% %TIME% - Warning: File %%i is unsigned >>%DOWNLOAD_LOGFILE%
  ) 
  if exist "%TEMP%\sigcheck-%1-%2.txt" del "%TEMP%\sigcheck-%1-%2.txt"
  echo %DATE% %TIME% - Info: Verified digital file signatures for %1 %2 >>%DOWNLOAD_LOGFILE%
  rem *** Create integrity database for %1 %2 ***
  if not exist ..\client\bin\hashdeep.exe goto NoHashDeep
  echo Creating integrity database for %1 %2...
  if not exist ..\client\md\nul md ..\client\md
  pushd ..\client\md
  ..\bin\hashdeep.exe -c md5,sha256 -l -r ..\%1\%2 >hashes-%1-%2.txt
  if errorlevel 1 (
    popd
    echo Warning: Error creating integrity database ..\client\md\hashes-%1-%2.txt.
    echo %DATE% %TIME% - Warning: Error creating integrity database ..\client\md\hashes-%1-%2.txt >>%DOWNLOAD_LOGFILE%
  ) else (
    popd
    for %%i in (..\client\md\hashes-%1-%2.txt) do (
      if %%~zi==0 (
        del %%i
        echo %DATE% %TIME% - Info: Deleted zero size integrity database for %1 %2 >>%DOWNLOAD_LOGFILE%
      ) else (
        echo %DATE% %TIME% - Info: Created integrity database for %1 %2 >>%DOWNLOAD_LOGFILE%
      )
    )
  )
) else (
  if exist ..\client\md\hashes-%1-%2.txt (
    del ..\client\md\hashes-%1-%2.txt 
    echo %DATE% %TIME% - Info: Deleted integrity database for %1 %2 >>%DOWNLOAD_LOGFILE%
  )
)

:EndDownload
if exist "%TEMP%\ValidStaticLinks-%1-%2.txt" del "%TEMP%\ValidStaticLinks-%1-%2.txt"
if exist "%TEMP%\ValidDownloadLinks-%1-%2.txt" del "%TEMP%\ValidDownloadLinks-%1-%2.txt"
if exist "%TEMP%\ValidDownloadLinks-%1-%2.csv" del "%TEMP%\ValidDownloadLinks-%1-%2.csv"
goto :eof

:RemindDate
rem *** Remind build date ***
echo Reminding build date...
date /T >..\client\builddate.txt
goto EoF

:NoExtensions
echo.
echo ERROR: No command extensions available.
echo.
exit /b 1

:InvalidParams
echo.
echo ERROR: Invalid parameter: %1 %2 %3 %4
echo Usage1: %~n0 {w2k ^| wxp ^| w2k3 ^| w2k3-x64 ^| oxp ^| o2k3 ^| o2k7 ^| o2k7-x64} {enu ^| fra ^| esn ^| jpn ^| kor ^| rus ^| ptg ^| ptb ^| deu ^| nld ^| ita ^| chs ^| cht ^| plk ^| hun ^| csy ^| sve ^| trk ^| ell ^| ara ^| heb ^| dan ^| nor ^| fin} [/excludesp ^| /excludestatics] [/includedotnet] [/nocleanup] [/verify] [/proxy http://[username:password@]^<server^>:^<port^>] [/wsus http://^<server^>]
echo Usage2: %~n0 {w60 ^| w60-x64 ^| w61 ^| w61-x64} {glb} [/excludesp ^| /excludestatics] [/includedotnet] [/nocleanup] [/verify] [/proxy http://[username:password@]^<server^>:^<port^>] [/wsus http://^<server^>]
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
echo ERROR: Download utility %WGET_PATH% not found.
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
echo ERROR: File %REG_PATH% has version %REG_VER_MAJOR%.%REG_VER_MINOR%,
echo which is incompatible with Windows 2000 target systems.
echo Please manually copy that file from a Windows 2000 or XP system
echo to the directory ..\client\bin.
echo %DATE% %TIME% - Error: File %REG_PATH% has incompatible version %REG_VER_MAJOR%.%REG_VER_MINOR% >>%DOWNLOAD_LOGFILE%
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
echo ERROR: Microsoft XSL processor frontend ..\bin\msxsl.exe not found.
echo %DATE% %TIME% - Error: Microsoft XSL processor frontend ..\bin\msxsl.exe not found >>%DOWNLOAD_LOGFILE%
echo.
goto Error

:NoHashDeep
echo.
echo ERROR: Hash computing/auditing utility ..\client\bin\hashdeep.exe not found.
echo %DATE% %TIME% - Error: Hash computing/auditing utility ..\client\bin\hashdeep.exe not found >>%DOWNLOAD_LOGFILE%
echo.
goto Error

:NoSigCheck
echo.
echo ERROR: Sysinternals' digital file signature verification tool ..\bin\sigcheck.exe not found.
echo %DATE% %TIME% - Error: Sysinternals' digital file signature verification tool ..\bin\sigcheck.exe not found >>%DOWNLOAD_LOGFILE%
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
rem *** Execute custom finalization hook ***
if exist .\custom\FinalizationHook.cmd (
  echo Executing custom finalization hook...
  call .\custom\FinalizationHook.cmd
  echo %DATE% %TIME% - Info: Executed custom finalization hook >>%DOWNLOAD_LOGFILE%
)
echo Done.
echo %DATE% %TIME% - Info: Ending download for %1 %2 >>%DOWNLOAD_LOGFILE%
title %ComSpec%
endlocal
