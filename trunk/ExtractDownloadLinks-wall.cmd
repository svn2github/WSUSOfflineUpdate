@echo off
rem *** Author: T. Wittrock, RZ Uni Kiel ***

.\bin\wget.exe -N -i .\static\StaticDownloadLink-msxsl.txt -P "%TEMP%"
.\bin\wget.exe -N -i .\static\StaticDownloadLinks-wsus.txt -P "%TEMP%"
del "%TEMP%\wuredist.cab"

if exist "%TEMP%\package.cab" del "%TEMP%\package.cab"
if exist "%TEMP%\package.xml" del "%TEMP%\package.xml"
expand "%TEMP%\wsusscn2.cab" -F:package.cab "%TEMP%"
del "%TEMP%\wsusscn2.cab"
expand "%TEMP%\package.cab" "%TEMP%\package.xml"
del "%TEMP%\package.cab"

if exist "%TEMP%\DownloadLinks-wall.txt" del "%TEMP%\DownloadLinks-wall.txt"
"%TEMP%\msxsl.exe" "%TEMP%\package.xml" .\xslt\ExtractDownloadLinks-wall.xsl -o "%TEMP%\DownloadLinks-wall.txt"
del "%TEMP%\msxsl.exe"

rem del "%TEMP%\package.xml"

:EoF
