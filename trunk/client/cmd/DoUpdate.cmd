@echo off
rem *** Author: T. Wittrock, RZ Uni Kiel ***

verify other 2>nul
setlocal enableextensions
if errorlevel 1 goto NoExtensions

if "%DIRCMD%" NEQ "" set DIRCMD=

%~d0
cd "%~p0"

set WSUSUPDATE_VERSION=6.51+
set UPDATE_LOGFILE=%SystemRoot%\wsusofflineupdate.log
if exist %SystemRoot%\ctupdate.log ren %SystemRoot%\ctupdate.log wsusofflineupdate.log 
title %~n0 %*
echo Starting WSUS Offline Update (v. %WSUSUPDATE_VERSION%)...
if exist %UPDATE_LOGFILE% echo. >>%UPDATE_LOGFILE%
echo %DATE% %TIME% - Info: Starting WSUS offline update (v. %WSUSUPDATE_VERSION%) on %COMPUTERNAME% (user: %USERNAME%) >>%UPDATE_LOGFILE%

:EvalParams
if "%1"=="" goto NoMoreParams
for %%i in (/nobackup /verify /instie7 /instie8 /updatewmp /updatetsc /instdotnet /instpsh /instofccnvs /autoreboot /shutdown /showlog /all /excludestatics) do (
  if /i "%1"=="%%i" echo %DATE% %TIME% - Info: Option %%i detected >>%UPDATE_LOGFILE%
)
if /i "%1"=="/nobackup" set BACKUP_MODE=/nobackup
if /i "%1"=="/verify" set VERIFY_MODE=/verify
if /i "%1"=="/instie7" set INSTALL_IE=/instie7
if /i "%1"=="/instie8" set INSTALL_IE=/instie8
if /i "%1"=="/updatewmp" set UPDATE_WMP=/updatewmp
if /i "%1"=="/updatetsc" set UPDATE_TSC=/updatetsc
if /i "%1"=="/instdotnet" set INSTALL_DOTNET=/instdotnet
if /i "%1"=="/instpsh" set INSTALL_PSH=/instpsh
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
if "%OS_ARCHITECTURE%"=="" set OS_ARCHITECTURE=%PROCESSOR_ARCHITECTURE%
if "%OS_LANGUAGE%"=="" goto UnsupLang

rem *** Set target environment variables ***
call SetTargetEnvVars.cmd %INSTALL_IE%
if errorlevel 1 goto Cleanup
if "%OS_NAME%"=="" goto NoOSName

