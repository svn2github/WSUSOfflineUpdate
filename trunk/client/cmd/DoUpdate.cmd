@echo off
rem *** Author: T. Wittrock, RZ Uni Kiel ***

verify other 2>nul
setlocal enableextensions
if errorlevel 1 goto NoExtensions

if "%DIRCMD%" NEQ "" set DIRCMD=

%~d0
cd "%~p0"

set WSUSOFFLINE_VERSION=6.6.4+ (r159)
set UPDATE_LOGFILE=%SystemRoot%\wsusofflineupdate.log
if exist %SystemRoot%\ctupdate.log ren %SystemRoot%\ctupdate.log wsusofflineupdate.log 
title %~n0 %*
echo Starting WSUS Offline Update (v. %WSUSOFFLINE_VERSION%) at %TIME%...
if exist %UPDATE_LOGFILE% echo. >>%UPDATE_LOGFILE%
echo %DATE% %TIME% - Info: Starting WSUS Offline Update (v. %WSUSOFFLINE_VERSION%) on %COMPUTERNAME% (user: %USERNAME%) >>%UPDATE_LOGFILE%

:EvalParams
if "%1"=="" goto NoMoreParams
for %%i in (/nobackup /verify /instie7 /instie8 /updatewmp /updatetsc /instdotnet35 /instdotnet4 /instpsh /instmsse /instofccnvs /autoreboot /shutdown /showlog /all /excludestatics) do (
  if /i "%1"=="%%i" echo %DATE% %TIME% - Info: Option %%i detected >>%UPDATE_LOGFILE%
)
if /i "%1"=="/nobackup" set BACKUP_MODE=/nobackup
if /i "%1"=="/verify" set VERIFY_MODE=/verify
if /i "%1"=="/instie7" set INSTALL_IE=/instie7
if /i "%1"=="/instie8" set INSTALL_IE=/instie8
if /i "%1"=="/updatewmp" set UPDATE_WMP=/updatewmp
if /i "%1"=="/updatetsc" set UPDATE_TSC=/updatetsc
if /i "%1"=="/instdotnet35" set INSTALL_DOTNET35=/instdotnet35
if /i "%1"=="/instdotnet4" set INSTALL_DOTNET4=/instdotnet4
if /i "%1"=="/instpsh" set INSTALL_PSH=/instpsh
if /i "%1"=="/instmsse" set INSTALL_MSSE=/instmsse
if /i "%1"=="/instofccnvs" set INSTALL_CONVERTERS=/instofccnvs
if /i "%1"=="/autoreboot" set BOOT_MODE=/autoreboot
if /i "%1"=="/shutdown" set FINISH_MODE=/shutdown
if /i "%1"=="/showlog" set SHOW_LOG=/showlog
if /i "%1"=="/all" set LIST_MODE_IDS=/all
if /i "%1"=="/excludestatics" set LIST_MODE_UPDATES=/excludestatics
shift /1
goto EvalParams

:NoMoreParams
if "%TEMP%"=="" goto NoTemp
pushd "%TEMP%"
if errorlevel 1 goto NoTempDir
popd

rem *** Execute custom initialization hook ***
if exist .\custom\InitializationHook.cmd (
  echo Executing custom initialization hook...
  call .\custom\InitializationHook.cmd
  echo %DATE% %TIME% - Info: Executed custom initialization hook >>%UPDATE_LOGFILE%
)

set CSCRIPT_PATH=%SystemRoot%\system32\cscript.exe
if not exist %CSCRIPT_PATH% goto NoCScript

if exist %SystemRoot%\system32\reg.exe (
  set REG_PATH=%SystemRoot%\system32\reg.exe
) else (
  set REG_PATH=..\bin\reg.exe
)
if "%BOOT_MODE%"=="/autoreboot" (if not exist %REG_PATH% goto NoReg)
if "%SHOW_LOG%"=="/showlog" (if not exist %REG_PATH% goto NoReg)

rem *** Check number of automatic recalls ***
if "%USERNAME%"=="WSUSUpdateAdmin" (
  if exist "%TEMP%\wsusadmin-recall.3" goto EndlessLoop
  if exist "%TEMP%\wsusadmin-recall.2" ren "%TEMP%\wsusadmin-recall.2" wsusadmin-recall.3
  if exist "%TEMP%\wsusadmin-recall.1" (
    ren "%TEMP%\wsusadmin-recall.1" wsusadmin-recall.2
  ) else (
    echo recall>"%TEMP%\wsusadmin-recall.1"
  )
)

rem *** Determine system's properties ***
echo Determining system's properties...
%CSCRIPT_PATH% //Nologo //E:vbs DetermineSystemProperties.vbs
if errorlevel 1 goto NoSysEnvVars

rem *** Set environment variables for system's properties ***
if not exist "%TEMP%\SetSystemEnvVars.cmd" goto NoSysEnvVars
call "%TEMP%\SetSystemEnvVars.cmd"
del "%TEMP%\SetSystemEnvVars.cmd"
if "%SystemDirectory%"=="" set SystemDirectory=%SystemRoot%\system32
if "%OS_ARCH%"=="" set OS_ARCH=%PROCESSOR_ARCHITECTURE%
if "%OS_LANG%"=="" goto UnsupLang

rem *** Set target environment variables ***
call SetTargetEnvVars.cmd %INSTALL_IE%
if errorlevel 1 goto Cleanup
if "%OS_NAME%"=="" goto NoOSName

