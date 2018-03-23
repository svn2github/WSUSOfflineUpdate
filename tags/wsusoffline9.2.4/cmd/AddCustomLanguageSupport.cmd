@echo off
rem *** Author: T. Wittrock, Kiel ***

verify other 2>nul
setlocal enableextensions
if errorlevel 1 goto NoExtensions

cd /D "%~dp0"

for %%i in (fra esn jpn kor rus ptg ptb nld ita chs cht plk hun csy sve trk ell ara heb dan nor fin) do if /i "%1"=="%%i" goto ValidParams
goto InvalidParams

:ValidParams
call RemoveCustomLanguageSupport.cmd %1 /quiet

rem *** Add support for %1 to .NET custom URL files ***
echo Adding support for %1 to .NET custom URL files...
for /F %%i in (..\static\StaticDownloadLinks-dotnet-x86-%1.txt) do (
  echo %%i | %SystemRoot%\System32\find.exe /I "dotNetFx40LP_Full_">>..\static\custom\StaticDownloadLinks-dotnet.txt
  echo %%i | %SystemRoot%\System32\find.exe /I "NDP46-KB3045557-">>..\static\custom\StaticDownloadLinks-dotnet.txt
  echo %%i | %SystemRoot%\System32\find.exe /I "NDP462-KB3151800-">>..\static\custom\StaticDownloadLinks-dotnet.txt
  echo %%i | %SystemRoot%\System32\find.exe /I "dotnetfx35langpack_x86">>..\static\custom\StaticDownloadLinks-dotnet-x86-glb.txt
)
for /F %%i in (..\static\StaticDownloadLinks-dotnet-x64-%1.txt) do (
  echo %%i | %SystemRoot%\System32\find.exe /I "dotnetfx35langpack_x64">>..\static\custom\StaticDownloadLinks-dotnet-x64-glb.txt
)
rem *** Add support for %1 to IEx custom URL files ***
echo Adding support for %1 to IEx custom URL files...
for %%i in (x86 x64) do (
  if exist ..\static\StaticDownloadLinks-ie8-w60-%%i-%1.txt (
    type ..\static\StaticDownloadLinks-ie8-w60-%%i-%1.txt >>..\static\custom\StaticDownloadLinks-w60-%%i-glb.txt
  )
  if exist ..\static\StaticDownloadLinks-ie9-w61-%%i-%1.txt (
    type ..\static\StaticDownloadLinks-ie9-w61-%%i-%1.txt >>..\static\custom\StaticDownloadLinks-w61-%%i-glb.txt
  )
)
rem *** Add support for %1 to MSSE custom URL files ***
echo Adding support for %1 to MSSE custom URL files...
for %%i in (x86 x64) do (
  if exist ..\static\StaticDownloadLinks-msse-%%i-%1.txt (
    type ..\static\StaticDownloadLinks-msse-%%i-%1.txt >>..\static\custom\StaticDownloadLinks-msse-%%i-glb.txt
  )
)
goto EoF

:NoExtensions
echo.
echo ERROR: No command extensions / delayed variable expansion available.
echo.
goto EoF

:InvalidParams
echo.
echo ERROR: Invalid parameter: %*
echo Usage: %~n0 {fra ^| esn ^| jpn ^| kor ^| rus ^| ptg ^| ptb ^| nld ^| ita ^| chs ^| cht ^| plk ^| hun ^| csy ^| sve ^| trk ^| ell ^| ara ^| heb ^| dan ^| nor ^| fin}
echo.
goto EoF

:EoF
endlocal
