@echo off
rem *** Author: T. Wittrock, RZ Uni Kiel ***

setlocal

if "%UPDATE_LOGFILE%"=="" set UPDATE_LOGFILE=%SystemRoot%\wsusofflineupdate.log

%~d0
cd "%~p0"

if "%REG_PATH%"=="" (
  if exist %SystemRoot%\system32\reg.exe (
    set REG_PATH=%SystemRoot%\system32\reg.exe
  ) else (
    set REG_PATH=..\bin\reg.exe
  )
)
if not exist %REG_PATH% goto NoReg

if "%CSCRIPT_PATH%"=="" set CSCRIPT_PATH=%SystemRoot%\system32\cscript.exe
if not exist %CSCRIPT_PATH% goto NoCScript

if exist %SystemRoot%\wsusbak-winlogon.reg (
  echo Restoring Winlogon registry hive...
  %REG_PATH% DELETE "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /va /f >nul 2>&1
  %REG_PATH% IMPORT %SystemRoot%\wsusbak-winlogon.reg >nul 2>&1
  if errorlevel 1 (
    echo Warning: Restore of Winlogon registry hive failed.
    echo %DATE% %TIME% - Warning: Restore of Winlogon registry hive failed >>%UPDATE_LOGFILE%
  ) else (
    del %SystemRoot%\wsusbak-winlogon.reg
    echo %DATE% %TIME% - Info: Restored Winlogon registry hive >>%UPDATE_LOGFILE%
  )
)

if exist %SystemRoot%\wsusbak-explorer-policies.reg (
  echo Restoring Explorer policies registry hive...
  %REG_PATH% DELETE "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" /va /f >nul 2>&1
  %REG_PATH% IMPORT %SystemRoot%\wsusbak-explorer-policies.reg >nul 2>&1
  if errorlevel 1 (
    echo Warning: Restore of Explorer policies registry hive failed.
    echo %DATE% %TIME% - Warning: Restore of Explorer policies registry hive failed >>%UPDATE_LOGFILE%
  ) else (
    del %SystemRoot%\wsusbak-explorer-policies.reg
    echo %DATE% %TIME% - Info: Restored Explorer policies registry hive >>%UPDATE_LOGFILE%
  )
)

if exist %SystemRoot%\wsusbak-desktop-policies.reg (
  echo Restoring Desktop policies registry hive...
  %REG_PATH% DELETE "HKLM\SOFTWARE\Policies\Microsoft\Windows\Control Panel\Desktop" /va /f >nul 2>&1
  %REG_PATH% IMPORT %SystemRoot%\wsusbak-desktop-policies.reg >nul 2>&1
  if errorlevel 1 (
    echo Warning: Restore of Desktop policies registry hive failed.
    echo %DATE% %TIME% - Warning: Restore of Desktop policies registry hive failed >>%UPDATE_LOGFILE%
  ) else (
    del %SystemRoot%\wsusbak-desktop-policies.reg
    echo %DATE% %TIME% - Info: Restored Desktop policies registry hive >>%UPDATE_LOGFILE%
  )
) else (
  %REG_PATH% DELETE "HKLM\SOFTWARE\Policies\Microsoft\Windows\Control Panel\Desktop" /v ScreenSaveActive /f >nul 2>&1
)

echo Unregistering recall...
%REG_PATH% DELETE HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run /v WSUSOfflineUpdate /f >nul 2>&1 
if errorlevel 1 (
  echo Warning: Deregistration of recall failed.
  echo %DATE% %TIME% - Warning: Deregistration of recall failed >>%UPDATE_LOGFILE%
) else (
  echo %DATE% %TIME% - Info: Unregistered recall >>%UPDATE_LOGFILE%
)

echo Deleting WSUSUpdateAdmin account...
if "%USERNAME%"=="WSUSUpdateAdmin" (
  %REG_PATH% ADD HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce /v DeleteWSUSUpdateAdminProfile /t REG_SZ /d "cmd /c rd /S /Q \"%USERPROFILE%\"" >nul 2>&1 
  echo %DATE% %TIME% - Info: Registered erasing of WSUSUpdateAdmin profile >>%UPDATE_LOGFILE%
) else (
  echo %DATE% %TIME% - Warning: WSUSUpdateAdmin is not logged on - registration of erasing of WSUSUpdateAdmin profile skipped >>%UPDATE_LOGFILE%
)
%CSCRIPT_PATH% //Nologo //B //E:vbs DeleteUpdateAdmin.vbs
if errorlevel 1 (
  echo Warning: Deletion of WSUSUpdateAdmin account failed.
  echo %DATE% %TIME% - Warning: Deletion of WSUSUpdateAdmin account failed >>%UPDATE_LOGFILE%
) else (
  echo %DATE% %TIME% - Info: Deleted WSUSUpdateAdmin account >>%UPDATE_LOGFILE%
)
goto EoF

:NoReg
echo.
echo ERROR: Registry tool %REG_PATH% not found.
echo %DATE% %TIME% - Error: Registry tool %REG_PATH% not found >>%UPDATE_LOGFILE%
goto Error

:NoCScript
echo.
echo ERROR: VBScript interpreter %CSCRIPT_PATH% not found.
echo %DATE% %TIME% - Error: VBScript interpreter %CSCRIPT_PATH% not found >>%UPDATE_LOGFILE%
goto Error

:Error
endlocal
exit /b 1

:EoF
endlocal
