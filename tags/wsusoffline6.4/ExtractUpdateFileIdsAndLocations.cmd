@echo off
rem *** Author: T. Wittrock, RZ Uni Kiel ***

if not exist "%TEMP%\msxsl.exe" .\bin\wget.exe -N -i .\static\StaticDownloadLink-msxsl.txt -P "%TEMP%"
if not exist "%TEMP%\wsusscn2.cab" (
  .\bin\wget.exe -N -i .\static\StaticDownloadLinks-wsus.txt -P "%TEMP%"
  if exist "%TEMP%\wuredist.cab" del "%TEMP%\wuredist.cab"
) 
if exist "%TEMP%\package.cab" del "%TEMP%\package.cab"
if exist "%TEMP%\package.xml" del "%TEMP%\package.xml"
expand "%TEMP%\wsusscn2.cab" -F:package.cab "%TEMP%"
expand "%TEMP%\package.cab" "%TEMP%\package.xml"
del "%TEMP%\package.cab"
if exist "%TEMP%\UpdateFileIdsAndLocations.txt" del "%TEMP%\UpdateFileIdsAndLocations.txt"
"%TEMP%\msxsl.exe" "%TEMP%\package.xml" .\xslt\ExtractUpdateFileIdsAndLocations.xsl -o "%TEMP%\UpdateFileIdsAndLocations.txt"
goto EoF

del "%TEMP%\msxsl.exe"
del "%TEMP%\wsusscn2.cab"
del "%TEMP%\package.xml"
:EoF
