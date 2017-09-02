@echo off
rem *** Author: T. Wittrock, Kiel ***

verify other 2>nul
setlocal enableextensions
if errorlevel 1 goto NoExtensions

if "%DIRCMD%" NEQ "" set DIRCMD=

cd /D "%~dp0"

set WSUSOFFLINE_VERSION=9.2.3
title %~n0 %*
echo Starting WSUS Offline Update (v. %WSUSOFFLINE_VERSION%) at %TIME%...
set UPDATE_LOGFILE=%SystemRoot%\wsusofflineupdate.log
rem *** Execute custom initialization hook ***
if exist .\custom\InitializationHook.cmd (
  echo Executing custom initialization hook...
  pushd .\custom
  call InitializationHook.cmd
  popd
  echo %DATE% %TIME% - Info: Executed custom initialization hook ^(Errorlevel: %errorlevel%^)>>%UPDATE_LOGFILE%
) else (
  if exist %UPDATE_LOGFILE% echo.>>%UPDATE_LOGFILE%
)
echo %DATE% %TIME% - Info: Starting WSUS Offline Update (v. %WSUSOFFLINE_VERSION%)>>%UPDATE_LOGFILE%
echo %DATE% %TIME% - Info: Used path "%~dp0" on %COMPUTERNAME% (user: %USERNAME%)>>%UPDATE_LOGFILE%

:EvalParams
if "%1"=="" goto NoMoreParams
for %%i in (/nobackup /verify /updatercerts /instie7 /instie8 /instie9 /instie10 /instie11 /instielatest /updatecpp /updatedx /instmssl /updatewmp /instdotnet35 /instdotnet4 /instpsh /instwmf /instmsse /updatetsc /instofc /instofv /autoreboot /shutdown /showlog /all /excludestatics /skipdynamic) do (
  if /i "%1"=="%%i" echo %DATE% %TIME% - Info: Option %%i detected>>%UPDATE_LOGFILE%
)
if /i "%1"=="/nobackup" set BACKUP_MODE=/nobackup
if /i "%1"=="/verify" set VERIFY_MODE=/verify
if /i "%1"=="/updatercerts" set UPDATE_RCERTS=/updatercerts
if /i "%1"=="/instie7" set INSTALL_IE=/instie7
if /i "%1"=="/instie8" set INSTALL_IE=/instie8
if /i "%1"=="/instie9" set INSTALL_IE=/instie9
if /i "%1"=="/instie10" set INSTALL_IE=/instie10
if /i "%1"=="/instie11" set INSTALL_IE=/instie11
if /i "%1"=="/instielatest" set INSTALL_IE=/instielatest
if /i "%1"=="/updatecpp" set UPDATE_CPP=/updatecpp
if /i "%1"=="/updatedx" set UPDATE_DX=/updatedx
if /i "%1"=="/instmssl" set INSTALL_MSSL=/instmssl
if /i "%1"=="/updatewmp" set UPDATE_WMP=/updatewmp
if /i "%1"=="/instdotnet35" set INSTALL_DOTNET35=/instdotnet35
if /i "%1"=="/instdotnet4" set INSTALL_DOTNET4=/instdotnet4
if /i "%1"=="/instpsh" set INSTALL_PSH=/instpsh
if /i "%1"=="/instwmf" set INSTALL_WMF=/instwmf
if /i "%1"=="/instmsse" set INSTALL_MSSE=/instmsse
if /i "%1"=="/updatetsc" set UPDATE_TSC=/updatetsc
if /i "%1"=="/instofc" set INSTALL_OFC=/instofc
if /i "%1"=="/instofv" set INSTALL_OFV=/instofv
if /i "%1"=="/autoreboot" set BOOT_MODE=/autoreboot
if /i "%1"=="/shutdown" set FINISH_MODE=/shutdown
if /i "%1"=="/showlog" set SHOW_LOG=/showlog
if /i "%1"=="/all" set LIST_MODE_IDS=/all
if /i "%1"=="/excludestatics" set LIST_MODE_UPDATES=/excludestatics
if /i "%1"=="/skipdynamic" set SKIP_DYNAMIC=/skipdynamic
shift /1
goto EvalParams

:NoMoreParams
if "%TEMP%"=="" goto NoTemp
pushd "%TEMP%"
if errorlevel 1 goto NoTempDir
popd

set CSCRIPT_PATH=%SystemRoot%\System32\cscript.exe
if not exist %CSCRIPT_PATH% goto NoCScript
set REG_PATH=%SystemRoot%\System32\reg.exe
if not exist %REG_PATH% goto NoReg

rem *** Check user's privileges ***
echo Checking user's privileges...
if not exist ..\bin\IfAdmin.exe goto NoIfAdmin
..\bin\IfAdmin.exe
if not errorlevel 1 goto NoAdmin

rem *** Determine system's properties ***
echo Determining system's properties...
%CSCRIPT_PATH% //Nologo //B //E:vbs DetermineSystemProperties.vbs
if errorlevel 1 goto NoSysEnvVars
if not exist "%TEMP%\SetSystemEnvVars.cmd" goto NoSysEnvVars

rem *** Set environment variables for system's properties ***
call "%TEMP%\SetSystemEnvVars.cmd"
del "%TEMP%\SetSystemEnvVars.cmd"
if "%SystemDirectory%"=="" set SystemDirectory=%SystemRoot%\system32
if "%OS_ARCH%"=="" (
  if /i "%PROCESSOR_ARCHITECTURE%"=="AMD64" (set OS_ARCH=x64) else (
    if /i "%PROCESSOR_ARCHITEW6432%"=="AMD64" (set OS_ARCH=x64) else (set OS_ARCH=x86)
  )
)
if "%OS_LANG%"=="" goto UnsupLang
if /i "%OS_ARCH%"=="x64" (set HASHDEEP_PATH=..\bin\hashdeep64.exe) else (set HASHDEEP_PATH=..\bin\hashdeep.exe)