rem *** Echo OS properties ***
echo Found OS caption: %OS_CAPTION%
echo Found Microsoft Windows version: %OS_VER_MAJOR%.%OS_VER_MINOR%.%OS_VER_BUILD% (%OS_NAME% %OS_ARCH% %OS_LANG% sp%OS_SP_VER_MAJOR%)
rem echo Found Windows Update Agent version: %WUA_VER_MAJOR%.%WUA_VER_MINOR%.%WUA_VER_BUILD%.%WUA_VER_REVISION%
rem echo Found Windows Installer version: %MSI_VER_MAJOR%.%MSI_VER_MINOR%.%MSI_VER_BUILD%.%MSI_VER_REVISION%
rem echo Found Windows Script Host version: %WSH_VER_MAJOR%.%WSH_VER_MINOR%.%WSH_VER_BUILD%.%WSH_VER_REVISION%
rem echo Found Internet Explorer version: %IE_VER_MAJOR%.%IE_VER_MINOR%.%IE_VER_BUILD%.%IE_VER_REVISION%
rem echo Found Microsoft Data Access Components version: %MDAC_VER_MAJOR%.%MDAC_VER_MINOR%.%MDAC_VER_BUILD%.%MDAC_VER_REVISION%
rem echo Found Microsoft DirectX version: %DIRECTX_VER_MAJOR%.%DIRECTX_VER_MINOR%.%DIRECTX_VER_BUILD%.%DIRECTX_VER_REVISION% (%DIRECTX_NAME%)
rem echo Found Microsoft .NET Framework 3.5 version: %DOTNET35_VER_MAJOR%.%DOTNET35_VER_MINOR%.%DOTNET35_VER_BUILD%.%DOTNET35_VER_REVISION%
rem echo Found Windows PowerShell version: %PSH_VER_MAJOR%.%PSH_VER_MINOR%
rem echo Found Windows Media Player version: %WMP_VER_MAJOR%.%WMP_VER_MINOR%.%WMP_VER_BUILD%.%WMP_VER_REVISION%
rem echo Found Terminal Services Client version: %TSC_VER_MAJOR%.%TSC_VER_MINOR%.%TSC_VER_BUILD%.%TSC_VER_REVISION%
if "%OXP_VER_MAJOR%" NEQ "" (
  echo Found Microsoft Office XP %OXP_VER_APP% version: %OXP_VER_MAJOR%.%OXP_VER_MINOR%.%OXP_VER_BUILD%.%OXP_VER_REVISION% ^(oxp %OXP_LANG% sp%OXP_SP_VER%^)
)
if "%O2K3_VER_MAJOR%" NEQ "" (
  echo Found Microsoft Office 2003 %O2K3_VER_APP% version: %O2K3_VER_MAJOR%.%O2K3_VER_MINOR%.%O2K3_VER_BUILD%.%O2K3_VER_REVISION% ^(o2k3 %O2K3_LANG% sp%O2K3_SP_VER%^)
)
if "%O2K7_VER_MAJOR%" NEQ "" (
  echo Found Microsoft Office 2007 %O2K7_VER_APP% version: %O2K7_VER_MAJOR%.%O2K7_VER_MINOR%.%O2K7_VER_BUILD%.%O2K7_VER_REVISION% ^(o2k7 %O2K7_LANG% sp%O2K7_SP_VER%^)
)
if "%O2K10_VER_MAJOR%" NEQ "" (
  echo Found Microsoft Office 2010 %O2K10_VER_APP% version: %O2K10_VER_MAJOR%.%O2K10_VER_MINOR%.%O2K10_VER_BUILD%.%O2K10_VER_REVISION% ^(o2k10 %O2K10_LANG% sp%O2K10_SP_VER%^)
)
echo %DATE% %TIME% - Info: Found OS caption '%OS_CAPTION%' >>%UPDATE_LOGFILE%
echo %DATE% %TIME% - Info: Found Microsoft Windows version %OS_VER_MAJOR%.%OS_VER_MINOR%.%OS_VER_BUILD% (%OS_NAME% %OS_ARCH% %OS_LANG% sp%OS_SP_VER_MAJOR%) >>%UPDATE_LOGFILE%
echo %DATE% %TIME% - Info: Found Windows Update Agent version %WUA_VER_MAJOR%.%WUA_VER_MINOR%.%WUA_VER_BUILD%.%WUA_VER_REVISION% >>%UPDATE_LOGFILE%
echo %DATE% %TIME% - Info: Found Windows Installer version %MSI_VER_MAJOR%.%MSI_VER_MINOR%.%MSI_VER_BUILD%.%MSI_VER_REVISION% >>%UPDATE_LOGFILE%
echo %DATE% %TIME% - Info: Found Windows Script Host version %WSH_VER_MAJOR%.%WSH_VER_MINOR%.%WSH_VER_BUILD%.%WSH_VER_REVISION% >>%UPDATE_LOGFILE%
echo %DATE% %TIME% - Info: Found Internet Explorer version %IE_VER_MAJOR%.%IE_VER_MINOR%.%IE_VER_BUILD%.%IE_VER_REVISION% >>%UPDATE_LOGFILE%
echo %DATE% %TIME% - Info: Found Microsoft Data Access Components version %MDAC_VER_MAJOR%.%MDAC_VER_MINOR%.%MDAC_VER_BUILD%.%MDAC_VER_REVISION% >>%UPDATE_LOGFILE%
echo %DATE% %TIME% - Info: Found Microsoft DirectX version %DIRECTX_VER_MAJOR%.%DIRECTX_VER_MINOR%.%DIRECTX_VER_BUILD%.%DIRECTX_VER_REVISION% (%DIRECTX_NAME%) >>%UPDATE_LOGFILE%
echo %DATE% %TIME% - Info: Found Microsoft .NET Framework 3.5 version %DOTNET35_VER_MAJOR%.%DOTNET35_VER_MINOR%.%DOTNET35_VER_BUILD%.%DOTNET35_VER_REVISION% >>%UPDATE_LOGFILE%
echo %DATE% %TIME% - Info: Found Windows PowerShell version %PSH_VER_MAJOR%.%PSH_VER_MINOR% >>%UPDATE_LOGFILE%
echo %DATE% %TIME% - Info: Found Windows Media Player version %WMP_VER_MAJOR%.%WMP_VER_MINOR%.%WMP_VER_BUILD%.%WMP_VER_REVISION% >>%UPDATE_LOGFILE%
echo %DATE% %TIME% - Info: Found Terminal Services Client version %TSC_VER_MAJOR%.%TSC_VER_MINOR%.%TSC_VER_BUILD%.%TSC_VER_REVISION% >>%UPDATE_LOGFILE%
if "%OXP_VER_MAJOR%" NEQ "" (
  echo %DATE% %TIME% - Info: Found Microsoft Office XP %OXP_VER_APP% version %OXP_VER_MAJOR%.%OXP_VER_MINOR%.%OXP_VER_BUILD%.%OXP_VER_REVISION% ^(oxp %OXP_LANG% sp%OXP_SP_VER%^) >>%UPDATE_LOGFILE%
)
if "%O2K3_VER_MAJOR%" NEQ "" (
  echo %DATE% %TIME% - Info: Found Microsoft Office 2003 %O2K3_VER_APP% version %O2K3_VER_MAJOR%.%O2K3_VER_MINOR%.%O2K3_VER_BUILD%.%O2K3_VER_REVISION% ^(o2k3 %O2K3_LANG% sp%O2K3_SP_VER%^) >>%UPDATE_LOGFILE%
)
if "%O2K7_VER_MAJOR%" NEQ "" (
  echo %DATE% %TIME% - Info: Found Microsoft Office 2007 %O2K7_VER_APP% version %O2K7_VER_MAJOR%.%O2K7_VER_MINOR%.%O2K7_VER_BUILD%.%O2K7_VER_REVISION% ^(o2k7 %O2K7_LANG% sp%O2K7_SP_VER%^) >>%UPDATE_LOGFILE%
)
if "%O2K10_VER_MAJOR%" NEQ "" (
  echo %DATE% %TIME% - Info: Found Microsoft Office 2010 %O2K10_VER_APP% version %O2K10_VER_MAJOR%.%O2K10_VER_MINOR%.%O2K10_VER_BUILD%.%O2K10_VER_REVISION% ^(o2k10 %O2K10_LANG% sp%O2K10_SP_VER%^) >>%UPDATE_LOGFILE%
)

rem *** Check Operating System architecture ***
for %%i in (x86 x64) do (if /i "%OS_ARCH%"=="%%i" goto ValidArch)
goto UnsupArch
:ValidArch

rem *** Check user's privileges ***
echo Checking user's privileges...
if not exist ..\bin\IfAdmin.exe goto NoIfAdmin
..\bin\IfAdmin.exe
if not errorlevel 1 goto NoAdmin

rem *** Check medium content ***
echo Checking medium content...
if exist ..\builddate.txt (
  for /F %%i in ('type ..\builddate.txt') do (
    echo Medium build date: %%i
    echo %DATE% %TIME% - Info: Medium build date: %%i >>%UPDATE_LOGFILE%
  )
)
if /i "%OS_ARCH%"=="x64" (
  if exist ..\%OS_NAME%-%OS_ARCH%\%OS_LANG%\nul (
    echo Medium supports Microsoft Windows ^(%OS_NAME%-%OS_ARCH% %OS_LANG%^).
    echo %DATE% %TIME% - Info: Medium supports Microsoft Windows ^(%OS_NAME%-%OS_ARCH% %OS_LANG%^) >>%UPDATE_LOGFILE%
    goto CheckOfficeMedium
  )
  if exist ..\%OS_NAME%-%OS_ARCH%\glb\nul (
    echo Medium supports Microsoft Windows ^(%OS_NAME%-%OS_ARCH% glb^).
    echo %DATE% %TIME% - Info: Medium supports Microsoft Windows ^(%OS_NAME%-%OS_ARCH% glb^) >>%UPDATE_LOGFILE%
    goto CheckOfficeMedium
  )
) else (
  if exist ..\%OS_NAME%\%OS_LANG%\nul (
    echo Medium supports Microsoft Windows ^(%OS_NAME% %OS_LANG%^).
    echo %DATE% %TIME% - Info: Medium supports Microsoft Windows ^(%OS_NAME% %OS_LANG%^) >>%UPDATE_LOGFILE%
    goto CheckOfficeMedium
  )
  if exist ..\%OS_NAME%\glb\nul (
    echo Medium supports Microsoft Windows ^(%OS_NAME% glb^).
    echo %DATE% %TIME% - Info: Medium supports Microsoft Windows ^(%OS_NAME% glb^) >>%UPDATE_LOGFILE%
    goto CheckOfficeMedium
  )
)
echo Medium does not support Microsoft Windows (%OS_NAME% %OS_LANG%).
echo %DATE% %TIME% - Info: Medium does not support Microsoft Windows (%OS_NAME% %OS_LANG%) >>%UPDATE_LOGFILE%
if "%OFC_NAME%"=="" goto InvalidMedium

