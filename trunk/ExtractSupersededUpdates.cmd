@echo off
rem *** Author: T. Wittrock, Kiel ***

if not exist "%TEMP%\msxsl.exe" .\bin\wget.exe -N -i .\static\StaticDownloadLink-msxsl.txt -P "%TEMP%"
if not exist "%TEMP%\wsusscn2.cab" (
  .\bin\wget.exe -N -i .\static\StaticDownloadLinks-wsus.txt -P "%TEMP%"
  if exist "%TEMP%\wuredist.cab" del "%TEMP%\wuredist.cab"
  if exist "%TEMP%\WindowsUpdateAgent30-x64.exe" del "%TEMP%\WindowsUpdateAgent30-x64.exe"
  if exist "%TEMP%\WindowsUpdateAgent30-x86.exe" del "%TEMP%\WindowsUpdateAgent30-x86.exe"
) 
if exist "%TEMP%\package.cab" del "%TEMP%\package.cab"
if exist "%TEMP%\package.xml" del "%TEMP%\package.xml"
%SystemRoot%\system32\expand.exe "%TEMP%\wsusscn2.cab" -F:package.cab "%TEMP%"
%SystemRoot%\system32\expand.exe "%TEMP%\package.cab" "%TEMP%\package.xml"
del "%TEMP%\package.cab"

"%TEMP%\msxsl.exe" "%TEMP%\package.xml" .\xslt\ExtractUpdateRevisionIds.xsl -o "%TEMP%\ValidUpdateRevisionIds.txt"
if errorlevel 1 goto DownloadError
"%TEMP%\msxsl.exe" "%TEMP%\package.xml" .\xslt\ExtractSupersedingRevisionIds.xsl -o "%TEMP%\SupersedingRevisionIds.txt"
if errorlevel 1 goto DownloadError
%SystemRoot%\system32\findstr.exe /G:"%TEMP%\SupersedingRevisionIds.txt" "%TEMP%\ValidUpdateRevisionIds.txt" >"%TEMP%\ValidSupersedingRevisionIds.txt"
del "%TEMP%\ValidUpdateRevisionIds.txt"
del "%TEMP%\SupersedingRevisionIds.txt"
"%TEMP%\msxsl.exe" "%TEMP%\package.xml" .\xslt\ExtractSupersededUpdateRelations.xsl -o "%TEMP%\SupersededUpdateRelations.txt"
if errorlevel 1 goto DownloadError
%SystemRoot%\system32\findstr.exe /G:"%TEMP%\ValidSupersedingRevisionIds.txt" "%TEMP%\SupersededUpdateRelations.txt" >"%TEMP%\ValidSupersededUpdateRelations.txt"
del "%TEMP%\SupersededUpdateRelations.txt"
del "%TEMP%\ValidSupersedingRevisionIds.txt"
"%TEMP%\msxsl.exe" "%TEMP%\package.xml" .\xslt\ExtractBundledUpdateRelationsAndFileIds.xsl -o "%TEMP%\BundledUpdateRelationsAndFileIds.txt"
if errorlevel 1 goto DownloadError
if exist "%TEMP%\ValidSupersededRevisionIds.txt" del "%TEMP%\ValidSupersededRevisionIds.txt"
for /F "usebackq tokens=1 delims=,;" %%i in ("%TEMP%\ValidSupersededUpdateRelations.txt") do echo %%i>>"%TEMP%\ValidSupersededRevisionIds.txt"
del "%TEMP%\ValidSupersededUpdateRelations.txt"
%SystemRoot%\system32\findstr.exe /G:"%TEMP%\ValidSupersededRevisionIds.txt" "%TEMP%\BundledUpdateRelationsAndFileIds.txt" >"%TEMP%\SupersededRevisionAndFileIds.txt"
del "%TEMP%\ValidSupersededRevisionIds.txt"
del "%TEMP%\BundledUpdateRelationsAndFileIds.txt"
if exist "%TEMP%\SupersededFileIds.txt" del "%TEMP%\SupersededFileIds.txt"
for /F "usebackq tokens=2 delims=,;" %%i in ("%TEMP%\SupersededRevisionAndFileIds.txt") do echo %%i>>"%TEMP%\SupersededFileIds.txt"
del "%TEMP%\SupersededRevisionAndFileIds.txt"
"%TEMP%\msxsl.exe" "%TEMP%\package.xml" .\xslt\ExtractUpdateCabExeIdsAndLocations.xsl -o "%TEMP%\UpdateCabExeIdsAndLocations.txt"
if errorlevel 1 goto DownloadError
%SystemRoot%\system32\findstr.exe /G:"%TEMP%\SupersededFileIds.txt" "%TEMP%\UpdateCabExeIdsAndLocations.txt" >"%TEMP%\SupersededCabExeIdsAndLocations.txt"
del "%TEMP%\UpdateCabExeIdsAndLocations.txt"
del "%TEMP%\SupersededFileIds.txt"
if exist .\exclude\ExcludeList-superseded.txt del .\exclude\ExcludeList-superseded.txt
for /F "usebackq tokens=2 delims=," %%i in ("%TEMP%\SupersededCabExeIdsAndLocations.txt") do echo %%~ni>>.\exclude\ExcludeList-superseded.txt
del "%TEMP%\SupersededCabExeIdsAndLocations.txt"
del "%TEMP%\package.xml"
goto EoF

del "%TEMP%\wsusscn2.cab"
del "%TEMP%\msxsl.exe"
:EoF
