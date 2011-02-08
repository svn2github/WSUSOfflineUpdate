@echo off

setlocal enabledelayedexpansion
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

"%TEMP%\msxsl.exe" "%TEMP%\package.xml" .\xslt\ExtractUpdateCategoriesAndFileIds.xsl -o "%TEMP%\UpdateCategoriesAndFileIds.txt"
"%TEMP%\msxsl.exe" "%TEMP%\package.xml" .\xslt\ExtractUpdateCabExeIdsAndLocations.xsl -o "%TEMP%\UpdateCabExeIdsAndLocations.txt"
goto DoIt

:Determine
if exist "%TEMP%\OfficeUpdateAndFileIds.txt" del "%TEMP%\OfficeUpdateAndFileIds.txt"
if exist "%TEMP%\OfficeFileIds.txt" del "%TEMP%\OfficeFileIds.txt"
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
              echo !UPDATE_ID!,%%l>>"%TEMP%\OfficeUpdateAndFileIds.txt"
              echo %%l>>"%TEMP%\OfficeFileIds.txt"
            )
            if "!UPDATE_LANGUAGES!_%%m"=="en_en" (
              echo !UPDATE_ID!,%%l>>"%TEMP%\OfficeUpdateAndFileIds.txt"
              echo %%l>>"%TEMP%\OfficeFileIds.txt"
            )
          ) else (
            if "%%m"=="%3" (
              echo !UPDATE_ID!,%%l>>"%TEMP%\OfficeUpdateAndFileIds.txt"
              echo %%l>>"%TEMP%\OfficeFileIds.txt"
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

%SystemRoot%\system32\findstr.exe /B /G:"%TEMP%\OfficeFileIds.txt" "%TEMP%\UpdateCabExeIdsAndLocations.txt" >"%TEMP%\OfficeUpdateCabExeIdsAndLocations.txt"
rem del "%TEMP%\OfficeFileIds.txt"
rem del "%TEMP%\UpdateCabExeIdsAndLocations.txt"

if exist "%TEMP%\DownloadLinks-%1-%2.txt" del "%TEMP%\DownloadLinks-%1-%2.txt"
if exist "%TEMP%\UpdateTable-%1-%2.csv" del "%TEMP%\UpdateTable-%1-%2.csv"
for /F "usebackq tokens=1,2 delims=," %%i in ("%TEMP%\OfficeUpdateCabExeIdsAndLocations.txt") do (
  for /F "usebackq tokens=1,2 delims=," %%k in ("%TEMP%\OfficeUpdateAndFileIds.txt") do (
    if /i "%%l"=="%%i" (
      echo %%j>>"%TEMP%\DownloadLinks-%1-%2.txt"
      echo %%k,%%~nj>>"%TEMP%\UpdateTable-%1-%2.csv"
    )
  )
)
rem del "%TEMP%\OfficeUpdateAndFileIds.txt"
rem del "%TEMP%\OfficeUpdateCabExeIdsAndLocations.txt"
goto :EoF

:DoIt
call :Determine ofc enu en
call :Determine ofc deu de
call :Determine ofc glb
goto EoF

del "%TEMP%\msxsl.exe"
del "%TEMP%\wsusscn2.cab"
del "%TEMP%\package.xml"

:EoF
endlocal
