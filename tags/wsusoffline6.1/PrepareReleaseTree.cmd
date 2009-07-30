@echo off
rem *** Author: T. Wittrock, RZ Uni Kiel ***

verify other 2>nul
setlocal enableextensions
if errorlevel 1 goto NoExtensions

if %1~==~ goto NoParam
set TARGET_DIR=%~fs1
set TARGET_DIR_LONG="%~f1"
if not exist %TARGET_DIR%\nul goto InvalidParam

rem *** Copy scripts and binaries ***
echo Copying scripts and binaries...
pushd %~dps0
xcopy *.* %TARGET_DIR% /E /Q /Y /EXCLUDE:exclude\ExcludeList-ReleaseTree.txt
popd

rem *** Compile AutoIt-Scripts ***
echo Compiling AutoIt-Scripts...
pushd %TARGET_DIR_LONG%
for /R %%i in (*.au3) do %~dps0bin\Aut2Exe.exe /in "%%i" /icon %~dps0ico\okshield.ico /comp 4 /nodecompile /nopack
popd
goto EoF

:NoExtensions
echo.
echo ERROR: No command extensions available.
echo.
goto EoF

:NoParam
echo.
echo ERROR: Invalid parameter %1
echo Usage: %~n0 TargetDirectory
echo.
goto EoF

:InvalidParam
echo.
echo ERROR: Target directory %TARGET_DIR% not found.
echo Usage: %~n0 TargetDirectory
echo.
goto EoF

:EoF
endlocal