:CheckOfficeMedium
if "%OFC_NAME%"=="" goto ProperMedium
if exist ..\%OFC_NAME%\%OFC_LANG%\nul (
  echo Medium supports Microsoft Office ^(%OFC_NAME% %OFC_LANG%^).
  echo %DATE% %TIME% - Info: Medium supports Microsoft Office ^(%OFC_NAME% %OFC_LANG%^) >>%UPDATE_LOGFILE%
  goto ProperMedium
)
if exist ..\%OFC_NAME%\glb\nul (
  echo Medium supports Microsoft Office ^(%OFC_NAME% glb^).
  echo %DATE% %TIME% - Info: Medium supports Microsoft Office ^(%OFC_NAME% glb^) >>%UPDATE_LOGFILE%
  goto ProperMedium
)
if exist ..\%OFC_NAME%-%OS_ARCH%\%OFC_LANG%\nul (
  echo Medium supports Microsoft Office ^(%OFC_NAME%-%OS_ARCH% %OFC_LANG%^).
  echo %DATE% %TIME% - Info: Medium supports Microsoft Office ^(%OFC_NAME%-%OS_ARCH% %OFC_LANG%^) >>%UPDATE_LOGFILE%
  goto ProperMedium
)
if exist ..\%OFC_NAME%-%OS_ARCH%\glb\nul (
  echo Medium supports Microsoft Office ^(%OFC_NAME%-%OS_ARCH% glb^).
  echo %DATE% %TIME% - Info: Medium supports Microsoft Office ^(%OFC_NAME%-%OS_ARCH% glb^) >>%UPDATE_LOGFILE%
  goto ProperMedium
)
echo Medium does not support Microsoft Office (%OFC_NAME% %OFC_LANG%).
echo %DATE% %TIME% - Info: Medium does not support Microsoft Office (%OFC_NAME% %OFC_LANG%) >>%UPDATE_LOGFILE%
:ProperMedium

rem *** Install Windows Service Pack ***
echo Checking Windows Service Pack version...
if %OS_SP_VER_MAJOR% GEQ %OS_SP_VER_TARGET_MAJOR% goto SkipSPInst
if "%OS_SP_TARGET_ID%"=="" goto NoSPTargetId
echo %OS_SP_TARGET_ID% >"%TEMP%\MissingUpdateIds.txt"
call ListUpdatesToInstall.cmd /excludestatics
if errorlevel 1 goto ListError
if not exist "%TEMP%\UpdatesToInstall.txt" (
  if "%OFC_NAME%"=="" goto NoUpdates
  echo Warning: Windows Service Pack installation file ^(kb%OS_SP_TARGET_ID%^) not found.
  echo %DATE% %TIME% - Warning: Windows Service Pack installation file ^(kb%OS_SP_TARGET_ID%^) not found >>%UPDATE_LOGFILE%
  goto SkipSPInst
)
echo Installing most recent Windows Service Pack...
goto SP%OS_NAME%

:SPwxp
if 0 EQU %OS_SP_VER_MAJOR% (
  if not exist %REG_PATH% goto NoReg
  echo Faking Windows XP Service Pack 1...
  %REG_PATH% ADD HKLM\SYSTEM\CurrentControlSet\Control\Windows /v CSDVersion /t REG_DWORD /d 0x100 /f >nul 2>&1
  if errorlevel 1 (
    echo Warning: Faking of Windows XP Service Pack 1 failed.
    echo %DATE% %TIME% - Warning: Faking of Windows XP Service Pack 1 failed >>%UPDATE_LOGFILE%
    goto SkipSPInst
  ) else (
    echo %DATE% %TIME% - Info: Faked Windows XP Service Pack 1 >>%UPDATE_LOGFILE%
  )
)
:SPw2k
:SPw2k3
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
echo %DATE% %TIME% - Info: Installing most recent Service Pack for Windows Vista >>%UPDATE_LOGFILE%
call InstallListedUpdates.cmd %VERIFY_MODE% /unattend /forcerestart
if errorlevel 1 goto InstError
set RECALL_REQUIRED=1
goto Installed

:SkipSPInst

rem *** Install DirectX End-User Runtime ***
if "%OS_NAME%"=="w60" goto SkipDirectXInst
if "%OS_NAME%"=="w61" goto SkipDirectXInst
echo Checking DirectX version...
if %DIRECTX_VER_MAJOR% LSS %DIRECTX_VER_TARGET_MAJOR% goto InstallDirectX
if %DIRECTX_VER_MAJOR% GTR %DIRECTX_VER_TARGET_MAJOR% goto SkipDirectXInst
if %DIRECTX_VER_MINOR% LSS %DIRECTX_VER_TARGET_MINOR% goto InstallDirectX
if %DIRECTX_VER_MINOR% GTR %DIRECTX_VER_TARGET_MINOR% goto SkipDirectXInst
if %DIRECTX_VER_BUILD% LSS %DIRECTX_VER_TARGET_BUILD% goto InstallDirectX
if %DIRECTX_VER_BUILD% GTR %DIRECTX_VER_TARGET_BUILD% goto SkipDirectXInst
if %DIRECTX_VER_REVISION% GEQ %DIRECTX_VER_TARGET_REVISION% goto SkipDirectXInst
:InstallDirectX
set DIRECTX_FILENAME=..\win\glb\directx_*_redist.exe
dir /B %DIRECTX_FILENAME% >nul 2>&1
if errorlevel 1 (
  echo Warning: File %DIRECTX_FILENAME% not found.
  echo %DATE% %TIME% - Warning: File %DIRECTX_FILENAME% not found >>%UPDATE_LOGFILE%
  goto SkipDirectXInst
)
echo Installing most recent DirectX End-User Runtime...
for /F %%i in ('dir /B %DIRECTX_FILENAME%') do (
  echo Installing ..\win\glb\%%i...
  ..\win\glb\%%i /Q /T:"%TEMP%\directx" /C
  "%TEMP%\directx\dxsetup.exe" /silent
  call SafeRmDir.cmd "%TEMP%\directx"
  echo %DATE% %TIME% - Info: Installed ..\win\glb\%%i >>%UPDATE_LOGFILE%
  set RECALL_REQUIRED=1
  goto Installed
)
:SkipDirectXInst

rem *** Install Windows Update Agent ***
echo Checking Windows Update Agent version...
if %WUA_VER_MAJOR% LSS %WUA_VER_TARGET_MAJOR% goto InstallWUA
if %WUA_VER_MAJOR% GTR %WUA_VER_TARGET_MAJOR% goto SkipWUAInst
if %WUA_VER_MINOR% LSS %WUA_VER_TARGET_MINOR% goto InstallWUA
if %WUA_VER_MINOR% GTR %WUA_VER_TARGET_MINOR% goto SkipWUAInst
if %WUA_VER_BUILD% LSS %WUA_VER_TARGET_BUILD% goto InstallWUA
if %WUA_VER_BUILD% GTR %WUA_VER_TARGET_BUILD% goto SkipWUAInst
if %WUA_VER_REVISION% GEQ %WUA_VER_TARGET_REVISION% goto SkipWUAInst
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
:SkipWUAInst

