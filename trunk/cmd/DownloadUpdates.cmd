@echo off
rem *** Author: T. Wittrock, Kiel ***

verify other 2>nul
setlocal enableextensions enabledelayedexpansion
if errorlevel 1 goto NoExtensions

if "%DIRCMD%" NEQ "" set DIRCMD=

cd /D "%~dp0"

set WSUSOFFLINE_VERSION=11.4+ (r972)
title %~n0 %1 %2 %3 %4 %5 %6 %7 %8 %9
echo Starting WSUS Offline Update download (v. %WSUSOFFLINE_VERSION%) for %1 %2...
set DOWNLOAD_LOGFILE=..\log\download.log
rem *** Execute custom initialization hook ***
if exist .\custom\InitializationHook.cmd (
  echo Executing custom initialization hook...
  pushd .\custom
  call InitializationHook.cmd
  set ERR_LEVEL=%errorlevel%
  popd
)
if exist %DOWNLOAD_LOGFILE% (
  echo.>>%DOWNLOAD_LOGFILE%
  echo -------------------------------------------------------------------------------->>%DOWNLOAD_LOGFILE%
  echo.>>%DOWNLOAD_LOGFILE%
)
if exist .\custom\InitializationHook.cmd (
  echo %DATE% %TIME% - Info: Executed custom initialization hook ^(Errorlevel: %ERR_LEVEL%^)>>%DOWNLOAD_LOGFILE%
  set ERR_LEVEL=
)
echo %DATE% %TIME% - Info: Starting WSUS Offline Update download (v. %WSUSOFFLINE_VERSION%) for %1 %2>>%DOWNLOAD_LOGFILE%
for %%i in (w60 w60-x64 w61 w61-x64 w62-x64 w63 w63-x64 w100 w100-x64 ofc o2k16) do (
  if /i "%1"=="%%i" (
    if /i "%2"=="glb" goto EvalParams
  )
)
for %%i in (o2k10 o2k13) do (
  if /i "%1"=="%%i" (
    for %%j in (enu fra esn jpn kor rus ptg ptb deu nld ita chs cht plk hun csy sve trk ell ara heb dan nor fin) do (if /i "%2"=="%%j" goto Lang_%%j)
  )
)
goto InvalidParams

:Lang_enu
set LANG_SHORT=en
goto EvalParams

:Lang_fra
set LANG_SHORT=fr
goto EvalParams

:Lang_esn
set LANG_SHORT=es
goto EvalParams

:Lang_jpn
set LANG_SHORT=ja
goto EvalParams

:Lang_kor
set LANG_SHORT=ko
goto EvalParams

:Lang_rus
set LANG_SHORT=ru
goto EvalParams

:Lang_ptg
set LANG_SHORT=pt
goto EvalParams

:Lang_ptb
set LANG_SHORT=pt-br
goto EvalParams

:Lang_deu
set LANG_SHORT=de
goto EvalParams

:Lang_nld
set LANG_SHORT=nl
goto EvalParams

:Lang_ita
set LANG_SHORT=it
goto EvalParams

:Lang_chs
set LANG_SHORT=zh-cn
goto EvalParams

:Lang_cht
set LANG_SHORT=zh-tw
goto EvalParams

:Lang_plk
set LANG_SHORT=pl
goto EvalParams

:Lang_hun
set LANG_SHORT=hu
goto EvalParams

:Lang_csy
set LANG_SHORT=cs
goto EvalParams

:Lang_sve
set LANG_SHORT=sv
goto EvalParams

:Lang_trk
set LANG_SHORT=tr
goto EvalParams

:Lang_ell
set LANG_SHORT=el
goto EvalParams

:Lang_ara
set LANG_SHORT=ar
goto EvalParams

:Lang_heb
set LANG_SHORT=he
goto EvalParams

:Lang_dan
set LANG_SHORT=da
goto EvalParams

:Lang_nor
set LANG_SHORT=no
goto EvalParams

:Lang_fin
set LANG_SHORT=fi
goto EvalParams

:EvalParams
if "%3"=="" goto NoMoreParams
for %%i in (/excludesp /excludestatics /excludewinglb /includedotnet /seconly /includemsse /includewddefs /nocleanup /verify /exitonerror /skipsdd /skiptz /skipdownload /skipdynamic /proxy /wsus /wsusonly /wsusbyproxy) do (
  if /i "%3"=="%%i" echo %DATE% %TIME% - Info: Option %%i detected>>%DOWNLOAD_LOGFILE%
)
if /i "%3"=="/excludesp" set EXC_SP=1
if /i "%3"=="/excludestatics" set EXC_STATICS=1
if /i "%3"=="/excludewinglb" set EXC_WINGLB=1
if /i "%3"=="/includedotnet" set INC_DOTNET=1
if /i "%3"=="/seconly" set SECONLY=1
if /i "%3"=="/includemsse" set INC_MSSE=1
if /i "%3"=="/includewddefs" (
  echo %1 | %SystemRoot%\System32\find.exe /I "w62" >nul 2>&1
  if errorlevel 1 (
    echo %1 | %SystemRoot%\System32\find.exe /I "w63" >nul 2>&1
    if errorlevel 1 (
      echo %1 | %SystemRoot%\System32\find.exe /I "w100" >nul 2>&1
      if errorlevel 1 (set INC_WDDEFS=1) else (set INC_MSSE=1)
    ) else (set INC_MSSE=1)
  )
)
if /i "%3"=="/nocleanup" set CLEANUP_DL=0
if /i "%3"=="/verify" set VERIFY_DL=1
if /i "%3"=="/exitonerror" set EXIT_ERR=1
if /i "%3"=="/skipsdd" set SKIP_SDD=1
if /i "%3"=="/skiptz" set SKIP_TZ=1
if /i "%3"=="/skipdownload" (
  set SKIP_DL=1
  set SKIP_PARAM=/skipdownload
)
if /i "%3"=="/skipdynamic" (if "%SKIP_PARAM%"=="" set SKIP_PARAM=/skipdynamic)
if /i "%3"=="/proxy" (
  set http_proxy=%4
  shift /3
)
if /i "%3"=="/wsus" (
  set WSUS_URL=%4
  shift /3
)
if /i "%3"=="/wsusonly" set WSUS_ONLY=1
if /i "%3"=="/wsusbyproxy" set WSUS_BY_PROXY=1
shift /3
goto EvalParams

:NoMoreParams
echo %1 | %SystemRoot%\System32\find.exe /I "x64" >nul 2>&1
if errorlevel 1 (set TARGET_ARCH=x86) else (set TARGET_ARCH=x64)
if "%SKIP_TZ%"=="1" goto SkipTZ
for /F "tokens=3" %%i in ('%SystemRoot%\System32\reg.exe QUERY HKLM\SYSTEM\CurrentControlSet\Control\TimeZoneInformation /v ActiveTimeBias ^| %SystemRoot%\System32\find.exe /I "ActiveTimeBias"') do set TZAB=%%i
set TZAB=0000000!TZAB:~2!
set TZAB=!TZAB:~-8!
set /A TZ=(0x!TZAB:~0,4!^<^<16^|0x!TZAB:~-4!)/60, TZ_MIN=(0x!TZAB:~0,4!^<^<16^|0x!TZAB:~-4!)-(TZ*60)
set TZ_MIN=0!TZ_MIN!
set TZ=LOC!TZ!:!TZ_MIN:~-2!
set TZ_MIN=
set TZAB=
echo %DATE% %TIME% - Info: Set time zone to !TZ!>>%DOWNLOAD_LOGFILE%
:SkipTZ
if "%TEMP%"=="" goto NoTemp
pushd "%TEMP%"
if errorlevel 1 goto NoTempDir
popd
if exist ..\doc\history.txt (
  echo Checking for sufficient file system rights...
  ren ..\doc\history.txt _history.txt
  if errorlevel 1 (
    echo.
    echo ERROR: Unable to rename file ..\doc\history.txt
    goto InsufficientRights
  )
  ren ..\doc\_history.txt history.txt
)
set CSCRIPT_PATH=%SystemRoot%\System32\cscript.exe
if not exist %CSCRIPT_PATH% goto NoCScript
if exist custom\SetAria2EnvVars.cmd (
  call ActivateAria2Downloads.cmd /reload
  call custom\SetAria2EnvVars.cmd
) else (
  if /i "%PROCESSOR_ARCHITECTURE%"=="AMD64" (set DLDR_PATH=..\bin\wget64.exe) else (
    if /i "%PROCESSOR_ARCHITEW6432%"=="AMD64" (set DLDR_PATH=..\bin\wget64.exe) else (set DLDR_PATH=..\bin\wget.exe)
  )
  set DLDR_COPT=-N --progress=bar:noscroll
  set DLDR_LOPT=-a %DOWNLOAD_LOGFILE%
  set DLDR_IOPT=-i
  set DLDR_POPT=-P
  set DLDR_NVOPT=-nv
)
if not exist %DLDR_PATH% goto NoDLdr
if not exist ..\bin\unzip.exe goto NoUnZip
if not exist ..\client\bin\unzip.exe copy ..\bin\unzip.exe ..\client\bin >nul
if /i "%PROCESSOR_ARCHITECTURE%"=="AMD64" (set HASHDEEP_EXE=hashdeep64.exe) else (
  if /i "%PROCESSOR_ARCHITEW6432%"=="AMD64" (set HASHDEEP_EXE=hashdeep64.exe) else (set HASHDEEP_EXE=hashdeep.exe)
)

rem *** Clean up existing directories ***
echo Cleaning up existing directories...
if exist ..\iso\dummy.txt del ..\iso\dummy.txt
if exist ..\log\dummy.txt del ..\log\dummy.txt
if exist ..\exclude\custom\dummy.txt del ..\exclude\custom\dummy.txt
if exist ..\static\custom\dummy.txt del ..\static\custom\dummy.txt
if exist ..\client\exclude\custom\dummy.txt del ..\client\exclude\custom\dummy.txt
if exist ..\client\static\custom\dummy.txt del ..\client\static\custom\dummy.txt
if exist ..\client\software\msi\dummy.txt del ..\client\software\msi\dummy.txt
if exist .\custom\InitializationHook.cmd (
  if exist .\custom\InitializationHook.cmdt del .\custom\InitializationHook.cmdt
)
if exist .\custom\FinalizationHook.cmd (
  if exist .\custom\FinalizationHook.cmdt del .\custom\FinalizationHook.cmdt
)
if exist ..\client\cmd\custom\InitializationHook.cmd (
  if exist ..\client\cmd\custom\InitializationHook.cmdt del ..\client\cmd\custom\InitializationHook.cmdt
)
if exist ..\client\cmd\custom\FinalizationHook.cmd (
  if exist ..\client\cmd\custom\FinalizationHook.cmdt del ..\client\cmd\custom\FinalizationHook.cmdt
)
if exist ..\client\cmd\custom\SetUpdatesPerStage.cmd (
  if exist ..\client\cmd\custom\SetUpdatesPerStage.cmdt del ..\client\cmd\custom\SetUpdatesPerStage.cmdt
)
if exist ..\client\software\custom\InstallCustomSoftware.cmd (
  if exist ..\client\software\custom\InstallCustomSoftware.cmdt del ..\client\software\custom\InstallCustomSoftware.cmdt
)
if exist .\--no-proxy\nul rd /S /Q .\--no-proxy

rem *** Obsolete internal stuff ***
if exist ActivateVistaAllLanguageServicePacks.cmd del ActivateVistaAllLanguageServicePacks.cmd
if exist ActivateVistaFiveLanguageServicePacks.cmd del ActivateVistaFiveLanguageServicePacks.cmd
if exist DetermineAutoDaylightTimeSet.vbs del DetermineAutoDaylightTimeSet.vbs
if exist ExtractUniqueFromSorted.vbs del ExtractUniqueFromSorted.vbs
if exist CheckTRCerts.cmd del CheckTRCerts.cmd
if exist ..\doc\faq.txt del ..\doc\faq.txt
if exist ..\client\cmd\Reboot.vbs del ..\client\cmd\Reboot.vbs
if exist ..\client\cmd\Shutdown.vbs del ..\client\cmd\Shutdown.vbs
if exist ..\client\msi\nul rd /S /Q ..\client\msi
if exist ..\client\static\StaticUpdateIds-ie9-w61.txt del ..\client\static\StaticUpdateIds-ie9-w61.txt
if exist ..\client\static\StaticUpdateIds-w100-x86.txt del ..\client\static\StaticUpdateIds-w100-x86.txt
if exist ..\client\static\StaticUpdateIds-w100-x64.txt del ..\client\static\StaticUpdateIds-w100-x64.txt
if exist ..\xslt\ExtractDownloadLinks-wua-x86.xsl del ..\xslt\ExtractDownloadLinks-wua-x86.xsl
if exist ..\xslt\ExtractDownloadLinks-wua-x64.xsl del ..\xslt\ExtractDownloadLinks-wua-x64.xsl
if exist ..\xslt\ExtractBundledUpdateRelationsAndFileIds.xsl del ..\xslt\ExtractBundledUpdateRelationsAndFileIds.xsl
del /Q ..\xslt\*-win-x86-*.* >nul 2>&1

rem *** Obsolete external stuff ***
if exist ..\bin\extract.exe del ..\bin\extract.exe
if exist ..\bin\fciv.exe del ..\bin\fciv.exe
if exist ..\bin\msxsl.exe del ..\bin\msxsl.exe
if exist ..\sh\hashdeep del ..\sh\hashdeep
if exist ..\fciv\nul rd /S /Q ..\fciv
if exist ..\static\StaticDownloadLink-extract.txt del ..\static\StaticDownloadLink-extract.txt
if exist ..\static\StaticDownloadLink-fciv.txt del ..\static\StaticDownloadLink-fciv.txt
if exist ..\static\StaticDownloadLink-msxsl.txt del ..\static\StaticDownloadLink-msxsl.txt
if exist ..\static\StaticDownloadLink-sigcheck.txt del ..\static\StaticDownloadLink-sigcheck.txt
if exist ..\static\StaticDownloadLink-streams.txt del ..\static\StaticDownloadLink-streams.txt
if exist ..\static\StaticDownloadLinks-mkisofs.txt del ..\static\StaticDownloadLinks-mkisofs.txt
if exist ..\static\StaticDownloadLink-unzip.txt del ..\static\StaticDownloadLink-unzip.txt

