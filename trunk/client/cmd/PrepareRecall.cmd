@echo off
rem *** Author: T. Wittrock, Kiel ***

if "%UPDATE_LOGFILE%"=="" set UPDATE_LOGFILE=%SystemRoot%\wsusofflineupdate.log

if "%OS_NAME%"=="" goto NoOSName
if "%REG_PATH%"=="" goto NoRegPath
if "%CSCRIPT_PATH%"=="" goto NoCScriptPath

echo Saving Winlogon registry hive...
%REG_PATH% EXPORT "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" %SystemRoot%\wsusbak-winlogon.reg >nul 2>&1
if errorlevel 1 (
  echo ERROR: Saving of Winlogon registry hive failed.
  echo %DATE% %TIME% - Error: Saving of Winlogon registry hive failed >>%UPDATE_LOGFILE%
  goto Error
) else (
  echo %DATE% %TIME% - Info: Saved Winlogon registry hive >>%UPDATE_LOGFILE%
)

echo Saving System policies registry hive...
%REG_PATH% EXPORT "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" %SystemRoot%\wsusbak-system-policies.reg >nul 2>&1
if errorlevel 1 (
  echo %DATE% %TIME% - Info: Saving of System policies registry hive failed >>%UPDATE_LOGFILE%
) else (
  echo %DATE% %TIME% - Info: Saved System policies registry hive >>%UPDATE_LOGFILE%
)

echo Creating WOUTempAdmin account...
%CSCRIPT_PATH% //Nologo //B //E:vbs CreateUpdateAdminAndEnableAutoLogon.vbs
if errorlevel 1 (
  echo Warning: Creation of WOUTempAdmin account failed.
  echo %DATE% %TIME% - Warning: Creation of WOUTempAdmin account failed >>%UPDATE_LOGFILE%
) else (
  echo %DATE% %TIME% - Info: Created WOUTempAdmin account >>%UPDATE_LOGFILE%
)

echo Registering recall...
%REG_PATH% ADD "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v WSUSOfflineUpdate /t REG_SZ /d "%*" >nul 2>&1
if errorlevel 1 (
  echo Warning: Registration of recall failed.
  echo %DATE% %TIME% - Warning: Registration of recall failed >>%UPDATE_LOGFILE%
) else (
  echo %DATE% %TIME% - Info: Registered recall >>%UPDATE_LOGFILE%
)
goto EoF

:NoOSName
echo ERROR: Environment variable OS_NAME not set.
echo %DATE% %TIME% - Error: Environment variable OS_NAME not set >>%UPDATE_LOGFILE%
goto Error

:NoRegPath
echo ERROR: Environment variable REG_PATH not set.
echo %DATE% %TIME% - Error: Environment variable REG_PATH not set >>%UPDATE_LOGFILE%
goto Error

:NoCScriptPath
echo ERROR: Environment variable CSCRIPT_PATH not set.
echo %DATE% %TIME% - Error: Environment variable CSCRIPT_PATH not set >>%UPDATE_LOGFILE%
goto Error

:Error
exit /b 1

:EoF