rem *** Determine DirectX main version ***
if "%UPDATE_DX%" NEQ "/updatedx" goto NoDXDiag
if "%OS_NAME%"=="w62" goto NoDXDiag
if "%OS_NAME%"=="w63" goto NoDXDiag
if not exist %SystemRoot%\System32\dxdiag.exe goto NoDXDiag
echo Determining DirectX main version...
if /i "%OS_ARCH%"=="x64" (
  %SystemRoot%\System32\dxdiag.exe /whql:off /64bit /t %TEMP%\dxdiag.txt
) else (
  %SystemRoot%\System32\dxdiag.exe /whql:off /t %TEMP%\dxdiag.txt
)
for /L %%i in (1,1,10) do (
  if exist "%TEMP%\dxdiag.txt" (goto CheckDXDiag) else (%CSCRIPT_PATH% //Nologo //B //E:vbs Sleep.vbs 100)
)
:CheckDXDiag
if not exist "%TEMP%\dxdiag.txt" goto NoDXDiag
%SystemRoot%\System32\findstr.exe /L /C:"DirectX Version" "%TEMP%\dxdiag.txt" >"%TEMP%\dxver.txt"
del "%TEMP%\dxdiag.txt"
for /F "usebackq tokens=2 delims=:" %%i in ("%TEMP%\dxver.txt") do (
  for /F "tokens=1*" %%j in ("%%i") do echo set DX_MAIN_VER=%%k>"%TEMP%\SetDXVer.cmd"
)
del "%TEMP%\dxver.txt"
call "%TEMP%\SetDXVer.cmd"
del "%TEMP%\SetDXVer.cmd"
:NoDXDiag

rem *** Set target environment variables ***
call SetTargetEnvVars.cmd
if errorlevel 1 goto Cleanup

rem *** Check number of automatic recalls ***
if "%USERNAME%"=="WOUTempAdmin" (
  echo Checking number of automatic recalls...
  if exist "%TEMP%\wourecall.%WOU_ENDLESS%" goto EndlessLoop
  if exist "%TEMP%\wourecall.5" ren "%TEMP%\wourecall.5" wourecall.6
  if exist "%TEMP%\wourecall.4" ren "%TEMP%\wourecall.4" wourecall.5
  if exist "%TEMP%\wourecall.3" ren "%TEMP%\wourecall.3" wourecall.4
  if exist "%TEMP%\wourecall.2" ren "%TEMP%\wourecall.2" wourecall.3
  if exist "%TEMP%\wourecall.1" ren "%TEMP%\wourecall.1" wourecall.2
  if not exist "%TEMP%\wourecall.*" echo. >"%TEMP%\wourecall.1"
)

rem *** Check Operating System ***
if "%OS_NAME%"=="" goto UnsupOS
if "%OS_NAME%"=="w2k" goto UnsupOS
for %%i in (x86 x64) do (if /i "%OS_ARCH%"=="%%i" goto ValidArch)
goto UnsupArch
:ValidArch

rem *** Adjust power management settings ***
if "%USERNAME%" NEQ "WOUTempAdmin" goto SkipPowerCfg
if not exist "%TEMP%\wourecall.1" goto SkipPowerCfg
rem *** Disable Screensaver for WOUTempAdmin ***
%REG_PATH% ADD "HKCU\Control Panel\Desktop" /v ScreenSaveActive /t REG_SZ /d 0 /f
if "%PWR_POL_IDX%"=="" goto SkipPowerCfg
if not exist %SystemRoot%\System32\powercfg.exe goto SkipPowerCfg
echo Adjusting power management settings...
goto PWR%OS_NAME%

:PWRwxp
:PWRw2k3
for %%i in (monitor disk standby hibernate) do (
  for %%j in (ac dc) do %SystemRoot%\System32\powercfg.exe /X %PWR_POL_IDX% /N /%%i-timeout-%%j 0
)
echo %DATE% %TIME% - Info: Adjusted power management settings>>%UPDATE_LOGFILE%
goto SkipPowerCfg

:PWRw60
:PWRw61
:PWRw62
:PWRw63
for %%i in (monitor disk standby hibernate) do (
  for %%j in (ac dc) do %SystemRoot%\System32\powercfg.exe -X -%%i-timeout-%%j 0
)
echo %DATE% %TIME% - Info: Adjusted power management settings>>%UPDATE_LOGFILE%
goto SkipPowerCfg

:SkipPowerCfg
rem *** Determine Windows licensing info ***
if exist %SystemRoot%\System32\slmgr.vbs (
  echo Determining Windows licensing info...
  %CSCRIPT_PATH% //Nologo //E:vbs %SystemRoot%\System32\slmgr.vbs -dli >"%TEMP%\slmgr-dli.txt"
  %SystemRoot%\System32\findstr.exe /N ":" "%TEMP%\slmgr-dli.txt" >"%TEMP%\wou_slmgr.txt"
  del "%TEMP%\slmgr-dli.txt"
)

rem *** Echo OS properties ***
echo Found Microsoft Windows version: %OS_VER_MAJOR%.%OS_VER_MINOR%.%OS_VER_BUILD%.%OS_VER_REVIS% (%OS_NAME% %OS_ARCH% %OS_LANG% sp%OS_SP_VER_MAJOR%)
if exist "%TEMP%\wou_slmgr.txt" (
  echo Found Microsoft Windows Software Licensing Management Tool info...
  for /F "tokens=1* delims=:" %%i in ('%SystemRoot%\System32\findstr.exe /B /L "1: 2: 3: 4: 5: 6:" "%TEMP%\wou_slmgr.txt"') do echo %%j
)
rem echo Found Windows Update Agent version: %WUA_VER_MAJOR%.%WUA_VER_MINOR%.%WUA_VER_BUILD%.%WUA_VER_REVIS%
rem echo Found Windows Installer version: %MSI_VER_MAJOR%.%MSI_VER_MINOR%.%MSI_VER_BUILD%.%MSI_VER_REVIS%
rem echo Found Windows Script Host version: %WSH_VER_MAJOR%.%WSH_VER_MINOR%.%WSH_VER_BUILD%.%WSH_VER_REVIS%
rem echo Found Internet Explorer version: %IE_VER_MAJOR%.%IE_VER_MINOR%.%IE_VER_BUILD%.%IE_VER_REVIS%
rem echo Found Trusted Root Certificates' version: %TRCERTS_VER_MAJOR%.%TRCERTS_VER_MINOR%.%TRCERTS_VER_BUILD%.%TRCERTS_VER_REVIS%
rem echo Found Revoked Root Certificates' version: %RRCERTS_VER_MAJOR%.%RRCERTS_VER_MINOR%.%RRCERTS_VER_BUILD%.%RRCERTS_VER_REVIS%
rem echo Found Microsoft Data Access Components version: %MDAC_VER_MAJOR%.%MDAC_VER_MINOR%.%MDAC_VER_BUILD%.%MDAC_VER_REVIS%
rem if "%DX_MAIN_VER%" NEQ "" echo Found Microsoft DirectX main version: %DX_MAIN_VER%
rem echo Found Microsoft DirectX core version: %DX_NAME% (%DX_CORE_VER_MAJOR%.%DX_CORE_VER_MINOR%.%DX_CORE_VER_BUILD%.%DX_CORE_VER_REVIS%)
rem echo Found Microsoft Silverlight version: %MSSL_VER_MAJOR%.%MSSL_VER_MINOR%.%MSSL_VER_BUILD%.%MSSL_VER_REVIS%
rem echo Found Windows Media Player version: %WMP_VER_MAJOR%.%WMP_VER_MINOR%.%WMP_VER_BUILD%.%WMP_VER_REVIS%
rem echo Found Remote Desktop Client version: %TSC_VER_MAJOR%.%TSC_VER_MINOR%.%TSC_VER_BUILD%.%TSC_VER_REVIS%
rem echo Found Microsoft .NET Framework 3.5 version: %DOTNET35_VER_MAJOR%.%DOTNET35_VER_MINOR%.%DOTNET35_VER_BUILD%.%DOTNET35_VER_REVIS%
rem echo Found Windows PowerShell version: %PSH_VER_MAJOR%.%PSH_VER_MINOR%
rem echo Found Microsoft .NET Framework 4 version: %DOTNET4_VER_MAJOR%.%DOTNET4_VER_MINOR%.%DOTNET4_VER_BUILD%
rem echo Found Windows Management Framework version: %WMF_VER_MAJOR%.%WMF_VER_MINOR%
rem echo Found Microsoft Security Essentials version: %MSSE_VER_MAJOR%.%MSSE_VER_MINOR%.%MSSE_VER_BUILD%.%MSSE_VER_REVIS%
rem echo Found Microsoft Security Essentials definitions version: %MSSEDEFS_VER_MAJOR%.%MSSEDEFS_VER_MINOR%.%MSSEDEFS_VER_BUILD%.%MSSEDEFS_VER_REVIS%
rem echo Found Network Inspection System definitions version: %NISDEFS_VER_MAJOR%.%NISDEFS_VER_MINOR%.%NISDEFS_VER_BUILD%.%NISDEFS_VER_REVIS%
rem echo Found Windows Defender definitions version: %WDDEFS_VER_MAJOR%.%WDDEFS_VER_MINOR%.%WDDEFS_VER_BUILD%.%WDDEFS_VER_REVIS%
if "%O2K3_VER_MAJOR%" NEQ "" (
  echo Found Microsoft Office 2003 %O2K3_VER_APP% version: %O2K3_VER_MAJOR%.%O2K3_VER_MINOR%.%O2K3_VER_BUILD%.%O2K3_VER_REVIS% ^(o2k3 %O2K3_LANG% sp%O2K3_SP_VER%^)
)
if "%O2K7_VER_MAJOR%" NEQ "" (
  echo Found Microsoft Office 2007 %O2K7_VER_APP% version: %O2K7_VER_MAJOR%.%O2K7_VER_MINOR%.%O2K7_VER_BUILD%.%O2K7_VER_REVIS% ^(o2k7 %O2K7_LANG% sp%O2K7_SP_VER%^)
)
if "%O2K10_VER_MAJOR%" NEQ "" (
  echo Found Microsoft Office 2010 %O2K10_VER_APP% version: %O2K10_VER_MAJOR%.%O2K10_VER_MINOR%.%O2K10_VER_BUILD%.%O2K10_VER_REVIS% ^(o2k10 %O2K10_ARCH% %O2K10_LANG% sp%O2K10_SP_VER%^)
)
if "%O2K13_VER_MAJOR%" NEQ "" (
  echo Found Microsoft Office 2013 %O2K13_VER_APP% version: %O2K13_VER_MAJOR%.%O2K13_VER_MINOR%.%O2K13_VER_BUILD%.%O2K13_VER_REVIS% ^(o2k13 %O2K13_ARCH% %O2K13_LANG% sp%O2K13_SP_VER%^)
)
echo %DATE% %TIME% - Info: Found Microsoft Windows version %OS_VER_MAJOR%.%OS_VER_MINOR%.%OS_VER_BUILD%.%OS_VER_REVIS% (%OS_NAME% %OS_ARCH% %OS_LANG% sp%OS_SP_VER_MAJOR%)>>%UPDATE_LOGFILE%
if exist "%TEMP%\wou_slmgr.txt" (
  echo %DATE% %TIME% - Info: Found Microsoft Windows Software Licensing Management Tool info...>>%UPDATE_LOGFILE%
  for /F "tokens=1* delims=:" %%i in ('%SystemRoot%\System32\findstr.exe /B /L "1: 2: 3: 4: 5: 6:" "%TEMP%\wou_slmgr.txt"') do echo %DATE% %TIME% - Info: %%j>>%UPDATE_LOGFILE%
  del "%TEMP%\wou_slmgr.txt"
)
echo %DATE% %TIME% - Info: Found Windows Update Agent version %WUA_VER_MAJOR%.%WUA_VER_MINOR%.%WUA_VER_BUILD%.%WUA_VER_REVIS%>>%UPDATE_LOGFILE%
echo %DATE% %TIME% - Info: Found Windows Installer version %MSI_VER_MAJOR%.%MSI_VER_MINOR%.%MSI_VER_BUILD%.%MSI_VER_REVIS%>>%UPDATE_LOGFILE%
echo %DATE% %TIME% - Info: Found Windows Script Host version %WSH_VER_MAJOR%.%WSH_VER_MINOR%.%WSH_VER_BUILD%.%WSH_VER_REVIS%>>%UPDATE_LOGFILE%
echo %DATE% %TIME% - Info: Found Internet Explorer version %IE_VER_MAJOR%.%IE_VER_MINOR%.%IE_VER_BUILD%.%IE_VER_REVIS%>>%UPDATE_LOGFILE%
echo %DATE% %TIME% - Info: Found Trusted Root Certificates' version %TRCERTS_VER_MAJOR%.%TRCERTS_VER_MINOR%.%TRCERTS_VER_BUILD%.%TRCERTS_VER_REVIS%>>%UPDATE_LOGFILE%
echo %DATE% %TIME% - Info: Found Revoked Root Certificates' version %RRCERTS_VER_MAJOR%.%RRCERTS_VER_MINOR%.%RRCERTS_VER_BUILD%.%RRCERTS_VER_REVIS%>>%UPDATE_LOGFILE%
echo %DATE% %TIME% - Info: Found Microsoft Data Access Components version %MDAC_VER_MAJOR%.%MDAC_VER_MINOR%.%MDAC_VER_BUILD%.%MDAC_VER_REVIS%>>%UPDATE_LOGFILE%
if "%DX_MAIN_VER%" NEQ "" echo %DATE% %TIME% - Info: Found Microsoft DirectX main version %DX_MAIN_VER%>>%UPDATE_LOGFILE%
echo %DATE% %TIME% - Info: Found Microsoft DirectX core version %DX_NAME% (%DX_CORE_VER_MAJOR%.%DX_CORE_VER_MINOR%.%DX_CORE_VER_BUILD%.%DX_CORE_VER_REVIS%)>>%UPDATE_LOGFILE%
echo %DATE% %TIME% - Info: Found Microsoft Silverlight version %MSSL_VER_MAJOR%.%MSSL_VER_MINOR%.%MSSL_VER_BUILD%.%MSSL_VER_REVIS%>>%UPDATE_LOGFILE%
echo %DATE% %TIME% - Info: Found Windows Media Player version %WMP_VER_MAJOR%.%WMP_VER_MINOR%.%WMP_VER_BUILD%.%WMP_VER_REVIS%>>%UPDATE_LOGFILE%
echo %DATE% %TIME% - Info: Found Remote Desktop Client version %TSC_VER_MAJOR%.%TSC_VER_MINOR%.%TSC_VER_BUILD%.%TSC_VER_REVIS%>>%UPDATE_LOGFILE%
echo %DATE% %TIME% - Info: Found Microsoft .NET Framework 3.5 version %DOTNET35_VER_MAJOR%.%DOTNET35_VER_MINOR%.%DOTNET35_VER_BUILD%.%DOTNET35_VER_REVIS%>>%UPDATE_LOGFILE%
echo %DATE% %TIME% - Info: Found Windows PowerShell version %PSH_VER_MAJOR%.%PSH_VER_MINOR%>>%UPDATE_LOGFILE%
echo %DATE% %TIME% - Info: Found Microsoft .NET Framework 4 version %DOTNET4_VER_MAJOR%.%DOTNET4_VER_MINOR%.%DOTNET4_VER_BUILD%>>%UPDATE_LOGFILE%
echo %DATE% %TIME% - Info: Found Windows Management Framework version %WMF_VER_MAJOR%.%WMF_VER_MINOR%>>%UPDATE_LOGFILE%
if "%OS_NAME%"=="w62" goto SkipLogMSSEVer
if "%OS_NAME%"=="w63" goto SkipLogMSSEVer
echo %DATE% %TIME% - Info: Found Microsoft Security Essentials version %MSSE_VER_MAJOR%.%MSSE_VER_MINOR%.%MSSE_VER_BUILD%.%MSSE_VER_REVIS%>>%UPDATE_LOGFILE%
echo %DATE% %TIME% - Info: Found Microsoft Security Essentials definitions version %MSSEDEFS_VER_MAJOR%.%MSSEDEFS_VER_MINOR%.%MSSEDEFS_VER_BUILD%.%MSSEDEFS_VER_REVIS%>>%UPDATE_LOGFILE%
echo %DATE% %TIME% - Info: Found Network Inspection System definitions version %NISDEFS_VER_MAJOR%.%NISDEFS_VER_MINOR%.%NISDEFS_VER_BUILD%.%NISDEFS_VER_REVIS%>>%UPDATE_LOGFILE%
:SkipLogMSSEVer
echo %DATE% %TIME% - Info: Found Windows Defender definitions version %WDDEFS_VER_MAJOR%.%WDDEFS_VER_MINOR%.%WDDEFS_VER_BUILD%.%WDDEFS_VER_REVIS%>>%UPDATE_LOGFILE%
if "%O2K3_VER_MAJOR%" NEQ "" (
  echo %DATE% %TIME% - Info: Found Microsoft Office 2003 %O2K3_VER_APP% version %O2K3_VER_MAJOR%.%O2K3_VER_MINOR%.%O2K3_VER_BUILD%.%O2K3_VER_REVIS% ^(o2k3 %O2K3_LANG% sp%O2K3_SP_VER%^)>>%UPDATE_LOGFILE%
)
if "%O2K7_VER_MAJOR%" NEQ "" (
  echo %DATE% %TIME% - Info: Found Microsoft Office 2007 %O2K7_VER_APP% version %O2K7_VER_MAJOR%.%O2K7_VER_MINOR%.%O2K7_VER_BUILD%.%O2K7_VER_REVIS% ^(o2k7 %O2K7_LANG% sp%O2K7_SP_VER%^)>>%UPDATE_LOGFILE%
)
if "%O2K10_VER_MAJOR%" NEQ "" (
  echo %DATE% %TIME% - Info: Found Microsoft Office 2010 %O2K10_VER_APP% version %O2K10_VER_MAJOR%.%O2K10_VER_MINOR%.%O2K10_VER_BUILD%.%O2K10_VER_REVIS% ^(o2k10 %O2K10_ARCH% %O2K10_LANG% sp%O2K10_SP_VER%^)>>%UPDATE_LOGFILE%
)
if "%O2K13_VER_MAJOR%" NEQ "" (
  echo %DATE% %TIME% - Info: Found Microsoft Office 2013 %O2K13_VER_APP% version %O2K13_VER_MAJOR%.%O2K13_VER_MINOR%.%O2K13_VER_BUILD%.%O2K13_VER_REVIS% ^(o2k13 %O2K13_ARCH% %O2K13_LANG% sp%O2K13_SP_VER%^)>>%UPDATE_LOGFILE%
)

rem *** Check medium content ***
echo Checking medium content...
if exist ..\builddate.txt (
  for /F %%i in ('type ..\builddate.txt') do (
    echo Medium build date: %%i
    echo %DATE% %TIME% - Info: Medium build date: %%i>>%UPDATE_LOGFILE%
  )
)
if /i "%OS_ARCH%"=="x64" (
  if exist ..\%OS_NAME%-%OS_ARCH%\%OS_LANG%\nul (
    echo Medium supports Microsoft Windows ^(%OS_NAME% %OS_ARCH% %OS_LANG%^).
    echo %DATE% %TIME% - Info: Medium supports Microsoft Windows ^(%OS_NAME% %OS_ARCH% %OS_LANG%^)>>%UPDATE_LOGFILE%
    goto CheckOfficeMedium
  )
  if exist ..\%OS_NAME%-%OS_ARCH%\glb\nul (
    echo Medium supports Microsoft Windows ^(%OS_NAME% %OS_ARCH% glb^).
    echo %DATE% %TIME% - Info: Medium supports Microsoft Windows ^(%OS_NAME% %OS_ARCH% glb^)>>%UPDATE_LOGFILE%
    goto CheckOfficeMedium
  )
) else (
  if exist ..\%OS_NAME%\%OS_LANG%\nul (
    echo Medium supports Microsoft Windows ^(%OS_NAME% %OS_ARCH% %OS_LANG%^).
    echo %DATE% %TIME% - Info: Medium supports Microsoft Windows ^(%OS_NAME% %OS_ARCH% %OS_LANG%^)>>%UPDATE_LOGFILE%
    goto CheckOfficeMedium
  )
  if exist ..\%OS_NAME%\glb\nul (
    echo Medium supports Microsoft Windows ^(%OS_NAME% %OS_ARCH% glb^).
    echo %DATE% %TIME% - Info: Medium supports Microsoft Windows ^(%OS_NAME% %OS_ARCH% glb^)>>%UPDATE_LOGFILE%
    goto CheckOfficeMedium
  )
)
echo Medium does not support Microsoft Windows (%OS_NAME% %OS_ARCH% %OS_LANG%).
echo %DATE% %TIME% - Info: Medium does not support Microsoft Windows (%OS_NAME% %OS_ARCH% %OS_LANG%)>>%UPDATE_LOGFILE%
if "%OFC_NAME%"=="" goto InvalidMedium

:CheckOfficeMedium
if "%OFC_NAME%"=="" goto ProperMedium
if exist ..\ofc\%OFC_LANG%\nul (
  echo Medium supports Microsoft Office ^(ofc %OFC_LANG%^).
  echo %DATE% %TIME% - Info: Medium supports Microsoft Office ^(ofc %OFC_LANG%^)>>%UPDATE_LOGFILE%
  goto ProperMedium
)
if exist ..\ofc\glb\nul (
  echo Medium supports Microsoft Office ^(ofc glb^).
  echo %DATE% %TIME% - Info: Medium supports Microsoft Office ^(ofc glb^)>>%UPDATE_LOGFILE%
  goto ProperMedium
)
echo Medium does not support Microsoft Office (ofc glb).
echo %DATE% %TIME% - Info: Medium does not support Microsoft Office (ofc glb)>>%UPDATE_LOGFILE%
:ProperMedium

rem *** Install Windows Service Pack ***
if "%OS_NAME%"=="w63" goto SPw63
echo Checking Windows Service Pack version...
if %OS_SP_VER_MAJOR% GEQ %OS_SP_VER_TARGET_MAJOR% goto SkipSPInst
if "%OS_SP_TARGET_ID%"=="" goto NoSPTargetId
echo %OS_SP_TARGET_ID%>"%TEMP%\MissingUpdateIds.txt"
call ListUpdatesToInstall.cmd /excludestatics /ignoreblacklist
if errorlevel 1 goto ListError
if not exist "%TEMP%\UpdatesToInstall.txt" (
  echo Warning: Windows Service Pack installation file ^(kb%OS_SP_TARGET_ID%^) not found.
  echo %DATE% %TIME% - Warning: Windows Service Pack installation file ^(kb%OS_SP_TARGET_ID%^) not found>>%UPDATE_LOGFILE%
  goto SkipSPInst
)
echo Installing most recent Windows Service Pack...
goto SP%OS_NAME%

:SPwxp
if 0 EQU %OS_SP_VER_MAJOR% (
  echo Faking Windows XP Service Pack 1...
  %REG_PATH% ADD HKLM\SYSTEM\CurrentControlSet\Control\Windows /v CSDVersion /t REG_DWORD /d 0x100 /f >nul 2>&1
  if errorlevel 1 (
    echo Warning: Faking of Windows XP Service Pack 1 failed.
    echo %DATE% %TIME% - Warning: Faking of Windows XP Service Pack 1 failed>>%UPDATE_LOGFILE%
    goto SkipSPInst
  ) else (
    echo %DATE% %TIME% - Info: Faked Windows XP Service Pack ^1>>%UPDATE_LOGFILE%
  )
)
:SPw2k3
echo %DATE% %TIME% - Info: Installing most recent Service Pack for Windows XP / Server 2003>>%UPDATE_LOGFILE%
if "%BACKUP_MODE%"=="/nobackup" (
  call InstallListedUpdates.cmd %VERIFY_MODE% /u /z /n
) else (
  call InstallListedUpdates.cmd %VERIFY_MODE% /u /z
)
if errorlevel 1 goto InstError
set RECALL_REQUIRED=1
goto Installed

:SPw60
:SPw61
:SPw62
if "%BOOT_MODE%" NEQ "/autoreboot" goto SPw6Now
if "%USERNAME%"=="WOUTempAdmin" goto SPw6Now
echo %DATE% %TIME% - Info: Preparing installation of most recent Service Pack for Windows Vista / ^7>>%UPDATE_LOGFILE%
set RECALL_REQUIRED=1
goto Installed
:SPw6Now
echo %DATE% %TIME% - Info: Installing most recent Service Pack for Windows Vista / ^7>>%UPDATE_LOGFILE%
call InstallListedUpdates.cmd %VERIFY_MODE% /unattend /forcerestart
if errorlevel 1 goto InstError
set RECALL_REQUIRED=1
goto Installed

:SPw63
if exist %SystemRoot%\Temp\wou_w63upd_tried.txt goto SkipSPInst
echo Checking Windows 8.1 Update 1 installation state...
%CSCRIPT_PATH% //Nologo //B //E:vbs ListInstalledUpdateIds.vbs
if exist "%TEMP%\InstalledUpdateIds.txt" (
  %SystemRoot%\System32\find.exe /I "%OS_SP_TARGET_ID%" "%TEMP%\InstalledUpdateIds.txt" >nul 2>&1
  if not errorlevel 1 (
    del "%TEMP%\InstalledUpdateIds.txt"
    goto SkipSPInst
  )
  del "%TEMP%\InstalledUpdateIds.txt"
)
copy /Y ..\static\StaticUpdateIds-w63-upd1.txt "%TEMP%\MissingUpdateIds.txt" >nul
call ListUpdatesToInstall.cmd /excludestatics /ignoreblacklist
if errorlevel 1 goto ListError
if exist "%TEMP%\UpdatesToInstall.txt" (
  echo Installing Windows 8.1 Update 1...
  echo %DATE% %TIME% - Info: Installing Windows 8.1 Update ^1>>%UPDATE_LOGFILE%
  call InstallListedUpdates.cmd %VERIFY_MODE% /errorsaswarnings
  if not errorlevel 1 (
    if not exist %SystemRoot%\Temp\nul md %SystemRoot%\Temp
    echo. >%SystemRoot%\Temp\wou_w63upd_tried.txt
    set RECALL_REQUIRED=1
    goto Installed
  )
) else (
  echo Warning: Windows 8.1 Update 1 installation files not found.
  echo %DATE% %TIME% - Warning: Windows 8.1 Update 1 installation files not found>>%UPDATE_LOGFILE%
  if not exist %SystemRoot%\Temp\nul md %SystemRoot%\Temp
  echo. >%SystemRoot%\Temp\wou_w63upd_tried.txt
)
:SkipSPInst

rem *** Install Windows Update Agent ***
echo Checking Windows Update Agent version...
if %WUA_VER_MAJOR% LSS %WUA_VER_TARGET_MAJOR% goto InstallWUA
if %WUA_VER_MAJOR% GTR %WUA_VER_TARGET_MAJOR% goto SkipWUAInst
if %WUA_VER_MINOR% LSS %WUA_VER_TARGET_MINOR% goto InstallWUA
if %WUA_VER_MINOR% GTR %WUA_VER_TARGET_MINOR% goto SkipWUAInst
if %WUA_VER_BUILD% LSS %WUA_VER_TARGET_BUILD% goto InstallWUA
if %WUA_VER_BUILD% GTR %WUA_VER_TARGET_BUILD% goto SkipWUAInst
if %WUA_VER_REVIS% GEQ %WUA_VER_TARGET_REVIS% goto SkipWUAInst
:InstallWUA
set WUA_FILENAME=..\wsus\WindowsUpdateAgent*-%OS_ARCH%.exe
dir /B %WUA_FILENAME% >nul 2>&1
if errorlevel 1 goto NoWUAInst
echo Installing most recent Windows Update Agent...
for /F %%i in ('dir /B %WUA_FILENAME%') do (
  call InstallOSUpdate.cmd ..\wsus\%%i %VERIFY_MODE% /ignoreerrors /wuforce /quiet /norestart
  if errorlevel 1 goto InstError
  set REBOOT_REQUIRED=1
)
set WUA_FILENAME=
:SkipWUAInst

rem *** Install Windows Installer ***
echo Checking Windows Installer version...
if %MSI_VER_MAJOR% LSS %MSI_VER_TARGET_MAJOR% goto InstallMSI
if %MSI_VER_MAJOR% GTR %MSI_VER_TARGET_MAJOR% goto SkipMSIInst
if %MSI_VER_MINOR% LSS %MSI_VER_TARGET_MINOR% goto InstallMSI
if %MSI_VER_MINOR% GTR %MSI_VER_TARGET_MINOR% goto SkipMSIInst
if %MSI_VER_BUILD% LSS %MSI_VER_TARGET_BUILD% goto InstallMSI
if %MSI_VER_BUILD% GTR %MSI_VER_TARGET_BUILD% goto SkipMSIInst
if %MSI_VER_REVIS% GEQ %MSI_VER_TARGET_REVIS% goto SkipMSIInst
:InstallMSI
if "%MSI_TARGET_ID%"=="" (
  echo Warning: Environment variable MSI_TARGET_ID not set.
  echo %DATE% %TIME% - Warning: Environment variable MSI_TARGET_ID not set>>%UPDATE_LOGFILE%
  goto SkipMSIInst
)
if /i "%OS_ARCH%"=="x64" (
  set MSI_FILENAME=..\%OS_NAME%-%OS_ARCH%\glb\*%MSI_TARGET_ID%*-%OS_ARCH%.*
) else (
  set MSI_FILENAME=..\%OS_NAME%\glb\*%MSI_TARGET_ID%*-%OS_ARCH%.*
)
dir /B %MSI_FILENAME% >nul 2>&1
if errorlevel 1 (
  echo Warning: File %MSI_FILENAME% not found.
  echo %DATE% %TIME% - Warning: File %MSI_FILENAME% not found>>%UPDATE_LOGFILE%
  goto SkipMSIInst
)
echo Installing most recent Windows Installer...
for /F %%i in ('dir /B %MSI_FILENAME%') do (
  if /i "%OS_ARCH%"=="x64" (
    call InstallOSUpdate.cmd ..\%OS_NAME%-%OS_ARCH%\glb\%%i %VERIFY_MODE% /quiet %BACKUP_MODE% /norestart
  ) else (
    call InstallOSUpdate.cmd ..\%OS_NAME%\glb\%%i %VERIFY_MODE% /quiet %BACKUP_MODE% /norestart
  )
  if not errorlevel 1 set REBOOT_REQUIRED=1
)
set MSI_FILENAME=
:SkipMSIInst

rem *** Install Windows Script Host ***
echo Checking Windows Script Host version...
if %WSH_VER_MAJOR% LSS %WSH_VER_TARGET_MAJOR% goto InstallWSH
if %WSH_VER_MAJOR% GTR %WSH_VER_TARGET_MAJOR% goto SkipWSHInst
if %WSH_VER_MINOR% LSS %WSH_VER_TARGET_MINOR% goto InstallWSH
if %WSH_VER_MINOR% GTR %WSH_VER_TARGET_MINOR% goto SkipWSHInst
if %WSH_VER_BUILD% LSS %WSH_VER_TARGET_BUILD% goto InstallWSH
if %WSH_VER_BUILD% GTR %WSH_VER_TARGET_BUILD% goto SkipWSHInst
if %WSH_VER_REVIS% GEQ %WSH_VER_TARGET_REVIS% goto SkipWSHInst
:InstallWSH
set WSH_FILENAME=..\%OS_NAME%\glb\scripten.exe
if not exist %WSH_FILENAME% (
  echo Warning: File %WSH_FILENAME% not found.
  echo %DATE% %TIME% - Warning: File %WSH_FILENAME% not found>>%UPDATE_LOGFILE%
  goto SkipWSHInst
)
echo Installing most recent Windows Script Host...
for /F %%i in ('dir /B %WSH_FILENAME%') do (
  call InstallOSUpdate.cmd ..\%OS_NAME%\glb\%%i %VERIFY_MODE% /quiet %BACKUP_MODE% /norestart
  if not errorlevel 1 set REBOOT_REQUIRED=1
)
set WSH_FILENAME=
:SkipWSHInst

rem *** Install Internet Explorer ***
if "%OS_CORE%"=="1" goto SkipIEInst
echo Checking Internet Explorer version...
if %IE_VER_MAJOR% LSS %IE_VER_TARGET_MAJOR% goto InstallIE
if %IE_VER_MAJOR% GTR %IE_VER_TARGET_MAJOR% goto SkipIEInst
if %IE_VER_MINOR% LSS %IE_VER_TARGET_MINOR% goto InstallIE
if %IE_VER_MINOR% GTR %IE_VER_TARGET_MINOR% goto SkipIEInst
if %IE_VER_BUILD% LSS %IE_VER_TARGET_BUILD% goto InstallIE
if %IE_VER_BUILD% GTR %IE_VER_TARGET_BUILD% goto SkipIEInst
if %IE_VER_REVIS% GEQ %IE_VER_TARGET_REVIS% goto SkipIEInst
:InstallIE
goto IE%OS_NAME%

:IEwxp
if "%INSTALL_IE%"=="/instie8" (
  set IE_FILENAME=..\%OS_NAME%\%OS_LANG%\IE8-WindowsXP-%OS_ARCH%-%OS_LANG%*.exe
) else (
  set IE_FILENAME=..\%OS_NAME%\%OS_LANG%\ie7-windowsxp-%OS_ARCH%-%OS_LANG%*.exe
)
goto IEwxp2k3

:IEw2k3
if /i "%OS_ARCH%"=="x64" (
  if "%INSTALL_IE%"=="/instie8" (
    set IE_FILENAME=..\%OS_NAME%-%OS_ARCH%\%OS_LANG%\IE8-WindowsServer2003-%OS_ARCH%-%OS_LANG%*.exe
  ) else (
    set IE_FILENAME=..\%OS_NAME%-%OS_ARCH%\%OS_LANG%\ie7-windowsserver2003-%OS_ARCH%-%OS_LANG%*.exe
  )
) else (
  if "%INSTALL_IE%"=="/instie8" (
    set IE_FILENAME=..\%OS_NAME%\%OS_LANG%\IE8-WindowsServer2003-%OS_ARCH%-%OS_LANG%*.exe
  ) else (
    set IE_FILENAME=..\%OS_NAME%\%OS_LANG%\ie7-windowsserver2003-%OS_ARCH%-%OS_LANG%*.exe
  )
)
goto IEwxp2k3

:IEwxp2k3
dir /B %IE_FILENAME% >nul 2>&1
if errorlevel 1 (
  echo Warning: File %IE_FILENAME% not found.
  echo %DATE% %TIME% - Warning: File %IE_FILENAME% not found>>%UPDATE_LOGFILE%
  goto SkipIEInst
)
if "%INSTALL_IE%"=="/instie8" (echo Installing Internet Explorer 8...) else (echo Installing Internet Explorer 7...)
for /F %%i in ('dir /B %IE_FILENAME%') do (
  if /i "%OS_ARCH%"=="x64" (
    if "%INSTALL_IE%"=="/instie8" (
      call InstallOSUpdate.cmd ..\%OS_NAME%-%OS_ARCH%\%OS_LANG%\%%i %VERIFY_MODE% /ignoreerrors /passive /update-no /no-default /norestart
    ) else (
      call InstallOSUpdate.cmd ..\%OS_NAME%-%OS_ARCH%\%OS_LANG%\%%i %VERIFY_MODE% /ignoreerrors /passive /update-no /no-default %BACKUP_MODE% /norestart
    )
  ) else (
    if "%INSTALL_IE%"=="/instie8" (
      call InstallOSUpdate.cmd ..\%OS_NAME%\%OS_LANG%\%%i %VERIFY_MODE% /ignoreerrors /passive /update-no /no-default /norestart
    ) else (
      call InstallOSUpdate.cmd ..\%OS_NAME%\%OS_LANG%\%%i %VERIFY_MODE% /ignoreerrors /passive /update-no /no-default %BACKUP_MODE% /norestart
    )
  )
  if not errorlevel 1 set RECALL_REQUIRED=1
)
goto IEInstalled

:IEw60
if exist %SystemRoot%\Temp\wou_ie_tried.txt goto SkipIEInst
if /i "%OS_ARCH%"=="x64" (
  if "%INSTALL_IE%"=="/instie9" (
    set IE_FILENAME=..\%OS_NAME%-%OS_ARCH%\glb\IE9-WindowsVista-%OS_ARCH%-%OS_LANG%*.exe
  ) else (
    set IE_FILENAME=..\%OS_NAME%-%OS_ARCH%\glb\IE8-WindowsVista-%OS_ARCH%-%OS_LANG%*.exe
  )
) else (
  if "%INSTALL_IE%"=="/instie9" (
    set IE_FILENAME=..\%OS_NAME%\glb\IE9-WindowsVista-%OS_ARCH%-%OS_LANG%*.exe
  ) else (
    set IE_FILENAME=..\%OS_NAME%\glb\IE8-WindowsVista-%OS_ARCH%-%OS_LANG%*.exe
  )
)
dir /B %IE_FILENAME% >nul 2>&1
if errorlevel 1 (
  echo Warning: File %IE_FILENAME% not found.
  echo %DATE% %TIME% - Warning: File %IE_FILENAME% not found>>%UPDATE_LOGFILE%
  goto SkipIEInst
)
if "%INSTALL_IE%"=="/instie9" (
  if exist %SystemRoot%\Temp\wou_iepre_tried.txt goto SkipIE9Pre
  echo Checking Internet Explorer 9 prerequisites...
  %CSCRIPT_PATH% //Nologo //B //E:vbs ListInstalledUpdateIds.vbs
  if exist "%TEMP%\InstalledUpdateIds.txt" (
    %SystemRoot%\System32\findstr.exe /L /I /V /G:"%TEMP%\InstalledUpdateIds.txt" ..\static\StaticUpdateIds-ie9-w60.txt >"%TEMP%\MissingUpdateIds.txt"
    del "%TEMP%\InstalledUpdateIds.txt"
  ) else (
    copy /Y ..\static\StaticUpdateIds-ie9-w60.txt "%TEMP%\MissingUpdateIds.txt" >nul
  )
  call ListUpdatesToInstall.cmd /excludestatics /ignoreblacklist
  if errorlevel 1 goto ListError
  if exist "%TEMP%\UpdatesToInstall.txt" (
    echo Installing Internet Explorer 9 prerequisites...
    call InstallListedUpdates.cmd /selectoptions %BACKUP_MODE% %VERIFY_MODE% /ignoreerrors
    if not errorlevel 1 (
      if not exist %SystemRoot%\Temp\nul md %SystemRoot%\Temp
      echo. >%SystemRoot%\Temp\wou_iepre_tried.txt
      set RECALL_REQUIRED=1
      goto IEInstalled
    )
  )
)
:SkipIE9Pre
for /F %%i in ('dir /B %IE_FILENAME%') do (
  if "%INSTALL_IE%"=="/instie9" (
    echo Installing Internet Explorer 9...
    if /i "%OS_ARCH%"=="x64" (
      call InstallOSUpdate.cmd ..\%OS_NAME%-%OS_ARCH%\glb\%%i %VERIFY_MODE% /ignoreerrors /passive /update-no /closeprograms /no-default /norestart
    ) else (
      call InstallOSUpdate.cmd ..\%OS_NAME%\glb\%%i %VERIFY_MODE% /ignoreerrors /passive /update-no /closeprograms /no-default /norestart
    )
  ) else (
    echo Installing Internet Explorer 8...
    if /i "%OS_ARCH%"=="x64" (
      call InstallOSUpdate.cmd ..\%OS_NAME%-%OS_ARCH%\glb\%%i %VERIFY_MODE% /ignoreerrors /passive /update-no /no-default /norestart
    ) else (
      call InstallOSUpdate.cmd ..\%OS_NAME%\glb\%%i %VERIFY_MODE% /ignoreerrors /passive /update-no /no-default /norestart
    )
  )
  if not errorlevel 1 set RECALL_REQUIRED=1
  if not exist %SystemRoot%\Temp\nul md %SystemRoot%\Temp
  echo. >%SystemRoot%\Temp\wou_ie_tried.txt
)
goto IEInstalled

:IEw61
if exist %SystemRoot%\Temp\wou_ie_tried.txt goto SkipIEInst
if /i "%OS_ARCH%"=="x64" (
  if "%INSTALL_IE%"=="/instie11" (
    set IE_FILENAME=..\%OS_NAME%-%OS_ARCH%\glb\IE11-Windows6.1-%OS_ARCH%-%OS_LANG_EXT%*.exe
  ) else (
    if "%INSTALL_IE%"=="/instie10" (
      set IE_FILENAME=..\%OS_NAME%-%OS_ARCH%\glb\IE10-Windows6.1-%OS_ARCH%-%OS_LANG_EXT%*.exe
    ) else (
      set IE_FILENAME=..\%OS_NAME%-%OS_ARCH%\glb\IE9-Windows7-%OS_ARCH%-%OS_LANG%*.exe
    )
  )
) else (
  if "%INSTALL_IE%"=="/instie11" (
    set IE_FILENAME=..\%OS_NAME%\glb\IE11-Windows6.1-%OS_ARCH%-%OS_LANG_EXT%*.exe
  ) else (
    if "%INSTALL_IE%"=="/instie10" (
      set IE_FILENAME=..\%OS_NAME%\glb\IE10-Windows6.1-%OS_ARCH%-%OS_LANG_EXT%*.exe
    ) else (
      set IE_FILENAME=..\%OS_NAME%\glb\IE9-Windows7-%OS_ARCH%-%OS_LANG%*.exe
    )
  )
)
dir /B %IE_FILENAME% >nul 2>&1
if errorlevel 1 (
  echo Warning: File %IE_FILENAME% not found.
  echo %DATE% %TIME% - Warning: File %IE_FILENAME% not found>>%UPDATE_LOGFILE%
  goto SkipIEInst
)
if "%INSTALL_IE%"=="/instie9" goto SkipIE10Pre
if exist %SystemRoot%\Temp\wou_iepre_tried.txt goto SkipIE10Pre
echo Checking Internet Explorer 10/11 prerequisites...
%CSCRIPT_PATH% //Nologo //B //E:vbs ListInstalledUpdateIds.vbs
if exist "%TEMP%\InstalledUpdateIds.txt" (
  %SystemRoot%\System32\findstr.exe /L /I /V /G:"%TEMP%\InstalledUpdateIds.txt" ..\static\StaticUpdateIds-ie10-w61.txt >"%TEMP%\MissingUpdateIds.txt"
  del "%TEMP%\InstalledUpdateIds.txt"
) else (
  copy /Y ..\static\StaticUpdateIds-ie10-w61.txt "%TEMP%\MissingUpdateIds.txt" >nul
)
call ListUpdatesToInstall.cmd /excludestatics /ignoreblacklist
if errorlevel 1 goto ListError
if exist "%TEMP%\UpdatesToInstall.txt" (
  echo Installing Internet Explorer 10/11 prerequisites...
  call InstallListedUpdates.cmd /selectoptions %BACKUP_MODE% %VERIFY_MODE% /ignoreerrors
  if not errorlevel 1 (
    if not exist %SystemRoot%\Temp\nul md %SystemRoot%\Temp
    echo. >%SystemRoot%\Temp\wou_iepre_tried.txt
    set RECALL_REQUIRED=1
    goto IEInstalled
  )
)
:SkipIE10Pre
if "%INSTALL_IE%"=="/instie11" (echo Installing Internet Explorer 11...) else (
  if "%INSTALL_IE%"=="/instie10" (echo Installing Internet Explorer 10...) else (echo Installing Internet Explorer 9...)
)
for /F %%i in ('dir /B %IE_FILENAME%') do (
  if /i "%OS_ARCH%"=="x64" (
    call InstallOSUpdate.cmd ..\%OS_NAME%-%OS_ARCH%\glb\%%i %VERIFY_MODE% /ignoreerrors /passive /update-no /closeprograms /no-default /norestart
  ) else (
    call InstallOSUpdate.cmd ..\%OS_NAME%\glb\%%i %VERIFY_MODE% /ignoreerrors /passive /update-no /closeprograms /no-default /norestart
  )
  if not errorlevel 1 set RECALL_REQUIRED=1
  if not exist %SystemRoot%\Temp\nul md %SystemRoot%\Temp
  echo. >%SystemRoot%\Temp\wou_ie_tried.txt
)
goto IEInstalled

:IEw62
:IEw63
:IEInstalled
set IE_FILENAME=
if "%RECALL_REQUIRED%"=="1" goto Installed
:SkipIEInst

rem *** Install update for Trusted Root Certificates ***
if "%UPDATE_RCERTS%" NEQ "/updatercerts" goto SkipTRCertsInst
echo Checking Trusted Root Certificates' version...
set TRCERTS_FILENAME=..\win\glb\rootsupd.exe
if not exist %TRCERTS_FILENAME% (
  echo Warning: File %TRCERTS_FILENAME% not found.
  echo %DATE% %TIME% - Warning: File %TRCERTS_FILENAME% not found>>%UPDATE_LOGFILE%
  goto SkipTRCertsInst
)
%TRCERTS_FILENAME% /T:"%TEMP%\rootsupd" /C /Q
for /F "tokens=2 delims== " %%i in ('%SystemRoot%\System32\findstr.exe /B /L /I "Version" "%TEMP%\rootsupd\rootsupd.inf"') do (
  call SafeRmDir.cmd "%TEMP%\rootsupd"
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
:InstallTRCerts
echo Installing most recent update for Trusted Root Certificates...
call InstallOSUpdate.cmd %TRCERTS_FILENAME% %VERIFY_MODE% /errorsaswarnings /Q
set TRCERTS_FILENAME=
:SkipTRCertsInst

rem *** Install update for Revoked Root Certificates ***
if "%UPDATE_RCERTS%" NEQ "/updatercerts" goto SkipRRCertsInst
echo Checking Revoked Root Certificates' version...
set RRCERTS_FILENAME=..\win\glb\rvkroots.exe
if not exist %RRCERTS_FILENAME% (
  echo Warning: File %RRCERTS_FILENAME% not found.
  echo %DATE% %TIME% - Warning: File %RRCERTS_FILENAME% not found>>%UPDATE_LOGFILE%
  goto SkipRRCertsInst
)
%RRCERTS_FILENAME% /T:"%TEMP%\rvkroots" /C /Q
for /F "tokens=2 delims== " %%i in ('%SystemRoot%\System32\findstr.exe /B /L /I "Version" "%TEMP%\rvkroots\rvkroots.inf"') do (
  call SafeRmDir.cmd "%TEMP%\rvkroots"
  for /F "tokens=1-4 delims=," %%j in (%%i) do (
    if %RRCERTS_VER_MAJOR% LSS %%j goto InstallRRCerts
    if %RRCERTS_VER_MAJOR% GTR %%j goto SkipRRCertsInst
    if %RRCERTS_VER_MINOR% LSS %%k goto InstallRRCerts
    if %RRCERTS_VER_MINOR% GTR %%k goto SkipRRCertsInst
    if %RRCERTS_VER_BUILD% LSS %%l goto InstallRRCerts
    if %RRCERTS_VER_BUILD% GTR %%l goto SkipRRCertsInst
    if %RRCERTS_VER_REVIS% GEQ %%m goto SkipRRCertsInst
  )
)
:InstallRRCerts
echo Installing most recent update for Revoked Root Certificates...
call InstallOSUpdate.cmd %RRCERTS_FILENAME% %VERIFY_MODE% /errorsaswarnings /Q
set RRCERTS_FILENAME=
:SkipRRCertsInst

rem *** Install C++ Runtime Libraries ***
if "%UPDATE_CPP%" NEQ "/updatecpp" goto SkipCPPInst
echo Checking C++ Runtime Libraries' installation state...
goto CPPInst%OS_ARCH%

:CPPInstx64
if "%CPP_2005_x64%"=="1" (
  if exist ..\cpp\vcredist2005_x64.exe (
    echo Installing most recent C++ 2005 x64 Runtime Library...
    call InstallOSUpdate.cmd ..\cpp\vcredist2005_x64.exe %VERIFY_MODE% /errorsaswarnings /Q /r:n
  ) else (
    echo Warning: File ..\cpp\vcredist2005_x64.exe not found.
    echo %DATE% %TIME% - Warning: File ..\cpp\vcredist2005_x64.exe not found>>%UPDATE_LOGFILE%
  )
)
if "%CPP_2008_x64%"=="1" (
  if exist ..\cpp\vcredist2008_x64.exe (
    echo Installing most recent C++ 2008 x64 Runtime Library...
    call InstallOSUpdate.cmd ..\cpp\vcredist2008_x64.exe %VERIFY_MODE% /errorsaswarnings /q /r:n
  ) else (
    echo Warning: File ..\cpp\vcredist2008_x64.exe not found.
    echo %DATE% %TIME% - Warning: File ..\cpp\vcredist2008_x64.exe not found>>%UPDATE_LOGFILE%
  )
)
if "%CPP_2010_x64%"=="1" (
  if exist ..\cpp\vcredist2010_x64.exe (
    echo Installing most recent C++ 2010 x64 Runtime Library...
    call InstallOSUpdate.cmd ..\cpp\vcredist2010_x64.exe %VERIFY_MODE% /errorsaswarnings /q /norestart
  ) else (
    echo Warning: File ..\cpp\vcredist2010_x64.exe not found.
    echo %DATE% %TIME% - Warning: File ..\cpp\vcredist2010_x64.exe not found>>%UPDATE_LOGFILE%
  )
)
if "%CPP_2012_x64%"=="1" (
  if exist ..\cpp\vcredist2012_x64.exe (
    echo Installing most recent C++ 2012 x64 Runtime Library...
    call InstallOSUpdate.cmd ..\cpp\vcredist2012_x64.exe %VERIFY_MODE% /errorsaswarnings /q /norestart
  ) else (
    echo Warning: File ..\cpp\vcredist2012_x64.exe not found.
    echo %DATE% %TIME% - Warning: File ..\cpp\vcredist2012_x64.exe not found>>%UPDATE_LOGFILE%
  )
)
if "%CPP_2013_x64%"=="1" (
  if exist ..\cpp\vcredist2013_x64.exe (
    echo Installing most recent C++ 2013 x64 Runtime Library...
    call InstallOSUpdate.cmd ..\cpp\vcredist2013_x64.exe %VERIFY_MODE% /errorsaswarnings /q /norestart
  ) else (
    echo Warning: File ..\cpp\vcredist2013_x64.exe not found.
    echo %DATE% %TIME% - Warning: File ..\cpp\vcredist2013_x64.exe not found>>%UPDATE_LOGFILE%
  )
)
if "%CPP_2017_x64%"=="1" (
  if exist ..\cpp\vcredist2017_x64.exe (
    echo Installing most recent C++ 2017 x64 Runtime Library...
    call InstallOSUpdate.cmd ..\cpp\vcredist2017_x64.exe %VERIFY_MODE% /errorsaswarnings /q /norestart
  ) else (
    echo Warning: File ..\cpp\vcredist2017_x64.exe not found.
    echo %DATE% %TIME% - Warning: File ..\cpp\vcredist2017_x64.exe not found>>%UPDATE_LOGFILE%
  )
)
:CPPInstx86
if "%CPP_2005_x86%"=="1" (
  if exist ..\cpp\vcredist2005_x86.exe (
    echo Installing most recent C++ 2005 x86 Runtime Library...
    call InstallOSUpdate.cmd ..\cpp\vcredist2005_x86.exe %VERIFY_MODE% /errorsaswarnings /Q /r:n
  ) else (
    echo Warning: File ..\cpp\vcredist2005_x86.exe not found.
    echo %DATE% %TIME% - Warning: File ..\cpp\vcredist2005_x86.exe not found>>%UPDATE_LOGFILE%
  )
)
if "%CPP_2008_x86%"=="1" (
  if exist ..\cpp\vcredist2008_x86.exe (
    echo Installing most recent C++ 2008 x86 Runtime Library...
    call InstallOSUpdate.cmd ..\cpp\vcredist2008_x86.exe %VERIFY_MODE% /errorsaswarnings /q /r:n
  ) else (
    echo Warning: File ..\cpp\vcredist2008_x86.exe not found.
    echo %DATE% %TIME% - Warning: File ..\cpp\vcredist2008_x86.exe not found>>%UPDATE_LOGFILE%
  )
)
if "%CPP_2010_x86%"=="1" (
  if exist ..\cpp\vcredist2010_x86.exe (
    echo Installing most recent C++ 2010 x86 Runtime Library...
    call InstallOSUpdate.cmd ..\cpp\vcredist2010_x86.exe %VERIFY_MODE% /errorsaswarnings /q /norestart
  ) else (
    echo Warning: File ..\cpp\vcredist2010_x86.exe not found.
    echo %DATE% %TIME% - Warning: File ..\cpp\vcredist2010_x86.exe not found>>%UPDATE_LOGFILE%
  )
)
if "%CPP_2012_x86%"=="1" (
  if exist ..\cpp\vcredist2012_x86.exe (
    echo Installing most recent C++ 2012 x86 Runtime Library...
    call InstallOSUpdate.cmd ..\cpp\vcredist2012_x86.exe %VERIFY_MODE% /errorsaswarnings /q /norestart
  ) else (
    echo Warning: File ..\cpp\vcredist2012_x86.exe not found.
    echo %DATE% %TIME% - Warning: File ..\cpp\vcredist2012_x86.exe not found>>%UPDATE_LOGFILE%
  )
)
if "%CPP_2013_x86%"=="1" (
  if exist ..\cpp\vcredist2013_x86.exe (
    echo Installing most recent C++ 2013 x86 Runtime Library...
    call InstallOSUpdate.cmd ..\cpp\vcredist2013_x86.exe %VERIFY_MODE% /errorsaswarnings /q /norestart
  ) else (
    echo Warning: File ..\cpp\vcredist2013_x86.exe not found.
    echo %DATE% %TIME% - Warning: File ..\cpp\vcredist2013_x86.exe not found>>%UPDATE_LOGFILE%
  )
)
if "%CPP_2017_x86%"=="1" (
  if exist ..\cpp\vcredist2017_x86.exe (
    echo Installing most recent C++ 2017 x86 Runtime Library...
    call InstallOSUpdate.cmd ..\cpp\vcredist2017_x86.exe %VERIFY_MODE% /errorsaswarnings /q /norestart
  ) else (
    echo Warning: File ..\cpp\vcredist2017_x86.exe not found.
    echo %DATE% %TIME% - Warning: File ..\cpp\vcredist2017_x86.exe not found>>%UPDATE_LOGFILE%
  )
)
:SkipCPPInst

rem *** Install DirectX End-User Runtime ***
if "%UPDATE_DX%" NEQ "/updatedx" goto SkipDirectXInst
if "%OS_NAME%"=="w62" goto SkipDirectXInst
if "%OS_NAME%"=="w63" goto SkipDirectXInst
echo Checking DirectX version...
if %DX_CORE_VER_MAJOR% LSS %DX_CORE_VER_TARGET_MAJOR% goto InstallDirectX
if %DX_CORE_VER_MAJOR% GTR %DX_CORE_VER_TARGET_MAJOR% goto SkipDirectXInst
if %DX_CORE_VER_MINOR% LSS %DX_CORE_VER_TARGET_MINOR% goto InstallDirectX
if %DX_CORE_VER_MINOR% GTR %DX_CORE_VER_TARGET_MINOR% goto SkipDirectXInst
if %DX_CORE_VER_BUILD% LSS %DX_CORE_VER_TARGET_BUILD% goto InstallDirectX
if %DX_CORE_VER_BUILD% GTR %DX_CORE_VER_TARGET_BUILD% goto SkipDirectXInst
if %DX_CORE_VER_REVIS% LSS %DX_CORE_VER_TARGET_REVIS% goto InstallDirectX
if exist %DX_DLL_LATEST% goto SkipDirectXInst
:InstallDirectX
set DIRECTX_FILENAME=..\win\glb\directx_*_redist.exe
dir /B %DIRECTX_FILENAME% >nul 2>&1
if errorlevel 1 (
  echo Warning: File %DIRECTX_FILENAME% not found.
  echo %DATE% %TIME% - Warning: File %DIRECTX_FILENAME% not found>>%UPDATE_LOGFILE%
  goto SkipDirectXInst
)
echo Installing most recent DirectX End-User Runtime...
for /F %%i in ('dir /B %DIRECTX_FILENAME%') do (
  echo Installing ..\win\glb\%%i...
  ..\win\glb\%%i /T:"%TEMP%\directx" /C /Q
  "%TEMP%\directx\dxsetup.exe" /silent
  call SafeRmDir.cmd "%TEMP%\directx"
  echo %DATE% %TIME% - Info: Installed ..\win\glb\%%i>>%UPDATE_LOGFILE%
  set REBOOT_REQUIRED=1
)
set DIRECTX_FILENAME=
:SkipDirectXInst

rem *** Install Microsoft Silverlight ***
if "%INSTALL_MSSL%" NEQ "/instmssl" goto SkipMSSLInst
echo Checking Microsoft Silverlight version...
if "%OS_NAME%"=="w61" goto MSSL%OS_ARCH%
if "%OS_NAME%"=="w62" goto MSSL%OS_ARCH%
if "%OS_NAME%"=="w63" goto MSSL%OS_ARCH%
:MSSLx86
set MSSL_FILENAME=..\win\glb\Silverlight.exe
goto CheckMSSL
:MSSLx64
set MSSL_FILENAME=..\win\glb\Silverlight_x64.exe
:CheckMSSL
if not exist %MSSL_FILENAME% (
  echo Warning: Microsoft Silverlight installation file ^(%MSSL_FILENAME%^) not found.
  echo %DATE% %TIME% - Warning: Microsoft Silverlight installation file ^(%MSSL_FILENAME%^) not found>>%UPDATE_LOGFILE%
  goto SkipMSSLInst
)
rem *** Determine Microsoft Silverlight installation file version ***
echo Determining Microsoft Silverlight installation file version...
%CSCRIPT_PATH% //Nologo //B //E:vbs DetermineFileVersion.vbs %MSSL_FILENAME% MSSL_VER_TARGET
if not exist "%TEMP%\SetFileVersion.cmd" goto SkipMSSLInst
call "%TEMP%\SetFileVersion.cmd"
del "%TEMP%\SetFileVersion.cmd"
if %MSSL_VER_MAJOR% LSS %MSSL_VER_TARGET_MAJOR% goto InstallMSSL
if %MSSL_VER_MAJOR% GTR %MSSL_VER_TARGET_MAJOR% goto SkipMSSLInst
if %MSSL_VER_MINOR% LSS %MSSL_VER_TARGET_MINOR% goto InstallMSSL
if %MSSL_VER_MINOR% GTR %MSSL_VER_TARGET_MINOR% goto SkipMSSLInst
if %MSSL_VER_BUILD% LSS %MSSL_VER_TARGET_BUILD% goto InstallMSSL
if %MSSL_VER_BUILD% GTR %MSSL_VER_TARGET_BUILD% goto SkipMSSLInst
if %MSSL_VER_REVIS% GEQ %MSSL_VER_TARGET_REVIS% goto SkipMSSLInst
:InstallMSSL
echo Installing Microsoft Silverlight...
call InstallOSUpdate.cmd %MSSL_FILENAME% %VERIFY_MODE% /errorsaswarnings /q
set MSSL_FILENAME=
set REBOOT_REQUIRED=1
:SkipMSSLInst
set MSSL_VER_TARGET_MAJOR=
set MSSL_VER_TARGET_MINOR=
set MSSL_VER_TARGET_BUILD=
set MSSL_VER_TARGET_REVIS=

rem *** Install most recent Windows Media Player ***
if "%OS_NAME%"=="w2k3" goto SkipWMPInst
if %OS_DOMAIN_ROLE% GEQ 2 goto SkipWMPInst
if "%UPDATE_WMP%" NEQ "/updatewmp" goto SkipWMPInst
echo Checking Windows Media Player version...
if %WMP_VER_MAJOR% LSS %WMP_VER_TARGET_MAJOR% goto InstallWMP
if %WMP_VER_MAJOR% GTR %WMP_VER_TARGET_MAJOR% goto SkipWMPInst
if %WMP_VER_MINOR% LSS %WMP_VER_TARGET_MINOR% goto InstallWMP
if %WMP_VER_MINOR% GEQ %WMP_VER_TARGET_MINOR% goto SkipWMPInst
:InstallWMP
if "%WMP_TARGET_ID%"=="" (
  echo Warning: Environment variable WMP_TARGET_ID not set.
  echo %DATE% %TIME% - Warning: Environment variable WMP_TARGET_ID not set>>%UPDATE_LOGFILE%
  goto SkipWMPInst
)
echo %WMP_TARGET_ID%>"%TEMP%\MissingUpdateIds.txt"
call ListUpdatesToInstall.cmd /excludestatics /ignoreblacklist
if errorlevel 1 goto ListError
if exist "%TEMP%\UpdatesToInstall.txt" (
  echo Installing most recent Windows Media Player...
  call InstallListedUpdates.cmd /selectoptions %BACKUP_MODE% %VERIFY_MODE% /errorsaswarnings
) else (
  echo Warning: Windows Media Player installation file ^(kb%WMP_TARGET_ID%^) not found.
  echo %DATE% %TIME% - Warning: Windows Media Player installation file ^(kb%WMP_TARGET_ID%^) not found>>%UPDATE_LOGFILE%
  goto SkipWMPInst
)
set REBOOT_REQUIRED=1
:SkipWMPInst

rem *** Install .NET Framework 3.5 SP1 ***
if "%INSTALL_DOTNET35%" NEQ "/instdotnet35" goto SkipDotNet35Inst
if "%OS_NAME%"=="w61" goto SkipDotNet35Inst
if "%OS_NAME%"=="w62" goto SkipDotNet35Inst
if "%OS_NAME%"=="w63" goto SkipDotNet35Inst
echo Checking .NET Framework 3.5 SP1 installation state...
if %DOTNET35_VER_MAJOR% LSS %DOTNET35_VER_TARGET_MAJOR% goto InstallDotNet35
if %DOTNET35_VER_MAJOR% GTR %DOTNET35_VER_TARGET_MAJOR% goto SkipDotNet35Inst
if %DOTNET35_VER_MINOR% LSS %DOTNET35_VER_TARGET_MINOR% goto InstallDotNet35
if %DOTNET35_VER_MINOR% GTR %DOTNET35_VER_TARGET_MINOR% goto SkipDotNet35Inst
if %DOTNET35_VER_BUILD% LSS %DOTNET35_VER_TARGET_BUILD% goto InstallDotNet35
if %DOTNET35_VER_BUILD% GTR %DOTNET35_VER_TARGET_BUILD% goto SkipDotNet35Inst
if %DOTNET35_VER_REVIS% GEQ %DOTNET35_VER_TARGET_REVIS% goto SkipDotNet35Inst
:InstallDotNet35
set DOTNET35_FILENAME=..\dotnet\dotnetfx35.exe
set DOTNET35LP_FILENAME=..\dotnet\%OS_ARCH%-glb\dotnetfx35langpack_%OS_ARCH%%OS_LANG_SHORT%*.exe
if not exist %DOTNET35_FILENAME% (
  echo Warning: .NET Framework 3.5 SP1 installation file ^(%DOTNET35_FILENAME%^) not found.
  echo %DATE% %TIME% - Warning: .NET Framework 3.5 SP1 installation file ^(%DOTNET35_FILENAME%^) not found>>%UPDATE_LOGFILE%
  goto SkipDotNet35Inst
)
echo Installing .NET Framework 3.5 SP1...
call InstallOSUpdate.cmd %DOTNET35_FILENAME% %VERIFY_MODE% /ignoreerrors /qb /norestart /lang:enu
if "%OS_LANG%" NEQ "enu" (
  dir /B %DOTNET35LP_FILENAME% >nul 2>&1
  if errorlevel 1 (
    echo Warning: .NET Framework 3.5 SP1 Language Pack installation file ^(%DOTNET35LP_FILENAME%^) not found.
    echo %DATE% %TIME% - Warning: .NET Framework 3.5 SP1 Language Pack installation file ^(%DOTNET35LP_FILENAME%^) not found>>%UPDATE_LOGFILE%
  ) else (
    echo Installing .NET Framework 3.5 SP1 Language Pack...
    for /F %%i in ('dir /B %DOTNET35LP_FILENAME%') do call InstallOSUpdate.cmd ..\dotnet\%OS_ARCH%-glb\%%i %VERIFY_MODE% /ignoreerrors /qb /norestart /nopatch
  )
)
copy /Y ..\static\StaticUpdateIds-dotnet35.txt "%TEMP%\MissingUpdateIds.txt" >nul
call ListUpdatesToInstall.cmd /excludestatics /ignoreblacklist
if errorlevel 1 goto ListError
if exist "%TEMP%\UpdatesToInstall.txt" (
  echo Installing .NET Framework 3.5 SP1 Family Update...
  call InstallListedUpdates.cmd /selectoptions %BACKUP_MODE% %VERIFY_MODE% /ignoreerrors
)
set RECALL_REQUIRED=1
set DOTNET35_FILENAME=
set DOTNET35LP_FILENAME=
:SkipDotNet35Inst

rem *** Install .NET Framework 4 ***
if "%INSTALL_DOTNET4%" NEQ "/instdotnet4" goto SkipDotNet4Inst
echo Checking .NET Framework 4 installation state...
if %DOTNET4_VER_MAJOR% LSS %DOTNET4_VER_TARGET_MAJOR% goto InstallDotNet4
if %DOTNET4_VER_MAJOR% GTR %DOTNET4_VER_TARGET_MAJOR% goto SkipDotNet4Inst
if %DOTNET4_VER_MINOR% LSS %DOTNET4_VER_TARGET_MINOR% goto InstallDotNet4
if %DOTNET4_VER_MINOR% GTR %DOTNET4_VER_TARGET_MINOR% goto SkipDotNet4Inst
if %DOTNET4_VER_BUILD% GEQ %DOTNET4_VER_TARGET_BUILD% goto SkipDotNet4Inst
:InstallDotNet4
if "%OS_NAME%" NEQ "w2k3" goto SkipDotNet4Prereq
if /i "%OS_ARCH%"=="x64" (
  set DOTNET4_PREREQ=..\%OS_NAME%-%OS_ARCH%\%OS_LANG%\wic_%OS_ARCH%_%OS_LANG%.exe
) else (
  set DOTNET4_PREREQ=..\%OS_NAME%\%OS_LANG%\wic_%OS_ARCH%_%OS_LANG%.exe
)
if exist %DOTNET4_PREREQ% (
  call InstallOSUpdate.cmd %DOTNET4_PREREQ% %VERIFY_MODE% /errorsaswarnings /quiet /norestart
) else (
  echo Warning: .NET Framework 4 prerequisite WIC installation file ^(%DOTNET4_PREREQ%^) not found.
  echo %DATE% %TIME% - Warning: .NET Framework 4 prerequisite WIC installation file ^(%DOTNET4_PREREQ%^) not found>>%UPDATE_LOGFILE%
)
set DOTNET4_PREREQ=
:SkipDotNet4Prereq
if %DOTNET4_VER_TARGET_MINOR% EQU 0 (
  set DOTNET4_FILENAME=..\dotnet\dotNetFx40_Full_x86_x64.exe
  set DOTNET4LP_FILENAME=..\dotnet\dotNetFx40LP_Full_x86_x64%OS_LANG_SHORT%.exe
) else (
  if "%OS_NAME%"=="w60" (
    set DOTNET4_FILENAME=..\dotnet\NDP46-KB3045557-x86-x64-AllOS-ENU.exe
    set DOTNET4LP_FILENAME=..\dotnet\NDP46-KB3045557-x86-x64-AllOS-%OS_LANG%.exe
  ) else (
    set DOTNET4_FILENAME=..\dotnet\NDP462-KB3151800-x86-x64-AllOS-ENU.exe
    set DOTNET4LP_FILENAME=..\dotnet\NDP462-KB3151800-x86-x64-AllOS-%OS_LANG%.exe
  )
)
if not exist %DOTNET4_FILENAME% (
  echo Warning: .NET Framework 4 installation file ^(%DOTNET4_FILENAME%^) not found.
  echo %DATE% %TIME% - Warning: .NET Framework 4 installation file ^(%DOTNET4_FILENAME%^) not found>>%UPDATE_LOGFILE%
  goto SkipDotNet4Inst
)
echo Installing .NET Framework 4...
for /F %%i in ('dir /B %DOTNET4_FILENAME%') do call InstallOSUpdate.cmd ..\dotnet\%%i %VERIFY_MODE% /errorsaswarnings /passive /norestart /lcid 1033
if "%OS_LANG%" NEQ "enu" (
  if exist %DOTNET4LP_FILENAME% (
    echo Installing .NET Framework 4 Language Pack...
    for /F %%i in ('dir /B %DOTNET4LP_FILENAME%') do call InstallOSUpdate.cmd ..\dotnet\%%i %VERIFY_MODE% /errorsaswarnings /passive /norestart
  ) else (
    echo Warning: .NET Framework 4 Language Pack installation file ^(%DOTNET4LP_FILENAME%^) not found.
    echo %DATE% %TIME% - Warning: .NET Framework 4 Language Pack installation file ^(%DOTNET4LP_FILENAME%^) not found>>%UPDATE_LOGFILE%
  )
)
set RECALL_REQUIRED=1
set DOTNET4_FILENAME=
set DOTNET4LP_FILENAME=
:SkipDotNet4Inst

rem *** Install .NET Framework 3.5 - Custom ***
if "%INSTALL_DOTNET35%" EQU "/instdotnet35" goto InstallDotNet35Custom
if %DOTNET35_VER_MAJOR% EQU %DOTNET35_VER_TARGET_MAJOR% goto InstallDotNet35Custom
goto SkipDotNet35CustomInst
:InstallDotNet35Custom
if not exist ..\static\custom\StaticUpdateIds-dotnet35.txt goto SkipDotNet35CustomInst
echo Checking .NET Framework 3.5 custom updates...
%CSCRIPT_PATH% //Nologo //B //E:vbs ListInstalledUpdateIds.vbs
if exist "%TEMP%\InstalledUpdateIds.txt" (
  %SystemRoot%\System32\findstr.exe /L /I /V /G:"%TEMP%\InstalledUpdateIds.txt" ..\static\custom\StaticUpdateIds-dotnet35.txt >"%TEMP%\MissingUpdateIds.txt"
  del "%TEMP%\InstalledUpdateIds.txt"
) else (
  copy /Y ..\static\custom\StaticUpdateIds-dotnet35.txt "%TEMP%\MissingUpdateIds.txt" >nul
)
call ListUpdatesToInstall.cmd /excludestatics /ignoreblacklist
if errorlevel 1 goto ListError
if exist "%TEMP%\UpdatesToInstall.txt" (
  echo Installing .NET Framework 3.5 custom updates...
  call InstallListedUpdates.cmd /selectoptions %BACKUP_MODE% %VERIFY_MODE% /ignoreerrors
)
:SkipDotNet35CustomInst
rem *** Install .NET Framework 4 - Custom ***
if "%INSTALL_DOTNET4%" EQU "/instdotnet4" goto InstallDotNet4Custom
if %DOTNET4_VER_MAJOR% EQU %DOTNET4_VER_TARGET_MAJOR% goto InstallDotNet4Custom
goto SkipDotNet4CustomInst
:InstallDotNet4Custom
if not exist ..\static\custom\StaticUpdateIds-dotnet4.txt goto SkipDotNet4CustomInst
echo Checking .NET Framework 4 custom updates...
%CSCRIPT_PATH% //Nologo //B //E:vbs ListInstalledUpdateIds.vbs
if exist "%TEMP%\InstalledUpdateIds.txt" (
  %SystemRoot%\System32\findstr.exe /L /I /V /G:"%TEMP%\InstalledUpdateIds.txt" ..\static\custom\StaticUpdateIds-dotnet4.txt >"%TEMP%\MissingUpdateIds.txt"
  del "%TEMP%\InstalledUpdateIds.txt"
) else (
  copy /Y ..\static\custom\StaticUpdateIds-dotnet4.txt "%TEMP%\MissingUpdateIds.txt" >nul
)
call ListUpdatesToInstall.cmd /excludestatics /ignoreblacklist
if errorlevel 1 goto ListError
if exist "%TEMP%\UpdatesToInstall.txt" (
  echo Installing .NET Framework 4 custom updates...
  call InstallListedUpdates.cmd /selectoptions %BACKUP_MODE% %VERIFY_MODE% /ignoreerrors
)
:SkipDotNet4CustomInst
if "%RECALL_REQUIRED%"=="1" goto Installed

rem *** Install Windows PowerShell 2.0 ***
if "%INSTALL_PSH%" NEQ "/instpsh" goto SkipPShInst
if %DOTNET35_VER_MAJOR% LSS %DOTNET35_VER_TARGET_MAJOR% (
  echo Warning: Missing Windows PowerShell 2.0 prerequisite .NET Framework 3.5 SP1.
  echo %DATE% %TIME% - Warning: Missing Windows PowerShell 2.0 prerequisite .NET Framework 3.5 SP1>>%UPDATE_LOGFILE%
  goto SkipPShInst
)
echo Checking Windows PowerShell 2.0 installation state...
if %PSH_VER_MAJOR% LSS %PSH_VER_TARGET_MAJOR% goto InstallPSh
if %PSH_VER_MAJOR% GTR %PSH_VER_TARGET_MAJOR% goto SkipPShInst
if %PSH_VER_MINOR% LSS %PSH_VER_TARGET_MINOR% goto InstallPSh
if %PSH_VER_MINOR% GEQ %PSH_VER_TARGET_MINOR% goto SkipPShInst
:InstallPSh
if "%PSH_TARGET_ID%"=="" (
  echo Warning: Environment variable PSH_TARGET_ID not set.
  echo %DATE% %TIME% - Warning: Environment variable PSH_TARGET_ID not set>>%UPDATE_LOGFILE%
  goto SkipPShInst
)
echo %PSH_TARGET_ID%>"%TEMP%\MissingUpdateIds.txt"
call ListUpdatesToInstall.cmd /excludestatics /ignoreblacklist
if errorlevel 1 goto ListError
if exist "%TEMP%\UpdatesToInstall.txt" (
  echo Installing Windows PowerShell 2.0...
  call InstallListedUpdates.cmd /selectoptions %BACKUP_MODE% %VERIFY_MODE% /errorsaswarnings
) else (
  echo Warning: Windows PowerShell 2.0 installation file ^(kb%PSH_TARGET_ID%^) not found.
  echo %DATE% %TIME% - Warning: Windows PowerShell 2.0 installation file ^(kb%PSH_TARGET_ID%^) not found>>%UPDATE_LOGFILE%
  goto SkipPShInst
)
set REBOOT_REQUIRED=1
:SkipPShInst

rem *** Install Windows Management Framework ***
if "%INSTALL_WMF%" NEQ "/instwmf" goto SkipWMFInst
if %DOTNET4_VER_MAJOR% LSS %DOTNET4_VER_TARGET_MAJOR% (
  echo Warning: Missing Windows Management Framework prerequisite .NET Framework 4.
  echo %DATE% %TIME% - Warning: Missing Windows Management Framework prerequisite .NET Framework ^4>>%UPDATE_LOGFILE%
  goto SkipWMFInst
)
if "%OS_NAME%"=="w60" (if %OS_DOMAIN_ROLE% GEQ 2 goto CheckWMF)
if "%OS_NAME%"=="w61" goto CheckWMF
if "%OS_NAME%"=="w62" (if %OS_DOMAIN_ROLE% GEQ 2 goto CheckWMF)
if "%OS_NAME%"=="w63" goto CheckWMF
goto SkipWMFInst
:CheckWMF
echo Checking Windows Management Framework installation state...
if %WMF_VER_MAJOR% LSS %WMF_VER_TARGET_MAJOR% goto InstallWMF
if %WMF_VER_MAJOR% GTR %WMF_VER_TARGET_MAJOR% goto SkipWMFInst
if %WMF_VER_MINOR% LSS %WMF_VER_TARGET_MINOR% goto InstallWMF
if %WMF_VER_MINOR% GEQ %WMF_VER_TARGET_MINOR% goto SkipWMFInst
:InstallWMF
if "%WMF_TARGET_ID%"=="" (
  echo Warning: Environment variable WMF_TARGET_ID not set.
  echo %DATE% %TIME% - Warning: Environment variable WMF_TARGET_ID not set>>%UPDATE_LOGFILE%
  goto SkipWMFInst
)
echo %WMF_TARGET_ID%>"%TEMP%\MissingUpdateIds.txt"
call ListUpdatesToInstall.cmd /excludestatics /ignoreblacklist
if errorlevel 1 goto ListError
if exist "%TEMP%\UpdatesToInstall.txt" (
  echo Installing Windows Management Framework...
  call InstallListedUpdates.cmd /selectoptions %BACKUP_MODE% %VERIFY_MODE% /errorsaswarnings
) else (
  echo Warning: Windows Management Framework installation file ^(kb%WMF_TARGET_ID%^) not found.
  echo %DATE% %TIME% - Warning: Windows Management Framework installation file ^(kb%WMF_TARGET_ID%^) not found>>%UPDATE_LOGFILE%
  goto SkipWMFInst
)
set REBOOT_REQUIRED=1
:SkipWMFInst

rem *** Install most recent Remote Desktop Client ***
if "%UPDATE_TSC%" NEQ "/updatetsc" goto SkipTSCInst
echo Checking Remote Desktop Client version...
if %TSC_VER_MAJOR% LSS %TSC_VER_TARGET_MAJOR% goto InstallTSC
if %TSC_VER_MAJOR% GTR %TSC_VER_TARGET_MAJOR% goto SkipTSCInst
if %TSC_VER_MINOR% LSS %TSC_VER_TARGET_MINOR% goto InstallTSC
if %TSC_VER_MINOR% GEQ %TSC_VER_TARGET_MINOR% goto SkipTSCInst
:InstallTSC
if "%TSC_TARGET_ID%"=="" (
  if "%TSC_TARGET_ID_FILE%"=="" (
    echo Warning: Environment variables TSC_TARGET_ID and TSC_TARGET_ID_FILE not set.
    echo %DATE% %TIME% - Warning: Environment variables TSC_TARGET_ID and TSC_TARGET_ID_FILE not set>>%UPDATE_LOGFILE%
    goto SkipTSCInst
  ) else (
    echo Checking Remote Desktop Client components...
    %CSCRIPT_PATH% //Nologo //B //E:vbs ListInstalledUpdateIds.vbs
    if exist "%TEMP%\InstalledUpdateIds.txt" (
      %SystemRoot%\System32\findstr.exe /L /I /V /G:"%TEMP%\InstalledUpdateIds.txt" %TSC_TARGET_ID_FILE% >"%TEMP%\MissingUpdateIds.txt"
      del "%TEMP%\InstalledUpdateIds.txt"
    ) else (
      copy /Y %TSC_TARGET_ID_FILE% "%TEMP%\MissingUpdateIds.txt" >nul
    )
  )
) else (
  echo %TSC_TARGET_ID%>"%TEMP%\MissingUpdateIds.txt"
)
call ListUpdatesToInstall.cmd /excludestatics /ignoreblacklist
if errorlevel 1 goto ListError
if exist "%TEMP%\UpdatesToInstall.txt" (
  echo Installing most recent Remote Desktop Client...
  call InstallListedUpdates.cmd /selectoptions %BACKUP_MODE% %VERIFY_MODE% /errorsaswarnings
) else (
  echo Warning: Remote Desktop Client installation file^(s^) not found.
  echo %DATE% %TIME% - Warning: Remote Desktop Client installation file^(s^) not found>>%UPDATE_LOGFILE%
  goto SkipTSCInst
)
set REBOOT_REQUIRED=1
:SkipTSCInst

rem *** Update Windows Defender definitions ***
echo Checking Windows Defender installation state...
if "%WD_INSTALLED%" NEQ "1" goto SkipWDInst
if "%WD_DISABLED%"=="1" goto SkipWDInst
if "%OS_NAME%"=="w62" goto WDmpam
if "%OS_NAME%"=="w63" goto WDmpam
if /i "%OS_ARCH%"=="x64" (
  set WDDEFS_FILENAME=..\wddefs\%OS_ARCH%-glb\mpas-feX64.exe
) else (
  set WDDEFS_FILENAME=..\wddefs\%OS_ARCH%-glb\mpas-fe.exe
)
goto WDmpas
:WDmpam
if /i "%OS_ARCH%"=="x64" (
  set WDDEFS_FILENAME=..\msse\%OS_ARCH%-glb\mpam-fex64.exe
) else (
  set WDDEFS_FILENAME=..\msse\%OS_ARCH%-glb\mpam-fe.exe
)
:WDmpas
if not exist %WDDEFS_FILENAME% (
  echo Warning: Windows Defender definition file ^(%WDDEFS_FILENAME%^) not found.
  echo %DATE% %TIME% - Warning: Windows Defender definition file ^(%WDDEFS_FILENAME%^) not found>>%UPDATE_LOGFILE%
  goto SkipWDInst
)
rem *** Determine Windows Defender definition file version ***
echo Determining Windows Defender definition file version...
%CSCRIPT_PATH% //Nologo //B //E:vbs DetermineFileVersion.vbs %WDDEFS_FILENAME% WDDEFS_VER_TARGET
if not exist "%TEMP%\SetFileVersion.cmd" goto SkipWDInst
call "%TEMP%\SetFileVersion.cmd"
del "%TEMP%\SetFileVersion.cmd"
if %WDDEFS_VER_MAJOR% LSS %WDDEFS_VER_TARGET_MAJOR% goto InstallWDDefs
if %WDDEFS_VER_MAJOR% GTR %WDDEFS_VER_TARGET_MAJOR% goto SkipWDInst
if %WDDEFS_VER_MINOR% LSS %WDDEFS_VER_TARGET_MINOR% goto InstallWDDefs
if %WDDEFS_VER_MINOR% GTR %WDDEFS_VER_TARGET_MINOR% goto SkipWDInst
if %WDDEFS_VER_BUILD% LSS %WDDEFS_VER_TARGET_BUILD% goto InstallWDDefs
if %WDDEFS_VER_BUILD% GTR %WDDEFS_VER_TARGET_BUILD% goto SkipWDInst
if %WDDEFS_VER_REVIS% GEQ %WDDEFS_VER_TARGET_REVIS% goto SkipWDInst
:InstallWDDefs
echo Installing Windows Defender definition file...
call InstallOSUpdate.cmd %WDDEFS_FILENAME% %VERIFY_MODE% /ignoreerrors -q
set WDDEFS_FILENAME=
:SkipWDInst
set WDDEFS_VER_TARGET_MAJOR=
set WDDEFS_VER_TARGET_MINOR=
set WDDEFS_VER_TARGET_BUILD=
set WDDEFS_VER_TARGET_REVIS=

if "%RECALL_REQUIRED%"=="1" goto Installed
if "%OFC_NAME%"=="" goto SkipOffice

rem *** Check Office Service Pack versions ***
echo Checking Office Service Pack versions...
if exist "%TEMP%\MissingUpdateIds.txt" del "%TEMP%\MissingUpdateIds.txt"
if "%O2K3_VER_MAJOR%"=="" goto SkipSPo2k3
if %O2K3_SP_VER% LSS %O2K3_SP_VER_TARGET% echo %O2K3_SP_TARGET_ID%>>"%TEMP%\MissingUpdateIds.txt"
:SkipSPo2k3
if "%O2K7_VER_MAJOR%"=="" goto SkipSPo2k7
if %O2K7_SP_VER% LSS %O2K7_SP_VER_TARGET% echo %O2K7_SP_TARGET_ID%>>"%TEMP%\MissingUpdateIds.txt"
:SkipSPo2k7
if "%O2K10_VER_MAJOR%"=="" goto SkipSPo2k10
if %O2K10_SP_VER% LSS %O2K10_SP_VER_TARGET% echo %O2K10_SP_TARGET_ID%>>"%TEMP%\MissingUpdateIds.txt"
:SkipSPo2k10
if "%O2K13_VER_MAJOR%"=="" goto SkipSPo2k13
if %O2K13_SP_VER% LSS %O2K13_SP_VER_TARGET% echo %O2K13_SP_TARGET_ID%>>"%TEMP%\MissingUpdateIds.txt"
:SkipSPo2k13
if not exist "%TEMP%\MissingUpdateIds.txt" goto SkipSPOfc
call ListUpdatesToInstall.cmd /excludestatics /ignoreblacklist
if errorlevel 1 goto ListError
if exist "%TEMP%\UpdatesToInstall.txt" (
  echo Installing most recent Office Service Pack^(s^)...
  call InstallListedUpdates.cmd %VERIFY_MODE% /errorsaswarnings
) else (
  echo Warning: Office Service Pack installation file^(s^) not found.
  echo %DATE% %TIME% - Warning: Office Service Pack installation file^(s^) not found>>%UPDATE_LOGFILE%
  goto SkipSPOfc
)
set REBOOT_REQUIRED=1
:SkipSPOfc

rem *** Check installation state of Office File Converter Packs ***
if "%INSTALL_OFC%" NEQ "/instofc" goto SkipOFCNV
if "%O2K3_VER_MAJOR%" NEQ "" goto InstOFCNV
goto SkipOFCNV

:InstOFCNV
echo Checking installation state of Office File Converter Pack...
if "%OFC_CONV_PACK%" NEQ "1" (
  if exist ..\ofc\glb\ork.exe (
    echo Installing Office File Converter Pack...
    ..\ofc\glb\ork.exe /T:"%TEMP%\ork" /C /Q
    %SystemRoot%\System32\expand.exe "%TEMP%\ork\ORK.CAB" -F:OCONVPCK.EXE "%TEMP%" >nul
    call SafeRmDir.cmd "%TEMP%\ork"
    "%TEMP%\OCONVPCK.EXE" /T:"%TEMP%\OCONVPCK" /C /Q
    del "%TEMP%\OCONVPCK.EXE"
    call InstallOSUpdate.cmd "%TEMP%\OCONVPCK\ocp11.msi"
    call SafeRmDir.cmd "%TEMP%\OCONVPCK"
    echo %DATE% %TIME% - Info: Installed Office File Converter Pack>>%UPDATE_LOGFILE%
  ) else (
    echo Warning: File ..\ofc\glb\ork.exe not found.
    echo %DATE% %TIME% - Warning: File ..\ofc\glb\ork.exe not found>>%UPDATE_LOGFILE%
  )
)
echo Checking installation state of Office Compatibility Pack...
if "%OFC_COMP_PACK%" NEQ "1" (
  if exist ..\ofc\%OFC_LANG%\FileFormatConverters.exe (
    echo Installing Office Compatibility Pack...
    call InstallOfficeUpdate.cmd ..\ofc\%OFC_LANG%\FileFormatConverters.exe /selectoptions %VERIFY_MODE% /errorsaswarnings
    echo %DATE% %TIME% - Info: Installed Office Compatibility Pack>>%UPDATE_LOGFILE%
  ) else (
    echo Warning: File ..\ofc\%OFC_LANG%\FileFormatConverters.exe not found.
    echo %DATE% %TIME% - Warning: File ..\ofc\%OFC_LANG%\FileFormatConverters.exe not found>>%UPDATE_LOGFILE%
  )
  dir /B ..\ofc\%OFC_LANG%\compatibilitypacksp*.exe >nul 2>&1
  if errorlevel 1 (
    echo Warning: File ..\ofc\%OFC_LANG%\compatibilitypacksp*.exe not found.
    echo %DATE% %TIME% - Warning: File ..\ofc\%OFC_LANG%\compatibilitypacksp*.exe not found>>%UPDATE_LOGFILE%
  ) else (
    for /F %%i in ('dir /B ..\ofc\%OFC_LANG%\compatibilitypacksp*.exe') do (
      echo Installing most recent Service Pack for Office Compatibility Pack...
      call InstallOfficeUpdate.cmd ..\ofc\%OFC_LANG%\%%i /selectoptions %VERIFY_MODE% /errorsaswarnings
      echo %DATE% %TIME% - Info: Installed most recent Service Pack for Office Compatibility Pack>>%UPDATE_LOGFILE%
    )
  )
)
:SkipOFCNV

rem *** Check installation state of Office File Validation ***
if "%INSTALL_OFV%" NEQ "/instofv" goto SkipOFVAL
if "%O2K3_VER_MAJOR%" NEQ "" goto InstOFVAL
if "%O2K7_VER_MAJOR%" NEQ "" goto InstOFVAL
goto SkipOFVAL

:InstOFVAL
echo Checking installation state of Office File Validation Add-In...
if "%OFC_FILE_VALID%" NEQ "1" (
  if exist ..\ofc\glb\OFV.exe (
    echo Installing Office File Validation Add-In...
    call InstallOfficeUpdate.cmd ..\ofc\glb\OFV.exe /selectoptions %VERIFY_MODE% /errorsaswarnings
    echo %DATE% %TIME% - Info: Installed Office File Validation Add-In>>%UPDATE_LOGFILE%
  ) else (
    echo Warning: File ..\ofc\glb\OFV.exe not found.
    echo %DATE% %TIME% - Warning: File ..\ofc\glb\OFV.exe not found>>%UPDATE_LOGFILE%
  )
  dir /B ..\ofc\glb\*kb2553065*.exe >nul 2>&1
  if errorlevel 1 (
    echo Warning: File ..\ofc\glb\*kb2553065*.exe not found.
    echo %DATE% %TIME% - Warning: File ..\ofc\glb\*kb2553065*.exe not found>>%UPDATE_LOGFILE%
  ) else (
    for /F %%i in ('dir /B ..\ofc\glb\*kb2553065*.exe') do (
      echo Installing Office File Validation update...
      call InstallOfficeUpdate.cmd ..\ofc\glb\%%i /selectoptions %VERIFY_MODE% /errorsaswarnings
    )
  )
)
:SkipOFVAL
:SkipOffice

rem *** Install MSI packages and custom software ***
if exist ..\software\custom\InstallCustomSoftware.cmd (
  echo Installing custom software...
  pushd ..\software\custom
  call InstallCustomSoftware.cmd
  popd
  echo %DATE% %TIME% - Info: Executed custom software installation hook ^(Errorlevel: %errorlevel%^)>>%UPDATE_LOGFILE%
  set REBOOT_REQUIRED=1
)
if exist %SystemRoot%\Temp\wouselmsi.txt (
  echo Installing selected MSI packages...
  call TouchMSITree.cmd /instselected
  echo %DATE% %TIME% - Info: Installed selected MSI packages>>%UPDATE_LOGFILE%
  del %SystemRoot%\Temp\wouselmsi.txt
  set REBOOT_REQUIRED=1
)

rem *** Determine and install missing Microsoft updates ***
if "%SKIP_DYNAMIC%"=="/skipdynamic" (
  echo Skipping determination of missing updates on demand...
  echo %DATE% %TIME% - Info: Skipped determination of missing updates on demand>>%UPDATE_LOGFILE%
  goto ListInstalledIds
)
if "%WUSCN_PREREQ_ID%"=="" goto CheckWUSvc
if exist %SystemRoot%\Temp\wou_wupre_tried.txt goto CheckWUSvc
echo Checking most recent Cumulative Security Update for Internet Explorer...
%CSCRIPT_PATH% //Nologo //B //E:vbs ListInstalledUpdateIds.vbs
if exist "%TEMP%\InstalledUpdateIds.txt" (
  %SystemRoot%\System32\find.exe /I "%WUSCN_PREREQ_ID%" "%TEMP%\InstalledUpdateIds.txt" >nul 2>&1
  if not errorlevel 1 (
    del "%TEMP%\InstalledUpdateIds.txt"
    goto CheckWUSvc
  )
  del "%TEMP%\InstalledUpdateIds.txt"
)
echo %WUSCN_PREREQ_ID%>"%TEMP%\MissingUpdateIds.txt"
call ListUpdatesToInstall.cmd /excludestatics /ignoreblacklist
if errorlevel 1 goto ListError
if exist "%TEMP%\UpdatesToInstall.txt" (
  echo Installing most recent Cumulative Security Update for Internet Explorer...
  call InstallListedUpdates.cmd /selectoptions %BACKUP_MODE% %VERIFY_MODE% /ignoreerrors
  if not errorlevel 1 (
    if not exist %SystemRoot%\Temp\nul md %SystemRoot%\Temp
    echo. >%SystemRoot%\Temp\wou_wupre_tried.txt
    set RECALL_REQUIRED=1
  )
) else (
  echo Warning: Cumulative Security Update for Internet Explorer ^(kb%WUSCN_PREREQ_ID%^) not found.
  echo %DATE% %TIME% - Warning: Cumulative Security Update for Internet Explorer ^(kb%WUSCN_PREREQ_ID%^) not found>>%UPDATE_LOGFILE%
)
if "%RECALL_REQUIRED%"=="1" goto Installed
:CheckWUSvc
rem *** Check state of service 'Windows Update' ***
echo Checking state of service 'Windows Update'...
%CSCRIPT_PATH% //Nologo //B //E:vbs DetermineServiceState.vbs wuauserv AUSVC
if not exist "%TEMP%\SetServiceState.cmd" goto ListMissingIds
call "%TEMP%\SetServiceState.cmd"
del "%TEMP%\SetServiceState.cmd"
echo %DATE% %TIME% - Info: Detected state of service 'Windows Update': %AUSVC_STATE% (start mode: %AUSVC_SMODE%)>>%UPDATE_LOGFILE%
if /i "%AUSVC_SMODE%"=="Auto" (
  if "%USERNAME%"=="WOUTempAdmin" goto ListMissingIds
)
if /i "%AUSVC_STATE%"=="Running" goto ListMissingIds
if /i "%AUSVC_STATE%"=="Start Pending" goto ListMissingIds
if /i "%AUSVC_STATE%"=="Unknown" goto ListMissingIds
if /i "%AUSVC_STATE%"=="" goto ListMissingIds
if /i "%AUSVC_SMODE%"=="Disabled" goto AUSvcNotRunning
echo Starting service 'Windows Update' (wuauserv)...
%SystemRoot%\System32\net.exe start wuauserv >nul
if errorlevel 1 goto AUSvcNotRunning
set AUSVC_STARTED=1
echo %DATE% %TIME% - Info: Started service 'Windows Update' (wuauserv)>>%UPDATE_LOGFILE%

:ListMissingIds
rem *** List ids of missing updates ***
if not exist ..\wsus\wsusscn2.cab goto NoCatalog
if "%VERIFY_MODE%" NEQ "/verify" goto SkipVerifyCatalog
if not exist %HASHDEEP_PATH% (
  echo Warning: Hash computing/auditing utility %HASHDEEP_PATH% not found.
  echo %DATE% %TIME% - Warning: Hash computing/auditing utility %HASHDEEP_PATH% not found>>%UPDATE_LOGFILE%
  goto SkipVerifyCatalog
)
if not exist ..\md\hashes-wsus.txt (
  echo Warning: Hash file hashes-wsus.txt not found.
  echo %DATE% %TIME% - Warning: Hash file hashes-wsus.txt not found>>%UPDATE_LOGFILE%
  goto SkipVerifyCatalog
)
echo Verifying integrity of Windows Update catalog file...
%SystemRoot%\System32\findstr.exe /L /C:%% /C:## /C:..\wsus\wsusscn2.cab ..\md\hashes-wsus.txt >"%TEMP%\hash-wsusscn2.txt"
%HASHDEEP_PATH% -a -l -k "%TEMP%\hash-wsusscn2.txt" ..\wsus\wsusscn2.cab
if errorlevel 1 (
  if exist "%TEMP%\hash-wsusscn2.txt" del "%TEMP%\hash-wsusscn2.txt"
  goto CatalogIntegrityError
)
if exist "%TEMP%\hash-wsusscn2.txt" del "%TEMP%\hash-wsusscn2.txt"
:SkipVerifyCatalog
echo %TIME% - Listing ids of missing updates (please be patient, this will take a while)...
copy /Y ..\wsus\wsusscn2.cab "%TEMP%" >nul
%CSCRIPT_PATH% //Nologo //B //E:vbs ListMissingUpdateIds.vbs %LIST_MODE_IDS%
if exist "%TEMP%\wsusscn2.cab" del "%TEMP%\wsusscn2.cab"
echo %TIME% - Done.
if not exist "%TEMP%\MissingUpdateIds.txt" set NO_MISSING_IDS=1

:ListInstalledIds
rem *** List ids of installed updates ***
if "%LIST_MODE_IDS%"=="/all" goto ListInstFiles
if "%LIST_MODE_UPDATES%"=="/excludestatics" goto ListInstFiles
echo Listing ids of installed updates...
%CSCRIPT_PATH% //Nologo //B //E:vbs ListInstalledUpdateIds.vbs

:ListInstFiles
rem *** List update files ***
echo Listing update files...
call ListUpdatesToInstall.cmd %LIST_MODE_UPDATES%
if errorlevel 1 goto ListError

:InstallUpdates
rem *** Install updates ***
if not exist "%TEMP%\UpdatesToInstall.txt" goto SkipUpdates
echo Installing updates...
call InstallListedUpdates.cmd /selectoptions %BACKUP_MODE% %VERIFY_MODE% /errorsaswarnings
if errorlevel 1 goto InstError
set REBOOT_REQUIRED=1
:SkipUpdates

rem *** Install Microsoft Security Essentials ***
if "%OS_NAME%"=="w62" goto SkipMSSEInst
if "%OS_NAME%"=="w63" goto SkipMSSEInst
echo Checking Microsoft Security Essentials installation state...
if "%INSTALL_MSSE%" NEQ "/instmsse" (
  if "%MSSE_INSTALLED%"=="1" (goto CheckMSSEDefs) else (goto SkipMSSEInst)
)
if %OS_DOMAIN_ROLE% GEQ 2 (
  if "%MSSE_INSTALLED%"=="1" (goto CheckMSSEDefs) else (goto SkipMSSEInst)
)
set MSSE_FILENAME=..\msse\%OS_ARCH%-glb\MSEInstall-%OS_ARCH%-%OS_LANG%.exe
if not exist %MSSE_FILENAME% (
  echo Warning: Microsoft Security Essentials installation file ^(%MSSE_FILENAME%^) not found.
  echo %DATE% %TIME% - Warning: Microsoft Security Essentials installation file ^(%MSSE_FILENAME%^) not found>>%UPDATE_LOGFILE%
  if "%MSSE_INSTALLED%"=="1" (goto CheckMSSEDefs) else (goto SkipMSSEInst)
)
rem *** Determine Microsoft Security Essentials installation file version ***
echo Determining Microsoft Security Essentials installation file version...
%CSCRIPT_PATH% //Nologo //B //E:vbs DetermineFileVersion.vbs %MSSE_FILENAME% MSSE_VER_TARGET
if not exist "%TEMP%\SetFileVersion.cmd" goto CheckMSSEDefs
call "%TEMP%\SetFileVersion.cmd"
del "%TEMP%\SetFileVersion.cmd"
if %MSSE_VER_MAJOR% LSS %MSSE_VER_TARGET_MAJOR% goto InstallMSSE
if %MSSE_VER_MAJOR% GTR %MSSE_VER_TARGET_MAJOR% goto CheckMSSEDefs
if %MSSE_VER_MINOR% LSS %MSSE_VER_TARGET_MINOR% goto InstallMSSE
if %MSSE_VER_MINOR% GTR %MSSE_VER_TARGET_MINOR% goto CheckMSSEDefs
if %MSSE_VER_BUILD% LSS %MSSE_VER_TARGET_BUILD% goto InstallMSSE
if %MSSE_VER_BUILD% GTR %MSSE_VER_TARGET_BUILD% goto CheckMSSEDefs
if %MSSE_VER_REVIS% GEQ %MSSE_VER_TARGET_REVIS% goto CheckMSSEDefs
:InstallMSSE
echo Installing Microsoft Security Essentials...
call InstallOSUpdate.cmd %MSSE_FILENAME% %VERIFY_MODE% /ignoreerrors /s /runwgacheck /o
set MSSE_FILENAME=
set REBOOT_REQUIRED=1
:CheckMSSEDefs
set MSSE_VER_TARGET_MAJOR=
set MSSE_VER_TARGET_MINOR=
set MSSE_VER_TARGET_BUILD=
set MSSE_VER_TARGET_REVIS=
if /i "%OS_ARCH%"=="x64" (
  set MSSEDEFS_FILENAME=..\msse\%OS_ARCH%-glb\mpam-fex64.exe
) else (
  set MSSEDEFS_FILENAME=..\msse\%OS_ARCH%-glb\mpam-fe.exe
)
if not exist %MSSEDEFS_FILENAME% (
  echo Warning: Microsoft Security Essentials definition file ^(%MSSEDEFS_FILENAME%^) not found.
  echo %DATE% %TIME% - Warning: Microsoft Security Essentials definition file ^(%MSSEDEFS_FILENAME%^) not found>>%UPDATE_LOGFILE%
  goto CheckNISDefs
)
rem *** Determine Microsoft Security Essentials definition file version ***
echo Determining Microsoft Security Essentials definition file version...
%CSCRIPT_PATH% //Nologo //B //E:vbs DetermineFileVersion.vbs %MSSEDEFS_FILENAME% MSSEDEFS_VER_TARGET
if not exist "%TEMP%\SetFileVersion.cmd" goto CheckNISDefs
call "%TEMP%\SetFileVersion.cmd"
del "%TEMP%\SetFileVersion.cmd"
if %MSSEDEFS_VER_MAJOR% LSS %MSSEDEFS_VER_TARGET_MAJOR% goto InstallMSSEDefs
if %MSSEDEFS_VER_MAJOR% GTR %MSSEDEFS_VER_TARGET_MAJOR% goto CheckNISDefs
if %MSSEDEFS_VER_MINOR% LSS %MSSEDEFS_VER_TARGET_MINOR% goto InstallMSSEDefs
if %MSSEDEFS_VER_MINOR% GTR %MSSEDEFS_VER_TARGET_MINOR% goto CheckNISDefs
if %MSSEDEFS_VER_BUILD% LSS %MSSEDEFS_VER_TARGET_BUILD% goto InstallMSSEDefs
if %MSSEDEFS_VER_BUILD% GTR %MSSEDEFS_VER_TARGET_BUILD% goto CheckNISDefs
if %MSSEDEFS_VER_REVIS% GEQ %MSSEDEFS_VER_TARGET_REVIS% goto CheckNISDefs
:InstallMSSEDefs
echo Installing Microsoft Security Essentials definition file...
call InstallOSUpdate.cmd %MSSEDEFS_FILENAME% %VERIFY_MODE% /ignoreerrors -q
set MSSEDEFS_FILENAME=
:CheckNISDefs
set MSSEDEFS_VER_TARGET_MAJOR=
set MSSEDEFS_VER_TARGET_MINOR=
set MSSEDEFS_VER_TARGET_BUILD=
set MSSEDEFS_VER_TARGET_REVIS=
set NISDEFS_FILENAME=..\msse\%OS_ARCH%-glb\nis_full_%OS_ARCH%.exe
if not exist %NISDEFS_FILENAME% (
  echo Warning: Network Inspection System definition file ^(%NISDEFS_FILENAME%^) not found.
  echo %DATE% %TIME% - Warning: Network Inspection System definition file ^(%NISDEFS_FILENAME%^) not found>>%UPDATE_LOGFILE%
  goto SkipMSSEInst
)
rem *** Determine Network Inspection System definition file version ***
echo Determining Network Inspection System definition file version...
%CSCRIPT_PATH% //Nologo //B //E:vbs DetermineFileVersion.vbs %NISDEFS_FILENAME% NISDEFS_VER_TARGET
if not exist "%TEMP%\SetFileVersion.cmd" goto SkipMSSEInst
call "%TEMP%\SetFileVersion.cmd"
del "%TEMP%\SetFileVersion.cmd"
if %NISDEFS_VER_MAJOR% LSS %NISDEFS_VER_TARGET_MAJOR% goto InstallNISDefs
if %NISDEFS_VER_MAJOR% GTR %NISDEFS_VER_TARGET_MAJOR% goto SkipMSSEInst
if %NISDEFS_VER_MINOR% LSS %NISDEFS_VER_TARGET_MINOR% goto InstallNISDefs
if %NISDEFS_VER_MINOR% GTR %NISDEFS_VER_TARGET_MINOR% goto SkipMSSEInst
if %NISDEFS_VER_BUILD% LSS %NISDEFS_VER_TARGET_BUILD% goto InstallNISDefs
if %NISDEFS_VER_BUILD% GTR %NISDEFS_VER_TARGET_BUILD% goto SkipMSSEInst
if %NISDEFS_VER_REVIS% GEQ %NISDEFS_VER_TARGET_REVIS% goto SkipMSSEInst
:InstallNISDefs
echo Installing Network Inspection System definition file...
call InstallOSUpdate.cmd %NISDEFS_FILENAME% %VERIFY_MODE% /ignoreerrors
set NISDEFS_FILENAME=
:SkipMSSEInst
set NISDEFS_VER_TARGET_MAJOR=
set NISDEFS_VER_TARGET_MINOR=
set NISDEFS_VER_TARGET_BUILD=
set NISDEFS_VER_TARGET_REVIS=

if "%REBOOT_REQUIRED%" NEQ "1" goto NoUpdates

:Installed
if "%RECALL_REQUIRED%"=="1" (
  if "%BOOT_MODE%"=="/autoreboot" (
    if %OS_DOMAIN_ROLE% GEQ 4 (
      echo.
      echo Automatic recall is not supported on domain controllers.
      echo %DATE% %TIME% - Info: Automatic recall is not supported on domain controllers>>%UPDATE_LOGFILE%
      goto ManualRecall
    )
    if not exist ..\bin\Autologon.exe (
      echo.
      echo Warning: Utility ..\bin\Autologon.exe not found. Automatic recall is unavailable.
      echo %DATE% %TIME% - Warning: Utility ..\bin\Autologon.exe not found. Automatic recall is unavailable>>%UPDATE_LOGFILE%
      goto ManualRecall
    )
    if "%USERNAME%" NEQ "WOUTempAdmin" (
      echo Preparing automatic recall...
      call PrepareRecall.cmd "%~f0" %BACKUP_MODE% %VERIFY_MODE% %UPDATE_RCERTS% %INSTALL_IE% %UPDATE_CPP% %UPDATE_DX% %INSTALL_MSSL% %UPDATE_WMP% %INSTALL_DOTNET35% %INSTALL_DOTNET4% %INSTALL_PSH% %INSTALL_WMF% %INSTALL_MSSE% %UPDATE_TSC% %INSTALL_OFC% %INSTALL_OFV% %BOOT_MODE% %FINISH_MODE% %SHOW_LOG% %LIST_MODE_IDS% %LIST_MODE_UPDATES% %SKIP_DYNAMIC%
    )
    if exist %SystemRoot%\System32\bcdedit.exe (
      echo Adjusting boot sequence for next reboot...
      %SystemRoot%\System32\bcdedit.exe /bootsequence {current}
      echo %DATE% %TIME% - Info: Adjusted boot sequence for next reboot>>%UPDATE_LOGFILE%
    )
    echo Rebooting...
    %SystemRoot%\System32\shutdown.exe /r /f /t 3
  ) else goto ManualRecall
) else (
  if exist %SystemRoot%\Temp\wou_w63upd_tried.txt del %SystemRoot%\Temp\wou_w63upd_tried.txt
  if exist %SystemRoot%\Temp\wou_iepre_tried.txt del %SystemRoot%\Temp\wou_iepre_tried.txt
  if exist %SystemRoot%\Temp\wou_ie_tried.txt del %SystemRoot%\Temp\wou_ie_tried.txt
  if exist %SystemRoot%\Temp\wou_wupre_tried.txt del %SystemRoot%\Temp\wou_wupre_tried.txt
  if exist "%TEMP%\UpdateInstaller.ini" del "%TEMP%\UpdateInstaller.ini"
  if "%SHOW_LOG%"=="/showlog" call PrepareShowLogFile.cmd
  if "%BOOT_MODE%"=="/autoreboot" (
    if "%USERNAME%"=="WOUTempAdmin" (
      echo Cleaning up automatic recall...
      call CleanupRecall.cmd
      del /Q "%TEMP%\wourecall.*"
    )
    if "%FINISH_MODE%"=="/shutdown" (
      echo Shutting down...
      %SystemRoot%\System32\shutdown.exe /s /f /t 3
    ) else (
      if exist %SystemRoot%\System32\bcdedit.exe (
        echo Adjusting boot sequence for next reboot...
        %SystemRoot%\System32\bcdedit.exe /bootsequence {current}
        echo %DATE% %TIME% - Info: Adjusted boot sequence for next reboot>>%UPDATE_LOGFILE%
      )
      echo Rebooting...
      %SystemRoot%\System32\shutdown.exe /r /f /t 3
    )
  ) else (
    if "%FINISH_MODE%"=="/shutdown" (
      echo Shutting down...
      %SystemRoot%\System32\shutdown.exe /s /f /t 3
    ) else (
      echo.
      echo Installation successful. Please reboot your system now.
      echo %DATE% %TIME% - Info: Installation successful>>%UPDATE_LOGFILE%
      echo.
      echo 
    )
  )
)
goto EoF

:ManualRecall
echo.
echo Installation successful. Please reboot your system now and recall Update afterwards.
echo %DATE% %TIME% - Info: Installation successful (Updates pending)>>%UPDATE_LOGFILE%
echo.
echo 
goto EoF

:NoExtensions
echo.
echo ERROR: No command extensions available.
echo.
exit /b 1

:NoTemp
echo.
echo ERROR: Environment variable TEMP not set.
echo %DATE% %TIME% - Error: Environment variable TEMP not set>>%UPDATE_LOGFILE%
echo.
goto Cleanup

:NoTempDir
echo.
echo ERROR: Directory "%TEMP%" not found.
echo %DATE% %TIME% - Error: Directory "%TEMP%" not found>>%UPDATE_LOGFILE%
echo.
goto Cleanup

:NoCScript
echo.
echo ERROR: VBScript interpreter %CSCRIPT_PATH% not found.
echo %DATE% %TIME% - Error: VBScript interpreter %CSCRIPT_PATH% not found>>%UPDATE_LOGFILE%
echo.
goto Cleanup

:NoReg
echo.
echo ERROR: Registry tool %REG_PATH% not found.
echo %DATE% %TIME% - Error: Registry tool %REG_PATH% not found>>%UPDATE_LOGFILE%
echo.
goto Cleanup

:EndlessLoop
echo.
echo ERROR: Potentially endless reboot/recall loop detected.
echo %DATE% %TIME% - Error: Potentially endless reboot/recall loop detected>>%UPDATE_LOGFILE%
echo.
goto Cleanup

:NoIfAdmin
echo.
echo ERROR: File ..\bin\IfAdmin.exe not found.
echo %DATE% %TIME% - Error: File ..\bin\IfAdmin.exe not found>>%UPDATE_LOGFILE%
echo.
goto Cleanup

:NoAdmin
echo.
echo ERROR: User %USERNAME% does not have administrative privileges.
echo %DATE% %TIME% - Error: User %USERNAME% does not have administrative privileges>>%UPDATE_LOGFILE%
echo.
goto EoF

:NoSysEnvVars
echo.
echo ERROR: Determination of OS properties failed.
echo %DATE% %TIME% - Error: Determination of OS properties failed>>%UPDATE_LOGFILE%
echo.
goto Cleanup

:UnsupLang
echo.
echo ERROR: Unsupported Operating System language.
echo %DATE% %TIME% - Error: Unsupported Operating System language>>%UPDATE_LOGFILE%
echo.
goto Cleanup

:UnsupOS
echo.
echo ERROR: Unsupported Operating System (%OS_NAME%).
echo %DATE% %TIME% - Error: Unsupported Operating System (%OS_NAME%)>>%UPDATE_LOGFILE%
echo.
goto Cleanup

:UnsupArch
echo.
echo ERROR: Unsupported Operating System architecture (%OS_ARCH%).
echo %DATE% %TIME% - Error: Unsupported Operating System architecture (%OS_ARCH%)>>%UPDATE_LOGFILE%
echo.
goto Cleanup

:InvalidMedium
echo.
echo ERROR: Medium neither supports your Windows nor your Office version.
echo %DATE% %TIME% - Error: Medium neither supports your Windows nor your Office version>>%UPDATE_LOGFILE%
echo.
goto Cleanup

:NoWUAInst
echo.
echo ERROR: File %WUA_FILENAME% not found.
echo %DATE% %TIME% - Error: File %WUA_FILENAME% not found>>%UPDATE_LOGFILE%
echo.
goto Cleanup

:NoSPTargetId
echo.
echo ERROR: Environment variable OS_SP_TARGET_ID not set.
echo %DATE% %TIME% - Error: Environment variable OS_SP_TARGET_ID not set>>%UPDATE_LOGFILE%
echo.
goto Cleanup

:AUSvcNotRunning
echo.
echo ERROR: Service 'Windows Update' (wuauserv) is not running and could not be started.
echo %DATE% %TIME% - Error: Service 'Windows Update' (wuauserv) is not running and could not be started>>%UPDATE_LOGFILE%
echo.
goto Cleanup

:NoCatalog
echo.
echo ERROR: File ..\wsus\wsusscn2.cab not found.
echo %DATE% %TIME% - Error: File ..\wsus\wsusscn2.cab not found>>%UPDATE_LOGFILE%
echo.
goto Cleanup

:CatalogIntegrityError
echo.
echo ERROR: File hash does not match stored value (file: ..\wsus\wsusscn2.cab).
echo %DATE% %TIME% - Error: File hash does not match stored value (file: ..\wsus\wsusscn2.cab)>>%UPDATE_LOGFILE%
echo.
goto Cleanup

:NoUpdates
echo.
if "%NO_MISSING_IDS%"=="1" (
  echo No missing update found. Nothing to do!
  echo %DATE% %TIME% - Info: No missing update found>>%UPDATE_LOGFILE%
) else (
  echo Any missing update was either black listed or not found.
  echo %DATE% %TIME% - Info: Any missing update was either black listed or not found>>%UPDATE_LOGFILE%
)
echo.
goto Cleanup

:ListError
echo.
echo ERROR: Listing of update files failed.
echo %DATE% %TIME% - Error: Listing of update files failed>>%UPDATE_LOGFILE%
echo.
goto Cleanup

:InstError
echo.
echo ERROR: Installation failed.
echo %DATE% %TIME% - Error: Installation failed>>%UPDATE_LOGFILE%
echo.
goto Cleanup

:Cleanup
if exist %SystemRoot%\Temp\wou_w63upd_tried.txt del %SystemRoot%\Temp\wou_w63upd_tried.txt
if exist %SystemRoot%\Temp\wou_iepre_tried.txt del %SystemRoot%\Temp\wou_iepre_tried.txt
if exist %SystemRoot%\Temp\wou_ie_tried.txt del %SystemRoot%\Temp\wou_ie_tried.txt
if exist %SystemRoot%\Temp\wou_wupre_tried.txt del %SystemRoot%\Temp\wou_wupre_tried.txt
if exist "%TEMP%\UpdateInstaller.ini" del "%TEMP%\UpdateInstaller.ini"
if "%USERNAME%"=="WOUTempAdmin" (
  if "%SHOW_LOG%"=="/showlog" call PrepareShowLogFile.cmd
  echo Cleaning up automatic recall...
  call CleanupRecall.cmd
  del /Q "%TEMP%\wourecall.*"
  if exist %SystemRoot%\System32\bcdedit.exe (
    echo Adjusting boot sequence for next reboot...
    %SystemRoot%\System32\bcdedit.exe /bootsequence {current}
    echo %DATE% %TIME% - Info: Adjusted boot sequence for next reboot>>%UPDATE_LOGFILE%
  )
  echo Rebooting...
  %SystemRoot%\System32\shutdown.exe /r /f /t 3
) else (
  if "%AUSVC_STARTED%"=="1" (
    echo Stopping service 'Windows Update' ^(wuauserv^)...
    %SystemRoot%\System32\net.exe stop wuauserv >nul
    if errorlevel 1 (
      echo %DATE% %TIME% - Warning: Stopping of service 'Windows Update' ^(wuauserv^) failed>>%UPDATE_LOGFILE%
    ) else (
      echo %DATE% %TIME% - Info: Stopped service 'Windows Update' ^(wuauserv^)>>%UPDATE_LOGFILE%
    )
  )
  if "%SHOW_LOG%"=="/showlog" start %SystemRoot%\System32\notepad.exe %UPDATE_LOGFILE%
)
goto EoF

:EoF
rem *** Execute custom finalization hook ***
if exist .\custom\FinalizationHook.cmd (
  echo Executing custom finalization hook...
  pushd .\custom
  call FinalizationHook.cmd
  popd
  echo %DATE% %TIME% - Info: Executed custom finalization hook ^(Errorlevel: %errorlevel%^)>>%UPDATE_LOGFILE%
)
cd ..
echo Ending WSUS Offline Update at %TIME%...
echo %DATE% %TIME% - Info: Ending WSUS Offline Update>>%UPDATE_LOGFILE%
title %ComSpec%
if "%RECALL_REQUIRED%"=="1" (
  verify other 2>nul
  exit /b 3011
)
if "%REBOOT_REQUIRED%"=="1" exit /b 3010
endlocal
