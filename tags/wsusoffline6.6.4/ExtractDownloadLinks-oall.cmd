@echo off
rem *** Author: T. Wittrock, RZ Uni Kiel ***

.\bin\wget.exe -N -i .\static\StaticDownloadLink-msxsl.txt -P "%TEMP%"
.\bin\wget.exe -N -i .\static\StaticDownloadLinks-inventory.txt -P "%TEMP%\inventory"

"%TEMP%\inventory\invcif.exe" /T:"%TEMP%\inventory" /C /Q
pushd "%TEMP%\inventory"
move patchdata.xml .. >nul
popd
rd /S /Q "%TEMP%\inventory"

if exist "%TEMP%\DownloadLinks-oall-enu.txt" del "%TEMP%\DownloadLinks-oall-enu.txt"
if exist "%TEMP%\DownloadLinks-oall-deu.txt" del "%TEMP%\DownloadLinks-oall-deu.txt"
if exist "%TEMP%\DownloadLinks-oall-fra.txt" del "%TEMP%\DownloadLinks-oall-fra.txt"
"%TEMP%\msxsl.exe" "%TEMP%\patchdata.xml" .\xslt\ExtractDownloadLinks-oall-enu.xsl -o "%TEMP%\DownloadLinks-oall-enu.txt"
rem "%TEMP%\msxsl.exe" "%TEMP%\patchdata.xml" .\xslt\ExtractDownloadLinks-oall-deu.xsl -o "%TEMP%\DownloadLinks-oall-deu.txt"
rem "%TEMP%\msxsl.exe" "%TEMP%\patchdata.xml" .\xslt\ExtractDownloadLinks-oall-fra.xsl -o "%TEMP%\DownloadLinks-oall-fra.txt"

del "%TEMP%\msxsl.exe"
rem del "%TEMP%\patchdata.xml"

:EoF
