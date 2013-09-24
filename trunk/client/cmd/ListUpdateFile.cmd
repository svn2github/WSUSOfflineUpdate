@echo off
rem *** Author: T. Wittrock, Kiel ***

verify other 2>nul
setlocal enableextensions
if errorlevel 1 goto NoExtensions

if "%DIRCMD%" NEQ "" set DIRCMD=
if "%UPDATE_LOGFILE%"=="" set UPDATE_LOGFILE=%SystemRoot%\wsusofflineupdate.log

if "%1"=="" goto NoParam
if "%2"=="" goto NoParam

if exist "%TEMP%\Update.txt" goto EoF
if not exist %2\nul goto EoF

if /i "%3"=="/searchleftmost" (
  dir /A:-D /B /OD %2\%1*.* >"%TEMP%\Update.txt" 2>nul
) else (
  dir /A:-D /B /OD %2\*%1*.* >"%TEMP%\Update.txt" 2>nul
)
if errorlevel 1 (
  if exist "%TEMP%\Update.txt" del "%TEMP%\Update.txt"
) else (
  for /F "usebackq" %%i in ("%TEMP%\Update.txt") do echo %2\%%i >>"%TEMP%\UpdatesToInstall.txt"
)
goto EoF

:NoExtensions
echo ERROR: No command extensions available.
goto Error

:NoParam
echo ERROR: Invalid parameter. Usage: %~n0 {kbid} {directory} [/searchleftmost]
echo %DATE% %TIME% - Error: Invalid parameter. Usage: %~n0 {kbid} {directory} [/searchleftmost]>>%UPDATE_LOGFILE%
goto Error

:Error
endlocal
exit /b 1

:EoF
endlocal