rem *** Install Windows Installer ***
echo Checking Windows Installer version...
if %MSI_VER_MAJOR% LSS %MSI_VER_TARGET_MAJOR% goto InstallMSI
if %MSI_VER_MAJOR% GTR %MSI_VER_TARGET_MAJOR% goto SkipMSIInst
if %MSI_VER_MINOR% LSS %MSI_VER_TARGET_MINOR% goto InstallMSI
if %MSI_VER_MINOR% GTR %MSI_VER_TARGET_MINOR% goto SkipMSIInst
if %MSI_VER_BUILD% LSS %MSI_VER_TARGET_BUILD% goto InstallMSI
if %MSI_VER_BUILD% GTR %MSI_VER_TARGET_BUILD% goto SkipMSIInst
if %MSI_VER_REVISION% GEQ %MSI_VER_TARGET_REVISION% goto SkipMSIInst
:InstallMSI
if "%MSI_TARGET_ID%"=="" (
  echo Warning: Environment variable MSI_TARGET_ID not set.
  echo %DATE% %TIME% - Warning: Environment variable MSI_TARGET_ID not set >>%UPDATE_LOGFILE%
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
  echo %DATE% %TIME% - Warning: File %MSI_FILENAME% not found >>%UPDATE_LOGFILE%
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
:SkipMSIInst

rem *** Install Windows Script Host ***
echo Checking Windows Script Host version...
if %WSH_VER_MAJOR% LSS %WSH_VER_TARGET_MAJOR% goto InstallWSH
if %WSH_VER_MAJOR% GTR %WSH_VER_TARGET_MAJOR% goto SkipWSHInst
if %WSH_VER_MINOR% LSS %WSH_VER_TARGET_MINOR% goto InstallWSH
if %WSH_VER_MINOR% GTR %WSH_VER_TARGET_MINOR% goto SkipWSHInst
if %WSH_VER_BUILD% LSS %WSH_VER_TARGET_BUILD% goto InstallWSH
if %WSH_VER_BUILD% GTR %WSH_VER_TARGET_BUILD% goto SkipWSHInst
if %WSH_VER_REVISION% GEQ %WSH_VER_TARGET_REVISION% goto SkipWSHInst
:InstallWSH
set WSH_FILENAME=..\%OS_NAME%\glb\scripten.exe
dir /B %WSH_FILENAME% >nul 2>&1
if errorlevel 1 (
  echo Warning: File %WSH_FILENAME% not found.
  echo %DATE% %TIME% - Warning: File %WSH_FILENAME% not found >>%UPDATE_LOGFILE%
  goto SkipWSHInst
)
echo Installing most recent Windows Script Host...
for /F %%i in ('dir /B %WSH_FILENAME%') do (
  call InstallOSUpdate.cmd ..\%OS_NAME%\glb\%%i %VERIFY_MODE% /quiet %BACKUP_MODE% /norestart
  if not errorlevel 1 set REBOOT_REQUIRED=1
)
:SkipWSHInst

rem *** Install Internet Explorer ***
echo Checking Internet Explorer version...
if %IE_VER_MAJOR% LSS %IE_VER_TARGET_MAJOR% goto InstallIE
if %IE_VER_MAJOR% GTR %IE_VER_TARGET_MAJOR% goto SkipIEInst
if %IE_VER_MINOR% LSS %IE_VER_TARGET_MINOR% goto InstallIE
if %IE_VER_MINOR% GTR %IE_VER_TARGET_MINOR% goto SkipIEInst
if %IE_VER_BUILD% LSS %IE_VER_TARGET_BUILD% goto InstallIE
if %IE_VER_BUILD% GTR %IE_VER_TARGET_BUILD% goto SkipIEInst
if %IE_VER_REVISION% GEQ %IE_VER_TARGET_REVISION% goto SkipIEInst
:InstallIE
goto IE%OS_NAME%

:IEw2k
set IE_FILENAME=..\win\%OS_LANG%\ie6setup\ie6setup.exe
if not exist %IE_FILENAME% (
  echo Warning: Unable to install Internet Explorer 6. File %IE_FILENAME% not found. 
  echo %DATE% %TIME% - Warning: Unable to install Internet Explorer 6. File %IE_FILENAME% not found >>%UPDATE_LOGFILE%
  goto SkipIEInst 
)
echo Installing Internet Explorer 6...
call InstallOSUpdate.cmd %IE_FILENAME% %VERIFY_MODE% /ignoreerrors /q:a /r:n
if not errorlevel 1 set RECALL_REQUIRED=1
goto IEInstalled 

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
  echo %DATE% %TIME% - Warning: File %IE_FILENAME% not found >>%UPDATE_LOGFILE%
  goto SkipIEInst 
)
if "%INSTALL_IE%"=="/instie8" (echo Installing Internet Explorer 8...) else (echo Installing Internet Explorer 7...)
for /F %%i in ('dir /B %IE_FILENAME%') do (
  if /i "%OS_ARCH%"=="x64" (
    if "%INSTALL_IE%"=="/instie8" (
      call InstallOSUpdate.cmd ..\%OS_NAME%-%OS_ARCH%\%OS_LANG%\%%i %VERIFY_MODE% /ignoreerrors /quiet /update-no /no-default /norestart
    ) else (
      call InstallOSUpdate.cmd ..\%OS_NAME%-%OS_ARCH%\%OS_LANG%\%%i %VERIFY_MODE% /ignoreerrors /quiet /update-no /no-default %BACKUP_MODE% /norestart
    )
  ) else (
    if "%INSTALL_IE%"=="/instie8" (
      call InstallOSUpdate.cmd ..\%OS_NAME%\%OS_LANG%\%%i %VERIFY_MODE% /ignoreerrors /quiet /update-no /no-default /norestart
    ) else (
      call InstallOSUpdate.cmd ..\%OS_NAME%\%OS_LANG%\%%i %VERIFY_MODE% /ignoreerrors /quiet /update-no /no-default %BACKUP_MODE% /norestart
    )
  )
  if not errorlevel 1 set RECALL_REQUIRED=1
)
goto IEInstalled 

:IEw60
if /i "%OS_ARCH%"=="x64" (
  set IE_FILENAME=..\%OS_NAME%-%OS_ARCH%\glb\IE8-WindowsVista-%OS_ARCH%-%OS_LANG%*.exe
) else (
  set IE_FILENAME=..\%OS_NAME%\glb\IE8-WindowsVista-%OS_ARCH%-%OS_LANG%*.exe
)
dir /B %IE_FILENAME% >nul 2>&1
if errorlevel 1 (
  echo Warning: File %IE_FILENAME% not found. 
  echo %DATE% %TIME% - Warning: File %IE_FILENAME% not found >>%UPDATE_LOGFILE%
  goto SkipIEInst
)
echo Installing Internet Explorer 8...
for /F %%i in ('dir /B %IE_FILENAME%') do (
  if /i "%OS_ARCH%"=="x64" (
    call InstallOSUpdate.cmd ..\%OS_NAME%-%OS_ARCH%\glb\%%i %VERIFY_MODE% /ignoreerrors /quiet /update-no /no-default /norestart
  ) else (
    call InstallOSUpdate.cmd ..\%OS_NAME%\glb\%%i %VERIFY_MODE% /ignoreerrors /quiet /update-no /no-default /norestart
  )
  if not errorlevel 1 set RECALL_REQUIRED=1
)
goto IEInstalled 

:IEw61
goto SkipIEInst

:IEInstalled
if "%RECALL_REQUIRED%"=="1" goto Installed
:SkipIEInst

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
  echo %DATE% %TIME% - Warning: Environment variable WMP_TARGET_ID not set >>%UPDATE_LOGFILE%
  goto SkipWMPInst
) 
echo %WMP_TARGET_ID% >"%TEMP%\MissingUpdateIds.txt"
call ListUpdatesToInstall.cmd /excludestatics
if errorlevel 1 goto ListError
if exist "%TEMP%\UpdatesToInstall.txt" (
  echo Installing most recent Windows Media Player...
  call InstallListedUpdates.cmd /selectoptions %BACKUP_MODE% %VERIFY_MODE% /errorsaswarnings
) else (
  echo Warning: Windows Media Player installation file ^(kb%WMP_TARGET_ID%^) not found.
  echo %DATE% %TIME% - Warning: Windows Media Player installation file ^(kb%WMP_TARGET_ID%^) not found >>%UPDATE_LOGFILE%
  goto SkipWMPInst
)
set REBOOT_REQUIRED=1
:SkipWMPInst

