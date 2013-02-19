@echo off
rem *** Author: T. Wittrock, Kiel ***

if "%UPDATE_LOGFILE%"=="" set UPDATE_LOGFILE=%SystemRoot%\wsusofflineupdate.log

for %%i in (listall install instselected) do (
  if /i "%1"=="/%%i" goto Proceed
    for %%j in (enu fra esn jpn kor rus ptg ptb deu nld ita chs cht plk hun csy sve trk ell ara heb dan nor fin) do (if /i "%2"=="%%j" goto EvalParams)
  )
)
goto InvalidParam

:InstMSI
echo Installing %1...
if not exist %SystemRoot%\Temp\nul md %SystemRoot%\Temp
@%SystemRoot%\system32\msiexec.exe /i %1 /passive /norestart /lic+ "%SystemRoot%\Temp\%~n1.log"
if errorlevel 1 (
  echo %DATE% %TIME% - Warning: Installation of %1 failed >>%UPDATE_LOGFILE%
) else (
  echo %DATE% %TIME% - Info: Installed %1 >>%UPDATE_LOGFILE%
)  
goto :eof

:Proceed
if /i "%1"=="/listall" (
  pushd "%~dp0..\software\msi"
  dir /B /ON /S *.msi >"%TEMP%\wouallmsi.txt" 2>nul
  for %%i in ("%TEMP%\wouallmsi.txt") do if %%~zi==0 del "%%i"
  popd
) else (
  for /R "%~dp0..\software\msi" %%i in (*.msi) do (
    if /i "%1"=="/instselected" (
      %SystemRoot%\system32\find.exe /I "%%~ni" "%SystemRoot%\Temp\wouselmsi.txt" >nul 2>&1
      if not errorlevel 1 call :InstMSI "%%i"
    ) else (
      if /i "%1"=="/install" call :InstMSI "%%i"
    )
  )
)
goto EoF

:InvalidParam
echo.
echo ERROR: Invalid parameter: %1
echo Usage: %~n0 {/listall ^| /install ^| /instselected}
echo %DATE% %TIME% - Error: Invalid parameter: %1 >>%UPDATE_LOGFILE%
echo.

:EoF