rem *** Windows 2000 stuff ***
if exist ..\client\bin\reg.exe del ..\client\bin\reg.exe
if exist ..\client\static\StaticUpdateIds-w2k-x86.txt del ..\client\static\StaticUpdateIds-w2k-x86.txt
if exist FixIE6SetupDir.cmd del FixIE6SetupDir.cmd
for %%i in (enu fra esn jpn kor rus ptg ptb deu nld ita chs cht plk hun csy sve trk ell ara heb dan nor fin) do (
  if exist ..\client\win\%%i\ie6setup\nul rd /S /Q ..\client\win\%%i\ie6setup
)
if exist ..\exclude\ExcludeList-w2k-x86.txt del ..\exclude\ExcludeList-w2k-x86.txt
if exist ..\exclude\ExcludeListISO-w2k-x86.txt del ..\exclude\ExcludeListISO-w2k-x86.txt
if exist ..\exclude\ExcludeListUSB-w2k-x86.txt del ..\exclude\ExcludeListUSB-w2k-x86.txt
if exist ..\sh\FIXIE6SetupDir.sh del ..\sh\FIXIE6SetupDir.sh
del /Q ..\static\*ie6-*.* >nul 2>&1
del /Q ..\static\*w2k-*.* >nul 2>&1
del /Q ..\xslt\*w2k-*.* >nul 2>&1

rem *** Windows XP stuff ***
if exist ..\client\static\StaticUpdateIds-wxp-x86.txt del ..\client\static\StaticUpdateIds-wxp-x86.txt
if exist ..\exclude\ExcludeList-wxp-x86.txt del ..\exclude\ExcludeList-wxp-x86.txt
if exist ..\exclude\ExcludeListISO-wxp-x86.txt del ..\exclude\ExcludeListISO-wxp-x86.txt
if exist ..\exclude\ExcludeListUSB-wxp-x86.txt del ..\exclude\ExcludeListUSB-wxp-x86.txt
del /Q ..\static\*-wxp-x86-*.* >nul 2>&1
del /Q ..\xslt\*-wxp-x86-*.* >nul 2>&1

rem *** Windows Server 2003 stuff ***
if exist ..\client\static\StaticUpdateIds-w2k3-x86.txt del ..\client\static\StaticUpdateIds-w2k3-x86.txt
if exist ..\client\static\StaticUpdateIds-w2k3-x64.txt del ..\client\static\StaticUpdateIds-w2k3-x64.txt
if exist ..\exclude\ExcludeList-w2k3-x86.txt del ..\exclude\ExcludeList-w2k3-x86.txt
if exist ..\exclude\ExcludeList-w2k3-x64.txt del ..\exclude\ExcludeList-w2k3-x64.txt
if exist ..\exclude\ExcludeListISO-w2k3-x86.txt del ..\exclude\ExcludeListISO-w2k3-x86.txt
if exist ..\exclude\ExcludeListISO-w2k3-x64.txt del ..\exclude\ExcludeListISO-w2k3-x64.txt
if exist ..\exclude\ExcludeListUSB-w2k3-x86.txt del ..\exclude\ExcludeListUSB-w2k3-x86.txt
if exist ..\exclude\ExcludeListUSB-w2k3-x64.txt del ..\exclude\ExcludeListUSB-w2k3-x64.txt
del /Q ..\static\*-w2k3-*.* >nul 2>&1
del /Q ..\xslt\*-w2k3-*.* >nul 2>&1

rem *** Windows language specific stuff ***
del /Q ..\static\*-win-x86-*.* >nul 2>&1

rem *** Windows 8 stuff ***
if exist ..\client\static\StaticUpdateIds-w62-x86.txt del ..\client\static\StaticUpdateIds-w62-x86.txt
if exist ..\exclude\ExcludeList-w62-x86.txt del ..\exclude\ExcludeList-w62-x86.txt
if exist ..\exclude\ExcludeListISO-w62-x86.txt del ..\exclude\ExcludeListISO-w62-x86.txt
if exist ..\exclude\ExcludeListUSB-w62-x86.txt del ..\exclude\ExcludeListUSB-w62-x86.txt
if exist ..\static\StaticDownloadLinks-w62-x86-glb.txt del ..\static\StaticDownloadLinks-w62-x86-glb.txt
if exist ..\xslt\ExtractDownloadLinks-w62-x86-glb.xsl del ..\xslt\ExtractDownloadLinks-w62-x86-glb.xsl

rem *** Windows 10 Version 1511 stuff ***
if exist ..\client\static\StaticUpdateIds-w100-10586-x64.txt del ..\client\static\StaticUpdateIds-w100-10586-x64.txt
if exist ..\client\static\StaticUpdateIds-w100-10586-x86.txt del ..\client\static\StaticUpdateIds-w100-10586-x86.txt

rem *** Office and invcif.exe stuff ***
if exist ..\static\StaticDownloadLinks-inventory.txt del ..\static\StaticDownloadLinks-inventory.txt
if exist ..\client\wsus\invcif.exe (
  if exist ..\client\md\hashes-wsus.txt del ..\client\md\hashes-wsus.txt
  del ..\client\wsus\invcif.exe
)
if exist ..\client\wsus\invcm.exe (
  if exist ..\client\md\hashes-wsus.txt del ..\client\md\hashes-wsus.txt
  del ..\client\wsus\invcm.exe
)
if exist ..\client\static\StaticUpdateIds-o2k7-x*.txt del ..\client\static\StaticUpdateIds-o2k7-x*.txt
if exist ..\ExtractDownloadLinks-oall.cmd del ..\ExtractDownloadLinks-oall.cmd
if exist ..\ExtractDownloadLinks-wall.cmd del ..\ExtractDownloadLinks-wall.cmd
if exist ..\static\StaticDownloadLinks-o2k7-x*.txt del ..\static\StaticDownloadLinks-o2k7-x*.txt
if exist ..\xslt\ExtractDownloadLinks-oall-deu.xsl del ..\xslt\ExtractDownloadLinks-oall-deu.xsl
if exist ..\xslt\ExtractDownloadLinks-oall-enu.xsl del ..\xslt\ExtractDownloadLinks-oall-enu.xsl
if exist ..\xslt\ExtractDownloadLinks-oall-fra.xsl del ..\xslt\ExtractDownloadLinks-oall-fra.xsl
if exist ..\xslt\ExtractDownloadLinks-wall.xsl del ..\xslt\ExtractDownloadLinks-wall.xsl
del /Q ..\exclude\ExcludeList*-oxp.txt >nul 2>&1
del /Q ..\exclude\ExcludeList*-o2k3.txt >nul 2>&1
del /Q ..\exclude\ExcludeList*-o2k7*.txt >nul 2>&1
del /Q ..\exclude\ExcludeList*-o2k10.txt >nul 2>&1
del /Q ..\xslt\ExtractDownloadLinks-o*.* >nul 2>&1
del /Q ..\xslt\ExtractExpiredIds-o*.* >nul 2>&1
del /Q ..\xslt\ExtractValidIds-o*.* >nul 2>&1

rem *** Office 2000 stuff ***
if exist ..\client\bin\msxsl.exe del ..\client\bin\msxsl.exe
if exist ..\client\xslt\nul rd /S /Q ..\client\xslt
if exist ..\client\static\StaticUpdateIds-o2k.txt del ..\client\static\StaticUpdateIds-o2k.txt
del /Q ..\exclude\ExcludeList*-o2k.txt >nul 2>&1
del /Q ..\static\*o2k-*.* >nul 2>&1
del /Q ..\xslt\*o2k-*.* >nul 2>&1
if exist ..\xslt\ExtractExpiredIds-o2k.xsl del ..\xslt\ExtractExpiredIds-o2k.xsl
if exist ..\xslt\ExtractValidIds-o2k.xsl del ..\xslt\ExtractValidIds-o2k.xsl

rem *** Office XP stuff ***
if exist ..\client\static\StaticUpdateIds-oxp.txt del ..\client\static\StaticUpdateIds-oxp.txt
del /Q ..\static\*oxp-*.* >nul 2>&1

rem *** Office 2003 stuff ***
if exist ..\client\static\StaticUpdateIds-o2k3.txt del ..\client\static\StaticUpdateIds-o2k3.txt
del /Q ..\static\*o2k3-*.* >nul 2>&1

rem *** Office 2007 stuff ***
if exist ..\client\static\StaticUpdateIds-o2k7.txt del ..\client\static\StaticUpdateIds-o2k7.txt
del /Q ..\static\*o2k7-*.* >nul 2>&1

rem *** CPP restructuring stuff ***
if exist ..\client\md\hashes-cpp-x64-glb.txt del ..\client\md\hashes-cpp-x64-glb.txt
if exist ..\client\cpp\x64-glb\nul (
  move /Y ..\client\cpp\x64-glb\*.* ..\client\cpp >nul
  rd /S /Q ..\client\cpp\x64-glb
)
if exist ..\client\md\hashes-cpp-x86-glb.txt del ..\client\md\hashes-cpp-x86-glb.txt
if exist ..\client\cpp\x86-glb\nul (
  move /Y ..\client\cpp\x86-glb\*.* ..\client\cpp >nul
  rd /S /Q ..\client\cpp\x86-glb
)

rem *** .NET restructuring stuff ***
if exist ..\exclude\ExcludeList-dotnet.txt del ..\exclude\ExcludeList-dotnet.txt
if exist ..\client\win\glb\ndp*.* (
  if not exist ..\client\dotnet\x86-glb\nul md ..\client\dotnet\x86-glb
  move /Y ..\client\win\glb\ndp*.* ..\client\dotnet\x86-glb >nul
)
if exist ..\static\StaticDownloadLink-dotnet.txt del ..\static\StaticDownloadLink-dotnet.txt
if exist ..\xslt\ExtractDownloadLinks-dotnet-glb.xsl del ..\xslt\ExtractDownloadLinks-dotnet-glb.xsl
if exist ..\client\static\StaticUpdateIds-dotnet.txt del ..\client\static\StaticUpdateIds-dotnet.txt
if exist ..\client\dotnet\glb\nul (
  if not exist ..\client\dotnet\x64-glb\nul md ..\client\dotnet\x64-glb
  move /Y ..\client\dotnet\glb\*-x64_*.* ..\client\dotnet\x64-glb >nul
  if not exist ..\client\dotnet\x86-glb\nul md ..\client\dotnet\x86-glb
  move /Y ..\client\dotnet\glb\*-x86_*.* ..\client\dotnet\x86-glb >nul
  rd /S /Q ..\client\dotnet\glb
)

rem *** Microsoft Security Essentials stuff ***
if exist ..\static\StaticDownloadLink-mssedefs-x64.txt del ..\static\StaticDownloadLink-mssedefs-x64.txt
if exist ..\static\StaticDownloadLink-mssedefs-x86.txt del ..\static\StaticDownloadLink-mssedefs-x86.txt
if exist ..\static\StaticDownloadLink-mssedefs-x64-glb.txt del ..\static\StaticDownloadLink-mssedefs-x64-glb.txt
if exist ..\static\StaticDownloadLink-mssedefs-x86-glb.txt del ..\static\StaticDownloadLink-mssedefs-x86-glb.txt
if exist ..\client\mssedefs\x64\nul (
  if not exist ..\client\mssedefs\x64-glb\nul md ..\client\mssedefs\x64-glb
  move /Y ..\client\mssedefs\x64\*.* ..\client\mssedefs\x64-glb >nul
  rd /S /Q ..\client\mssedefs\x64
)
if exist ..\client\mssedefs\x86\nul (
  if not exist ..\client\mssedefs\x86-glb\nul md ..\client\mssedefs\x86-glb
  move /Y ..\client\mssedefs\x86\*.* ..\client\mssedefs\x86-glb >nul
  rd /S /Q ..\client\mssedefs\x86
)
if exist ..\client\mssedefs\nul move /Y ..\client\mssedefs msse >nul
if exist ..\client\md\hashes-mssedefs.txt del ..\client\md\hashes-mssedefs.txt

rem *** Windows Update Agent stuff ***
if exist ..\client\wsus\WindowsUpdateAgent30-x64.exe (
  del ..\client\wsus\WindowsUpdateAgent30-x64.exe
  if exist ..\client\md\hashes-wsus.txt del ..\client\md\hashes-wsus.txt
)
if exist ..\client\wsus\WindowsUpdateAgent30-x86.exe (
  del ..\client\wsus\WindowsUpdateAgent30-x86.exe
  if exist ..\client\md\hashes-wsus.txt del ..\client\md\hashes-wsus.txt
)

rem *** Windows Essentials 2012 stuff ***
del /Q ..\static\StaticDownloadLinks-wle-*.txt >nul 2>&1
del /Q ..\static\custom\StaticDownloadLinks-wle-*.txt >nul 2>&1
if exist ..\exclude\ExcludeList-wle.txt del ..\exclude\ExcludeList-wle.txt
if exist ..\client\wle\nul rd /S /Q ..\client\wle
if exist ..\client\md\hashes-wle.txt del ..\client\md\hashes-wle.txt

rem *** Update static download definitions ***
if "%SKIP_SDD%"=="1" goto SkipSDD
echo Preserving custom language and architecture additions and removals...
set REMOVE_CMD=
%SystemRoot%\System32\find.exe /I "us." ..\static\StaticDownloadLinks-w61-x86-glb.txt >nul 2>&1
if errorlevel 1 (
  set REMOVE_CMD=RemoveEnglishLanguageSupport.cmd !REMOVE_CMD!
)
%SystemRoot%\System32\find.exe /I "de." ..\static\StaticDownloadLinks-w61-x86-glb.txt >nul 2>&1
if errorlevel 1 (
  set REMOVE_CMD=RemoveGermanLanguageSupport.cmd !REMOVE_CMD!
)
set CUST_LANG=
if exist ..\static\custom\StaticDownloadLinks-dotnet.txt (
  for %%i in (fra esn jpn kor rus ptg ptb nld ita chs cht plk hun csy sve trk ell ara heb dan nor fin) do (
    %SystemRoot%\System32\find.exe /I "%%i" ..\static\custom\StaticDownloadLinks-dotnet.txt >nul 2>&1
    if not errorlevel 1 (
      set CUST_LANG=%%i !CUST_LANG!
      call RemoveCustomLanguageSupport.cmd %%i /quiet
    )
  )
)
set OX64_LANG=
for %%i in (enu fra esn jpn kor rus ptg ptb deu nld ita chs cht plk hun csy sve trk ell ara heb dan nor fin) do (
  if exist ..\static\custom\StaticDownloadLinks-o2k13-%%i.txt (
    set OX64_LANG=%%i !OX64_LANG!
    call RemoveOffice2010x64Support.cmd %%i /quiet
  )
)
echo %DATE% %TIME% - Info: Preserved custom language and architecture additions and removals>>%DOWNLOAD_LOGFILE%