rem *** Install most recent Windows Terminal Services Client ***
if "%OS_NAME%"=="w2k" goto SkipTSCInst
if "%UPDATE_TSC%" NEQ "/updatetsc" goto SkipTSCInst
echo Checking Windows Terminal Services Client version...
if %TSC_VER_MAJOR% LSS %TSC_VER_TARGET_MAJOR% goto InstallTSC
if %TSC_VER_MAJOR% GTR %TSC_VER_TARGET_MAJOR% goto SkipTSCInst
if %TSC_VER_MINOR% LSS %TSC_VER_TARGET_MINOR% goto InstallTSC
if %TSC_VER_MINOR% GEQ %TSC_VER_TARGET_MINOR% goto SkipTSCInst
:InstallTSC
if "%TSC_TARGET_ID%"=="" (
  echo Warning: Environment variable TSC_TARGET_ID not set.
  echo %DATE% %TIME% - Warning: Environment variable TSC_TARGET_ID not set >>%UPDATE_LOGFILE%
  goto SkipTSCInst
) 
echo %TSC_TARGET_ID% >"%TEMP%\MissingUpdateIds.txt"
call ListUpdatesToInstall.cmd /excludestatics
if errorlevel 1 goto ListError
if exist "%TEMP%\UpdatesToInstall.txt" (
  echo Installing most recent Windows Terminal Services Client...
  call InstallListedUpdates.cmd /selectoptions %BACKUP_MODE% %VERIFY_MODE% /errorsaswarnings
) else (
  echo Warning: Windows Terminal Services Client installation file ^(kb%TSC_TARGET_ID%^) not found.
  echo %DATE% %TIME% - Warning: Windows Terminal Services Client installation file ^(kb%TSC_TARGET_ID%^) not found >>%UPDATE_LOGFILE%
  goto SkipTSCInst
)
set REBOOT_REQUIRED=1
:SkipTSCInst

rem *** Install .NET Framework 3.5 SP1 ***
if "%OS_NAME%"=="w2k" goto SkipDotNet35Inst
if "%INSTALL_DOTNET35%" NEQ "/instdotnet35" goto SkipDotNet35Inst
echo Checking .NET Framework 3.5 installation state...
if %DOTNET35_VER_MAJOR% LSS %DOTNET35_VER_TARGET_MAJOR% goto InstallDotNet35
if %DOTNET35_VER_MAJOR% GTR %DOTNET35_VER_TARGET_MAJOR% goto SkipDotNet35Inst
if %DOTNET35_VER_MINOR% LSS %DOTNET35_VER_TARGET_MINOR% goto InstallDotNet35
if %DOTNET35_VER_MINOR% GTR %DOTNET35_VER_TARGET_MINOR% goto SkipDotNet35Inst
if %DOTNET35_VER_BUILD% LSS %DOTNET35_VER_TARGET_BUILD% goto InstallDotNet35
if %DOTNET35_VER_BUILD% GTR %DOTNET35_VER_TARGET_BUILD% goto SkipDotNet35Inst
if %DOTNET35_VER_REVISION% GEQ %DOTNET35_VER_TARGET_REVISION% goto SkipDotNet35Inst
:InstallDotNet35
set DOTNET35_FILENAME=..\dotnet\dotnetfx35.exe
if not exist %DOTNET35_FILENAME% (
  echo Warning: File %DOTNET35_FILENAME% not found. 
  echo %DATE% %TIME% - Warning: File %DOTNET35_FILENAME% not found >>%UPDATE_LOGFILE%
  goto SkipDotNet35Inst
)
echo Installing .NET Framework 3.5 SP1...
call InstallOSUpdate.cmd %DOTNET35_FILENAME% %VERIFY_MODE% /ignoreerrors /qb /norestart /lang:enu
copy /Y ..\static\StaticUpdateIds-dotnet.txt "%TEMP%\MissingUpdateIds.txt" >nul
call ListUpdatesToInstall.cmd /excludestatics
if errorlevel 1 goto ListError
if exist "%TEMP%\UpdatesToInstall.txt" (
  echo Installing .NET Framework 3.5 SP1 Family Update...
  call InstallListedUpdates.cmd /selectoptions %BACKUP_MODE% %VERIFY_MODE% /ignoreerrors
)
set RECALL_REQUIRED=1
if "%RECALL_REQUIRED%"=="1" goto Installed
:SkipDotNet35Inst

rem *** Install .NET Framework 4 ***
if "%OS_NAME%"=="w2k" goto SkipDotNet4Inst
if "%INSTALL_DOTNET4%" NEQ "/instdotnet4" goto SkipDotNet4Inst
echo Checking .NET Framework 4 installation state...
if %DOTNET4_VER_MAJOR% LSS %DOTNET4_VER_TARGET_MAJOR% goto InstallDotNet4
if %DOTNET4_VER_MAJOR% GTR %DOTNET4_VER_TARGET_MAJOR% goto SkipDotNet4Inst
if %DOTNET4_VER_MINOR% LSS %DOTNET4_VER_TARGET_MINOR% goto InstallDotNet4
if %DOTNET4_VER_MINOR% GTR %DOTNET4_VER_TARGET_MINOR% goto SkipDotNet4Inst
if %DOTNET4_VER_BUILD% GEQ %DOTNET4_VER_TARGET_BUILD% goto SkipDotNet4Inst
:InstallDotNet4
set DOTNET4_FILENAME=..\dotnet\dotNetFx40_Full_x86_x64.exe
if not exist %DOTNET4_FILENAME% (
  echo Warning: File %DOTNET4_FILENAME% not found. 
  echo %DATE% %TIME% - Warning: File %DOTNET4_FILENAME% not found >>%UPDATE_LOGFILE%
  goto SkipDotNet4Inst
)
echo Installing .NET Framework 4...
call InstallOSUpdate.cmd %DOTNET4_FILENAME% %VERIFY_MODE% /errorsaswarnings /passive /norestart /lcid 1033
set REBOOT_REQUIRED=1
:SkipDotNet4Inst

rem *** Install Windows PowerShell 2.0 ***
if "%OS_NAME%"=="w2k" goto SkipPShInst
if "%INSTALL_PSH%" NEQ "/instpsh" goto SkipPShInst
echo Checking Windows PowerShell 2.0 installation state...
if %PSH_VER_MAJOR% LSS %PSH_VER_TARGET_MAJOR% goto InstallPSh
if %PSH_VER_MAJOR% GTR %PSH_VER_TARGET_MAJOR% goto SkipPShInst
if %PSH_VER_MINOR% LSS %PSH_VER_TARGET_MINOR% goto InstallPSh
if %PSH_VER_MINOR% GEQ %PSH_VER_TARGET_MINOR% goto SkipPShInst
:InstallPSh
if "%PSH_TARGET_ID%"=="" (
  echo Warning: Environment variable PSH_TARGET_ID not set.
  echo %DATE% %TIME% - Warning: Environment variable PSH_TARGET_ID not set >>%UPDATE_LOGFILE%
  goto SkipPShInst
) 
echo %PSH_TARGET_ID% >"%TEMP%\MissingUpdateIds.txt"
call ListUpdatesToInstall.cmd /excludestatics
if errorlevel 1 goto ListError
if exist "%TEMP%\UpdatesToInstall.txt" (
  echo Installing Windows PowerShell 2.0...
  call InstallListedUpdates.cmd /selectoptions %BACKUP_MODE% %VERIFY_MODE% /errorsaswarnings
) else (
  echo Warning: Windows PowerShell 2.0 installation file ^(kb%PSH_TARGET_ID%^) not found.
  echo %DATE% %TIME% - Warning: Windows PowerShell 2.0 installation file ^(kb%PSH_TARGET_ID%^) not found >>%UPDATE_LOGFILE%
  goto SkipPShInst
)
set REBOOT_REQUIRED=1
:SkipPShInst

