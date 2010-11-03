@echo off
rem *** Author: T. Wittrock, RZ Uni Kiel ***

verify other 2>nul
setlocal enableextensions
if errorlevel 1 goto NoExtensions

%~d0
cd "%~p0"

for %%i in (all all-x86 all-x64 enu fra esn jpn kor rus ptg ptb deu nld ita chs cht plk hun csy sve trk ell ara heb dan nor fin) do (if /i "%1"=="%%i" goto V1EvalParams)
for %%i in (w2k wxp w2k3 w2k3-x64 oxp o2k3 o2k7 o2k7-x64) do (
  if /i "%1"=="%%i" (
    for %%j in (enu fra esn jpn kor rus ptg ptb deu nld ita chs cht plk hun csy sve trk ell ara heb dan nor fin) do (if /i "%2"=="%%j" goto V2EvalParams)
    goto V1EvalParams
  )
)
for %%i in (w60 w60-x64 w61 w61-x64) do (
  if /i "%1"=="%%i" (
    if /i "%2"=="glb" shift /2
    goto V1EvalParams
  )
)
goto InvalidParams

:V1EvalParams
if "%2"=="" goto V1CreateFilter
if /i "%2"=="/excludesp" set EXCLUDE_SP=1
if /i "%2"=="/includedotnet" set INCLUDE_DOTNET=1
if /i "%2"=="/includemsse" set INCLUDE_MSSE=1
if /i "%2"=="/outputpath" (
  if %3~==~ (goto InvalidParams) else (set OUTPUT_PATH=%~fs3)
  shift /2
)
shift /2
goto V1EvalParams

:V2EvalParams
if "%3"=="" goto V2CreateFilter
if /i "%3"=="/excludesp" set EXCLUDE_SP=1
if /i "%3"=="/includedotnet" set INCLUDE_DOTNET=1
if /i "%3"=="/includemsse" set INCLUDE_MSSE=1
if /i "%3"=="/outputpath" (
  if %4~==~ (goto InvalidParams) else (set OUTPUT_PATH=%~fs4)
  shift /3
)
shift /3
goto V2EvalParams

:CopyFilter
rem *** Copy ISO filter ***
if exist ..\exclude\ExcludeListISO-%1.txt (
  copy /Y ..\exclude\ExcludeListISO-%1.txt %ISO_FILTER% >nul
) else (
  copy /Y ..\exclude\ExcludeListISO-%1-x86.txt %ISO_FILTER% >nul
)
if exist ..\exclude\custom\ExcludeListISO-%1.txt (
  for /F %%i in (..\exclude\custom\ExcludeListISO-%1.txt) do echo %%i>>%ISO_FILTER%
)
if exist ..\exclude\custom\ExcludeListISO-%1-x86.txt (
  for /F %%i in (..\exclude\custom\ExcludeListISO-%1-x86.txt) do echo %%i>>%ISO_FILTER%
)
goto :eof

