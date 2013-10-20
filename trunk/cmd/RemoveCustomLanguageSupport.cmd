@echo off
rem *** Author: T. Wittrock, Kiel ***

verify other 2>nul
setlocal enableextensions
if errorlevel 1 goto NoExtensions

cd /D "%~dp0"

for %%i in (fra esn jpn kor rus ptg ptb nld ita chs cht plk hun csy sve trk ell ara heb dan nor fin) do if /i "%1"=="%%i" goto ValidParams
goto InvalidParams

:ValidParams
rem *** Remove support for %1 from .NET custom URL files ***
if /i "%2" NEQ "/quiet" echo Removing support for %1 from .NET custom URL files...
for %%i in (x86 x64) do (
  for /F %%j in (..\static\StaticDownloadLinks-dotnet-%%i-%1.txt) do (
    if exist ..\static\custom\StaticDownloadLinks-dotnet.txt (
      ren ..\static\custom\StaticDownloadLinks-dotnet.txt StaticDownloadLinks-dotnet.tmp
      %SystemRoot%\System32\findstr.exe /L /I /V "%%~nxj" ..\static\custom\StaticDownloadLinks-dotnet.tmp>..\static\custom\StaticDownloadLinks-dotnet.txt
      del ..\static\custom\StaticDownloadLinks-dotnet.tmp
    )
    if exist ..\static\custom\StaticDownloadLinks-dotnet-%%i-glb.txt (
      ren ..\static\custom\StaticDownloadLinks-dotnet-%%i-glb.txt StaticDownloadLinks-dotnet-%%i-glb.tmp
      %SystemRoot%\System32\findstr.exe /L /I /V "%%~nxj" ..\static\custom\StaticDownloadLinks-dotnet-%%i-glb.tmp>..\static\custom\StaticDownloadLinks-dotnet-%%i-glb.txt
      del ..\static\custom\StaticDownloadLinks-dotnet-%%i-glb.tmp
    )
  )
  for %%j in (..\static\custom\StaticDownloadLinks-dotnet.txt) do if %%~zj==0 del %%j
  for %%j in (..\static\custom\StaticDownloadLinks-dotnet-%%i-glb.txt) do if %%~zj==0 del %%j
)
rem *** Remove support for %1 from IEx custom URL files ***
if /i "%2" NEQ "/quiet" echo Removing support for %1 from IEx custom URL files...
for %%i in (x86 x64) do (
  for /F %%j in (..\static\StaticDownloadLinks-ie8-w60-%%i-%1.txt) do (
    if exist ..\static\custom\StaticDownloadLinks-w60-%%i-glb.txt (
      ren ..\static\custom\StaticDownloadLinks-w60-%%i-glb.txt StaticDownloadLinks-w60-%%i-glb.tmp
      %SystemRoot%\System32\findstr.exe /L /I /V "%%~nxj" ..\static\custom\StaticDownloadLinks-w60-%%i-glb.tmp>..\static\custom\StaticDownloadLinks-w60-%%i-glb.txt
      del ..\static\custom\StaticDownloadLinks-w60-%%i-glb.tmp
    )
  )
  for %%j in (..\static\custom\StaticDownloadLinks-w60-%%i-glb.txt) do if %%~zj==0 del %%j
  for /F %%j in (..\static\StaticDownloadLinks-ie9-w61-%%i-%1.txt) do (
    if exist ..\static\custom\StaticDownloadLinks-w61-%%i-glb.txt (
      ren ..\static\custom\StaticDownloadLinks-w61-%%i-glb.txt StaticDownloadLinks-w61-%%i-glb.tmp
      %SystemRoot%\System32\findstr.exe /L /I /V "%%~nxj" ..\static\custom\StaticDownloadLinks-w61-%%i-glb.tmp>..\static\custom\StaticDownloadLinks-w61-%%i-glb.txt
      del ..\static\custom\StaticDownloadLinks-w61-%%i-glb.tmp
    )
  )
  for %%j in (..\static\custom\StaticDownloadLinks-w61-%%i-glb.txt) do if %%~zj==0 del %%j
)
rem *** Remove support for %1 from MSSE custom URL files ***
if /i "%2" NEQ "/quiet" echo Removing support for %1 from MSSE custom URL files...
for %%i in (x86 x64) do (
  if exist ..\static\StaticDownloadLinks-msse-%%i-%1.txt (
    for /F %%j in (..\static\StaticDownloadLinks-msse-%%i-%1.txt) do (
      if exist ..\static\custom\StaticDownloadLinks-msse-%%i-glb.txt (
        ren ..\static\custom\StaticDownloadLinks-msse-%%i-glb.txt StaticDownloadLinks-msse-%%i-glb.tmp
        %SystemRoot%\System32\findstr.exe /L /I /V "%%~nxj" ..\static\custom\StaticDownloadLinks-msse-%%i-glb.tmp>..\static\custom\StaticDownloadLinks-msse-%%i-glb.txt
        del ..\static\custom\StaticDownloadLinks-msse-%%i-glb.tmp
      )
    )
    for %%j in (..\static\custom\StaticDownloadLinks-msse-%%i-glb.txt) do if %%~zj==0 del %%j
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
