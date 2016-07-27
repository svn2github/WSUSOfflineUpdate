@echo off
rem *** Author: T. Wittrock, Kiel ***

if not exist "%TEMP%\wsusscn2.cab" (
  .\bin\wget.exe -N -i .\static\StaticDownloadLinks-wsus.txt -P "%TEMP%"
)
if exist "%TEMP%\package.cab" del "%TEMP%\package.cab"
if exist "%TEMP%\package.xml" del "%TEMP%\package.xml"
%SystemRoot%\System32\expand.exe "%TEMP%\wsusscn2.cab" -F:package.cab "%TEMP%"
%SystemRoot%\System32\expand.exe "%TEMP%\package.cab" "%TEMP%\package.xml"
del "%TEMP%\package.cab"

%SystemRoot%\System32\cscript.exe //Nologo //E:vbs .\cmd\XSLT.vbs "%TEMP%\package.xml" .\xslt\ExtractUpdateFileIdsAndLocations.xsl "%TEMP%\DownloadLinks-all.txt"
goto EoF

del "%TEMP%\package.xml"
del "%TEMP%\wsusscn2.cab"

:EoF