:LocaleFilter
for %%i in (enu fra esn jpn kor rus ptg ptb deu nld ita chs cht plk hun csy sve trk ell ara heb dan nor fin) do (
  if /i "%1" NEQ "%%i" (
    if /i "%%i"=="enu" (echo *%%i\/*>>%ISO_FILTER%) else (echo *%%i*>>%ISO_FILTER%)
  )
)
goto :eof

:ExtendFilter
if "%EXCLUDE_SP%"=="1" (
  for /F %%i in (..\exclude\ExcludeList-SPs.txt) do echo *%%i*>>%ISO_FILTER%
)
for %%i in (w2k oxp o2k3 o2k7 o2k7-x64) do (
  if /i "%1"=="%%i" (
    for /F %%j in (..\exclude\ExcludeList-dotnet.txt) do echo *%%j/*>>%ISO_FILTER%
    for /F %%j in (..\exclude\ExcludeList-msse.txt) do echo *%%j/*>>%ISO_FILTER%
  )
)
if "%INCLUDE_DOTNET%" NEQ "1" (
  for /F %%i in (..\exclude\ExcludeList-dotnet.txt) do echo *%%i/*>>%ISO_FILTER%
)
if "%INCLUDE_MSSE%" NEQ "1" (
  for /F %%i in (..\exclude\ExcludeList-msse.txt) do echo *%%i/*>>%ISO_FILTER%
)
goto :eof

:V1CreateFilter
rem *** Create ISO filter ***
echo Creating ISO filter for %1...
set ISO_FILTER="%TEMP%\ExcludeListISO-%1.txt"
for %%i in (all all-x86 all-x64 w2k wxp w2k3 w2k3-x64 w60 w60-x64 w61 w61-x64 oxp o2k3 o2k7 o2k7-x64) do (if /i "%1"=="%%i" goto V1CopyFilter)
set ISO_IMAGE=wsusoffline-%1-x86.iso
set ISO_VOLID=wou_%1-x86
copy /Y ..\exclude\ExcludeListISO-all-x86.txt %ISO_FILTER% >nul
if exist ..\exclude\custom\ExcludeListISO-all-x86.txt (
  for /F %%i in (..\exclude\custom\ExcludeListISO-all-x86.txt) do echo %%i>>%ISO_FILTER%
)
call :LocaleFilter %1 
call :ExtendFilter %1
goto CreateImage

:V1CopyFilter
set ISO_IMAGE=wsusoffline-%1.iso
set ISO_VOLID=wou_%1
call :CopyFilter %1
call :ExtendFilter %1
goto CreateImage

:V2CreateFilter
rem *** Create ISO filter ***
echo Creating ISO filter for %1 %2...
set ISO_FILTER="%TEMP%\ExcludeListISO-%1-%2.txt"
set ISO_IMAGE=wsusoffline-%1-%2.iso
set ISO_VOLID=wou_%1_%2
call :CopyFilter %1
call :LocaleFilter %2 
call :ExtendFilter %1
goto CreateImage

:CreateImage
rem *** Create ISO image ***
if %OUTPUT_PATH%~==~ set OUTPUT_PATH=..\iso
if not exist %OUTPUT_PATH%\nul goto NoOutputPath
if not exist ..\bin\mkisofs.exe goto NoMkIsoFs
title Creating ISO image %OUTPUT_PATH%\%ISO_IMAGE%...
echo Creating ISO image %OUTPUT_PATH%\%ISO_IMAGE%...
if exist %OUTPUT_PATH%\%ISO_IMAGE% del %OUTPUT_PATH%\%ISO_IMAGE%
..\bin\mkisofs.exe -iso-level 4 -joliet -joliet-long -rational-rock -exclude-list %ISO_FILTER% -output %OUTPUT_PATH%\%ISO_IMAGE% -volid %ISO_VOLID% ..\client
if errorlevel 1 goto MkIsoError
if exist %ISO_FILTER% del %ISO_FILTER%
goto EoF

:NoExtensions
echo.
echo ERROR: No command extensions available.
echo.
exit /b 1

:InvalidParams
echo.
echo ERROR: Invalid parameter: %*
echo Usage1: %~n0 {w2k ^| wxp ^| w2k3 ^| w2k3-x64 ^| oxp ^| o2k3 ^| o2k7 ^| o2k7-x64} {enu ^| fra ^| esn ^| jpn ^| kor ^| rus ^| ptg ^| ptb ^| deu ^| nld ^| ita ^| chs ^| cht ^| plk ^| hun ^| csy ^| sve ^| trk ^| ell ^| ara ^| heb ^| dan ^| nor ^| fin} [/excludesp] [/includedotnet] [/outputpath ^<OutputPath^>]
echo Usage2: %~n0 {all ^| all-x86 ^| all-x64 ^| w2k ^| wxp ^| w2k3 ^| w2k3-x64 ^| w60 ^| w60-x64 ^| w61 ^| w61-x64 ^| oxp ^| o2k3 ^| o2k7 ^| o2k7-x64 ^| enu ^| fra ^| esn ^| jpn ^| kor ^| rus ^| ptg ^| ptb ^| deu ^| nld ^| ita ^| chs ^| cht ^| plk ^| hun ^| csy ^| sve ^| trk ^| ell ^| ara ^| heb ^| dan ^| nor ^| fin} [/excludesp] [/includedotnet] [/outputpath ^<OutputPath^>]
echo.
goto Error

:NoOutputPath
echo.
echo ERROR: Output path %OUTPUT_PATH% not found.
echo.
goto Error

:NoMkIsoFs
echo.
echo ERROR: Utility ..\bin\mkisofs.exe not found.
echo.
goto Error

:MkIsoError
echo.
echo ERROR: Creation of ISO image failed.
echo.
goto Error

:Error
if exist %ISO_FILTER% del %ISO_FILTER%
set MKISO_ERROR=1 

:EoF
title %ComSpec%
if "%MKISO_ERROR%"=="1" verify other 2>nul
endlocal