echo Updating static and exclude definitions for download and update...
%DLDR_PATH% %DLDR_COPT% %DLDR_NVOPT% %DLDR_POPT% ..\static %DLDR_LOPT% http://download.wsusoffline.net/StaticDownloadFiles-modified.txt
%DLDR_PATH% %DLDR_COPT% %DLDR_IOPT% ..\static\StaticDownloadFiles-modified.txt %DLDR_POPT% ..\static
%DLDR_PATH% %DLDR_COPT% %DLDR_NVOPT% %DLDR_POPT% ..\exclude %DLDR_LOPT% http://download.wsusoffline.net/ExcludeDownloadFiles-modified.txt
%DLDR_PATH% %DLDR_COPT% %DLDR_IOPT% ..\exclude\ExcludeDownloadFiles-modified.txt %DLDR_POPT% ..\exclude
%DLDR_PATH% %DLDR_COPT% %DLDR_NVOPT% %DLDR_POPT% ..\client\static %DLDR_LOPT% http://download.wsusoffline.net/StaticUpdateFiles-modified.txt
%DLDR_PATH% %DLDR_COPT% %DLDR_IOPT% ..\client\static\StaticUpdateFiles-modified.txt %DLDR_POPT% ..\client\static
echo %DATE% %TIME% - Info: Updated static and exclude definitions for download and update>>%DOWNLOAD_LOGFILE%

echo Restoring custom language and architecture additions and removals...
if "%REMOVE_CMD%" NEQ "" (
  for %%i in (%REMOVE_CMD%) do call %%i /quiet
)
if "%CUST_LANG%" NEQ "" (
  for %%i in (%CUST_LANG%) do call AddCustomLanguageSupport.cmd %%i /quiet
)
if "%OX64_LANG%" NEQ "" (
  for %%i in (%OX64_LANG%) do call AddOffice2010x64Support.cmd %%i /quiet
)
set REMOVE_CMD=
set CUST_LANG=
set OX64_LANG=
echo %DATE% %TIME% - Info: Restored custom language and architecture additions and removals>>%DOWNLOAD_LOGFILE%
:SkipSDD

rem *** Download mkisofs tool ***
if "%SKIP_DL%"=="1" goto SkipMkIsoFs
echo Downloading/validating mkisofs tool...
%DLDR_PATH% %DLDR_COPT% %DLDR_IOPT% ..\static\StaticDownloadLink-mkisofs.txt %DLDR_POPT% ..\bin
if errorlevel 1 (
  echo Warning: Download of mkisofs tool failed.
  echo %DATE% %TIME% - Warning: Download of mkisofs tool failed>>%DOWNLOAD_LOGFILE%
) else (
  echo %DATE% %TIME% - Info: Downloaded/validated mkisofs tool>>%DOWNLOAD_LOGFILE%
)
:SkipMkIsoFs

rem *** Download Sysinternals' tools Autologon, Sigcheck and Streams ***
if not exist ..\client\bin\Autologon.exe goto DownloadSysinternals
if not exist ..\bin\sigcheck.exe goto DownloadSysinternals
if not exist ..\bin\sigcheck64.exe goto DownloadSysinternals
if not exist ..\bin\streams.exe goto DownloadSysinternals
if not exist ..\bin\streams64.exe goto DownloadSysinternals
goto SkipSysinternals
:DownloadSysinternals
echo Downloading Sysinternals' tools Autologon, Sigcheck and Streams...
%DLDR_PATH% %DLDR_COPT% %DLDR_IOPT% ..\static\StaticDownloadLinks-sysinternals.txt %DLDR_POPT% ..\bin
if errorlevel 1 goto DownloadError
echo %DATE% %TIME% - Info: Downloaded Sysinternals' tools Autologon, Sigcheck and Streams>>%DOWNLOAD_LOGFILE%
pushd ..\bin
unzip.exe -o AutoLogon.zip Autologon.exe
del AutoLogon.zip
move /Y Autologon.exe ..\client\bin >nul
unzip.exe -o Sigcheck.zip sigcheck.exe
unzip.exe -o Sigcheck.zip sigcheck64.exe
del Sigcheck.zip
unzip.exe -o Streams.zip streams.exe
unzip.exe -o Streams.zip streams64.exe
del Streams.zip
popd
:SkipSysinternals
if /i "%PROCESSOR_ARCHITECTURE%"=="AMD64" (set SIGCHK_PATH=..\bin\sigcheck64.exe) else (
  if /i "%PROCESSOR_ARCHITEW6432%"=="AMD64" (set SIGCHK_PATH=..\bin\sigcheck64.exe) else (set SIGCHK_PATH=..\bin\sigcheck.exe)
)
if not exist %SIGCHK_PATH% goto SkipSigChkOpts
%CSCRIPT_PATH% //Nologo //B //E:vbs ..\client\cmd\DetermineFileVersion.vbs %SIGCHK_PATH% SIGCHK_VER
if exist "%TEMP%\SetFileVersion.cmd" (
  call "%TEMP%\SetFileVersion.cmd"
  del "%TEMP%\SetFileVersion.cmd"
) else (set SIGCHK_VER_MAJOR=2)
if %SIGCHK_VER_MAJOR% GEQ 2 (set SIGCHK_COPT=/accepteula -q -c -nobanner) else (set SIGCHK_COPT=/accepteula -q -v)
set SIGCHK_VER_MAJOR=
set SIGCHK_VER_MINOR=
set SIGCHK_VER_BUILD=
set SIGCHK_VER_REVIS=
:SkipSigChkOpts
if /i "%PROCESSOR_ARCHITECTURE%"=="AMD64" (set STRMS_PATH=..\bin\streams64.exe) else (
  if /i "%PROCESSOR_ARCHITEW6432%"=="AMD64" (set STRMS_PATH=..\bin\streams64.exe) else (set STRMS_PATH=..\bin\streams.exe)
)

rem *** Cleanup UpdateOU.new ***
if exist UpdateOU.new (
  if exist UpdateOU.cmd del UpdateOU.cmd
  ren UpdateOU.new UpdateOU.cmd
  rem *** Remove NTFS alternate data streams from new or updated script files ***
  if exist %STRMS_PATH% (
    %STRMS_PATH% /accepteula ..\*.* >nul 2>&1
    if errorlevel 1 (
      echo %DATE% %TIME% - Info: File system does not support streams>>%DOWNLOAD_LOGFILE%
    ) else (
      echo Removing NTFS alternate data streams from new or updated script files...
      %STRMS_PATH% /accepteula -s -d ..\*.cmd >nul 2>&1
      %STRMS_PATH% /accepteula -s -d ..\*.exe >nul 2>&1
      %STRMS_PATH% /accepteula -s -d ..\*.vbs >nul 2>&1
      if errorlevel 1 (
        echo Warning: Unable to remove NTFS alternate data streams from new or updated script files.
        echo %DATE% %TIME% - Warning: Unable to remove NTFS alternate data streams from new or updated script files>>%DOWNLOAD_LOGFILE%
      ) else (
        echo %DATE% %TIME% - Info: Removed NTFS alternate data streams from new or updated script files>>%DOWNLOAD_LOGFILE%
      )
    )
  ) else (
    echo Warning: Sysinternals' NTFS alternate data stream handling tool %STRMS_PATH% not found.
    echo %DATE% %TIME% - Warning: Sysinternals' NTFS alternate data stream handling tool %STRMS_PATH% not found>>%DOWNLOAD_LOGFILE%
  )
)

rem *** Download most recent Windows Update catalog file ***
if "%VERIFY_DL%" NEQ "1" goto DownloadWSUS
if not exist ..\client\wsus\nul goto DownloadWSUS
if not exist ..\client\bin\%HASHDEEP_EXE% goto NoHashDeep
if exist ..\client\md\hashes-wsus.txt (
  echo Verifying integrity of Windows Update catalog file...
  pushd ..\client\md
  ..\bin\%HASHDEEP_EXE% -a -l -vv -k hashes-wsus.txt -r ..\wsus
  if errorlevel 1 (
    popd
    goto IntegrityError
  )
  popd
  echo %DATE% %TIME% - Info: Verified integrity of Windows Update catalog file>>%DOWNLOAD_LOGFILE%
) else (
  echo Warning: Integrity database ..\client\md\hashes-wsus.txt not found.
  echo %DATE% %TIME% - Warning: Integrity database ..\client\md\hashes-wsus.txt not found>>%DOWNLOAD_LOGFILE%
)
:DownloadWSUS
if exist ..\client\md\hashes-wsus.txt del ..\client\md\hashes-wsus.txt
echo Downloading/validating most recent Windows Update catalog file...
if exist ..\client\wsus\wsusscn2.cab (
  copy /Y ..\client\wsus\wsusscn2.cab ..\client\wsus\wsusscn2.bak >nul
)
%DLDR_PATH% %DLDR_COPT% %DLDR_IOPT% ..\static\StaticDownloadLinks-wsus.txt %DLDR_POPT% ..\client\wsus
if errorlevel 1 goto DownloadError
echo %DATE% %TIME% - Info: Downloaded/validated most recent Windows Update catalog file>>%DOWNLOAD_LOGFILE%
if "%VERIFY_DL%" NEQ "1" goto SkipWSUS
if not exist %SIGCHK_PATH% goto NoSigCheck
echo Verifying digital file signature of Windows Update catalog file...
for /F "skip=1 tokens=1 delims=," %%i in ('%SIGCHK_PATH% %SIGCHK_COPT% -s ..\client\wsus ^| %SystemRoot%\System32\findstr.exe /I /V "\"Signed\""') do (
  del %%i
  echo Warning: Deleted unsigned file %%i.
  echo %DATE% %TIME% - Warning: Deleted unsigned file %%i>>%DOWNLOAD_LOGFILE%
)
if exist ..\client\wsus\wsusscn2.cab (
  if exist ..\client\wsus\wsusscn2.bak del ..\client\wsus\wsusscn2.bak
) else (
  if not exist ..\client\wsus\wsusscn2.bak goto SignatureError
  ren ..\client\wsus\wsusscn2.bak wsusscn2.cab
  %SystemRoot%\System32\attrib.exe -A ..\client\wsus\wsusscn2.cab
  echo %DATE% %TIME% - Info: Restored preexisting catalog file ..\client\wsus\wsusscn2.cab>>%DOWNLOAD_LOGFILE%
)
echo %DATE% %TIME% - Info: Verified digital file signature of Windows Update catalog file>>%DOWNLOAD_LOGFILE%
if not exist ..\client\bin\%HASHDEEP_EXE% goto NoHashDeep
echo Creating integrity database for Windows Update catalog file...
if not exist ..\client\md\nul md ..\client\md
pushd ..\client\md
..\bin\%HASHDEEP_EXE% -c md5,sha1,sha256 -l -r ..\wsus >hashes-wsus.txt
if errorlevel 1 (
  popd
  echo Warning: Error creating integrity database ..\client\md\hashes-wsus.txt.
  echo %DATE% %TIME% - Warning: Error creating integrity database ..\client\md\hashes-wsus.txt>>%DOWNLOAD_LOGFILE%
) else (
  popd
  echo %DATE% %TIME% - Info: Created integrity database for Windows Update catalog file>>%DOWNLOAD_LOGFILE%
)
for %%i in (..\client\md\hashes-wsus.txt) do if %%~zi==0 del %%i
:SkipWSUS

rem *** Download installation files for .NET Frameworks 3.5 SP1 and 4.x ***
if "%INC_DOTNET%" NEQ "1" goto SkipDotNet
if "%SKIP_DL%"=="1" (
  call :DownloadCore dotnet %TARGET_ARCH%-glb %TARGET_ARCH% %SKIP_PARAM%
  goto SkipDotNet
)
if "%VERIFY_DL%" NEQ "1" goto DownloadDotNet
if not exist ..\client\dotnet\nul goto DownloadDotNet
if not exist ..\client\bin\%HASHDEEP_EXE% goto NoHashDeep
if exist ..\client\md\hashes-dotnet.txt (
  echo Verifying integrity of .NET Frameworks' installation files...
  pushd ..\client\md
  ..\bin\%HASHDEEP_EXE% -a -l -vv -k hashes-dotnet.txt ..\dotnet\*.exe
  if errorlevel 1 (
    popd
    goto IntegrityError
  )
  popd
  echo %DATE% %TIME% - Info: Verified integrity of .NET Frameworks' installation files>>%DOWNLOAD_LOGFILE%
  if exist ..\client\md\hashes-dotnet-%TARGET_ARCH%-glb.txt (
    for %%i in (..\client\md\hashes-dotnet-%TARGET_ARCH%-glb.txt) do echo _%%~ti | %SystemRoot%\System32\find.exe "_%DATE:~-10%" >nul 2>&1
    if not errorlevel 1 (
      echo Skipping download/validation of .NET Frameworks' files ^(%TARGET_ARCH%^) due to 'same day' rule.
      echo %DATE% %TIME% - Info: Skipped download/validation of .NET Frameworks' files ^(%TARGET_ARCH%^) due to 'same day' rule>>%DOWNLOAD_LOGFILE%
      goto SkipDotNet
    )
  )
) else (
  echo Warning: Integrity database ..\client\md\hashes-dotnet.txt not found.
  echo %DATE% %TIME% - Warning: Integrity database ..\client\md\hashes-dotnet.txt not found>>%DOWNLOAD_LOGFILE%
)
:DownloadDotNet
if exist ..\client\md\hashes-dotnet.txt del ..\client\md\hashes-dotnet.txt
echo Downloading/validating installation files for .NET Frameworks 3.5 SP1 and 4.x...
copy /Y ..\static\StaticDownloadLinks-dotnet.txt "%TEMP%\StaticDownloadLinks-dotnet.txt" >nul
if exist ..\static\custom\StaticDownloadLinks-dotnet.txt (
  type ..\static\custom\StaticDownloadLinks-dotnet.txt >>"%TEMP%\StaticDownloadLinks-dotnet.txt"
)
%DLDR_PATH% %DLDR_COPT% %DLDR_IOPT% "%TEMP%\StaticDownloadLinks-dotnet.txt" %DLDR_POPT% ..\client\dotnet
if errorlevel 1 (
  del "%TEMP%\StaticDownloadLinks-dotnet.txt"
  goto DownloadError
)
echo %DATE% %TIME% - Info: Downloaded/validated installation files for .NET Frameworks 3.5 SP1 and 4.x>>%DOWNLOAD_LOGFILE%
call :DownloadCore dotnet %TARGET_ARCH%-glb %TARGET_ARCH% %SKIP_PARAM%
if errorlevel 1 goto Error
if "%CLEANUP_DL%"=="0" (
  del "%TEMP%\StaticDownloadLinks-dotnet.txt"
  goto VerifyDotNet
)
echo Cleaning up client directory for .NET Frameworks 3.5 SP1 and 4.x...
for /F %%i in ('dir ..\client\dotnet /A:-D /B') do (
  %SystemRoot%\System32\find.exe /I "%%i" "%TEMP%\StaticDownloadLinks-dotnet.txt" >nul 2>&1
  if errorlevel 1 (
    del ..\client\dotnet\%%i
    echo %DATE% %TIME% - Info: Deleted ..\client\dotnet\%%i>>%DOWNLOAD_LOGFILE%
  )
)
del "%TEMP%\StaticDownloadLinks-dotnet.txt"
echo %DATE% %TIME% - Info: Cleaned up client directory for .NET Frameworks 3.5 SP1 and 4.x>>%DOWNLOAD_LOGFILE%
:VerifyDotNet
if "%VERIFY_DL%" NEQ "1" goto SkipDotNet
rem *** Verifying digital file signatures for .NET Frameworks' installation files ***
if not exist %SIGCHK_PATH% goto NoSigCheck
echo Verifying digital file signatures for .NET Frameworks' installation files...
for /F "skip=1 tokens=1 delims=," %%i in ('%SIGCHK_PATH% %SIGCHK_COPT% -s ..\client\dotnet ^| %SystemRoot%\System32\findstr.exe /I /V "\"Signed\""') do (
  del %%i
  echo Warning: Deleted unsigned file %%i.
  echo %DATE% %TIME% - Warning: Deleted unsigned file %%i>>%DOWNLOAD_LOGFILE%
)
echo %DATE% %TIME% - Info: Verified digital file signatures for .NET Frameworks' installation files>>%DOWNLOAD_LOGFILE%
if not exist ..\client\bin\%HASHDEEP_EXE% goto NoHashDeep
echo Creating integrity database for .NET Frameworks' installation files...
if not exist ..\client\md\nul md ..\client\md
pushd ..\client\md
..\bin\%HASHDEEP_EXE% -c md5,sha1,sha256 -l ..\dotnet\*.exe >hashes-dotnet.txt
if errorlevel 1 (
  popd
  echo Warning: Error creating integrity database ..\client\md\hashes-dotnet.txt.
  echo %DATE% %TIME% - Warning: Error creating integrity database ..\client\md\hashes-dotnet.txt>>%DOWNLOAD_LOGFILE%
) else (
  popd
  echo %DATE% %TIME% - Info: Created integrity database for .NET Frameworks' installation files>>%DOWNLOAD_LOGFILE%
)
for %%i in (..\client\md\hashes-dotnet.txt) do if %%~zi==0 del %%i
:SkipDotNet

