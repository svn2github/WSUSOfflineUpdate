@echo off
rem *** Author: T. Wittrock, RZ Uni Kiel ***

if not exist "%TEMP%\msxsl.exe" .\bin\wget.exe -N -i .\static\StaticDownloadLink-msxsl.txt -P "%TEMP%"
if not exist "%TEMP%\wsusscn2.cab" (
  .\bin\wget.exe -N -i .\static\StaticDownloadLinks-wsus.txt -P "%TEMP%"
  del "%TEMP%\wuredist.cab"
) 
if exist "%TEMP%\package.cab" del "%TEMP%\package.cab"
if exist "%TEMP%\package.xml" del "%TEMP%\package.xml"
expand "%TEMP%\wsusscn2.cab" -F:package.cab "%TEMP%"
expand "%TEMP%\package.cab" "%TEMP%\package.xml"
del "%TEMP%\package.cab"
if exist "%TEMP%\UpdateCategories.txt" del "%TEMP%\UpdateCategories.txt"
if exist "%TEMP%\_UpdateCategories.txt" del "%TEMP%\_UpdateCategories.txt"
if exist "%TEMP%\UpdatePayloadFiles.txt" del "%TEMP%\UpdatePayloadFiles.txt"
if exist "%TEMP%\_UpdatePayloadFiles.txt" del "%TEMP%\_UpdatePayloadFiles.txt"
"%TEMP%\msxsl.exe" "%TEMP%\package.xml" .\xslt\ExtractUpdateCategories.xsl -o "%TEMP%\_UpdateCategories.txt"
for /F "usebackq tokens=1* delims=," %%i in ("%TEMP%\_UpdateCategories.txt") do if "%%j" NEQ "" echo %%i,%%j>>"%TEMP%\UpdateCategories.txt"
del "%TEMP%\_UpdateCategories.txt"
"%TEMP%\msxsl.exe" "%TEMP%\package.xml" .\xslt\ExtractUpdatePayloadFiles.xsl -o "%TEMP%\_UpdatePayloadFiles.txt"
for /F "usebackq tokens=1* delims=," %%i in ("%TEMP%\_UpdatePayloadFiles.txt") do if "%%j" NEQ "" echo %%i,%%j>>"%TEMP%\UpdatePayloadFiles.txt"
del "%TEMP%\_UpdatePayloadFiles.txt"
goto EoF

del "%TEMP%\msxsl.exe"
del "%TEMP%\wsusscn2.cab"
del "%TEMP%\package.xml"
:EoF
