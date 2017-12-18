@echo off

setlocal enabledelayedexpansion
rem *** Author: T. Wittrock, Kiel ***

if not exist "%TEMP%\wsusscn2.cab" (
  .\bin\wget.exe -N -i .\static\StaticDownloadLinks-wsus.txt -P "%TEMP%"
)
if exist "%TEMP%\package.cab" del "%TEMP%\package.cab"
if exist "%TEMP%\package.xml" del "%TEMP%\package.xml"
%SystemRoot%\System32\expand.exe "%TEMP%\wsusscn2.cab" -F:package.cab "%TEMP%"
%SystemRoot%\System32\expand.exe "%TEMP%\package.cab" "%TEMP%\package.xml"
del "%TEMP%\package.cab"

%SystemRoot%\System32\cscript.exe //Nologo //B //E:vbs .\cmd\XSLT.vbs "%TEMP%\package.xml" .\xslt\ExtractUpdateCategoriesAndFileIds.xsl "%TEMP%\UpdateCategoriesAndFileIds.txt"
%SystemRoot%\System32\cscript.exe //Nologo //B //E:vbs .\cmd\XSLT.vbs "%TEMP%\package.xml" .\xslt\ExtractUpdateCabExeIdsAndLocations.xsl "%TEMP%\UpdateCabExeIdsAndLocations.txt"
.\bin\gsort.exe -u -T "%TEMP%" "%TEMP%\UpdateCabExeIdsAndLocations.txt" >"%TEMP%\UpdateCabExeIdsAndLocationsUnique.txt"
rem del "%TEMP%\UpdateCabExeIdsAndLocations.txt"
goto DoIt

:Determine
if exist "%TEMP%\OfficeFileAndUpdateIds.txt" del "%TEMP%\OfficeFileAndUpdateIds.txt"
set UPDATE_ID=
set UPDATE_CATEGORY=
set UPDATE_LANGUAGES=
for /F "usebackq tokens=1,2 delims=;" %%i in ("%TEMP%\UpdateCategoriesAndFileIds.txt") do (
  if "%%j"=="" (
    if "!UPDATE_CATEGORY!"=="477b856e-65c4-4473-b621-a8b230bb70d9" (
      for /F "tokens=1-3 delims=," %%k in ("%%i") do (
        if "%%l" NEQ "" (
          if /i "%2"=="glb" (
            if "!UPDATE_LANGUAGES!_%%m"=="_" (
              echo %%l,!UPDATE_ID!>>"%TEMP%\OfficeFileAndUpdateIds.txt"
            )
            if "!UPDATE_LANGUAGES!_%%m"=="en_en" (
              echo %%l,!UPDATE_ID!>>"%TEMP%\OfficeFileAndUpdateIds.txt"
            )
          ) else (
            if "%%m"=="%3" (
              echo %%l,!UPDATE_ID!>>"%TEMP%\OfficeFileAndUpdateIds.txt"
            )
          )
        )
      )
    )
  ) else (
    for /F "tokens=1 delims=," %%k in ("%%i") do (
      set UPDATE_ID=%%k
    )
    for /F "tokens=1* delims=," %%k in ("%%j") do (
      set UPDATE_CATEGORY=%%k
      set UPDATE_LANGUAGES=%%l
    )
  )
)
set UPDATE_ID=
set UPDATE_CATEGORY=
set UPDATE_LANGUAGES=
rem del "%TEMP%\UpdateCategoriesAndFileIds.txt"

%SystemRoot%\System32\cscript.exe //Nologo //B //E:vbs .\cmd\ExtractIdsAndFileNames.vbs "%TEMP%\OfficeFileAndUpdateIds.txt" "%TEMP%\OfficeFileIds.txt" /firstonly
.\bin\gsort.exe -u -T "%TEMP%" "%TEMP%\OfficeFileIds.txt" >"%TEMP%\OfficeFileIdsUnique.txt"
rem del "%TEMP%\OfficeFileIds.txt"
.\bin\gsort.exe -u -T "%TEMP%" "%TEMP%\OfficeFileAndUpdateIds.txt" >"%TEMP%\OfficeFileAndUpdateIdsUnique.txt"
rem del "%TEMP%\OfficeFileAndUpdateIds.txt"
.\bin\join.exe -t "," "%TEMP%\OfficeFileIdsUnique.txt" "%TEMP%\UpdateCabExeIdsAndLocationsUnique.txt" >"%TEMP%\OfficeUpdateCabExeIdsAndLocationsUnique.txt"
rem del "%TEMP%\OfficeFileIdsUnique.txt"
rem del "%TEMP%\UpdateCabExeIdsAndLocationsUnique.txt"
.\bin\join.exe -t "," -o "1.2" "%TEMP%\OfficeUpdateCabExeIdsAndLocationsUnique.txt" "%TEMP%\OfficeFileAndUpdateIdsUnique.txt" >"%TEMP%\DynamicDownloadLinks-%1-%2.txt"
.\bin\join.exe -t "," -o "2.2,1.2" "%TEMP%\OfficeUpdateCabExeIdsAndLocationsUnique.txt" "%TEMP%\OfficeFileAndUpdateIdsUnique.txt" >"%TEMP%\UpdateTableURL-%1-%2.csv"
rem del "%TEMP%\OfficeFileAndUpdateIdsUnique.txt"
rem del "%TEMP%\OfficeUpdateCabExeIdsAndLocationsUnique.txt"
%SystemRoot%\System32\cscript.exe //Nologo //B //E:vbs .\cmd\ExtractIdsAndFileNames.vbs "%TEMP%\UpdateTableURL-%1-%2.csv" "%TEMP%\UpdateTable-%1-%2.csv"
rem del "%TEMP%\UpdateTableURL-%1-%2.csv"
goto :EoF

:DoIt
call :Determine ofc enu en
call :Determine ofc deu de
call :Determine ofc glb
goto EoF

del "%TEMP%\package.xml"
del "%TEMP%\wsusscn2.cab"

:EoF
endlocal