rem *** Download C++ Runtime Libraries' installation files ***
if "%INC_DOTNET%" NEQ "1" goto SkipCPP
if "%SKIP_DL%"=="1" goto SkipCPP
if "%VERIFY_DL%" NEQ "1" goto DownloadCPP
if not exist ..\client\cpp\nul goto DownloadCPP
if not exist ..\client\bin\%HASHDEEP_EXE% goto NoHashDeep
if exist ..\client\md\hashes-cpp.txt (
  echo Verifying integrity of C++ Runtime Libraries' installation files...
  pushd ..\client\md
  ..\bin\%HASHDEEP_EXE% -a -l -vv -k hashes-cpp.txt -r ..\cpp
  if errorlevel 1 (
    popd
    goto IntegrityError
  )
  popd
  echo %DATE% %TIME% - Info: Verified integrity of C++ Runtime Libraries' installation files>>%DOWNLOAD_LOGFILE%
  for %%i in (..\client\md\hashes-cpp.txt) do echo _%%~ti | %SystemRoot%\System32\find.exe "_%DATE:~-10%" >nul 2>&1
  if not errorlevel 1 (
    echo Skipping download/validation of C++ Runtime Libraries' installation files due to 'same day' rule.
    echo %DATE% %TIME% - Info: Skipped download/validation of C++ Runtime Libraries' installation files due to 'same day' rule>>%DOWNLOAD_LOGFILE%
    goto SkipCPP
  )
) else (
  echo Warning: Integrity database ..\client\md\hashes-cpp.txt not found.
  echo %DATE% %TIME% - Warning: Integrity database ..\client\md\hashes-cpp.txt not found>>%DOWNLOAD_LOGFILE%
)
:DownloadCPP
if exist ..\client\md\hashes-cpp.txt del ..\client\md\hashes-cpp.txt
echo Downloading/validating C++ Runtime Libraries' installation files...
for %%i in (x64 x86) do (
  for /F "tokens=1,2 delims=," %%j in (..\static\StaticDownloadLinks-cpp-%%i-glb.txt) do (
    if "%%k" NEQ "" (
      if exist ..\client\cpp\%%k (
        echo Renaming file ..\client\cpp\%%k to %%~nxj...
        if exist ..\client\cpp\%%~nxj del ..\client\cpp\%%~nxj
        ren ..\client\cpp\%%k %%~nxj
        echo %DATE% %TIME% - Info: Renamed file ..\client\cpp\%%k to %%~nxj>>%DOWNLOAD_LOGFILE%
      )
    )
    %DLDR_PATH% %DLDR_COPT% %DLDR_POPT% ..\client\cpp %%j
    if errorlevel 1 (
      if exist ..\client\cpp\%%~nxj del ..\client\cpp\%%~nxj
      echo Warning: Download of %%j failed.
      echo %DATE% %TIME% - Warning: Download of %%j failed>>%DOWNLOAD_LOGFILE%
    )
    if "%%k" NEQ "" (
      if exist ..\client\cpp\%%~nxj (
        echo Renaming file ..\client\cpp\%%~nxj to %%k...
        ren ..\client\cpp\%%~nxj %%k
        echo %DATE% %TIME% - Info: Renamed file ..\client\cpp\%%~nxj to %%k>>%DOWNLOAD_LOGFILE%
      )
    )
  )
)
echo %DATE% %TIME% - Info: Downloaded/validated C++ Runtime Libraries' installation files>>%DOWNLOAD_LOGFILE%
if "%CLEANUP_DL%"=="0" goto VerifyCPP
echo Cleaning up client directory for C++ Runtime Libraries...
for /F %%i in ('dir ..\client\cpp /A:-D /B') do (
  %SystemRoot%\System32\find.exe /I "%%i" ..\static\StaticDownloadLinks-cpp-x64-glb.txt >nul 2>&1
  if errorlevel 1 (
    %SystemRoot%\System32\find.exe /I "%%i" ..\static\StaticDownloadLinks-cpp-x86-glb.txt >nul 2>&1
    if errorlevel 1 (
      del ..\client\cpp\%%i
      echo %DATE% %TIME% - Info: Deleted ..\client\cpp\%%i>>%DOWNLOAD_LOGFILE%
    )
  )
)
echo %DATE% %TIME% - Info: Cleaned up client directory for C++ Runtime Libraries>>%DOWNLOAD_LOGFILE%
:VerifyCPP
if "%VERIFY_DL%" NEQ "1" goto SkipCPP
rem *** Verifying digital file signatures for C++ Runtime Libraries' installation files ***
if not exist %SIGCHK_PATH% goto NoSigCheck
echo Verifying digital file signatures for C++ Runtime Libraries' installation files...
for /F "skip=1 tokens=1 delims=," %%i in ('%SIGCHK_PATH% %SIGCHK_COPT% -s ..\client\cpp ^| %SystemRoot%\System32\findstr.exe /I /V "\"Signed\""') do (
  del %%i
  echo Warning: Deleted unsigned file %%i.
  echo %DATE% %TIME% - Warning: Deleted unsigned file %%i>>%DOWNLOAD_LOGFILE%
)
echo %DATE% %TIME% - Info: Verified digital file signatures for C++ Runtime Libraries' installation files>>%DOWNLOAD_LOGFILE%
if not exist ..\client\bin\%HASHDEEP_EXE% goto NoHashDeep
echo Creating integrity database for C++ Runtime Libraries' installation files...
if not exist ..\client\md\nul md ..\client\md
pushd ..\client\md
..\bin\%HASHDEEP_EXE% -c md5,sha1,sha256 -l -r ..\cpp >hashes-cpp.txt
if errorlevel 1 (
  popd
  echo Warning: Error creating integrity database ..\client\md\hashes-cpp.txt.
  echo %DATE% %TIME% - Warning: Error creating integrity database ..\client\md\hashes-cpp.txt>>%DOWNLOAD_LOGFILE%
) else (
  popd
  echo %DATE% %TIME% - Info: Created integrity database for C++ Runtime Libraries' installation files>>%DOWNLOAD_LOGFILE%
)
for %%i in (..\client\md\hashes-cpp.txt) do if %%~zi==0 del %%i
:SkipCPP

rem *** Download Microsoft Security Essentials ***
if "%INC_MSSE%" NEQ "1" goto SkipMSSE
if "%SKIP_DL%"=="1" goto SkipMSSE
if "%VERIFY_DL%" NEQ "1" goto DownloadMSSE
if not exist ..\client\msse\nul goto DownloadMSSE
if not exist ..\client\bin\%HASHDEEP_EXE% goto NoHashDeep
if exist ..\client\md\hashes-msse.txt (
  echo Verifying integrity of Microsoft Security Essentials files...
  pushd ..\client\md
  ..\bin\%HASHDEEP_EXE% -a -l -vv -k hashes-msse.txt -r ..\msse
  if errorlevel 1 (
    popd
    goto IntegrityError
  )
  popd
  echo %DATE% %TIME% - Info: Verified integrity of Microsoft Security Essentials files>>%DOWNLOAD_LOGFILE%
  if exist ..\client\msse\%TARGET_ARCH%-glb\mpam*.exe (
    for %%i in (..\client\msse\%TARGET_ARCH%-glb\mpam*.exe) do echo _%%~ti | %SystemRoot%\System32\find.exe "_%DATE:~-10%" >nul 2>&1
    if not errorlevel 1 (
      echo Skipping download/validation of Microsoft Security Essentials files ^(%TARGET_ARCH%^) due to 'same day' rule.
      echo %DATE% %TIME% - Info: Skipped download/validation of Microsoft Security Essentials files ^(%TARGET_ARCH%^) due to 'same day' rule>>%DOWNLOAD_LOGFILE%
      goto SkipMSSE
    )
  )
) else (
  echo Warning: Integrity database ..\client\md\hashes-msse.txt not found.
  echo %DATE% %TIME% - Warning: Integrity database ..\client\md\hashes-msse.txt not found>>%DOWNLOAD_LOGFILE%
)
:DownloadMSSE
if exist ..\client\md\hashes-msse.txt del ..\client\md\hashes-msse.txt
echo Downloading/validating Microsoft Security Essentials files...
copy /Y ..\static\StaticDownloadLinks-msse-%TARGET_ARCH%-glb.txt "%TEMP%\StaticDownloadLinks-msse-%TARGET_ARCH%-glb.txt" >nul
if exist ..\static\custom\StaticDownloadLinks-msse-%TARGET_ARCH%-glb.txt (
  type ..\static\custom\StaticDownloadLinks-msse-%TARGET_ARCH%-glb.txt >>"%TEMP%\StaticDownloadLinks-msse-%TARGET_ARCH%-glb.txt"
)
for /F "usebackq tokens=1,2 delims=," %%i in ("%TEMP%\StaticDownloadLinks-msse-%TARGET_ARCH%-glb.txt") do (
  if "%%j" NEQ "" (
    if exist ..\client\msse\%TARGET_ARCH%-glb\%%j (
      echo Renaming file ..\client\msse\%TARGET_ARCH%-glb\%%j to %%~nxi...
      if exist ..\client\msse\%TARGET_ARCH%-glb\%%~nxi del ..\client\msse\%TARGET_ARCH%-glb\%%~nxi
      ren ..\client\msse\%TARGET_ARCH%-glb\%%j %%~nxi
      echo %DATE% %TIME% - Info: Renamed file ..\client\msse\%TARGET_ARCH%-glb\%%j to %%~nxi>>%DOWNLOAD_LOGFILE%
    )
  )
  %DLDR_PATH% %DLDR_COPT% %DLDR_POPT% ..\client\msse\%TARGET_ARCH%-glb %%i
  if errorlevel 1 (
    if exist ..\client\msse\%TARGET_ARCH%-glb\%%~nxi del ..\client\msse\%TARGET_ARCH%-glb\%%~nxi
    echo Warning: Download of %%i failed.
    echo %DATE% %TIME% - Warning: Download of %%i failed>>%DOWNLOAD_LOGFILE%
  )
  if "%%j" NEQ "" (
    if exist ..\client\msse\%TARGET_ARCH%-glb\%%~nxi (
      echo Renaming file ..\client\msse\%TARGET_ARCH%-glb\%%~nxi to %%j...
      ren ..\client\msse\%TARGET_ARCH%-glb\%%~nxi %%j
      echo %DATE% %TIME% - Info: Renamed file ..\client\msse\%TARGET_ARCH%-glb\%%~nxi to %%j>>%DOWNLOAD_LOGFILE%
    )
  )
)
echo %DATE% %TIME% - Info: Downloaded/validated Microsoft Security Essentials files>>%DOWNLOAD_LOGFILE%
if "%CLEANUP_DL%"=="0" (
  del "%TEMP%\StaticDownloadLinks-msse-%TARGET_ARCH%-glb.txt"
  goto VerifyMSSE
)
echo Cleaning up client directory for Microsoft Security Essentials...
for /F %%i in ('dir ..\client\msse\%TARGET_ARCH%-glb /A:-D /B') do (
  %SystemRoot%\System32\find.exe /I "%%i" "%TEMP%\StaticDownloadLinks-msse-%TARGET_ARCH%-glb.txt" >nul 2>&1
  if errorlevel 1 (
    del ..\client\msse\%TARGET_ARCH%-glb\%%i
    echo %DATE% %TIME% - Info: Deleted ..\client\msse\%TARGET_ARCH%-glb\%%i>>%DOWNLOAD_LOGFILE%
  )
)
del "%TEMP%\StaticDownloadLinks-msse-%TARGET_ARCH%-glb.txt"
echo %DATE% %TIME% - Info: Cleaned up client directory for Microsoft Security Essentials>>%DOWNLOAD_LOGFILE%
:VerifyMSSE
if "%VERIFY_DL%" NEQ "1" goto SkipMSSE
rem *** Verifying digital file signatures for Microsoft Security Essentials files ***
if not exist %SIGCHK_PATH% goto NoSigCheck
echo Verifying digital file signatures for Microsoft Security Essentials files...
for /F "skip=1 tokens=1 delims=," %%i in ('%SIGCHK_PATH% %SIGCHK_COPT% -s ..\client\msse\%TARGET_ARCH%-glb ^| %SystemRoot%\System32\findstr.exe /I /V "\"Signed\""') do (
  del %%i
  echo Warning: Deleted unsigned file %%i.
  echo %DATE% %TIME% - Warning: Deleted unsigned file %%i>>%DOWNLOAD_LOGFILE%
)
echo %DATE% %TIME% - Info: Verified digital file signatures for Microsoft Security Essentials files>>%DOWNLOAD_LOGFILE%
if not exist ..\client\bin\%HASHDEEP_EXE% goto NoHashDeep
echo Creating integrity database for Microsoft Security Essentials files...
if not exist ..\client\md\nul md ..\client\md
pushd ..\client\md
..\bin\%HASHDEEP_EXE% -c md5,sha1,sha256 -l -r ..\msse >hashes-msse.txt
if errorlevel 1 (
  popd
  echo Warning: Error creating integrity database ..\client\md\hashes-msse.txt.
  echo %DATE% %TIME% - Warning: Error creating integrity database ..\client\md\hashes-msse.txt>>%DOWNLOAD_LOGFILE%
) else (
  popd
  echo %DATE% %TIME% - Info: Created integrity database for Microsoft Security Essentials files>>%DOWNLOAD_LOGFILE%
)
for %%i in (..\client\md\hashes-msse.txt) do if %%~zi==0 del %%i
:SkipMSSE