rem *** Install Microsoft Security Essentials ***
if "%OS_NAME%"=="w2k" goto SkipMSSEInst
if %OS_DOMAIN_ROLE% GEQ 2 goto SkipMSSEInst
echo Checking Microsoft Security Essentials installation state...
if "%MSSE_INSTALLED%"=="1" goto CheckMSSEDefs
if "%INSTALL_MSSE%" NEQ "/instmsse" goto SkipMSSEInst
:InstallMSSE
set MSSE_TARGET_ID=mssefullinstall-*-%OS_LANG_EXT%-
echo %MSSE_TARGET_ID% >"%TEMP%\MissingUpdateIds.txt"
call ListUpdatesToInstall.cmd /excludestatics
if errorlevel 1 goto ListError
if exist "%TEMP%\UpdatesToInstall.txt" (
  echo Installing Microsoft Security Essentials...
  call InstallListedUpdates.cmd %VERIFY_MODE% /ignoreerrors /s /runwgacheck /o
) else (
  echo Warning: Microsoft Security Essentials installation file ^(%MSSE_TARGET_ID%^) not found.
  echo %DATE% %TIME% - Warning: Microsoft Security Essentials installation file ^(%MSSE_TARGET_ID%^) not found >>%UPDATE_LOGFILE%
  goto SkipMSSEInst
)
set REBOOT_REQUIRED=1
:CheckMSSEDefs
if /i "%OS_ARCH%"=="x64" (
  set MSSEDEFS_FILENAME=..\mssedefs\%OS_ARCH%-glb\mpam-fex64.exe
) else (
  set MSSEDEFS_FILENAME=..\mssedefs\%OS_ARCH%-glb\mpam-fe.exe
)
if not exist %MSSEDEFS_FILENAME% (
  echo Warning: Microsoft Security Essentials definition file ^(%MSSEDEFS_FILENAME%^) not found.
  echo %DATE% %TIME% - Warning: Microsoft Security Essentials definition file ^(%MSSEDEFS_FILENAME%^) not found >>%UPDATE_LOGFILE%
  goto SkipMSSEInst
)
rem *** Determine Microsoft Security Essentials definition file version ***
echo Determining Microsoft Security Essentials definition file version...
%CSCRIPT_PATH% //Nologo //E:vbs DetermineFileVersion.vbs %MSSEDEFS_FILENAME% MSSEDEFS_VER_TARGET
if not exist "%TEMP%\SetFileVersion.cmd" goto SkipMSSEInst
call "%TEMP%\SetFileVersion.cmd"
del "%TEMP%\SetFileVersion.cmd"
if %MSSEDEFS_VER_MAJOR% LSS %MSSEDEFS_VER_TARGET_MAJOR% goto InstallMSSEDefs
if %MSSEDEFS_VER_MAJOR% GTR %MSSEDEFS_VER_TARGET_MAJOR% goto SkipMSSEInst
if %MSSEDEFS_VER_MINOR% LSS %MSSEDEFS_VER_TARGET_MINOR% goto InstallMSSEDefs
if %MSSEDEFS_VER_MINOR% GTR %MSSEDEFS_VER_TARGET_MINOR% goto SkipMSSEInst
if %MSSEDEFS_VER_BUILD% LSS %MSSEDEFS_VER_TARGET_BUILD% goto InstallMSSEDefs
if %MSSEDEFS_VER_BUILD% GTR %MSSEDEFS_VER_TARGET_BUILD% goto SkipMSSEInst
if %MSSEDEFS_VER_REVISION% GEQ %MSSEDEFS_VER_TARGET_REVISION% goto SkipMSSEInst
:InstallMSSEDefs
echo Installing Microsoft Security Essentials definition file...
call InstallOSUpdate.cmd %MSSEDEFS_FILENAME% %VERIFY_MODE% /ignoreerrors -q
:SkipMSSEInst

if "%RECALL_REQUIRED%"=="1" goto Installed
if "%OFC_NAME%"=="" goto CheckAUService
if not exist ..\%OFC_NAME%\%OFC_LANG%\nul (
  if not exist ..\%OFC_NAME%\glb\nul goto CheckAUService
)
rem *** Check Office Service Pack versions ***
echo Checking Office Service Pack versions...
if exist "%TEMP%\MissingUpdateIds.txt" del "%TEMP%\MissingUpdateIds.txt"
if "%OXP_VER_MAJOR%"=="" goto SkipSPoxp
if %OXP_SP_VER% LSS %OXP_SP_VER_TARGET% echo %OXP_SP_TARGET_ID% >>"%TEMP%\MissingUpdateIds.txt"
:SkipSPoxp
if "%O2K3_VER_MAJOR%"=="" goto SkipSPo2k3
if %O2K3_SP_VER% LSS %O2K3_SP_VER_TARGET% echo %O2K3_SP_TARGET_ID% >>"%TEMP%\MissingUpdateIds.txt"
:SkipSPo2k3
if "%O2K7_VER_MAJOR%"=="" goto SkipSPo2k7
if %O2K7_SP_VER% LSS %O2K7_SP_VER_TARGET% echo %O2K7_SP_TARGET_ID% >>"%TEMP%\MissingUpdateIds.txt"
:SkipSPo2k7
if "%O2K10_VER_MAJOR%"=="" goto SkipSPo2k10
if %O2K10_SP_VER% LSS %O2K10_SP_VER_TARGET% echo %O2K10_SP_TARGET_ID% >>"%TEMP%\MissingUpdateIds.txt"
:SkipSPo2k10
if not exist "%TEMP%\MissingUpdateIds.txt" goto SkipSPOfc
call ListUpdatesToInstall.cmd /excludestatics
if errorlevel 1 goto ListError
if exist "%TEMP%\UpdatesToInstall.txt" (
  echo Installing most recent Office Service Pack^(s^)...
  call InstallListedUpdates.cmd %VERIFY_MODE% /errorsaswarnings
) else (
  echo Warning: Office Service Pack installation file^(s^) not found.
  echo %DATE% %TIME% - Warning: Office Service Pack installation file^(s^) not found >>%UPDATE_LOGFILE%
  goto SkipSPOfc
)
set REBOOT_REQUIRED=1
:SkipSPOfc

rem *** Check installation state of Office Converter/Compatibility Packs ***
if "%INSTALL_CONVERTERS%" NEQ "/instofccnvs" goto CheckAUService
goto CNV%OFC_NAME%

:CNVoxp
:CNVo2k3
echo Checking installation state of Office Converter/Compatibility Packs...
if "%OFC_CONV_PACK%" NEQ "1" (
  if exist ..\ofc\glb\OCONVPCK.EXE (
    echo Installing Office Converter Pack...
    echo Installing ..\ofc\glb\OCONVPCK.EXE...
    ..\ofc\glb\OCONVPCK.EXE /T:"%TEMP%\ocnvpack" /C /Q
    %SystemRoot%\system32\msiexec.exe /i "%TEMP%\ocnvpack\ocp11.msi" /qn /norestart
    call SafeRmDir.cmd "%TEMP%\ocnvpack"
    echo %DATE% %TIME% - Info: Installed ..\ofc\glb\OCONVPCK.EXE >>%UPDATE_LOGFILE%
  ) else (
    echo Warning: File ..\ofc\glb\OCONVPCK.EXE not found. 
    echo %DATE% %TIME% - Warning: File ..\ofc\glb\OCONVPCK.EXE not found >>%UPDATE_LOGFILE%
  )
)
if "%OFC_COMP_PACK%" NEQ "1" (
  if exist ..\ofc\%OFC_LANG%\FileFormatConverters.exe (
    echo Installing Office 2007 Compatibility Pack...
    echo Installing ..\ofc\%OFC_LANG%\FileFormatConverters.exe...
    ..\ofc\%OFC_LANG%\FileFormatConverters.exe /quiet /norestart
    echo %DATE% %TIME% - Info: Installed ..\ofc\%OFC_LANG%\FileFormatConverters.exe >>%UPDATE_LOGFILE%
  ) else (
    echo Warning: File ..\ofc\%OFC_LANG%\FileFormatConverters.exe not found. 
    echo %DATE% %TIME% - Warning: File ..\ofc\%OFC_LANG%\FileFormatConverters.exe not found >>%UPDATE_LOGFILE%
  )
)
:CNVo2k7
:CNVo2k10