rem *** Echo OS properties ***
echo Found OS caption: %OS_CAPTION%
echo Found Microsoft Windows version: %OS_VERSION_MAJOR%.%OS_VERSION_MINOR%.%OS_VERSION_BUILD% (%OS_NAME% %OS_ARCHITECTURE% %OS_LANGUAGE% sp%OS_SP_VERSION_MAJOR%)
rem echo Found Windows Update Agent version: %WUA_VERSION_MAJOR%.%WUA_VERSION_MINOR%.%WUA_VERSION_BUILD%.%WUA_VERSION_REVISION%
rem echo Found Windows Installer version: %MSI_VERSION_MAJOR%.%MSI_VERSION_MINOR%.%MSI_VERSION_BUILD%.%MSI_VERSION_REVISION%
rem echo Found Windows Script Host version: %WSH_VERSION_MAJOR%.%WSH_VERSION_MINOR%.%WSH_VERSION_BUILD%.%WSH_VERSION_REVISION%
rem echo Found Internet Explorer version: %IE_VERSION_MAJOR%.%IE_VERSION_MINOR%.%IE_VERSION_BUILD%.%IE_VERSION_REVISION%
rem echo Found Microsoft Data Access Components version: %MDAC_VERSION_MAJOR%.%MDAC_VERSION_MINOR%.%MDAC_VERSION_BUILD%.%MDAC_VERSION_REVISION%
rem echo Found Microsoft DirectX version: %DIRECTX_VERSION_MAJOR%.%DIRECTX_VERSION_MINOR%.%DIRECTX_VERSION_BUILD%.%DIRECTX_VERSION_REVISION% (%DIRECTX_NAME%)
rem echo Found Microsoft .NET Framework 3.5 version: %DOTNET_VERSION_MAJOR%.%DOTNET_VERSION_MINOR%.%DOTNET_VERSION_BUILD%.%DOTNET_VERSION_REVISION%
rem echo Found Windows Media Player version: %WMP_VERSION_MAJOR%.%WMP_VERSION_MINOR%.%WMP_VERSION_BUILD%.%WMP_VERSION_REVISION%
if "%OXP_VERSION_MAJOR%" NEQ "" (
  echo Found Microsoft Office XP %OXP_VERSION_APP% version: %OXP_VERSION_MAJOR%.%OXP_VERSION_MINOR%.%OXP_VERSION_BUILD%.%OXP_VERSION_REVISION% ^(oxp %OXP_LANGUAGE% sp%OXP_SP_VERSION%^)
)
if "%O2K3_VERSION_MAJOR%" NEQ "" (
  echo Found Microsoft Office 2003 %O2K3_VERSION_APP% version: %O2K3_VERSION_MAJOR%.%O2K3_VERSION_MINOR%.%O2K3_VERSION_BUILD%.%O2K3_VERSION_REVISION% ^(o2k3 %O2K3_LANGUAGE% sp%O2K3_SP_VERSION%^)
)
if "%O2K7_VERSION_MAJOR%" NEQ "" (
  echo Found Microsoft Office 2007 %O2K7_VERSION_APP% version: %O2K7_VERSION_MAJOR%.%O2K7_VERSION_MINOR%.%O2K7_VERSION_BUILD%.%O2K7_VERSION_REVISION% ^(o2k7 %O2K7_LANGUAGE% sp%O2K7_SP_VERSION%^)
)
echo %DATE% %TIME% - Info: Found OS caption '%OS_CAPTION%' >>%UPDATE_LOGFILE%
echo %DATE% %TIME% - Info: Found Microsoft Windows version %OS_VERSION_MAJOR%.%OS_VERSION_MINOR%.%OS_VERSION_BUILD% (%OS_NAME% %OS_ARCHITECTURE% %OS_LANGUAGE% sp%OS_SP_VERSION_MAJOR%) >>%UPDATE_LOGFILE%
echo %DATE% %TIME% - Info: Found Windows Update Agent version %WUA_VERSION_MAJOR%.%WUA_VERSION_MINOR%.%WUA_VERSION_BUILD%.%WUA_VERSION_REVISION% >>%UPDATE_LOGFILE%
echo %DATE% %TIME% - Info: Found Windows Installer version %MSI_VERSION_MAJOR%.%MSI_VERSION_MINOR%.%MSI_VERSION_BUILD%.%MSI_VERSION_REVISION% >>%UPDATE_LOGFILE%
echo %DATE% %TIME% - Info: Found Windows Script Host version %WSH_VERSION_MAJOR%.%WSH_VERSION_MINOR%.%WSH_VERSION_BUILD%.%WSH_VERSION_REVISION% >>%UPDATE_LOGFILE%
echo %DATE% %TIME% - Info: Found Internet Explorer version %IE_VERSION_MAJOR%.%IE_VERSION_MINOR%.%IE_VERSION_BUILD%.%IE_VERSION_REVISION% >>%UPDATE_LOGFILE%
echo %DATE% %TIME% - Info: Found Microsoft Data Access Components version %MDAC_VERSION_MAJOR%.%MDAC_VERSION_MINOR%.%MDAC_VERSION_BUILD%.%MDAC_VERSION_REVISION% >>%UPDATE_LOGFILE%
echo %DATE% %TIME% - Info: Found Microsoft DirectX version %DIRECTX_VERSION_MAJOR%.%DIRECTX_VERSION_MINOR%.%DIRECTX_VERSION_BUILD%.%DIRECTX_VERSION_REVISION% (%DIRECTX_NAME%) >>%UPDATE_LOGFILE%
echo %DATE% %TIME% - Info: Found Microsoft .NET Framework 3.5 version %DOTNET_VERSION_MAJOR%.%DOTNET_VERSION_MINOR%.%DOTNET_VERSION_BUILD%.%DOTNET_VERSION_REVISION% >>%UPDATE_LOGFILE%
echo %DATE% %TIME% - Info: Found Windows Media Player version %WMP_VERSION_MAJOR%.%WMP_VERSION_MINOR%.%WMP_VERSION_BUILD%.%WMP_VERSION_REVISION% >>%UPDATE_LOGFILE%
if "%OXP_VERSION_MAJOR%" NEQ "" (
  echo %DATE% %TIME% - Info: Found Microsoft Office XP %OXP_VERSION_APP% version %OXP_VERSION_MAJOR%.%OXP_VERSION_MINOR%.%OXP_VERSION_BUILD%.%OXP_VERSION_REVISION% ^(oxp %OXP_LANGUAGE% sp%OXP_SP_VERSION%^) >>%UPDATE_LOGFILE%
)
if "%O2K3_VERSION_MAJOR%" NEQ "" (
  echo %DATE% %TIME% - Info: Found Microsoft Office 2003 %O2K3_VERSION_APP% version %O2K3_VERSION_MAJOR%.%O2K3_VERSION_MINOR%.%O2K3_VERSION_BUILD%.%O2K3_VERSION_REVISION% ^(o2k3 %O2K3_LANGUAGE% sp%O2K3_SP_VERSION%^) >>%UPDATE_LOGFILE%
)
if "%O2K7_VERSION_MAJOR%" NEQ "" (
  echo %DATE% %TIME% - Info: Found Microsoft Office 2007 %O2K7_VERSION_APP% version %O2K7_VERSION_MAJOR%.%O2K7_VERSION_MINOR%.%O2K7_VERSION_BUILD%.%O2K7_VERSION_REVISION% ^(o2k7 %O2K7_LANGUAGE% sp%O2K7_SP_VERSION%^) >>%UPDATE_LOGFILE%
)