rem *** Download Windows Defender definition files ***
if "%INC_WDDEFS%" NEQ "1" goto SkipWDDefs
if "%SKIP_DL%"=="1" goto SkipWDDefs
if "%VERIFY_DL%" NEQ "1" goto DownloadWDDefs
if not exist ..\client\wddefs\nul goto DownloadWDDefs
if not exist ..\client\bin\%HASHDEEP_EXE% goto NoHashDeep
if exist ..\client\md\hashes-wddefs.txt (
  echo Verifying integrity of Windows Defender definition files...
  pushd ..\client\md
  ..\bin\%HASHDEEP_EXE% -a -l -vv -k hashes-wddefs.txt -r ..\wddefs
  if errorlevel 1 (
    popd
    goto IntegrityError
  )
  popd
  echo %DATE% %TIME% - Info: Verified integrity of Windows Defender definition files>>%DOWNLOAD_LOGFILE%
  if exist ..\client\wddefs\%TARGET_ARCH%-glb\mpas*.exe (
    for %%i in (..\client\wddefs\%TARGET_ARCH%-glb\mpas*.exe) do echo _%%~ti | %SystemRoot%\System32\find.exe "_%DATE:~-10%" >nul 2>&1
    if not errorlevel 1 (
      echo Skipping download/validation of Windows Defender definition files ^(%TARGET_ARCH%^) due to 'same day' rule.
      echo %DATE% %TIME% - Info: Skipped download/validation of Windows Defender definition files ^(%TARGET_ARCH%^) due to 'same day' rule>>%DOWNLOAD_LOGFILE%
      goto SkipWDDefs
    )
  )
) else (
  echo Warning: Integrity database ..\client\md\hashes-wddefs.txt not found.
  echo %DATE% %TIME% - Warning: Integrity database ..\client\md\hashes-wddefs.txt not found>>%DOWNLOAD_LOGFILE%
)
:DownloadWDDefs
if exist ..\client\md\hashes-wddefs.txt del ..\client\md\hashes-wddefs.txt
echo Downloading/validating Windows Defender definition files...
%DLDR_PATH% %DLDR_COPT% %DLDR_IOPT% ..\static\StaticDownloadLink-wddefs-%TARGET_ARCH%-glb.txt %DLDR_POPT% ..\client\wddefs\%TARGET_ARCH%-glb
if errorlevel 1 goto DownloadError
echo %DATE% %TIME% - Info: Downloaded/validated Windows Defender definition files>>%DOWNLOAD_LOGFILE%

rem *** Verifying digital file signatures for Windows Defender definition files ***
if "%VERIFY_DL%" NEQ "1" goto SkipWDDefs
if not exist %SIGCHK_PATH% goto NoSigCheck
echo Verifying digital file signatures for Windows Defender definition files...
for /F "skip=1 tokens=1 delims=," %%i in ('%SIGCHK_PATH% %SIGCHK_COPT% -s ..\client\wddefs\%TARGET_ARCH%-glb ^| %SystemRoot%\System32\findstr.exe /I /V "\"Signed\""') do (
  del %%i
  echo Warning: Deleted unsigned file %%i.
  echo %DATE% %TIME% - Warning: Deleted unsigned file %%i>>%DOWNLOAD_LOGFILE%
)
echo %DATE% %TIME% - Info: Verified digital file signatures for Windows Defender definition files>>%DOWNLOAD_LOGFILE%
if not exist ..\client\bin\%HASHDEEP_EXE% goto NoHashDeep
echo Creating integrity database for Windows Defender definition files...
if not exist ..\client\md\nul md ..\client\md
pushd ..\client\md
..\bin\%HASHDEEP_EXE% -c md5,sha1,sha256 -l -r ..\wddefs >hashes-wddefs.txt
if errorlevel 1 (
  popd
  echo Warning: Error creating integrity database ..\client\md\hashes-wddefs.txt.
  echo %DATE% %TIME% - Warning: Error creating integrity database ..\client\md\hashes-wddefs.txt>>%DOWNLOAD_LOGFILE%
) else (
  popd
  echo %DATE% %TIME% - Info: Created integrity database for Windows Defender definition files>>%DOWNLOAD_LOGFILE%
)
for %%i in (..\client\md\hashes-wddefs.txt) do if %%~zi==0 del %%i
:SkipWDDefs

rem *** Download the platform specific patches ***
if "%EXC_WINGLB%"=="1" goto SkipWinGlb
for %%i in (w60 w60-x64 w61 w61-x64 w62-x64 w63 w63-x64 w100 w100-x64) do (
  if /i "%1"=="%%i" (
    call :DownloadCore win glb x86 /skipdynamic
    if errorlevel 1 goto Error
  )
)
:SkipWinGlb
for %%i in (o2k10 o2k13) do (
  if /i "%1"=="%%i" (
    call :DownloadCore ofc %2 %TARGET_ARCH% %SKIP_PARAM%
    if errorlevel 1 goto Error
    call :DownloadCore %1 glb %TARGET_ARCH% %SKIP_PARAM%
    if errorlevel 1 goto Error
    call :DownloadCore %1 %2 %TARGET_ARCH% %SKIP_PARAM%
    if errorlevel 1 goto Error
  )
)
for %%i in (o2k16) do (
  if /i "%1"=="%%i" (
    call :DownloadCore %1 glb %TARGET_ARCH% %SKIP_PARAM%
    if errorlevel 1 goto Error
  )
)
for %%i in (w60 w60-x64 w61 w61-x64 w62-x64 w63 w63-x64 w100 w100-x64 ofc) do (
  if /i "%1"=="%%i" (
    call :DownloadCore %1 %2 %TARGET_ARCH% %SKIP_PARAM%
    if errorlevel 1 goto Error
  )
)
goto RemindDate

:DownloadCore
rem *** Determine update urls for %1 %2 ***
title %~n0 %1 %2 %3 %4 %5 %6 %7 %8 %9
echo.

if "%SECONLY%"=="1" (
  set SUSED_LIST=..\exclude\ExcludeList-superseded-seconly.txt
) else (
  set SUSED_LIST=..\exclude\ExcludeList-superseded.txt
)
if "%4"=="/skipdynamic" (
  echo Skipping unneeded determination of superseded updates.
  echo %DATE% %TIME% - Info: Skipped unneeded determination of superseded updates>>%DOWNLOAD_LOGFILE%
  goto SkipSuperseded
)
rem *** Extract Microsoft's update catalog file package.xml ***
echo Extracting Microsoft's update catalog file package.xml...
if exist "%TEMP%\package.cab" del "%TEMP%\package.cab"
if exist "%TEMP%\package.xml" del "%TEMP%\package.xml"
%SystemRoot%\System32\expand.exe ..\client\wsus\wsusscn2.cab -F:package.cab "%TEMP%" >nul
%SystemRoot%\System32\expand.exe "%TEMP%\package.cab" "%TEMP%\package.xml" >nul
del "%TEMP%\package.cab"
rem *** Determine superseded updates ***
if not exist ..\exclude\ExcludeList-superseded-seconly.txt (
  if exist ..\exclude\ExcludeList-superseded.txt del ..\exclude\ExcludeList-superseded.txt
)
if exist ..\exclude\ExcludeList-superseded.txt (
  %SystemRoot%\System32\find.exe /I "http://" ..\exclude\ExcludeList-superseded.txt >nul 2>&1
  if errorlevel 1 del ..\exclude\ExcludeList-superseded.txt
)
for %%i in (..\client\wsus\wsusscn2.cab) do echo %%~ai | %SystemRoot%\System32\find.exe /I "a" >nul 2>&1
if not errorlevel 1 (
  if exist ..\exclude\ExcludeList-superseded.txt del ..\exclude\ExcludeList-superseded.txt
)
if "%SKIP_SDD%" NEQ "1" (
  copy /Y ..\exclude\ExcludeList-superseded-exclude.txt ..\exclude\ExcludeList-superseded-exclude.ori >nul
  %DLDR_PATH% %DLDR_COPT% %DLDR_NVOPT% %DLDR_POPT% ..\exclude %DLDR_LOPT% http://download.wsusoffline.net/ExcludeList-superseded-exclude.txt
  echo n | %SystemRoot%\System32\comp.exe ..\exclude\ExcludeList-superseded-exclude.txt ..\exclude\ExcludeList-superseded-exclude.ori /A /L /C >nul 2>&1
  if errorlevel 1 (
    if exist ..\exclude\ExcludeList-superseded.txt del ..\exclude\ExcludeList-superseded.txt
  )
  del ..\exclude\ExcludeList-superseded-exclude.ori
  copy /Y ..\exclude\ExcludeList-superseded-exclude-seconly.txt ..\exclude\ExcludeList-superseded-exclude-seconly.ori >nul
  %DLDR_PATH% %DLDR_COPT% %DLDR_NVOPT% %DLDR_POPT% ..\exclude %DLDR_LOPT% http://download.wsusoffline.net/ExcludeList-superseded-exclude-seconly.txt
  echo n | %SystemRoot%\System32\comp.exe ..\exclude\ExcludeList-superseded-exclude-seconly.txt ..\exclude\ExcludeList-superseded-exclude-seconly.ori /A /L /C >nul 2>&1
  if errorlevel 1 (
    if exist ..\exclude\ExcludeList-superseded.txt del ..\exclude\ExcludeList-superseded.txt
  )
  del ..\exclude\ExcludeList-superseded-exclude-seconly.ori
  copy /Y ..\client\exclude\HideList-seconly.txt ..\client\exclude\HideList-seconly.ori >nul
  %DLDR_PATH% %DLDR_COPT% %DLDR_NVOPT% %DLDR_POPT% ..\client\exclude %DLDR_LOPT% http://download.wsusoffline.net/HideList-seconly.txt
  echo n | %SystemRoot%\System32\comp.exe ..\client\exclude\HideList-seconly.txt ..\client\exclude\HideList-seconly.ori /A /L /C >nul 2>&1
  if errorlevel 1 (
    if exist ..\exclude\ExcludeList-superseded.txt del ..\exclude\ExcludeList-superseded.txt
  )
  del ..\client\exclude\HideList-seconly.ori
)
if exist ..\exclude\ExcludeList-superseded.txt (
  echo Found valid list of superseded updates.
  echo %DATE% %TIME% - Info: Found valid list of superseded updates>>%DOWNLOAD_LOGFILE%
  goto SkipSuperseded
)
echo %TIME% - Determining superseded updates (please be patient, this will take a while)...
rem *** Revised part for determination of superseded updates starts here ***
rem *** First step ***
echo Extracting file 1...
%CSCRIPT_PATH% //Nologo //B //E:vbs ..\cmd\XSLT.vbs "%TEMP%\package.xml" ..\xslt\extract-existing-bundle-revision-ids.xsl "%TEMP%\existing-bundle-revision-ids.txt"
..\bin\gsort.exe -u -T "%TEMP%" "%TEMP%\existing-bundle-revision-ids.txt" >"%TEMP%\existing-bundle-revision-ids-unique.txt"
del "%TEMP%\existing-bundle-revision-ids.txt"
echo Extracting file 2...
%CSCRIPT_PATH% //Nologo //B //E:vbs ..\cmd\XSLT.vbs "%TEMP%\package.xml" ..\xslt\extract-superseding-and-superseded-revision-ids.xsl "%TEMP%\superseding-and-superseded-revision-ids.txt"
..\bin\gsort.exe -u -T "%TEMP%" "%TEMP%\superseding-and-superseded-revision-ids.txt" >"%TEMP%\superseding-and-superseded-revision-ids-unique.txt"
del "%TEMP%\superseding-and-superseded-revision-ids.txt"
echo Joining files 1 and 2 to file 3...
..\bin\join.exe -t "," -o "2.2" "%TEMP%\existing-bundle-revision-ids-unique.txt" "%TEMP%\superseding-and-superseded-revision-ids-unique.txt" >"%TEMP%\ValidSupersededRevisionIds.txt"
del "%TEMP%\existing-bundle-revision-ids-unique.txt"
del "%TEMP%\superseding-and-superseded-revision-ids-unique.txt"
..\bin\gsort.exe -u -T "%TEMP%" "%TEMP%\ValidSupersededRevisionIds.txt" >"%TEMP%\ValidSupersededRevisionIds-unique.txt"
del "%TEMP%\ValidSupersededRevisionIds.txt"

rem *** Second step ***
echo Extracting file 4...
%CSCRIPT_PATH% //Nologo //B //E:vbs ..\cmd\XSLT.vbs "%TEMP%\package.xml" ..\xslt\extract-update-revision-and-file-ids.xsl "%TEMP%\BundledUpdateRevisionAndFileIds.txt"
..\bin\gsort.exe -u -T "%TEMP%" "%TEMP%\BundledUpdateRevisionAndFileIds.txt" >"%TEMP%\BundledUpdateRevisionAndFileIds-unique.txt"
del "%TEMP%\BundledUpdateRevisionAndFileIds.txt"
echo Joining files 3 and 4 to file 5...
..\bin\join.exe -t "," -o "2.3" "%TEMP%\ValidSupersededRevisionIds-unique.txt" "%TEMP%\BundledUpdateRevisionAndFileIds-unique.txt" >"%TEMP%\SupersededFileIds.txt"
del "%TEMP%\ValidSupersededRevisionIds-unique.txt"
del "%TEMP%\BundledUpdateRevisionAndFileIds-unique.txt"
..\bin\gsort.exe -u -T "%TEMP%" "%TEMP%\SupersededFileIds.txt" >"%TEMP%\SupersededFileIds-unique.txt"
del "%TEMP%\SupersededFileIds.txt"