:CheckAUService
rem *** Check state of service 'automatic updates' ***
echo Checking state of service 'automatic updates'...
echo %DATE% %TIME% - Info: Detected state of service 'automatic updates': %AU_SVC_STATE_INITIAL% (start mode: %AU_SVC_START_MODE%) >>%UPDATE_LOGFILE%
if /i "%AU_SVC_STATE_INITIAL%"=="" goto ListUpdateIds
if /i "%AU_SVC_STATE_INITIAL%"=="Unknown" goto ListUpdateIds
if /i "%AU_SVC_STATE_INITIAL%"=="Running" goto ListUpdateIds
if /i "%AU_SVC_START_MODE%"=="Disabled" goto AUSvcNotRunning
echo Starting service 'automatic updates' (wuauserv)...
%SystemRoot%\system32\net.exe start wuauserv >nul
if not errorlevel 0 goto AUSvcNotRunning
set AU_SVC_STARTED=1
echo %DATE% %TIME% - Info: Started service 'automatic updates' (wuauserv) >>%UPDATE_LOGFILE%

:ListUpdateIds
rem *** List ids of missing updates ***
if not exist ..\wsus\wsusscn2.cab goto NoWSUSScan
if "%VERIFY_MODE%" NEQ "/verify" goto SkipVerifyWSUSScan
if not exist ..\bin\hashdeep.exe (
  echo Warning: Hash computing/auditing utility ..\bin\hashdeep.exe not found.
  echo %DATE% %TIME% - Warning: Hash computing/auditing utility ..\bin\hashdeep.exe not found >>%UPDATE_LOGFILE%
  goto SkipVerifyWSUSScan
)
if not exist ..\md\hashes-wsus.txt (
  echo Warning: Hash file hashes-wsus.txt not found.
  echo %DATE% %TIME% - Warning: Hash file hashes-wsus.txt not found >>%UPDATE_LOGFILE%
  goto SkipVerifyWSUSScan
)
echo Verifying integrity of Windows Update catalog file...
%SystemRoot%\system32\findstr.exe /C:%% /C:## /C:..\wsus\wsusscn2.cab ..\md\hashes-wsus.txt >"%TEMP%\hash-wsusscn2.txt"
..\bin\hashdeep.exe -a -l -k "%TEMP%\hash-wsusscn2.txt" ..\wsus\wsusscn2.cab
if errorlevel 1 (
  if exist "%TEMP%\hash-wsusscn2.txt" del "%TEMP%\hash-wsusscn2.txt"
  goto WSUSScanIntegrityError
)
if exist "%TEMP%\hash-wsusscn2.txt" del "%TEMP%\hash-wsusscn2.txt"
:SkipVerifyWSUSScan
echo Listing ids of missing updates...
copy /Y ..\wsus\wsusscn2.cab "%TEMP%" >nul
if exist "%TEMP%\MissingUpdateIds.txt" del "%TEMP%\MissingUpdateIds.txt"
%CSCRIPT_PATH% //Nologo //E:vbs ListMissingUpdateIds.vbs %LIST_MODE_IDS%
if exist "%TEMP%\wsusscn2.cab" del "%TEMP%\wsusscn2.cab"

rem *** List ids of installed updates ***
if "%LIST_MODE_IDS%"=="/all" goto ListInstFiles
if "%LIST_MODE_UPDATES%"=="/excludestatics" goto ListInstFiles
echo Listing ids of installed updates...
if exist "%TEMP%\InstalledUpdateIds.txt" del "%TEMP%\InstalledUpdateIds.txt"
%CSCRIPT_PATH% //Nologo //E:vbs ListInstalledUpdateIds.vbs

:ListInstFiles
rem *** List update files ***
if not exist "%TEMP%\MissingUpdateIds.txt" (
  if "%REBOOT_REQUIRED%"=="1" (goto Installed) else (goto NoMissingIds)
)
echo Listing update files...
call ListUpdatesToInstall.cmd %LIST_MODE_UPDATES%
if errorlevel 1 goto ListError

:InstallUpdates
rem *** Install updates ***
if not exist "%TEMP%\UpdatesToInstall.txt" (
  if "%REBOOT_REQUIRED%"=="1" (goto Installed) else (goto NoUpdates)
)
echo Installing updates...
call InstallListedUpdates.cmd /selectoptions %BACKUP_MODE% %VERIFY_MODE% /errorsaswarnings
if errorlevel 1 goto InstError
set REBOOT_REQUIRED=1

:Installed
if "%RECALL_REQUIRED%"=="1" (
  if "%BOOT_MODE%"=="/autoreboot" (
    if "%OS_NAME%"=="w60" (
      echo.
      echo Automatic recall is not supported for Windows Vista / Server 2008.
      echo %DATE% %TIME% - Info: Automatic recall is not supported for Windows Vista / Server 2008 >>%UPDATE_LOGFILE%
      goto ManualRecall
    )
    if "%OS_NAME%"=="w61" (
      echo.
      echo Automatic recall is not supported for Windows 7 / Server 2008 R2.
      echo %DATE% %TIME% - Info: Automatic recall is not supported for Windows 7 / Server 2008 R2 >>%UPDATE_LOGFILE%
      goto ManualRecall
    )
    if %OS_DOMAIN_ROLE% GEQ 4 (                 
      echo.
      echo Automatic recall is not supported on domain controllers.
      echo %DATE% %TIME% - Info: Automatic recall is not supported on domain controllers >>%UPDATE_LOGFILE%
      goto ManualRecall
    )
    if not "%USERNAME%"=="WSUSUpdateAdmin" (
      echo Preparing automatic recall...
      call PrepareRecall.cmd %~f0 %BACKUP_MODE% %VERIFY_MODE% %INSTALL_IE% %UPDATE_WMP% %UPDATE_TSC% %INSTALL_DOTNET35% %INSTALL_DOTNET4% %INSTALL_PSH% %INSTALL_MSSE% %INSTALL_CONVERTERS% %BOOT_MODE% %FINISH_MODE% %SHOW_LOG% %LIST_MODE_IDS% %LIST_MODE_UPDATES%
    )
    if exist %SystemRoot%\system32\bcdedit.exe (
      echo Adjusting boot sequence for next reboot...
      %SystemRoot%\system32\bcdedit.exe /bootsequence {current}
      echo %DATE% %TIME% - Info: Adjusted boot sequence for next reboot >>%UPDATE_LOGFILE%
    )
    echo Rebooting...
    %CSCRIPT_PATH% //Nologo //E:vbs Shutdown.vbs /reboot
  ) else goto ManualRecall
) else (
  if "%SHOW_LOG%"=="/showlog" call PrepareShowLogFile.cmd
  if "%BOOT_MODE%"=="/autoreboot" (
    if "%USERNAME%"=="WSUSUpdateAdmin" (
      echo Cleaning up automatic recall...
      call CleanupRecall.cmd
      del /Q "%TEMP%\wsusadmin-recall.*"
    )
    if "%FINISH_MODE%"=="/shutdown" (
      echo Shutting down...
      %CSCRIPT_PATH% //Nologo //E:vbs Shutdown.vbs
    ) else (
      if exist %SystemRoot%\system32\bcdedit.exe (
        echo Adjusting boot sequence for next reboot...
        %SystemRoot%\system32\bcdedit.exe /bootsequence {current}
        echo %DATE% %TIME% - Info: Adjusted boot sequence for next reboot >>%UPDATE_LOGFILE%
      )
      echo Rebooting...
      %CSCRIPT_PATH% //Nologo //E:vbs Shutdown.vbs /reboot
    )
  ) else (
    if "%FINISH_MODE%"=="/shutdown" (
      echo Shutting down...
      %CSCRIPT_PATH% //Nologo //E:vbs Shutdown.vbs
    ) else (
      echo.
      echo Installation successful. Please reboot your system now.
      echo %DATE% %TIME% - Info: Installation successful >>%UPDATE_LOGFILE%
      echo.
    )
  )
)
goto EoF

