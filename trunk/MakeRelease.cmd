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

if exist "%TEMP%\wsusoffline" rd /S /Q "%TEMP%\wsusoffline"
md "%TEMP%\wsusoffline"
call PrepareReleaseTree.cmd "%TEMP%\wsusoffline"
pushd "%TEMP%"
if exist wsusoffline%1.zip del wsusoffline%1.zip
if exist wsusoffline%1.mds del wsusoffline%1.mds
if exist wsusoffline%1_hashes.txt del wsusoffline%1_hashes.txt
echo Creating release archive "%TEMP%\wsusoffline%1.zip"...
ren "%TEMP%\wsusoffline\cmd\UpdateOU.cmd" UpdateOU.new
"%ProgramFiles%\7-Zip\7z.exe" a -tzip -mx9 -r wsusoffline%1.zip wsusoffline
echo Creating message digest file "%TEMP%\wsusoffline%1_hashes.txt"...
if /i "%PROCESSOR_ARCHITECTURE%"=="AMD64" (set HASHDEEP_EXE=hashdeep64.exe) else (
  if /i "%PROCESSOR_ARCHITEW6432%"=="AMD64" (set HASHDEEP_EXE=hashdeep64.exe) else (set HASHDEEP_EXE=hashdeep.exe)
)
"%~dps0client\bin\%HASHDEEP_EXE%" -c md5,sha1,sha256 -b wsusoffline%1.zip >wsusoffline%1.mds
%SystemRoot%\System32\findstr.exe /L /I /C:## /V wsusoffline%1.mds >wsusoffline%1_hashes.txt
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
