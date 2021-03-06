@echo off
rem *** Author: T. Wittrock, Kiel ***

setlocal

if "%UPDATE_LOGFILE%"=="" set UPDATE_LOGFILE=%SystemRoot%\wsusofflineupdate.log

%~d0
cd "%~p0"

if "%REG_PATH%"=="" set REG_PATH=%SystemRoot%\system32\reg.exe
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

if exist %SystemRoot%\wsusbak-system-policies.reg (
  echo Restoring System policies registry hive...
  %REG_PATH% DELETE "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /va /f >nul 2>&1
  %REG_PATH% IMPORT %SystemRoot%\wsusbak-system-policies.reg >nul 2>&1
  if errorlevel 1 (
    echo Warning: Restore of System policies registry hive failed.
    echo %DATE% %TIME% - Warning: Restore of System policies registry hive failed >>%UPDATE_LOGFILE%
  ) else (
    del %SystemRoot%\wsusbak-system-policies.reg
    echo %DATE% %TIME% - Info: Restored System policies registry hive >>%UPDATE_LOGFILE%
  )
) else (
  %REG_PATH% ADD "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v ConsentPromptBehaviorAdmin /t REG_DWORD /d 2 /f >nul 2>&1 
  %REG_PATH% ADD "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v EnableLUA /t REG_DWORD /d 1 /f >nul 2>&1 
)

echo Unregistering recall...
%REG_PATH% DELETE "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v WSUSOfflineUpdate /f >nul 2>&1 
if errorlevel 1 (
  echo Warning: Deregistration of recall failed.
  echo %DATE% %TIME% - Warning: Deregistration of recall failed >>%UPDATE_LOGFILE%
) else (
  echo %DATE% %TIME% - Info: Unregistered recall >>%UPDATE_LOGFILE%
)

echo Disabling autologon...
%REG_PATH% ADD "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v AutoAdminLogon /t REG_SZ /d "0" /f >nul 2>&1 
if errorlevel 1 (
  echo Warning: Disabling of autologon failed.
  echo %DATE% %TIME% - Warning: Disabling of autologon failed >>%UPDATE_LOGFILE%
) else (
  echo %DATE% %TIME% - Info: Disabled autologon >>%UPDATE_LOGFILE%
)

echo Deleting WOUTempAdmin account...
if "%USERNAME%"=="WOUTempAdmin" (
  %REG_PATH% ADD "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce" /v DeleteWOUTempAdminProfile /t REG_SZ /d "cmd /c rd /S /Q \"%USERPROFILE%\"" >nul 2>&1 
  echo %DATE% %TIME% - Info: Registered erasing of WOUTempAdmin profile >>%UPDATE_LOGFILE%
) else (
  echo %DATE% %TIME% - Warning: WOUTempAdmin is not logged on - registration of erasing of WOUTempAdmin profile skipped >>%UPDATE_LOGFILE%
)
%CSCRIPT_PATH% //Nologo //B //E:vbs DeleteUpdateAdmin.vbs
if errorlevel 1 (
  echo Warning: Deletion of WOUTempAdmin account failed.
  echo %DATE% %TIME% - Warning: Deletion of WOUTempAdmin account failed >>%UPDATE_LOGFILE%
) else (
  echo %DATE% %TIME% - Info: Deleted WOUTempAdmin account >>%UPDATE_LOGFILE%
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
