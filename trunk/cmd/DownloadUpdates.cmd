@echo off
rem *** Author: T. Wittrock, Kiel ***

verify other 2>nul
setlocal enableextensions enabledelayedexpansion
if errorlevel 1 goto NoExtensions

if "%DIRCMD%" NEQ "" set DIRCMD=

cd /D "%~dp0"

set WSUSOFFLINE_VERSION=11.1+ (r917)
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
  set DLDR_PATH=..\bin\wget.exe
  set DLDR_COPT=-N
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
%Sÿ