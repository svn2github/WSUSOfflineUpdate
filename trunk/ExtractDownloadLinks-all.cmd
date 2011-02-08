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

"%TEMP%\msxsl.exe" "%TEMP%\package.xml" .\xslt\ExtractUpdateFileIdsAndLocations.xsl -o "%TEMP%\DownloadLinks-all.txt"
del "%TEMP%\package.xml"
goto EoF

del "%TEMP%\wsusscn2.cab"
del "%TEMP%\msxsl.exe"
:EoF