rem *** Check Operating System architecture ***
for %%i in (x86 x64) do (if /i "%OS_ARCHITECTURE%"=="%%i" goto ValidArch)
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
if /i "%OS_ARCHITECTURE%"=="x64" (
  if exist ..\%OS_NAME%-%OS_ARCHITECTURE%\%OS_LANGUAGE%\nul (
    echo Medium supports Microsoft Windows ^(%OS_NAME%-%OS_ARCHITECTURE% %OS_LANGUAGE%^).
    echo %DATE% %TIME% - Info: Medium supports Microsoft Windows ^(%OS_NAME%-%OS_ARCHITECTURE% %OS_LANGUAGE%^) >>%UPDATE_LOGFILE%
    goto CheckOfficeMedium
  )
  if exist ..\%OS_NAME%-%OS_ARCHITECTURE%\glb\nul (
    echo Medium supports Microsoft Windows ^(%OS_NAME%-%OS_ARCHITECTURE% glb^).
    echo %DATE% %TIME% - Info: Medium supports Microsoft Windows ^(%OS_NAME%-%OS_ARCHITECTURE% glb^) >>%UPDATE_LOGFILE%
    goto CheckOfficeMedium
  )
) else (
  if exist ..\%OS_NAME%\%OS_LANGUAGE%\nul (
    echo Medium supports Microsoft Windows ^(%OS_NAME% %OS_LANGUAGE%^).
    echo %DATE% %TIME% - Info: Medium supports Microsoft Windows ^(%OS_NAME% %OS_LANGUAGE%^) >>%UPDATE_LOGFILE%
    goto CheckOfficeMedium
  )
  if exist ..\%OS_NAME%\glb\nul (
    echo Medium supports Microsoft Windows ^(%OS_NAME% glb^).
    echo %DATE% %TIME% - Info: Medium supports Microsoft Windows ^(%OS_NAME% glb^) >>%UPDATE_LOGFILE%
    goto CheckOfficeMedium
  )
)
echo Medium does not support Microsoft Windows (%OS_NAME% %OS_LANGUAGE%).
echo %DATE% %TIME% - Info: Medium does not support Microsoft Windows (%OS_NAME% %OS_LANGUAGE%) >>%UPDATE_LOGFILE%
if "%OFFICE_NAME%"=="" goto InvalidMedium

:CheckOfficeMedium
if "%OFFICE_NAME%"=="" goto ProperMedium
if exist ..\%OFFICE_NAME%\%OFFICE_LANGUAGE%\nul (
  echo Medium supports Microsoft Office ^(%OFFICE_NAME% %OFFICE_LANGUAGE%^).
  echo %DATE% %TIME% - Info: Medium supports Microsoft Office ^(%OFFICE_NAME% %OFFICE_LANGUAGE%^) >>%UPDATE_LOGFILE%
  goto ProperMedium
)
if exist ..\%OFFICE_NAME%\glb\nul (
  echo Medium supports Microsoft Office ^(%OFFICE_NAME% glb^).
  echo %DATE% %TIME% - Info: Medium supports Microsoft Office ^(%OFFICE_NAME% glb^) >>%UPDATE_LOGFILE%
  goto ProperMedium
)
if exist ..\%OFFICE_NAME%-%OS_ARCHITECTURE%\%OFFICE_LANGUAGE%\nul (
  echo Medium supports Microsoft Office ^(%OFFICE_NAME%-%OS_ARCHITECTURE% %OFFICE_LANGUAGE%^).
  echo %DATE% %TIME% - Info: Medium supports Microsoft Office ^(%OFFICE_NAME%-%OS_ARCHITECTURE% %OFFICE_LANGUAGE%^) >>%UPDATE_LOGFILE%
  goto ProperMedium
)
if exist ..\%OFFICE_NAME%-%OS_ARCHITECTURE%\glb\nul (
  echo Medium supports Microsoft Office ^(%OFFICE_NAME%-%OS_ARCHITECTURE% glb^).
  echo %DATE% %TIME% - Info: Medium supports Microsoft Office ^(%OFFICE_NAME%-%OS_ARCHITECTURE% glb^) >>%UPDATE_LOGFILE%
  goto ProperMedium
)
echo Medium does not support Microsoft Office (%OFFICE_NAME% %OFFICE_LANGUAGE%).
echo %DATE% %TIME% - Info: Medium does not support Microsoft Office (%OFFICE_NAME% %OFFICE_LANGUAGE%) >>%UPDATE_LOGFILE%
:ProperMedium

rem *** Install Windows Service Pack ***
echo Checking Windows Service Pack version...
if %OS_SP_VERSION_MAJOR% GEQ %OS_SP_VERSION_TARGET_MAJOR% goto SkipSPInst
if "%OS_SP_TARGET_ID%"=="" goto NoSPTargetId
echo %OS_SP_TARGET_ID% >"%TEMP%\MissingUpdateIds.txt"
call ListUpdatesToInstall.cmd /excludestatics
if errorlevel 1 goto ListError
if not exist "%TEMP%\UpdatesToInstall.txt" (
  if "%OFFICE_NAME%"=="" goto NoUpdates
  echo Warning: Windows Service Pack installation file ^(kb%OS_SP_TARGET_ID%^) not found.
  echo %DATE% %TIME% - Warning: Windows Service Pack installation file ^(kb%OS_SP_TARGET_ID%^) not found >>%UPDATE_LOGFILE%
  goto SkipSPInst
)
echo Installing most recent Windows Service Pack...
goto SP%OS_NAME%

