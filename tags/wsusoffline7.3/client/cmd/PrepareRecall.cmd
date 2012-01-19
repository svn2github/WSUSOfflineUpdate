@echo off
rem *** Author: T. Wittrock, Kiel ***

if "%UPDATE_LOGFILE%"=="" set UPDATE_LOGFILE=%SystemRoot%\wsusofflineupdate.log

if "%OS_NAME%"=="" goto NoOSName
if "%REG_PATH%"=="" goto NoRegPath
if "%CSCRIPT_PATH%"=="" goto NoCScriptPath

if "%OS_NAME%"=="w60" goto SkipWinlogon
if "%OS_NAME%"=="w61" goto SkipWinlogon
echo Saving Winlogon registry hive...
%REG_PATH% EXPORT "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" %SystemRoot%\woubak-winlogon.reg >nul 2>&1
if errorlevel 1 (
  echo ERROR: Saving of Winlogon registry hive failed.
  echo %DATE% %TIME% - Error: Saving of Winlogon registry hive failed >>%UPDATE_LOGFILE%
  goto Error
) else (
  echo %DATE% %TIME% - Info: Saved Winlogon registry hive >>%UPDATE_LOGFILE%
)
:SkipWinlogon

echo Saving System policies registry hive...
%REG_PATH% EXPORT "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" %SystemRoot%\woubak-system-policies.reg >nul 2>&1
if errorlevel 1 (
  echo %DATE% %TIME% - Info: Saving of System policies registry hive failed >>%UPDATE_LOGFILE%
) else (
  echo %DATE% %TIME% - Info: Saved System policies registry hive >>%UPDATE_LOGFILE%
)

if "%OS_NAME%"=="wxp" goto SkipPowerCfg
if "%OS_NAME%"=="w2k3" goto SkipPowerCfg
echo Creating temporary power scheme...
for /F "tokens=2 delims=:(" %%i in ('%SystemRoot%\system32\powercfg.exe -getactivescheme') do echo %%i>%SystemRoot%\woubak-pwrscheme-act.txt
for /F %%i in (%SystemRoot%\woubak-pwrscheme-act.txt) do (
  for /F "tokens=2 delims=:(" %%j in ('%SystemRoot%\system32\powercfg.exe -duplicatescheme %%i') do echo %%j>%SystemRoot%\woubak-pwrscheme-temp.txt
)
for /F %%i in (%SystemRoot%\woubak-pwrscheme-temp.txt) do (
  %SystemRoot%\system32\powercfg.exe -changename %%i WOUTemp
  %SystemRoot%\system32\powercfg.exe -setactive %%i
)
if errorlevel 1 (
  echo Warning: Activation of temporary power scheme failed.
  echo %DATE% %TIME% - Warning: Activation of temporary power scheme failed >>%UPDATE_LOGFILE%
) else (
  echo %DATE% %TIME% - Info: Activated temporary power scheme >>%UPDATE_LOGFILE%
)
:SkipPowerCfg

echo Preparing recall directory...
if not exist %SystemRoot%\Temp\WOURecall\nul md %SystemRoot%\Temp\WOURecall
for %%i in (CleanupRecall.cmd DeleteUpdateAdmin.vbs RecallStub.cmd ..\bin\Autologon.exe) do copy /Y %%i %SystemRoot%\Temp\WOURecall >nul
echo @%*>%SystemRoot%\Temp\WOURecall\RecallUpdate.cmd
%SystemRoot%\system32\net.exe use %~d0 >nul 2>&1
if errorlevel 1 (
  echo %DATE% %TIME% - Info: WSUS Offline Update was started from a local drive ^(%~d0^) >>%UPDATE_LOGFILE%
) else (
  if exist %SystemRoot%\Temp\WOURecall\ReconnectNetDrive.cmd del %SystemRoot%\Temp\WOURecall\ReconnectNetDrive.cmd
  for /F "tokens=1*" %%i in ('%SystemRoot%\system32\net.exe use %~d0') do echo @%SystemRoot%\system32\net.exe use %~d0 "%%j" | %SystemRoot%\system32\find.exe "\\">>%SystemRoot%\Temp\WOURecall\ReconnectNetDrive.cmd
  echo %DATE% %TIME% - Info: WSUS Offline Update was started from a network drive ^(%~d0^) >>%UPDATE_LOGFILE%
)
echo %DATE% %TIME% - Info: Prepared recall directory >>%UPDATE_LOGFILE%

echo Creating WOUTempAdmin account...
%CSCRIPT_PATH% //Nologo //B //E:vbs CreateUpdateAdminAndEnableAutoLogon.vbs
if errorlevel 1 (
  echo Warning: Creation of WOUTempAdmin account failed.
  echo %DATE% %TIME% - Warning: Creation of WOUTempAdmin account failed >>%UPDATE_LOGFILE%
) else (
  echo %DATE% %TIME% - Info: Created WOUTempAdmin account >>%UPDATE_LOGFILE%
)

echo Registering recall...
%REG_PATH% ADD "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v WSUSOfflineUpdate /t REG_SZ /d "%SystemRoot%\Temp\WOURecall\RecallStub.cmd" >nul 2>&1
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