:ManualRecall
echo.
echo Installation successful. Please reboot your system now and recall Update afterwards.
echo %DATE% %TIME% - Info: Installation successful >>%UPDATE_LOGFILE%
echo.
goto EoF

:NoExtensions
echo.
echo ERROR: No command extensions available.
echo.
exit /b 1

:NoTemp
echo.
echo ERROR: Environment variable TEMP not set.
echo %DATE% %TIME% - Error: Environment variable TEMP not set >>%UPDATE_LOGFILE%
echo.
goto Cleanup

:NoTempDir
echo.
echo ERROR: Directory "%TEMP%" not found.
echo %DATE% %TIME% - Error: Directory "%TEMP%" not found >>%UPDATE_LOGFILE%
echo.
goto Cleanup

:NoCScript
echo.
echo ERROR: VBScript interpreter %CSCRIPT_PATH% not found.
echo %DATE% %TIME% - Error: VBScript interpreter %CSCRIPT_PATH% not found >>%UPDATE_LOGFILE%
echo.
goto Cleanup

:NoReg
echo.
echo ERROR: Registry tool %REG_PATH% not found.
echo %DATE% %TIME% - Error: Registry tool %REG_PATH% not found >>%UPDATE_LOGFILE%
echo.
goto Cleanup

:EndlessLoop
echo.
echo ERROR: Potentially endless reboot/recall loop detected.
echo %DATE% %TIME% - Error: Potentially endless reboot/recall loop detected >>%UPDATE_LOGFILE%
echo.
goto Cleanup

:NoSysEnvVars
echo.
echo ERROR: Determination of OS properties failed.
echo %DATE% %TIME% - Error: Determination of OS properties failed >>%UPDATE_LOGFILE%
echo.
goto Cleanup

:UnsupLang
echo.
echo ERROR: Unsupported Operating System language.
echo %DATE% %TIME% - Error: Unsupported Operating System language >>%UPDATE_LOGFILE%
echo.
goto Cleanup

:NoOSName
echo.
echo ERROR: Environment variable OS_NAME not set.
echo %DATE% %TIME% - Error: Environment variable OS_NAME not set >>%UPDATE_LOGFILE%
echo.
goto Cleanup

:UnsupArch
echo.
echo ERROR: Unsupported Operating System architecture (%OS_ARCH%).
echo %DATE% %TIME% - Error: Unsupported Operating System architecture (%OS_ARCH%) >>%UPDATE_LOGFILE%
echo.
goto Cleanup

:NoIfAdmin
echo.
echo ERROR: File ..\bin\IfAdmin.exe not found.
echo %DATE% %TIME% - Error: File ..\bin\IfAdmin.exe not found >>%UPDATE_LOGFILE%
echo.
goto Cleanup

:NoAdmin
echo.
echo ERROR: User %USERNAME% does not have administrative privileges.
echo %DATE% %TIME% - Error: User %USERNAME% does not have administrative privileges >>%UPDATE_LOGFILE%
echo.
goto EoF

:InvalidMedium
echo.
echo ERROR: Medium neither supports your Windows nor your Office version.
echo %DATE% %TIME% - Error: Medium neither supports your Windows nor your Office version >>%UPDATE_LOGFILE%
echo.
goto Cleanup

:NoWUAInst
echo.
echo ERROR: File %WUA_FILENAME% not found. 
echo %DATE% %TIME% - Error: File %WUA_FILENAME% not found >>%UPDATE_LOGFILE%
echo.
goto Cleanup

:NoSPTargetId
echo.
echo ERROR: Environment variable OS_SP_TARGET_ID not set.
echo %DATE% %TIME% - Error: Environment variable OS_SP_TARGET_ID not set >>%UPDATE_LOGFILE%
echo.
goto Cleanup

:AUSvcNotRunning
echo.
echo ERROR: Service 'automatic updates' (wuauserv) is not running and could not be started.
echo %DATE% %TIME% - Error: Service 'automatic updates' (wuauserv) is not running and could not be started >>%UPDATE_LOGFILE%
echo.
goto Cleanup

:NoWSUSScan
echo.
echo ERROR: File ..\wsus\wsusscn2.cab not found. 
echo %DATE% %TIME% - Error: File ..\wsus\wsusscn2.cab not found >>%UPDATE_LOGFILE%
echo.
goto Cleanup

:WSUSScanIntegrityError
echo.
echo ERROR: File hash does not match stored value (file: ..\wsus\wsusscn2.cab).
echo %DATE% %TIME% - Error: File hash does not match stored value (file: ..\wsus\wsusscn2.cab) >>%UPDATE_LOGFILE%
echo.
goto Cleanup

:NoMissingIds
echo.
echo No missing update found. Nothing to do!
echo %DATE% %TIME% - Info: No missing update found >>%UPDATE_LOGFILE%
echo.
goto Cleanup

:NoUpdates
echo.
echo Any missing update was either black listed or not found.
echo %DATE% %TIME% - Info: Any missing update was either black listed or not found >>%UPDATE_LOGFILE%
echo.
goto Cleanup

:ListError
echo.
echo ERROR: Listing of update files failed.
echo %DATE% %TIME% - Error: Listing of update files failed >>%UPDATE_LOGFILE%
echo.
goto Cleanup

:InstError
echo.
echo ERROR: Installation failed.
echo %DATE% %TIME% - Error: Installation failed >>%UPDATE_LOGFILE%
echo.
goto Cleanup

:Cleanup
if "%USERNAME%"=="WSUSUpdateAdmin" (
  if "%SHOW_LOG%"=="/showlog" call PrepareShowLogFile.cmd
  echo Cleaning up automatic recall...
  call CleanupRecall.cmd
  del /Q "%TEMP%\wsusadmin-recall.*"
  if exist %SystemRoot%\system32\bcdedit.exe (
    echo Adjusting boot sequence for next reboot...
    %SystemRoot%\system32\bcdedit.exe /bootsequence {current}
    echo %DATE% %TIME% - Info: Adjusted boot sequence for next reboot >>%UPDATE_LOGFILE%
  )
  echo Rebooting...
  %CSCRIPT_PATH% //Nologo //E:vbs Shutdown.vbs /reboot
) else (
  if "%AU_SVC_STARTED%"=="1" (
    echo Stopping service 'automatic updates' ^(wuauserv^)...
    %SystemRoot%\system32\net.exe stop wuauserv >nul
    if errorlevel 1 (
      echo %DATE% %TIME% - Warning: Stopping of service 'automatic updates' ^(wuauserv^) failed >>%UPDATE_LOGFILE%
    ) else (
      echo %DATE% %TIME% - Info: Stopped service 'automatic updates' ^(wuauserv^) >>%UPDATE_LOGFILE%
    )
  )
  if "%SHOW_LOG%"=="/showlog" start %SystemRoot%\system32\notepad.exe %UPDATE_LOGFILE%
)
goto EoF

:EoF
rem *** Execute custom finalization hook ***
if exist .\custom\FinalizationHook.cmd (
  echo Executing custom finalization hook...
  call .\custom\FinalizationHook.cmd
  echo %DATE% %TIME% - Info: Executed custom finalization hook >>%UPDATE_LOGFILE%
)
cd ..
echo Ending WSUS Offline Update at %TIME%...
echo %DATE% %TIME% - Info: Ending WSUS Offline Update >>%UPDATE_LOGFILE%
title %ComSpec%
if "%RECALL_REQUIRED%"=="1" (
  verify other 2>nul
  exit /b 3011
)
if "%REBOOT_REQUIRED%"=="1" exit /b 3010
endlocal
