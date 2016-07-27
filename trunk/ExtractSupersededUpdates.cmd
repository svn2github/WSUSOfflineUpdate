@echo off
rem *** Author: H. Buhrmester ***

setlocal enabledelayedexpansion

if not exist "%TEMP%\wsusscn2.cab" (
  .\bin\wget.exe -N -i .\static\StaticDownloadLinks-wsus.txt -P "%TEMP%"
)
if exist "%TEMP%\package.cab" del "%TEMP%\package.cab"
if exist "%TEMP%\package.xml" del "%TEMP%\package.xml"
%SystemRoot%\System32\expand.exe "%TEMP%\wsusscn2.cab" -F:package.cab "%TEMP%"
%SystemRoot%\System32\expand.exe "%TEMP%\package.cab" "%TEMP%\package.xml"
del "%TEMP%\package.cab"

rem *** Determine superseded updates ***
echo %TIME% - Determining superseded updates (please be patient, this will take a while)...

rem *** Revised part for determination of superseded updates starts here ***
rem *** First step ***
echo Extracting file 1...
%SystemRoot%\System32\cscript.exe //Nologo //B //E:vbs .\cmd\XSLT.vbs "%TEMP%\package.xml" .\xslt\extract-existing-bundle-revision-ids.xsl "%TEMP%\existing-bundle-revision-ids.txt"
.\bin\gsort.exe -u -T "%TEMP%" "%TEMP%\existing-bundle-revision-ids.txt" >"%TEMP%\existing-bundle-revision-ids-unique.txt"
rem del "%TEMP%\existing-bundle-revision-ids.txt"
echo Extracting file 2...
%SystemRoot%\System32\cscript.exe //Nologo //B //E:vbs .\cmd\XSLT.vbs "%TEMP%\package.xml" .\xslt\extract-superseding-and-superseded-revision-ids.xsl "%TEMP%\superseding-and-superseded-revision-ids.txt"
.\bin\gsort.exe -u -T "%TEMP%" "%TEMP%\superseding-and-superseded-revision-ids.txt" >"%TEMP%\superseding-and-superseded-revision-ids-unique.txt"
rem del "%TEMP%\superseding-and-superseded-revision-ids.txt"
echo Joining files 1 and 2 to file 3...
.\bin\join.exe -t "," -o "2.2" "%TEMP%\existing-bundle-revision-ids-unique.txt" "%TEMP%\superseding-and-superseded-revision-ids-unique.txt" >"%TEMP%\ValidSupersededRevisionIds.txt"
rem del "%TEMP%\existing-bundle-revision-ids-unique.txt"
rem del "%TEMP%\superseding-and-superseded-revision-ids-unique.txt"
.\bin\gsort.exe -u -T "%TEMP%" "%TEMP%\ValidSupersededRevisionIds.txt" >"%TEMP%\ValidSupersededRevisionIds-unique.txt"
rem del "%TEMP%\ValidSupersededRevisionIds.txt"

rem *** Second step ***
echo Extracting file 4...
%SystemRoot%\System32\cscript.exe //Nologo //B //E:vbs .\cmd\XSLT.vbs "%TEMP%\package.xml" .\xslt\extract-update-revision-and-file-ids.xsl "%TEMP%\BundledUpdateRevisionAndFileIds.txt"
.\bin\gsort.exe -u -T "%TEMP%" "%TEMP%\BundledUpdateRevisionAndFileIds.txt" >"%TEMP%\BundledUpdateRevisionAndFileIds-unique.txt"
rem del "%TEMP%\BundledUpdateRevisionAndFileIds.txt"
echo Joining files 3 and 4 to file 5...
.\bin\join.exe -t "," -o "2.3" "%TEMP%\ValidSupersededRevisionIds-unique.txt" "%TEMP%\BundledUpdateRevisionAndFileIds-unique.txt" >"%TEMP%\SupersededFileIds.txt"
rem del "%TEMP%\ValidSupersededRevisionIds-unique.txt"
rem del "%TEMP%\BundledUpdateRevisionAndFileIds-unique.txt"
.\bin\gsort.exe -u -T "%TEMP%" "%TEMP%\SupersededFileIds.txt" >"%TEMP%\SupersededFileIds-unique.txt"
rem del "%TEMP%\SupersededFileIds.txt"

rem *** Third step ***
echo Extracting file 6...
%SystemRoot%\System32\cscript.exe //Nologo //B //E:vbs .\cmd\XSLT.vbs "%TEMP%\package.xml" .\xslt\extract-update-cab-exe-ids-and-locations.xsl "%TEMP%\UpdateCabExeIdsAndLocations.txt"
.\bin\gsort.exe -u -T "%TEMP%" "%TEMP%\UpdateCabExeIdsAndLocations.txt" >"%TEMP%\UpdateCabExeIdsAndLocations-unique.txt"
rem del "%TEMP%\UpdateCabExeIdsAndLocations.txt"
echo Joining files 5 and 6 to file 7...
.\bin\join.exe -t "," -o "2.2" "%TEMP%\SupersededFileIds-unique.txt" "%TEMP%\UpdateCabExeIdsAndLocations-unique.txt" >"%TEMP%\ExcludeListLocations-superseded-all.txt"
rem del "%TEMP%\SupersededFileIds-unique.txt"
rem del "%TEMP%\UpdateCabExeIdsAndLocations-unique.txt"
.\bin\gsort.exe -u -T "%TEMP%" "%TEMP%\ExcludeListLocations-superseded-all.txt" >"%TEMP%\ExcludeListLocations-superseded-all-unique.txt"
rem del "%TEMP%\ExcludeListLocations-superseded-all.txt"

rem *** Apply ExcludeList-superseded-exclude.txt ***
if exist .\exclude\ExcludeList-superseded-exclude.txt copy /Y .\exclude\ExcludeList-superseded-exclude.txt "%TEMP%\ExcludeList-superseded-exclude.txt" >nul
if exist .\exclude\custom\ExcludeList-superseded-exclude.txt (
  type .\exclude\custom\ExcludeList-superseded-exclude.txt >>"%TEMP%\ExcludeList-superseded-exclude.txt"
)
rem *** Delete file if empty ***
for %%i in ("%TEMP%\ExcludeList-superseded-exclude.txt") do if %%~zi==0 del %%i
if exist "%TEMP%\ExcludeList-superseded-exclude.txt" (
  %SystemRoot%\System32\findstr.exe /L /I /V /G:"%TEMP%\ExcludeList-superseded-exclude.txt" "%TEMP%\ExcludeListLocations-superseded-all-unique.txt" >"%TEMP%\ExcludeList-superseded.txt"
  rem del "%TEMP%\ExcludeListLocations-superseded-all-unique.txt"
  rem del "%TEMP%\ExcludeList-superseded-exclude.txt"
) else (
  move /Y "%TEMP%\ExcludeListLocations-superseded-all-unique.txt" "%TEMP%\ExcludeList-superseded.txt" >nul
)
echo %TIME% - Done.
del "%TEMP%\package.xml"
goto EoF

del "%TEMP%\wsusscn2.cab"
:EoF
endlocal
