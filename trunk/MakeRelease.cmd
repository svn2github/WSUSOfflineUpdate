@echo off
rem *** Author: T. Wittrock, Kiel ***

verify other 2>nul
setlocal enableextensions
if errorlevel 1 goto NoExtensions

if %1~==~ goto NoParam
if "%TEMP%"=="" goto NoTemp
pushd "%TEMP%"
if errorlevel 1 goto NoTempDir
popd
if not exist "%ProgramFiles%\7-Zip\7z.exe" goto No7Zip

set TARGET_DIR="%TEMP%\wsusoffline"
if exist "%TEMP%\wsusoffline" rd /S /Q "%TEMP%\wsusoffline" 
md "%TEMP%\wsusoffline" 
call PrepareReleaseTree.cmd "%TEMP%\wsusoffline"
pushd "%TEMP%"
if exist wsusoffline%1.zip del wsusoffline%1.zip
if exist wsusoffline%1.mds del wsusoffline%1.mds
if exist wsusoffline%1_hashes.txt del wsusoffline%1_hashes.txt
echo Creating release archive "%TEMP%\wsusoffline%1.zip"...
"%ProgramFiles%\7-Zip\7z.exe" a -tzip -mx9 -r wsusoffline%1.zip wsusoffline
echo Creating message digest file "%TEMP%\wsusoffline%1_hashes.txt"...
%~dps0client\bin\hashdeep.exe -c md5,sha256 -b wsusoffline%1.zip >wsusoffline%1.mds
%SystemRoot%\system32\findstr.exe /C:## /V wsusoffline%1.mds >wsusoffline%1_hashes.txt
del wsusoffline%1.mds
popd
rd /S /Q "%TEMP%\wsusoffline" 
goto EoF

:NoExtensions
echo.
echo ERROR: No command extensions available.
echo.
goto EoF

:NoParam
echo.
echo ERROR: Missing parameter %1
echo Usage: %~n0 ^<VersionNumber^>
echo.
goto EoF

:NoTemp
echo.
echo ERROR: Environment variable TEMP not set.
echo.
goto EoF

:NoTempDir
echo.
echo ERROR: Directory "%TEMP%" not found.
echo.
goto EoF

:No7Zip
echo.
echo ERROR: Compression utility "%ProgramFiles%\7-Zip\7z.exe" not found.
echo.
goto EoF

:EoF
endlocal