:SPwxp
if 0 EQU %OS_SP_VERSION_MAJOR% (
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
if %DIRECTX_VERSION_MAJOR% LSS %DIRECTX_VERSION_TARGET_MAJOR% goto InstallDirectX
if %DIRECTX_VERSION_MAJOR% GTR %DIRECTX_VERSION_TARGET_MAJOR% goto SkipDirectXInst
if %DIRECTX_VERSION_MINOR% LSS %DIRECTX_VERSION_TARGET_MINOR% goto InstallDirectX
if %DIRECTX_VERSION_MINOR% GTR %DIRECTX_VERSION_TARGET_MINOR% goto SkipDirectXInst
if %DIRECTX_VERSION_BUILD% LSS %DIRECTX_VERSION_TARGET_BUILD% goto InstallDirectX
if %DIRECTX_VERSION_BUILD% GTR %DIRECTX_VERSION_TARGET_BUILD% goto SkipDirectXInst
if %DIRECTX_VERSION_REVISION% GEQ %DIRECTX_VERSION_TARGET_REVISION% goto SkipDirectXInst
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
if %WUA_VERSION_MAJOR% LSS %WUA_VERSION_TARGET_MAJOR% goto InstallWUA
if %WUA_VERSION_MAJOR% GTR %WUA_VERSION_TARGET_MAJOR% goto SkipWUAInst
if %WUA_VERSION_MINOR% LSS %WUA_VERSION_TARGET_MINOR% goto InstallWUA
if %WUA_VERSION_MINOR% GTR %WUA_VERSION_TARGET_MINOR% goto SkipWUAInst
if %WUA_VERSION_BUILD% LSS %WUA_VERSION_TARGET_BUILD% goto InstallWUA
if %WUA_VERSION_BUILD% GTR %WUA_VERSION_TARGET_BUILD% goto SkipWUAInst
if %WUA_VERSION_REVISION% GEQ %WUA_VERSION_TARGET_REVISION% goto SkipWUAInst
:InstallWUA
set WUA_FILENAME=..\wsus\WindowsUpdateAgent*-%OS_ARCHITECTURE%.exe
dir /B %WUA_FILENAME% >nul 2>&1
if errorlevel 1 goto NoWUAInst
echo Installing most recent Windows Update Agent...
for /F %%i in ('dir /B %WUA_FILENAME%') do (
  call InstallOSUpdate.cmd ..\wsus\%%i /ignoreerrors /wuforce /quiet /norestart
  if errorlevel 1 goto InstError
  set REBOOT_REQUIRED=1
)
:SkipWUAInst

rem *** Install Windows Installer ***
if "%OS_NAME%"=="w61" goto SkipMSIInst
echo Checking Windows Installer version...
if %MSI_VERSION_MAJOR% LSS %MSI_VERSION_TARGET_MAJOR% goto InstallMSI
if %MSI_VERSION_MAJOR% GTR %MSI_VERSION_TARGET_MAJOR% goto SkipMSIInst
if %MSI_VERSION_MINOR% LSS %MSI_VERSION_TARGET_MINOR% goto InstallMSI
if %MSI_VERSION_MINOR% GTR %MSI_VERSION_TARGET_MINOR% goto SkipMSIInst
if %MSI_VERSION_BUILD% LSS %MSI_VERSION_TARGET_BUILD% goto InstallMSI
if %MSI_VERSION_BUILD% GTR %MSI_VERSION_TARGET_BUILD% goto SkipMSIInst
if %MSI_VERSION_REVISION% GEQ %MSI_VERSION_TARGET_REVISION% goto SkipMSIInst
:InstallMSI
if "%MSI_TARGET_ID%"=="" (
  echo Warning: Environment variable MSI_TARGET_ID not set.
  echo %DATE% %TIME% - Warning: Environment variable MSI_TARGET_ID not set >>%UPDATE_LOGFILE%
  goto SkipMSIInst
) 
if /i "%OS_ARCHITECTURE%"=="x64" (
  set MSI_FILENAME=..\%OS_NAME%-%OS_ARCHITECTURE%\glb\*%MSI_TARGET_ID%*-%OS_ARCHITECTURE%.*
) else (
  set MSI_FILENAME=..\%OS_NAME%\glb\*%MSI_TARGET_ID%*-%OS_ARCHITECTURE%.*
)
dir /B %MSI_FILENAME% >nul 2>&1
if errorlevel 1 (
  echo Warning: File %MSI_FILENAME% not found.
  echo %DATE% %TIME% - Warning: File %MSI_FILENAME% not found >>%UPDATE_LOGFILE%
  goto SkipMSIInst
)
echo Installing most recent Windows Installer...
for /F %%i in ('dir /B %MSI_FILENAME%') do (
  if /i "%OS_ARCHITECTURE%"=="x64" (
    call InstallOSUpdate.cmd ..\%OS_NAME%-%OS_ARCHITECTURE%\glb\%%i %VERIFY_MODE% /quiet %BACKUP_MODE% /norestart
  ) else (
    call InstallOSUpdate.cmd ..\%OS_NAME%\glb\%%i %VERIFY_MODE% /quiet %BACKUP_MODE% /norestart
  )
  if not errorlevel 1 set RECALL_REQUIRED=1
)
:SkipMSIInst

rem *** Install Windows Script Host ***
if /i "%OS_ARCHITECTURE%"=="x64" goto SkipWSHInst
echo Checking Windows Script Host version...
if %WSH_VERSION_MAJOR% LSS %WSH_VERSION_TARGET_MAJOR% goto InstallWSH
if %WSH_VERSION_MAJOR% GTR %WSH_VERSION_TARGET_MAJOR% goto SkipWSHInst
if %WSH_VERSION_MINOR% LSS %WSH_VERSION_TARGET_MINOR% goto InstallWSH
if %WSH_VERSION_MINOR% GTR %WSH_VERSION_TARGET_MINOR% goto SkipWSHInst
if %WSH_VERSION_BUILD% LSS %WSH_VERSION_TARGET_BUILD% goto InstallWSH
if %WSH_VERSION_BUILD% GTR %WSH_VERSION_TARGET_BUILD% goto SkipWSHInst
if %WSH_VERSION_REVISION% GEQ %WSH_VERSION_TARGET_REVISION% goto SkipWSHInst
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
  if not errorlevel 1 set RECALL_REQUIRED=1
)
:SkipWSHInst

