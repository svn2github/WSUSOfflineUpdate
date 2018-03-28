@echo off
rem *** Author: T. Wittrock, Kiel ***

if "%UPDATE_LOGFILE%"=="" set UPDATE_LOGFILE=%SystemRoot%\wsusofflineupdate.log

for %%i in (listall install instselected) do (
  if /i "%1"=="/%%i" goto Proceed
)
goto InvalidParam

:InstMSI
if not exist %SystemRoot%\Temp\nul md %SystemRoot%\Temp
if exist "%~dpn1.mst" (
  echo Installing %1 using "%~dpn1.mst"...
  %SystemRoot%\System32\msiexec.exe /i %1 TRANSFORMS="%~dpn1.mst" /passive /norestart /log "%SystemRoot%\Temp\%~n1.log"
  if errorlevel 1 (
    echo %DATE% %TIME% - Warning: Installation of %1 using "%~dpn1.mst" failed>>%UPDATE_LOGFILE%
  ) else (
    echo %DATE% %TIME% - Info: Installed %1 using "%~dpn1.mst">>%UPDATE_LOGFILE%
  )  
) else (
  echo Installing %1...
  %SystemRoot%\System32\msiexec.exe /i %1 /passive /norestart /log "%SystemRoot%\Temp\%~n1.log"
  if errorlevel 1 (
    echo %DATE% %TIME% - Warning: Installation of %1 failed>>%UPDATE_LOGFILE%
  ) else (
    echo %DATE% %TIME% - Info: Installed %1>>%UPDATE_LOGFILE%
  )  
)
goto :eof

:Proceed
if /i "%1"=="/listall" (
  if exist "%TEMP%\wouallmsi.txt" del "%TEMP%\wouallmsi.txt"
  for /R "%~dp0..\software\msi" %%i in (*.msi) do echo %%~nxi>>"%TEMP%\wouallmsi.txt"
  for %%i in ("%TEMP%\wouallmsi.txt") do if %%~zi==0 del "%%i"
) else (
  for /R "%~dp0..\software\msi" %%i in (*.msi) do (
    if /i "%1"=="/instselected" (
      %SystemRoot%\System32\find.exe /I "%%~nxi" %SystemRoot%\Temp\wouselmsi.txt >nul 2>&1
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
echo %DATE% %TIME% - Error: Invalid parameter: %1>>%UPDATE_LOGFILE%
echo.

:EoF