rem *** Third step ***
echo Extracting file 6...
%CSCRIPT_PATH% //Nologo //B //E:vbs ..\cmd\XSLT.vbs "%TEMP%\package.xml" ..\xslt\extract-update-cab-exe-ids-and-locations.xsl "%TEMP%\UpdateCabExeIdsAndLocations.txt"
..\bin\gsort.exe -u -T "%TEMP%" "%TEMP%\UpdateCabExeIdsAndLocations.txt" >"%TEMP%\UpdateCabExeIdsAndLocations-unique.txt"
del "%TEMP%\UpdateCabExeIdsAndLocations.txt"
echo Joining files 5 and 6 to file 7...
..\bin\join.exe -t "," -o "2.2" "%TEMP%\SupersededFileIds-unique.txt" "%TEMP%\UpdateCabExeIdsAndLocations-unique.txt" >"%TEMP%\ExcludeListLocations-superseded-all.txt"
del "%TEMP%\SupersededFileIds-unique.txt"
del "%TEMP%\UpdateCabExeIdsAndLocations-unique.txt"
..\bin\gsort.exe -u -T "%TEMP%" "%TEMP%\ExcludeListLocations-superseded-all.txt" >"%TEMP%\ExcludeListLocations-superseded-all-unique.txt"
del "%TEMP%\ExcludeListLocations-superseded-all.txt"

rem *** Apply ExcludeList-superseded-exclude.txt ***
if exist ..\exclude\ExcludeList-superseded-exclude.txt copy /Y ..\exclude\ExcludeList-superseded-exclude.txt "%TEMP%\ExcludeList-superseded-exclude.txt" >nul
if exist ..\exclude\custom\ExcludeList-superseded-exclude.txt (
  type ..\exclude\custom\ExcludeList-superseded-exclude.txt >>"%TEMP%\ExcludeList-superseded-exclude.txt"
)
for %%i in ("%TEMP%\ExcludeList-superseded-exclude.txt") do if %%~zi==0 del %%i
if exist "%TEMP%\ExcludeList-superseded-exclude.txt" (
  %SystemRoot%\System32\findstr.exe /L /I /V /G:"%TEMP%\ExcludeList-superseded-exclude.txt" "%TEMP%\ExcludeListLocations-superseded-all-unique.txt" >..\exclude\ExcludeList-superseded.txt
) else (
  copy /Y "%TEMP%\ExcludeListLocations-superseded-all-unique.txt" ..\exclude\ExcludeList-superseded.txt >nul
)
if exist ..\exclude\ExcludeList-superseded-exclude-seconly.txt (
  type ..\exclude\ExcludeList-superseded-exclude-seconly.txt >>"%TEMP%\ExcludeList-superseded-exclude.txt"
)
for %%i in (w61 w62 w63) do (
  for /F %%j in ('dir /B ..\client\static\StaticUpdateIds-%%i*-seconly.txt 2^>nul') do (
    for /F "tokens=1* delims=,;" %%k in (..\client\static\%%j) do (
      echo %%k>>"%TEMP%\ExcludeList-superseded-exclude.txt"
    )
  )
  for /F %%j in ('dir /B ..\client\static\custom\StaticUpdateIds-%%i*-seconly.txt 2^>nul') do (
    for /F "tokens=1* delims=,;" %%k in (..\client\static\custom\%%j) do (
      echo %%k>>"%TEMP%\ExcludeList-superseded-exclude.txt"
    )
  )
)
for %%i in ("%TEMP%\ExcludeList-superseded-exclude.txt") do if %%~zi==0 del %%i
if exist "%TEMP%\ExcludeList-superseded-exclude.txt" (
  %SystemRoot%\System32\findstr.exe /L /I /V /G:"%TEMP%\ExcludeList-superseded-exclude.txt" "%TEMP%\ExcludeListLocations-superseded-all-unique.txt" >..\exclude\ExcludeList-superseded-seconly.txt
  del "%TEMP%\ExcludeListLocations-superseded-all-unique.txt"
  del "%TEMP%\ExcludeList-superseded-exclude.txt"
) else (
  move /Y "%TEMP%\ExcludeListLocations-superseded-all-unique.txt" ..\exclude\ExcludeList-superseded-seconly.txt >nul
)
%SystemRoot%\System32\attrib.exe -A ..\client\wsus\wsusscn2.cab
echo %TIME% - Done.
echo %DATE% %TIME% - Info: Determined superseded updates>>%DOWNLOAD_LOGFILE%
:SkipSuperseded

rem *** Verify integrity of existing updates for %1 %2 ***
if "%4"=="/skipdownload" goto SkipStatics
if "%VERIFY_DL%" NEQ "1" goto SkipAudit
if not exist ..\client\%1\%2\nul goto SkipAudit
if not exist ..\client\bin\%HASHDEEP_EXE% goto NoHashDeep
if exist ..\client\md\hashes-%1-%2.txt (
  echo Verifying integrity of existing updates for %1 %2...
  pushd ..\client\md
  ..\bin\%HASHDEEP_EXE% -a -l -vv -k hashes-%1-%2.txt -r ..\%1\%2
  if errorlevel 1 (
    popd
    goto IntegrityError
  )
  popd
  echo %DATE% %TIME% - Info: Verified integrity of existing updates for %1 %2>>%DOWNLOAD_LOGFILE%
  for %%i in (..\client\md\hashes-%1-%2.txt) do echo _%%~ti | %SystemRoot%\System32\find.exe "_%DATE:~-10%" >nul 2>&1
  if not errorlevel 1 (
    if exist %SUSED_LIST% (
      for %%i in (%SUSED_LIST%) do echo _%%~ti | %SystemRoot%\System32\find.exe "_%DATE:~-10%" >nul 2>&1
      if errorlevel 1 (
        echo Skipping download/validation of %1 %2 due to 'same day' rule.
        echo %DATE% %TIME% - Info: Skipped download/validation of %1 %2 due to 'same day' rule>>%DOWNLOAD_LOGFILE%
        verify >nul
        goto :eof
      )
    )
  )
) else (
  echo Warning: Integrity database ..\client\md\hashes-%1-%2.txt not found.
  echo %DATE% %TIME% - Warning: Integrity database ..\client\md\hashes-%1-%2.txt not found>>%DOWNLOAD_LOGFILE%
)
:SkipAudit
if exist ..\client\md\hashes-%1-%2.txt del ..\client\md\hashes-%1-%2.txt

rem *** Determine static update urls for %1 %2 ***
if "%EXC_STATICS%"=="1" goto SkipStatics
echo Determining static update urls for %1 %2...
if exist ..\static\StaticDownloadLinks-%1-%2.txt copy /Y ..\static\StaticDownloadLinks-%1-%2.txt "%TEMP%\StaticDownloadLinks-%1-%2.txt" >nul
if exist ..\static\StaticDownloadLinks-%1-%3-%2.txt copy /Y ..\static\StaticDownloadLinks-%1-%3-%2.txt "%TEMP%\StaticDownloadLinks-%1-%2.txt" >nul
if exist ..\static\custom\StaticDownloadLinks-%1-%2.txt (
  type ..\static\custom\StaticDownloadLinks-%1-%2.txt >>"%TEMP%\StaticDownloadLinks-%1-%2.txt"
)
if exist ..\static\custom\StaticDownloadLinks-%1-%3-%2.txt (
  type ..\static\custom\StaticDownloadLinks-%1-%3-%2.txt >>"%TEMP%\StaticDownloadLinks-%1-%2.txt"
)
if not exist "%TEMP%\StaticDownloadLinks-%1-%2.txt" goto SkipStatics

:EvalStatics
if exist "%TEMP%\ExcludeListStatic.txt" del "%TEMP%\ExcludeListStatic.txt"
if exist ..\exclude\custom\ExcludeListForce-all.txt copy /Y ..\exclude\custom\ExcludeListForce-all.txt "%TEMP%\ExcludeListStatic.txt" >nul
if "%EXC_SP%"=="1" (
  type ..\exclude\ExcludeList-SPs.txt >>"%TEMP%\ExcludeListStatic.txt"
)
if exist "%TEMP%\ValidStaticLinks-%1-%2.txt" del "%TEMP%\ValidStaticLinks-%1-%2.txt"
if exist "%TEMP%\ExcludeListStatic.txt" (
  %SystemRoot%\System32\findstr.exe /L /I /V /G:"%TEMP%\ExcludeListStatic.txt" "%TEMP%\StaticDownloadLinks-%1-%2.txt" >"%TEMP%\ValidStaticLinks-%1-%2.txt"
  del "%TEMP%\ExcludeListStatic.txt"
  del "%TEMP%\StaticDownloadLinks-%1-%2.txt"
) else (
  ren "%TEMP%\StaticDownloadLinks-%1-%2.txt" ValidStaticLinks-%1-%2.txt
)
echo %DATE% %TIME% - Info: Determined static update urls for %1 %2>>%DOWNLOAD_LOGFILE%

:SkipStatics
if "%4"=="/skipdynamic" (
  echo Skipping determination of dynamic update urls for %1 %2 on demand.
  echo %DATE% %TIME% - Info: Skipped determination of dynamic update urls for %1 %2 on demand>>%DOWNLOAD_LOGFILE%
  goto DoDownload
)
for %%i in (dotnet win w60 w60-x64 w61 w61-x64 w62-x64 w63 w63-x64 w100 w100-x64) do (if /i "%1"=="%%i" goto DetermineWindows)
for %%i in (ofc) do (if /i "%1"=="%%i" goto DetermineOffice)
if exist "%TEMP%\package.xml" del "%TEMP%\package.xml"
goto DoDownload

:DetermineWindows
rem *** Determine dynamic update urls for %1 %2 ***
echo %TIME% - Determining dynamic update urls for %1 %2...
if exist ..\xslt\ExtractDownloadLinks-%1-%2.xsl (
  %CSCRIPT_PATH% //Nologo //B //E:vbs XSLT.vbs "%TEMP%\package.xml" ..\xslt\ExtractDownloadLinks-%1-%2.xsl "%TEMP%\DynamicDownloadLinks-%1-%2.txt"
  if errorlevel 1 goto DownloadError
)
if exist ..\xslt\ExtractDownloadLinks-%1-%3-%2.xsl (
  %CSCRIPT_PATH% //Nologo //B //E:vbs XSLT.vbs "%TEMP%\package.xml" ..\xslt\ExtractDownloadLinks-%1-%3-%2.xsl "%TEMP%\DynamicDownloadLinks-%1-%2.txt"
  if errorlevel 1 goto DownloadError
)
del "%TEMP%\package.xml"

if not exist "%TEMP%\DynamicDownloadLinks-%1-%2.txt" goto DoDownload

rem A left join of the files DynamicDownloadLinks.txt and
rem ExcludeList-superseded.txt returns URLs, which are unique
rem to the left side. The intermediate file will be called
rem "DynamicDownloadLinks-pruned.txt".

if exist %SUSED_LIST% (
  rem As always, both input files must be sorted.
  ..\bin\gsort.exe -u -T "%TEMP%" "%TEMP%\DynamicDownloadLinks-%1-%2.txt" >"%TEMP%\DynamicDownloadLinks-%1-%2-unique.txt"
  del "%TEMP%\DynamicDownloadLinks-%1-%2.txt"
  ..\bin\join.exe -v1 "%TEMP%\DynamicDownloadLinks-%1-%2-unique.txt" %SUSED_LIST% >"%TEMP%\DynamicDownloadLinks-%1-%2-pruned.txt"
  del "%TEMP%\DynamicDownloadLinks-%1-%2-unique.txt"
) else (
  move /Y "%TEMP%\DynamicDownloadLinks-%1-%2.txt" "%TEMP%\DynamicDownloadLinks-%1-%2-pruned.txt" >nul
)

rem The remaining exclude lists are applied as before.
if exist "%TEMP%\ExcludeList-%1.txt" del "%TEMP%\ExcludeList-%1.txt"
if exist ..\exclude\ExcludeList-%1-%3.txt (
  copy /Y ..\exclude\ExcludeList-%1-%3.txt "%TEMP%\ExcludeList-%1.txt" >nul
  if exist ..\exclude\custom\ExcludeList-%1-%3.txt (
    type ..\exclude\custom\ExcludeList-%1-%3.txt >>"%TEMP%\ExcludeList-%1.txt"
  )
) else (
  if exist ..\exclude\ExcludeList-%1.txt copy /Y ..\exclude\ExcludeList-%1.txt "%TEMP%\ExcludeList-%1.txt" >nul
  if exist ..\exclude\custom\ExcludeList-%1.txt (
    type ..\exclude\custom\ExcludeList-%1.txt >>"%TEMP%\ExcludeList-%1.txt"
  )
)
if "%SECONLY%"=="1" (
  if exist ..\client\exclude\HideList-seconly.txt (
    for /F "tokens=1* delims=,;" %%i in (..\client\exclude\HideList-seconly.txt) do (
      echo %%i>>"%TEMP%\ExcludeList-%1.txt"
    )
  )
  if exist ..\client\exclude\custom\HideList-seconly.txt (
    for /F "tokens=1* delims=,;" %%i in (..\client\exclude\custom\HideList-seconly.txt) do (
      echo %%i>>"%TEMP%\ExcludeList-%1.txt"
    )
  )
)
if exist ..\exclude\custom\ExcludeListForce-all.txt (
  type ..\exclude\custom\ExcludeListForce-all.txt >>"%TEMP%\ExcludeList-%1.txt"
)
if "%EXC_SP%"=="1" (
  type ..\exclude\ExcludeList-SPs.txt >>"%TEMP%\ExcludeList-%1.txt"
)
for %%i in ("%TEMP%\ExcludeList-%1.txt") do if %%~zi==0 del %%i
if exist "%TEMP%\ExcludeList-%1.txt" (
  %SystemRoot%\System32\findstr.exe /L /I /V /G:"%TEMP%\ExcludeList-%1.txt" "%TEMP%\DynamicDownloadLinks-%1-%2-pruned.txt" >"%TEMP%\ValidDynamicLinks-%1-%2.txt"
  del "%TEMP%\DynamicDownloadLinks-%1-%2-pruned.txt"
  del "%TEMP%\ExcludeList-%1.txt"
) else (
  move /Y "%TEMP%\DynamicDownloadLinks-%1-%2-pruned.txt" "%TEMP%\ValidDynamicLinks-%1-%2.txt" >nul
)
echo %TIME% - Done.
echo %DATE% %TIME% - Info: Determined dynamic update urls for %1 %2>>%DOWNLOAD_LOGFILE%
goto DoDownload

:DetermineOffice
rem *** Determine dynamic update urls for %1 %2 ***
echo %TIME% - Determining dynamic update urls for %1 %2 (please be patient, this will take a while)...
%CSCRIPT_PATH% //Nologo //B //E:vbs XSLT.vbs "%TEMP%\package.xml" ..\xslt\ExtractUpdateCategoriesAndFileIds.xsl "%TEMP%\UpdateCategoriesAndFileIds.txt"
if errorlevel 1 goto DownloadError
%CSCRIPT_PATH% //Nologo //B //E:vbs XSLT.vbs "%TEMP%\package.xml" ..\xslt\ExtractUpdateCabExeIdsAndLocations.xsl "%TEMP%\UpdateCabExeIdsAndLocations.txt"
if errorlevel 1 goto DownloadError
del "%TEMP%\package.xml"
..\bin\gsort.exe -u -T "%TEMP%" "%TEMP%\UpdateCabExeIdsAndLocations.txt" >"%TEMP%\UpdateCabExeIdsAndLocationsUnique.txt"
del "%TEMP%\UpdateCabExeIdsAndLocations.txt"