rem *** Install Internet Explorer ***
if "%OS_NAME%"=="w61" goto SkipIEInst
echo Checking Internet Explorer version...
if %IE_VERSION_MAJOR% LSS %IE_VERSION_TARGET_MAJOR% goto InstallIE
if %IE_VERSION_MAJOR% GTR %IE_VERSION_TARGET_MAJOR% goto SkipIEInst
if %IE_VERSION_MINOR% LSS %IE_VERSION_TARGET_MINOR% goto InstallIE
if %IE_VERSION_MINOR% GTR %IE_VERSION_TARGET_MINOR% goto SkipIEInst
if %IE_VERSION_BUILD% LSS %IE_VERSION_TARGET_BUILD% goto InstallIE
if %IE_VERSION_BUILD% GTR %IE_VERSION_TARGET_BUILD% goto SkipIEInst
if %IE_VERSION_REVISION% GEQ %IE_VERSION_TARGET_REVISION% goto SkipIEInst
:InstallIE
goto IE%OS_NAME%

:IEw2k
set IE_FILENAME=..\win\%OS_LANGUAGE%\ie6setup\ie6setup.exe
if not exist %IE_FILENAME% (
  echo Warning: Unable to install Internet Explorer 6. File %IE_FILENAME% not found. 
  echo %DATE% %TIME% - Warning: Unable to install Internet Explorer 6. File %IE_FILENAME% not found >>%UPDATE_LOGFILE%
  goto SkipIEInst 
)
echo Installing Internet Explorer 6...
call InstallOSUpdate.cmd %IE_FILENAME% %VERIFY_MODE% /ignoreerrors /q:a /r:n
if not errorlevel 1 set RECALL_REQUIRED=1
goto SkipIEInst 

:IEwxp
if "%INSTALL_IE%"=="/instie8" (
  set IE_FILENAME=..\%OS_NAME%\%OS_LANGUAGE%\IE8-WindowsXP-%OS_ARCHITECTURE%-%OS_LANGUAGE%*.exe
) else (
  set IE_FILENAME=..\%OS_NAME%\%OS_LANGUAGE%\ie7-windowsxp-%OS_ARCHITECTURE%-%OS_LANGUAGE%*.exe
)
goto IEwxp2k3

