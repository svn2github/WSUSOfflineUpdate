@echo off
rem *** Author: T. Wittrock, RZ Uni Kiel ***

rem goto DoXslt
if not exist "%TEMP%\msxsl.exe" .\bin\wget.exe -N -i .\static\StaticDownloadLink-msxsl.txt -P "%TEMP%"
.\bin\wget.exe -N -i .\static\StaticDownloadLinks-wsus.txt -P "%TEMP%"
del "%TEMP%\wuredist.cab"

if exist "%TEMP%\package.cab" del "%TEMP%\package.cab"
if exist "%TEMP%\package.xml" del "%TEMP%\package.xml"
expand "%TEMP%\wsusscn2.cab" -F:package.cab "%TEMP%"
expand "%TEMP%\package.cab" "%TEMP%\package.xml"
del "%TEMP%\package.cab"

:DoXslt
if exist "%TEMP%\DownloadLinks-wall.txt" del "%TEMP%\DownloadLinks-wall.txt"
"%TEMP%\msxsl.exe" "%TEMP%\package.xml" .\xslt\ExtractDownloadLinks-wall.xsl -o "%TEMP%\DownloadLinks-wall.txt"
goto EoF

del "%TEMP%\msxsl.exe"
del "%TEMP%\wsusscn2.cab"
del "%TEMP%\package.xml"
:EoF