if exist "%TEMP%\OfficeFileAndUpdateIds.txt" del "%TEMP%\OfficeFileAndUpdateIds.txt"
set UPDATE_ID=
set UPDATE_CATEGORY=
set UPDATE_LANGUAGES=
for /F "usebackq tokens=1,2 delims=;" %%i in ("%TEMP%\UpdateCategoriesAndFileIds.txt") do (
  if "%%j"=="" (
    if "!UPDATE_CATEGORY!"=="477b856e-65c4-4473-b621-a8b230bb70d9" (
      for /F "tokens=1-3 delims=," %%k in ("%%i") do (
        if "%%l" NEQ "" (
          if /i "%2"=="glb" (
            if "!UPDATE_LANGUAGES!_%%m"=="_" (
              echo %%l,!UPDATE_ID!>>"%TEMP%\OfficeFileAndUpdateIds.txt"
            )
            if "!UPDATE_LANGUAGES!_%%m"=="en_en" (
              echo %%l,!UPDATE_ID!>>"%TEMP%\OfficeFileAndUpdateIds.txt"
            )
          ) else (
            if "%%m"=="%LANG_SHORT%" (
              echo %%l,!UPDATE_ID!>>"%TEMP%\OfficeFileAndUpdateIds.txt"
            )
          )
        )
      )
    )
  ) else (
    for /F "tokens=1 delims=," %%k in ("%%i") do (
      set UPDATE_ID=%%k
    )
    for /F "tokens=1* delims=," %%k in ("%%j") do (
      set UPDATE_CATEGORY=%%k
      set UPDATE_LANGUAGES=%%l
    )
  )
)
set UPDATE_ID=
set UPDATE_CATEGORY=
set UPDATE_LANGUAGES=
del "%TEMP%\UpdateCategoriesAndFileIds.txt"

%CSCRIPT_PATH% //Nologo //B //E:vbs ExtractIdsAndFileNames.vbs "%TEMP%\OfficeFileAndUpdateIds.txt" "%TEMP%\OfficeFileIds.txt" /firstonly
..\bin\gsort.exe -u -T "%TEMP%" "%TEMP%\OfficeFileIds.txt" >"%TEMP%\OfficeFileIdsUnique.txt"
del "%TEMP%\OfficeFileIds.txt"
..\bin\gsort.exe -u -T "%TEMP%" "%TEMP%\OfficeFileAndUpdateIds.txt" >"%TEMP%\OfficeFileAndUpdateIdsUnique.txt"
del "%TEMP%\OfficeFileAndUpdateIds.txt"
..\bin\join.exe -t "," "%TEMP%\OfficeFileIdsUnique.txt" "%TEMP%\UpdateCabExeIdsAndLocationsUnique.txt" >"%TEMP%\OfficeUpdateCabExeIdsAndLocationsUnique.txt"
del "%TEMP%\OfficeFileIdsUnique.txt"
del "%TEMP%\UpdateCabExeIdsAndLocationsUnique.txt"
..\bin\join.exe -t "," -o "1.2" "%TEMP%\OfficeUpdateCabExeIdsAndLocationsUnique.txt" "%TEMP%\OfficeFileAndUpdateIdsUnique.txt" >"%TEMP%\DynamicDownloadLinks-%1-%2.txt"
..\bin\join.exe -t "," -o "2.2,1.2" "%TEMP%\OfficeUpdateCabExeIdsAndLocationsUnique.txt" "%TEMP%\OfficeFileAndUpdateIdsUnique.txt" >"%TEMP%\UpdateTableURL-%1-%2.csv"
del "%TEMP%\OfficeFileAndUpdateIdsUnique.txt"
del "%TEMP%\OfficeUpdateCabExeIdsAndLocationsUnique.txt"
if not exist ..\client\ofc\nul md ..\client\ofc
%CSCRIPT_PATH% //Nologo //B //E:vbs ExtractIdsAndFileNames.vbs "%TEMP%\UpdateTableURL-%1-%2.csv" ..\client\ofc\UpdateTable-%1-%2.csv
del "%TEMP%\UpdateTableURL-%1-%2.csv"

rem A left join of the files DynamicDownloadLinks.txt and
rem ExcludeList-superseded.txt returns URLs, which are unique
rem to the left side. The intermediate file will be called
rem "DynamicDownloadLinks-pruned.txt".

if exist %SUSED_LIST% (
  rem As always, both input files must be sorted.
  ..\bin\gsort.exe -u -T "%TEMP%" "%TEMP%\DynamicDownloadLinks-%1-%2.txt" >"%TEMP%\DynamicDownloadLinks-%1-%2-unique.txt"
  del "%TEMP%\DynamicDownloadLinks-%1-%2.txt"
  ..\bin\join.exe -v1 "%TEMP%\DynamicDownloadLinks-%1-%2-unique.txt" %SUSED_LIST% >"%TEMP%\DynamicDownloadLinks-%1-%2-pruned.txt"
  del "%TEMP%\DynamicDownloadLinks-%1-%2-unique.txt"
) else (
  move /Y "%TEMP%\DynamicDownloadLinks-%1-%2.txt" "%TEMP%\DynamicDownloadLinks-%1-%2-pruned.txt" >nul
)

rem The remaining exclude lists are applied as before.
if exist "%TEMP%\ExcludeList-%1.txt" del "%TEMP%\ExcludeList-%1.txt"
if exist ..\exclude\ExcludeList-%1.txt copy /Y ..\exclude\ExcludeList-%1.txt "%TEMP%\ExcludeList-%1.txt" >nul
if exist ..\exclude\ExcludeList-%1-%2.txt (
  type ..\exclude\ExcludeList-%1-%2.txt >>"%TEMP%\ExcludeList-%1.txt"
)
if exist ..\exclude\custom\ExcludeList-%1.txt (
  type ..\exclude\custom\ExcludeList-%1.txt >>"%TEMP%\ExcludeList-%1.txt"
)
if exist ..\exclude\custom\ExcludeList-%1-%2.txt (
  type ..\exclude\custom\ExcludeList-%1-%2.txt >>"%TEMP%\ExcludeList-%1.txt"
)
if exist ..\exclude\custom\ExcludeListForce-all.txt (
  type ..\exclude\custom\ExcludeListForce-all.txt >>"%TEMP%\ExcludeList-%1.txt"
)
if "%EXC_SP%"=="1" (
  type ..\exclude\ExcludeList-SPs.txt >>"%TEMP%\ExcludeList-%1.txt"
)
for %%i in ("%TEMP%\ExcludeList-%1.txt") do if %%~zi==0 del %%i
if exist "%TEMP%\ExcludeList-%1.txt" (
  %SystemRoot%\System32\findstr.exe /L /I /V /G:"%TEMP%\ExcludeList-%1.txt" "%TEMP%\DynamicDownloadLinks-%1-%2-pruned.txt" >"%TEMP%\ValidDynamicLinks-%1-%2.txt"
  del "%TEMP%\DynamicDownloadLinks-%1-%2-pruned.txt"
  del "%TEMP%\ExcludeList-%1.txt"
) else (
  move /Y "%TEMP%\DynamicDownloadLinks-%1-%2-pruned.txt" "%TEMP%\ValidDynamicLinks-%1-%2.txt" >nul
)
echo %TIME% - Done.
echo %DATE% %TIME% - Info: Determined dynamic update urls for %1 %2>>%DOWNLOAD_LOGFILE%

:DoDownload
rem *** Download updates for %1 %2 ***
if "%4"=="/skipdownload" (
  echo Skipping download/validation of updates for %1 %2 on demand.
  echo %DATE% %TIME% - Info: Skipped download/validation of updates for %1 %2 on demand>>%DOWNLOAD_LOGFILE%
  goto EndDownload
)
if not exist "%TEMP%\ValidStaticLinks-%1-%2.txt" goto DownloadDynamicUpdates
echo Downloading/validating statically defined updates for %1 %2...
set LINES_COUNT=0
for /F "tokens=1* delims=:" %%i in ('%SystemRoot%\System32\findstr.exe /N $ "%TEMP%\ValidStaticLinks-%1-%2.txt"') do set LINES_COUNT=%%i
for /F "tokens=1* delims=:" %%i in ('%SystemRoot%\System32\findstr.exe /N $ "%TEMP%\ValidStaticLinks-%1-%2.txt"') do (
  echo Downloading/validating update %%i of %LINES_COUNT%...
  for /F "tokens=1,2 delims=," %%k in ("%%j") do (
    if "%%l" NEQ "" (
      if exist ..\client\%1\%2\%%l (
        echo Renaming file ..\client\%1\%2\%%l to %%~nxk...
        ren ..\client\%1\%2\%%l %%~nxk
        echo %DATE% %TIME% - Info: Renamed file ..\client\%1\%2\%%l to %%~nxk>>%DOWNLOAD_LOGFILE%
      )
    )
    %DLDR_PATH% %DLDR_COPT% %DLDR_POPT% ..\client\%1\%2 %%k
    if errorlevel 1 (
      if exist ..\client\%1\%2\%%~nxk del ..\client\%1\%2\%%~nxk
      echo Warning: Download of %%k failed.
      echo %DATE% %TIME% - Warning: Download of %%k failed>>%DOWNLOAD_LOGFILE%
    ) else (
      echo %DATE% %TIME% - Info: Downloaded/validated %%k to ..\client\%1\%2>>%DOWNLOAD_LOGFILE%
    )
    if "%%l" NEQ "" (
      if exist ..\client\%1\%2\%%~nxk (
        echo Renaming file ..\client\%1\%2\%%~nxk to %%l...
        ren ..\client\%1\%2\%%~nxk %%l
        echo %DATE% %TIME% - Info: Renamed file ..\client\%1\%2\%%~nxk to %%l>>%DOWNLOAD_LOGFILE%
      )
    )
  )
)
echo %DATE% %TIME% - Info: Downloaded/validated %LINES_COUNT% statically defined updates for %1 %2>>%DOWNLOAD_LOGFILE%

:DownloadDynamicUpdates
if not exist "%TEMP%\ValidDynamicLinks-%1-%2.txt" goto CleanupDownload
echo Downloading/validating dynamically determined updates for %1 %2...
set LINES_COUNT=0
for /F "tokens=1* delims=:" %%i in ('%SystemRoot%\System32\findstr.exe /N $ "%TEMP%\ValidDynamicLinks-%1-%2.txt"') do set LINES_COUNT=%%i
if "%WSUS_URL%"=="" (
  for /F "tokens=1* delims=:" %%i in ('%SystemRoot%\System32\findstr.exe /N $ "%TEMP%\ValidDynamicLinks-%1-%2.txt"') do (
    echo Downloading/validating update %%i of %LINES_COUNT%...
    %DLDR_PATH% %DLDR_COPT% %DLDR_POPT% ..\client\%1\%2 %%j
    if errorlevel 1 (
      echo Warning: Download of %%j failed.
      echo %DATE% %TIME% - Warning: Download of %%j failed>>%DOWNLOAD_LOGFILE%
    ) else (
      echo %DATE% %TIME% - Info: Downloaded/validated %%j to ..\client\%1\%2>>%DOWNLOAD_LOGFILE%
    )
  )
) else (
  echo Creating WSUS download table for %1 %2...
  %CSCRIPT_PATH% //Nologo //B //E:vbs CreateDownloadTable.vbs "%TEMP%\ValidDynamicLinks-%1-%2.txt" %WSUS_URL%
  if errorlevel 1 goto DownloadError
  echo %DATE% %TIME% - Info: Created WSUS download table for %1 %2>>%DOWNLOAD_LOGFILE%
  for /F "tokens=1* delims=:" %%i in ('%SystemRoot%\System32\findstr.exe /N $ "%TEMP%\ValidDynamicLinks-%1-%2.csv"') do (
    echo Downloading/validating update %%i of %LINES_COUNT%...
    for /F "tokens=1-3 delims=," %%k in ("%%j") do (
      if "%%m"=="" (
        %DLDR_PATH% %DLDR_COPT% %DLDR_POPT% ..\client\%1\%2 %%l
        if errorlevel 1 (
          echo Warning: Download of %%l failed.
          echo %DATE% %TIME% - Warning: Download of %%l failed>>%DOWNLOAD_LOGFILE%
        ) else (
          echo %DATE% %TIME% - Info: Downloaded/validated %%l to ..\client\%1\%2>>%DOWNLOAD_LOGFILE%
        )
      ) else (
        if exist ..\client\%1\%2\%%k (
          echo Renaming file ..\client\%1\%2\%%k to %%~nxl...
          ren ..\client\%1\%2\%%k %%~nxl
          echo %DATE% %TIME% - Info: Renamed file ..\client\%1\%2\%%k to %%~nxl>>%DOWNLOAD_LOGFILE%
        )
        if "%WSUS_BY_PROXY%"=="1" (
          %DLDR_PATH% %DLDR_COPT% %DLDR_NVOPT% %DLDR_POPT% ..\client\%1\%2 %DLDR_LOPT% %%l
        ) else (
          %DLDR_PATH% %DLDR_COPT% %DLDR_NVOPT% --no-proxy %DLDR_POPT% ..\client\%1\%2 %DLDR_LOPT% %%l
        )
        if errorlevel 1 (
          if exist ..\client\%1\%2\%%~nxl (
            echo Renaming file ..\client\%1\%2\%%~nxl to %%k...
            ren ..\client\%1\%2\%%~nxl %%k
            echo %DATE% %TIME% - Info: Renamed file ..\client\%1\%2\%%~nxl to %%k>>%DOWNLOAD_LOGFILE%
          )
          if "%WSUS_ONLY%"=="1" (
            echo Warning: Download of %%l ^(%%k^) failed.
            echo %DATE% %TIME% - Warning: Download of %%l ^(%%k^) failed>>%DOWNLOAD_LOGFILE%
          ) else (
            %DLDR_PATH% %DLDR_COPT% %DLDR_POPT% ..\client\%1\%2 %%m
            if errorlevel 1 (
              echo Warning: Download of %%m failed.
              echo %DATE% %TIME% - Warning: Download of %%m failed>>%DOWNLOAD_LOGFILE%
            ) else (
              echo %DATE% %TIME% - Info: Downloaded/validated %%m to ..\client\%1\%2>>%DOWNLOAD_LOGFILE%
            )
          )
        ) else (
          if exist ..\client\%1\%2\%%~nxl (
            echo Renaming file ..\client\%1\%2\%%~nxl to %%k...
            ren ..\client\%1\%2\%%~nxl %%k
            echo %DATE% %TIME% - Info: Renamed file ..\client\%1\%2\%%~nxl to %%k>>%DOWNLOAD_LOGFILE%
          )
        )
      )
    )
  )
)
echo %DATE% %TIME% - Info: Downloaded/validated %LINES_COUNT% dynamically determined updates for %1 %2>>%DOWNLOAD_LOGFILE%

