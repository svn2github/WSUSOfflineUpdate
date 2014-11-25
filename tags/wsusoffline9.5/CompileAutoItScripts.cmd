@echo off
rem *** Author: T. Wittrock, Kiel ***

verify other 2>nul
setlocal enableextensions
if errorlevel 1 goto NoExtensions

echo Compiling AutoIt-Scripts...
for %%i in (UpdateGenerator.au3 client\UpdateInstaller.au3) do %~dps0bin\Aut2Exe.exe /in "%%i" /icon %~dps0ico\okshield.ico /comp 0 /nodecompile /nopack
goto EoF

:NoExtensions
echo.
echo ERROR: No command extensions available.
echo.
goto EoF

:EoF
endlocal