:IEw2k3
if /i "%OS_ARCHITECTURE%"=="x64" (
  if "%INSTALL_IE%"=="/instie8" (
    set IE_FILENAME=..\%OS_NAME%-%OS_ARCHITECTURE%\%OS_LANGUAGE%\IE8-WindowsServer2003-%OS_ARCHITECTURE%-%OS_LANGUAGE%*.exe
  ) else (
    set IE_FILENAME=..\%OS_NAME%-%OS_ARCHITECTURE%\%OS_LANGUAGE%\ie7-windowsserver2003-%OS_ARCHITECTURE%-%OS_LANGUAGE%*.exe
  ) 
) else (
  if "%INSTALL_IE%"=="/instie8" (
    set IE_FILENAME=..\%OS_NAME%\%OS_LANGUAGE%\IE8-WindowsServer2003-%OS_ARCHITECTURE%-%OS_LANGUAGE%*.exe
  ) else (
    set IE_FILENAME=..\%OS_NAME%\%OS_LANGUAGE%\ie7-windowsserver2003-%OS_ARCHITECTURE%-%OS_LANGUAGE%*.exe
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
  if /i "%OS_ARCHITECTURE%"=="x64" (
    if "%INSTALL_IE%"=="/instie8" (
      call InstallOSUpdate.cmd ..\%OS_NAME%-%OS_ARCHITECTURE%\%OS_LANGUAGE%\%%i %VERIFY_MODE% /ignoreerrors /quiet /update-no /no-default /norestart
    ) else (
      call InstallOSUpdate.cmd ..\%OS_NAME%-%OS_ARCHITECTURE%\%OS_LANGUAGE%\%%i %VERIFY_MODE% /ignoreerrors /quiet /update-no /no-default %BACKUP_MODE% /norestart
    )
  ) else (
    if "%INSTALL_IE%"=="/instie8" (
      call InstallOSUpdate.cmd ..\%OS_NAME%\%OS_LANGUAGE%\%%i %VERIFY_MODE% /ignoreerrors /quiet /update-no /no-default /norestart
    ) else (
      call InstallOSUpdate.cmd ..\%OS_NAME%\%OS_LANGUAGE%\%%i %VERIFY_MODE% /ignoreerrors /quiet /update-no /no-default %BACKUP_MODE% /norestart
    )
  )
  if not errorlevel 1 set RECALL_REQUIRED=1
)
goto SkipIEInst

:IEw60
if /i "%OS_ARCHITECTURE%"=="x64" (
  set IE_FILENAME=..\%OS_NAME%-%OS_ARCHITECTURE%\glb\IE8-WindowsVista-%OS_ARCHITECTURE%-%OS_LANGUAGE%*.exe
) else (
  set IE_FILENAME=..\%OS_NAME%\glb\IE8-WindowsVista-%OS_ARCHITECTURE%-%OS_LANGUAGE%*.exe
)
dir /B %IE_FILENAME% >nul 2>&1
if errorlevel 1 (
  echo Warning: File %IE_FILENAME% not found. 
  echo %DATE% %TIME% - Warning: File %IE_FILENAME% not found >>%UPDATE_LOGFILE%
  goto SkipIEInst
)
echo Installing Internet Explorer 8...
for /F %%i in ('dir /B %IE_FILENAME%') do (
  if /i "%OS_ARCHITECTURE%"=="x64" (
    call InstallOSUpdate.cmd ..\%OS_NAME%-%OS_ARCHITECTURE%\glb\%%i %VERIFY_MODE% /ignoreerrors /quiet /update-no /no-default /norestart
  ) else (
    call InstallOSUpdate.cmd ..\%OS_NAME%\glb\%%i %VERIFY_MODE% /ignoreerrors /quiet /update-no /no-default /norestart
  )
  if not errorlevel 1 set REBOOT_REQUIRED=1
)
goto SkipIEInst

:IEw61
:SkipIEInst

rem *** Install most recent Windows Media Player ***
if "%UPDATE_WMP%" NEQ "/updatewmp" goto SkipWMPInst
echo Checking Windows Media Player version...
if %WMP_VERSION_MAJOR% LSS %WMP_VERSION_TARGET_MAJOR% goto InstallWMP
if %WMP_VERSION_MAJOR% GTR %WMP_VERSION_TARGET_MAJOR% goto SkipWMPInst
if %WMP_VERSION_MINOR% LSS %WMP_VERSION_TARGET_MINOR% goto InstallWMP
if %WMP_VERSION_MINOR% GEQ %WMP_VERSION_TARGET_MINOR% goto SkipWMPInst
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
if %TSC_VERSION_MAJOR% LSS %TSC_VERSION_TARGET_MAJOR% goto InstallTSC
if %TSC_VERSION_MAJOR% GTR %TSC_VERSION_TARGET_MAJOR% goto SkipTSCInst
if %TSC_VERSION_MINOR% LSS %TSC_VERSION_TARGET_MINOR% goto InstallTSC
if %TSC_VERSION_MINOR% GEQ %TSC_VERSION_TARGET_MINOR% goto SkipTSCInst
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
if "%OS_NAME%"=="w2k" goto SkipDotNetInst
if "%INSTALL_DOTNET%" NEQ "/instdotnet" goto SkipDotNetInst
echo Checking .NET Framework 3.5 installation state...
if %DOTNET_VERSION_MAJOR% LSS %DOTNET_VERSION_TARGET_MAJOR% goto InstallDotNet
if %DOTNET_VERSION_MAJOR% GTR %DOTNET_VERSION_TARGET_MAJOR% goto SkipDotNetInst
if %DOTNET_VERSION_MINOR% LSS %DOTNET_VERSION_TARGET_MINOR% goto InstallDotNet
if %DOTNET_VERSION_MINOR% GTR %DOTNET_VERSION_TARGET_MINOR% goto SkipDotNetInst
if %DOTNET_VERSION_BUILD% LSS %DOTNET_VERSION_TARGET_BUILD% goto InstallDotNet
if %DOTNET_VERSION_BUILD% GTR %DOTNET_VERSION_TARGET_BUILD% goto SkipDotNetInst
if %DOTNET_VERSION_REVISION% GEQ %DOTNET_VERSION_TARGET_REVISION% goto SkipDotNetInst
:InstallDotNet
set DOTNET_FILENAME=..\dotnet\dotnetfx35.exe
if not exist %DOTNET_FILENAME% (
  echo Warning: File %DOTNET_FILENAME% not found. 
  echo %DATE% %TIME% - Warning: File %DOTNET_FILENAME% not found >>%UPDATE_LOGFILE%
  goto SkipDotNetInst
)
echo Installing .NET Framework 3.5 SP1...
call InstallOSUpdate.cmd %DOTNET_FILENAME% %VERIFY_MODE% /ignoreerrors /qb /norestart /lang:%OS_LANGUAGE%
copy /Y ..\static\StaticUpdateIds-dotnet.txt "%TEMP%\MissingUpdateIds.txt" >nul
call ListUpdatesToInstall.cmd /excludestatics
if errorlevel 1 goto ListError
if exist "%TEMP%\UpdatesToInstall.txt" (
  echo Installing .NET Framework 3.5 SP1 Family Update...
  call InstallListedUpdates.cmd /selectoptions %BACKUP_MODE% %VERIFY_MODE% /ignoreerrors
)
set REBOOT_REQUIRED=1
:SkipDotNetInst

rem *** Install Windows PowerShell 2.0 ***
if "%OS_NAME%"=="w2k" goto SkipPShInst
if "%INSTALL_PSH%" NEQ "/instpsh" goto SkipPShInst
echo Checking Windows PowerShell 2.0 installation state...
if %PSH_VERSION_MAJOR% LSS %PSH_VERSION_TARGET_MAJOR% goto InstallPSh
if %PSH_VERSION_MAJOR% GTR %PSH_VERSION_TARGET_MAJOR% goto SkipPShInst
if %PSH_VERSION_MINOR% LSS %PSH_VERSION_TARGET_MINOR% goto InstallPSh
if %PSH_VERSION_MINOR% GEQ %PSH_VERSION_TARGET_MINOR% goto SkipPShInst
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

if "%RECALL_REQUIRED%"=="1" goto Installed
if "%OFFICE_NAME%"=="" goto CheckAUService
if not exist ..\%OFFICE_NAME%\%OFFICE_LANGUAGE%\nul (
  if not exist ..\%OFFICE_NAME%\glb\nul goto CheckAUService
)
rem *** Check Office Service Pack versions ***
echo Checking Office Service Pack versions...
if exist "%TEMP%\MissingUpdateIds.txt" del "%TEMP%\MissingUpdateIds.txt"
if "%OXP_VERSION_MAJOR%"=="" goto SkipSPoxp
if %OXP_SP_VERSION% LSS %OXP_SP_VERSION_TARGET% echo %OXP_SP_TARGET_ID% >>"%TEMP%\MissingUpdateIds.txt"
:SkipSPoxp
if "%O2K3_VERSION_MAJOR%"=="" goto SkipSPo2k3
if %O2K3_SP_VERSION% LSS %O2K3_SP_VERSION_TARGET% echo %O2K3_SP_TARGET_ID% >>"%TEMP%\MissingUpdateIds.txt"
:SkipSPo2k3
if "%O2K7_VERSION_MAJOR%"=="" goto SkipSPo2k7
if %O2K7_SP_VERSION% LSS %O2K7_SP_VERSION_TARGET% echo %O2K7_SP_TARGET_ID% >>"%TEMP%\MissingUpdateIds.txt"
:SkipSPo2k7
if not exist "%TEMP%\MissingUpdateIds.txt" goto SkipSPOfc
call ListUpdatesToInstall.cmd /excludestatics
if errorlevel 1 goto ListError
if not exist "%TEMP%\UpdatesToInstall.txt" goto NoUpdates
echo Installing most recent Office Service Pack(s)...
call InstallListedUpdates.cmd %VERIFY_MODE% /errorsaswarnings
if errorlevel 1 goto InstError
set REBOOT_REQUIRED=1

:SkipSPOfc
rem *** Check installation state of Office Converter/Compatibility Packs ***
if "%INSTALL_CONVERTERS%" NEQ "/instofccnvs" goto CheckAUService
goto CNV%OFFICE_NAME%

:CNVoxp
:CNVo2k3
echo Checking installation state of Office Converter/Compatibility Packs...
if "%OFFICE_CONVERTER_PACK%" NEQ "1" (
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
if "%OFFICE_COMPATIBILITY_PACK%" NEQ "1" (
  if exist ..\ofc\%OFFICE_LANGUAGE%\FileFormatConverters.exe (
    echo Installing Office 2007 Compatibility Pack...
    echo Installing ..\ofc\%OFFICE_LANGUAGE%\FileFormatConverters.exe...
    ..\ofc\%OFFICE_LANGUAGE%\FileFormatConverters.exe /quiet /norestart
    echo %DATE% %TIME% - Info: Installed ..\ofc\%OFFICE_LANGUAGE%\FileFormatConverters.exe >>%UPDATE_LOGFILE%
  ) else (
    echo Warning: File ..\ofc\%OFFICE_LANGUAGE%\FileFormatConverters.exe not found. 
    echo %DATE% %TIME% - Warning: File ..\ofc\%OFFICE_LANGUAGE%\FileFormatConverters.exe not found >>%UPDATE_LOGFILE%
  )
)
:CNVo2k7

:CheckAUService
rem *** Check state of service 'automatic updates' ***
echo Checking state of service 'automatic updates'...
echo %DATE% %TIME% - Info: Detected state of service 'automatic updates': %AU_SERVICE_STATE_INITIAL% (start mode: %AU_SERVICE_START_MODE%) >>%UPDATE_LOGFILE%
if /i "%AU_SERVICE_STATE_INITIAL%"=="" goto ListUpdateIds
if /i "%AU_SERVICE_STATE_INITIAL%"=="Unknown" goto ListUpdateIds
if /i "%AU_SERVICE_STATE_INITIAL%"=="Running" goto ListUpdateIds
if /i "%AU_SERVICE_START_MODE%"=="Disabled" goto AUSvcNotRunning
echo Starting service 'automatic updates' (wuauserv)...
%SystemRoot%\system32\net.exe start wuauserv >nul
if not errorlevel 0 goto AUSvcNotRunning
set AU_SERVICE_STARTED=1
echo %DATE% %TIME% - Info: Started service 'automatic updates' (wuauserv) >>%UPDATE_LOGFILE%

:ListUpdateIds
rem *** List ids of missing updates ***
echo Listing ids of missing updates...
if not exist ..\wsus\wsusscn2.cab goto NoWSUSScan
copy /Y ..\wsus\wsusscn2.cab "%TEMP%" >nul
if exist "%TEMP%\MissingUpdateIds.txt" del "%TEMP%\MissingUpdateIds.txt"
%CSCRIPT_PATH% //Nologo //E:vbs ListMissingUpdateIds.vbs %LIST_MODE_IDS%

rem *** List ids of installed updates ***
if "%LIST_MODE_IDS%"=="/all" goto ListInstFiles
if "%LIST_MODE_UPDATES%"=="/excludestatics" goto ListInstFiles
echo Listing ids of installed updates...
if exist "%TEMP%\InstalledUpdateIds.txt" del "%TEMP%\InstalledUpdateIds.txt"
%CSCRIPT_PATH% //Nologo //E:vbs ListInstalledUpdateIds.vbs

:ListInstFiles
if exist "%TEMP%\wsusscn2.cab" del "%TEMP%\wsusscn2.cab"
rem *** List update files ***
if not exist "%TEMP%\MissingUpdateIds.txt" (
  if "%REBOOT_REQUIRED%"=="1" (goto Installed) else (goto NoMissingIds)
)
echo Listing update files...
call ListUpdatesToInstall.cmd %LIST_MODE_UPDATES%
if errorlevel 1 goto ListError

:InstallUpdates
rem *** Install updates ***
if not exist "%TEMP%\UpdatesToInstall.txt" goto NoUpdates
echo Installing updates...
call InstallListedUpdates.cmd /selectoptions %BACKUP_MODE% %VERIFY_MODE% /errorsaswarnings
if errorlevel 1 goto InstError

:Installed
if "%RECALL_REQUIRED%"=="1" (
  if "%BOOT_MODE%"=="/autoreboot" (
    if "%OS_NAME%"=="w60" (
      echo Automatic recall is not supported for Windows Vista / Server 2008.
      echo %DATE% %TIME% - Info: Automatic recall is not supported for Windows Vista / Server 2008 >>%UPDATE_LOGFILE%
      goto ManualRecall
    )
    if "%OS_NAME%"=="w61" (
      echo Automatic recall is not supported for Windows 7 / Server 2008 R2.
      echo %DATE% %TIME% - Info: Automatic recall is not supported for Windows 7 / Server 2008 R2 >>%UPDATE_LOGFILE%
      goto ManualRecall
    )
    if "%DOMAIN_ROLE%"=="4" (
      echo Automatic recall is not supported on domain controllers.
      echo %DATE% %TIME% - Info: Automatic recall is not supported on domain controllers >>%UPDATE_LOGFILE%
    )
    if "%DOMAIN_ROLE%"=="5" (
      echo Automatic recall is not supported on domain controllers.
      echo %DATE% %TIME% - Info: Automatic recall is not supported on domain controllers >>%UPDATE_LOGFILE%
    )
    if not "%USERNAME%"=="WSUSUpdateAdmin" (
      echo Preparing automatic recall...
      call PrepareRecall.cmd %~f0 %BACKUP_MODE% %VERIFY_MODE% %INSTALL_IE% %UPDATE_WMP% %UPDATE_TSC% %INSTALL_DOTNET% %INSTALL_PSH% %INSTALL_CONVERTERS% %BOOT_MODE% %FINISH_MODE% %SHOW_LOG% %LIST_MODE_IDS% %LIST_MODE_UPDATES%
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
echo ERROR: Unsupported Operating System architecture (%OS_ARCHITECTURE%).
echo %DATE% %TIME% - Error: Unsupported Operating System architecture (%OS_ARCHITECTURE%) >>%UPDATE_LOGFILE%
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
  echo Rebooting...
  %CSCRIPT_PATH% //Nologo //E:vbs Shutdown.vbs /reboot
) else (
  if "%AU_SERVICE_STARTED%"=="1" (
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
cd ..
rem *** Execute custom finalization hook ***
if exist .\custom\FinalizationHook.cmd (
  echo Executing custom finalization hook...
  call .\custom\FinalizationHook.cmd
  echo %DATE% %TIME% - Info: Executed custom finalization hook >>%UPDATE_LOGFILE%
)
echo %DATE% %TIME% - Info: Ending update >>%UPDATE_LOGFILE%
title %ComSpec%
if "%RECALL_REQUIRED%"=="1" (
  verify other 2>nul
  exit /b 3011
)
if "%REBOOT_REQUIRED%"=="1" exit /b 3010
endlocal