echo Adjusting UpdateInstaller.ini file...
if exist ..\client\UpdateInstaller.ini (
  if exist ..\client\UpdateInstaller.ori del ..\client\UpdateInstaller.ori
  ren ..\client\UpdateInstaller.ini UpdateInstaller.ori
  for /F "tokens=1* delims==" %%i in (..\client\UpdateInstaller.ori) do (
    if /i "%%i"=="seconly" (
      if "%SECONLY%"=="1" (
        echo seconly=Enabled>>..\client\UpdateInstaller.ini
      ) else (
        echo seconly=Disabled>>..\client\UpdateInstaller.ini
      )
    ) else (
      if "%%j"=="" (
        echo %%i>>..\client\UpdateInstaller.ini
      ) else (
        echo %%i=%%j>>..\client\UpdateInstaller.ini
      )
    )
  )
  del ..\client\UpdateInstaller.ori
)
echo %DATE% %TIME% - Info: Adjusted UpdateInstaller.ini file>>%DOWNLOAD_LOGFILE%

:CleanupDownload
rem *** Clean up client directory for %1 %2 ***
if not exist ..\client\%1\%2\nul goto RemoveHashes
if "%CLEANUP_DL%"=="0" goto VerifyDownload
echo Cleaning up client directory for %1 %2...
if exist "%TEMP%\ValidLinks-%1-%2.txt" del "%TEMP%\ValidLinks-%1-%2.txt"
if exist "%TEMP%\ValidStaticLinks-%1-%2.txt" (
  type "%TEMP%\ValidStaticLinks-%1-%2.txt" >>"%TEMP%\ValidLinks-%1-%2.txt"
)
if exist "%TEMP%\ValidDynamicLinks-%1-%2.txt" (
  type "%TEMP%\ValidDynamicLinks-%1-%2.txt" >>"%TEMP%\ValidLinks-%1-%2.txt"
)
for /F %%i in ('dir ..\client\%1\%2 /A:-D /B') do (
  if exist "%TEMP%\ValidLinks-%1-%2.txt" (
    %SystemRoot%\System32\find.exe /I "%%i" "%TEMP%\ValidLinks-%1-%2.txt" >nul 2>&1
    if errorlevel 1 (
      del ..\client\%1\%2\%%i
      echo %DATE% %TIME% - Info: Deleted ..\client\%1\%2\%%i>>%DOWNLOAD_LOGFILE%
    )
  ) else (
    del ..\client\%1\%2\%%i
    echo %DATE% %TIME% - Info: Deleted ..\client\%1\%2\%%i>>%DOWNLOAD_LOGFILE%
  )
)
if exist "%TEMP%\ValidLinks-%1-%2.txt" del "%TEMP%\ValidLinks-%1-%2.txt"
dir ..\client\%1\%2 /A:-D >nul 2>&1
if errorlevel 1 rd ..\client\%1\%2
echo %DATE% %TIME% - Info: Cleaned up client directory for %1 %2>>%DOWNLOAD_LOGFILE%

:VerifyDownload
if not exist ..\client\%1\%2\nul goto RemoveHashes
rem *** Remove NTFS alternate data streams for %1 %2 ***
if exist %STRMS_PATH% (
  %STRMS_PATH% /accepteula ..\client\%1\%2\*.* >nul 2>&1
  if errorlevel 1 (
    echo %DATE% %TIME% - Info: File system does not support streams>>%DOWNLOAD_LOGFILE%
  ) else (
    echo Removing NTFS alternate data streams for %1 %2...
    %STRMS_PATH% /accepteula -s -d ..\client\%1\%2\*.* >nul 2>&1
    if errorlevel 1 (
      echo Warning: Unable to remove NTFS alternate data streams for %1 %2.
      echo %DATE% %TIME% - Warning: Unable to remove NTFS alternate data streams for %1 %2>>%DOWNLOAD_LOGFILE%
    ) else (
      echo %DATE% %TIME% - Info: Removed NTFS alternate data streams for %1 %2>>%DOWNLOAD_LOGFILE%
    )
  )
) else (
  echo Warning: Sysinternals' NTFS alternate data stream handling tool %STRMS_PATH% not found.
  echo %DATE% %TIME% - Warning: Sysinternals' NTFS alternate data stream handling tool %STRMS_PATH% not found>>%DOWNLOAD_LOGFILE%
)
if "%VERIFY_DL%" NEQ "1" goto RemoveHashes
rem *** Verifying digital file signatures for %1 %2 ***
if not exist %SIGCHK_PATH% goto NoSigCheck
echo Verifying digital file signatures for %1 %2...
for /F "skip=1 tokens=1 delims=," %%i in ('%SIGCHK_PATH% %SIGCHK_COPT% -s ..\client\%1\%2 ^| %SystemRoot%\System32\findstr.exe /I /V "\"Signed\""') do (
  if /i "%%~xi" NEQ ".zip" (
    del %%i
    echo Warning: Deleted unsigned file %%i.
    echo %DATE% %TIME% - Warning: Deleted unsigned file %%i>>%DOWNLOAD_LOGFILE%
  )
)
echo %DATE% %TIME% - Info: Verified digital file signatures for %1 %2>>%DOWNLOAD_LOGFILE%
rem *** Create integrity database for %1 %2 ***
if not exist ..\client\bin\%HASHDEEP_EXE% goto NoHashDeep
echo Creating integrity database for %1 %2...
if not exist ..\client\md\nul md ..\client\md
pushd ..\client\md
..\bin\%HASHDEEP_EXE% -c md5,sha1,sha256 -l -r ..\%1\%2 >hashes-%1-%2.txt
if errorlevel 1 (
  popd
  echo Warning: Error creating integrity database ..\client\md\hashes-%1-%2.txt.
  echo %DATE% %TIME% - Warning: Error creating integrity database ..\client\md\hashes-%1-%2.txt>>%DOWNLOAD_LOGFILE%
) else (
  popd
  echo %DATE% %TIME% - Info: Created integrity database for %1 %2>>%DOWNLOAD_LOGFILE%
)
for %%i in (..\client\md\hashes-%1-%2.txt) do if %%~zi==0 del %%i
if not exist ..\client\md\hashes-%1-%2.txt goto EndDownload
%SystemRoot%\System32\findstr.exe _[A-Fa-f0-9]*\.[A-Za-z0-9][A-Za-z0-9][A-Za-z0-9]$ ..\client\md\hashes-%1-%2.txt >"%TEMP%\sha1-%1-%2.txt"
for /F "usebackq tokens=3,5 delims=," %%i in ("%TEMP%\sha1-%1-%2.txt") do (
  for /F "tokens=2 delims=_" %%k in ("%%j") do (
    for /F "tokens=1 delims=." %%l in ("%%k") do (
      if "%%l" NEQ "%%i" (
        pushd ..\client\md
        del %%j
        ren hashes-%1-%2.txt hashes-%1-%2.bak
        %SystemRoot%\System32\findstr.exe /L /I /V "%%j" hashes-%1-%2.bak >hashes-%1-%2.txt
        del hashes-%1-%2.bak
        popd
        echo Warning: Deleted file %%j due to mismatching SHA-1 message digest ^(%%i^).
        echo %DATE% %TIME% - Warning: Deleted file %%j due to mismatching SHA-1 message digest ^(%%i^)>>%DOWNLOAD_LOGFILE%
      )
    )
  )
)
del "%TEMP%\sha1-%1-%2.txt"
goto EndDownload

:RemoveHashes
if exist ..\client\md\hashes-%1-%2.txt (
  del ..\client\md\hashes-%1-%2.txt
  echo %DATE% %TIME% - Info: Deleted integrity database for %1 %2>>%DOWNLOAD_LOGFILE%
)
:EndDownload
if exist "%TEMP%\ValidStaticLinks-%1-%2.txt" del "%TEMP%\ValidStaticLinks-%1-%2.txt"
if exist "%TEMP%\ValidDynamicLinks-%1-%2.csv" del "%TEMP%\ValidDynamicLinks-%1-%2.csv"
if "%4"=="/skipdownload" (
  for %%i in (win w60 w61 w62 w63 w100) do (
    if /i "%1"=="%%i" (
      if exist "%TEMP%\ValidDynamicLinks-%1-%2.txt" move /Y "%TEMP%\ValidDynamicLinks-%1-%2.txt" ..\static\custom\StaticDownloadLinks-%1-%3-%2.txt >nul
    )
  )
  if exist "%TEMP%\ValidDynamicLinks-%1-%2.txt" move /Y "%TEMP%\ValidDynamicLinks-%1-%2.txt" ..\static\custom\StaticDownloadLinks-%1-%2.txt >nul
) else (
  if exist "%TEMP%\ValidDynamicLinks-%1-%2.txt" del "%TEMP%\ValidDynamicLinks-%1-%2.txt"
)
verify >nul
goto :eof

:RemindDate
if "%SKIP_DL%"=="1" goto EoF
rem *** Remind build date ***
echo Reminding build date...
echo %DATE:~-11%>..\client\builddate.txt
rem *** Create autorun.inf file ***
echo Creating autorun.inf file...
echo [autorun]>..\client\autorun.inf
echo open=UpdateInstaller.exe>>..\client\autorun.inf
echo icon=UpdateInstaller.exe,0 >>..\client\autorun.inf
echo action=Run WSUS Offline Update v. %WSUSOFFLINE_VERSION% (%DATE:~-11%)>>..\client\autorun.inf
goto EoF

:NoExtensions
echo.
echo ERROR: No command extensions / delayed variable expansion available.
echo.
exit /b 1

:InvalidParams
echo.
echo ERROR: Invalid parameter: %*
echo Usage1: %~n0 {o2k10 ^| o2k13} {enu ^| fra ^| esn ^| jpn ^| kor ^| rus ^| ptg ^| ptb ^| deu ^| nld ^| ita ^| chs ^| cht ^| plk ^| hun ^| csy ^| sve ^| trk ^| ell ^| ara ^| heb ^| dan ^| nor ^| fin} [/excludesp ^| /excludestatics] [/excludewinglb] [/includedotnet] [/seconly] [/includemsse] [/includewddefs] [/nocleanup] [/verify] [/skiptz] [/skipdownload] [/skipdynamic] [/proxy http://[username:password@]^<server^>:^<port^>] [/wsus http://^<server^>] [/wsusonly] [/wsusbyproxy]
echo Usage2: %~n0 {w60 ^| w60-x64 ^| w61 ^| w61-x64 ^| w62-x64 ^| w63 ^| w63-x64 ^| w100 ^| w100-x64 ^| ofc ^| o2k16} {glb} [/excludesp ^| /excludestatics] [/excludewinglb] [/includedotnet] [/seconly] [/includemsse] [/includewddefs] [/nocleanup] [/verify] [/skiptz] [/skipdownload] [/skipdynamic] [/proxy http://[username:password@]^<server^>:^<port^>] [/wsus http://^<server^>] [/wsusonly] [/wsusbyproxy]
echo %DATE% %TIME% - Error: Invalid parameter: %*>>%DOWNLOAD_LOGFILE%
echo.
goto Error

:NoTemp
echo.
echo ERROR: Environment variable TEMP not set.
echo %DATE% %TIME% - Error: Environment variable TEMP not set>>%DOWNLOAD_LOGFILE%
echo.
goto Error

:NoTempDir
echo.
echo ERROR: Directory "%TEMP%" not found.
echo %DATE% %TIME% - Error: Directory "%TEMP%" not found>>%DOWNLOAD_LOGFILE%
echo.
goto Error

:InsufficientRights
echo ERROR: Insufficient file system rights.
echo %DATE% %TIME% - Error: Insufficient file system rights>>%DOWNLOAD_LOGFILE%
echo.
goto Error

:NoCScript
echo.
echo ERROR: VBScript interpreter %CSCRIPT_PATH% not found.
echo %DATE% %TIME% - Error: VBScript interpreter %CSCRIPT_PATH% not found>>%DOWNLOAD_LOGFILE%
echo.
goto Error

:NoDLdr
echo.
echo ERROR: Download utility %DLDR_PATH% not found.
echo %DATE% %TIME% - Error: Download utility %DLDR_PATH% not found>>%DOWNLOAD_LOGFILE%
echo.
goto Error

:NoUnZip
echo.
echo ERROR: Utility ..\bin\unzip.exe not found.
echo %DATE% %TIME% - Error: Utility ..\bin\unzip.exe not found>>%DOWNLOAD_LOGFILE%
echo.
goto Error

:NoHashDeep
echo.
echo ERROR: Hash computing/auditing utility ..\client\bin\%HASHDEEP_EXE% not found.
echo %DATE% %TIME% - Error: Hash computing/auditing utility ..\client\bin\%HASHDEEP_EXE% not found>>%DOWNLOAD_LOGFILE%
echo.
goto Error

:NoSigCheck
echo.
echo ERROR: Sysinternals' digital file signature verification tool %SIGCHK_PATH% not found.
echo %DATE% %TIME% - Error: Sysinternals' digital file signature verification tool %SIGCHK_PATH% not found>>%DOWNLOAD_LOGFILE%
echo.
goto Error

:DownloadError
echo.
echo ERROR: Download failure for %1 %2.
echo %DATE% %TIME% - Error: Download failure for %1 %2>>%DOWNLOAD_LOGFILE%
echo.
goto Error

:IntegrityError
echo.
echo ERROR: File integrity verification failure.
echo %DATE% %TIME% - Error: File integrity verification failure>>%DOWNLOAD_LOGFILE%
echo.
goto Error

:SignatureError
echo.
echo ERROR: Catalog file ..\client\wsus\wsusscn2.cab signature verification failure.
echo %DATE% %TIME% - Error: Catalog file ..\client\wsus\wsusscn2.cab signature verification failure>>%DOWNLOAD_LOGFILE%
echo.
goto Error

:Error
if "%EXIT_ERR%"=="1" (
  echo Note: To better help understanding this error, you can select and copy the last messages from this window using the context menu ^(right mouse click in the window^).
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
  pushd .\custom
  call FinalizationHook.cmd
  popd
  echo %DATE% %TIME% - Info: Executed custom finalization hook ^(Errorlevel: %errorlevel%^)>>%DOWNLOAD_LOGFILE%
)
echo Done.
echo %DATE% %TIME% - Info: Ending WSUS Offline Update download for %1 %2>>%DOWNLOAD_LOGFILE%
title %ComSpec%
endlocal
