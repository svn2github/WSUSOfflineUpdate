@echo off
rem *** Author: T. Wittrock, Kiel ***

verify other 2>nul
setlocal enableextensions
if errorlevel 1 goto NoExtensions

cd /D "%~dp0"

rem *** Remove support for deu from static URL files ***
pushd ..\static
echo Removing support for deu from static URL files...
for %%i in (dotnet msse w60 w61) do (
  for %%j in (x86 x64) do (
    if exist StaticDownloadLinks-%%i-%%j-glb.txt (
      echo Processing file ..\static\StaticDownloadLinks-%%i-%%j-glb.txt
      if exist StaticDownloadLinks-%%i-%%j-glb.ori del StaticDownloadLinks-%%i-%%j-glb.ori
      ren StaticDownloadLinks-%%i-%%j-glb.txt StaticDownloadLinks-%%i-%%j-glb.ori  
      %SystemRoot%\System32\findstr.exe /L /I /V "deu. de." StaticDownloadLinks-%%i-%%j-glb.ori>StaticDownloadLinks-%%i-%%j-glb.txt
      del StaticDownloadLinks-%%i-%%j-glb.ori
      for %%k in (StaticDownloadLinks-%%i-%%j-glb.txt) do if %%~zk==0 del %%k
    )
    if exist StaticDownloadLinks-%%i-%%j-5lg.txt (
      echo Processing file ..\static\StaticDownloadLinks-%%i-%%j-5lg.txt
      if exist StaticDownloadLinks-%%i-%%j-5lg.ori del StaticDownloadLinks-%%i-%%j-5lg.ori
      ren StaticDownloadLinks-%%i-%%j-5lg.txt StaticDownloadLinks-%%i-%%j-5lg.ori  
      %SystemRoot%\System32\findstr.exe /L /I /V "deu. de." StaticDownloadLinks-%%i-%%j-5lg.ori>StaticDownloadLinks-%%i-%%j-5lg.txt
      del StaticDownloadLinks-%%i-%%j-5lg.ori
      for %%k in (StaticDownloadLinks-%%i-%%j-5lg.txt) do if %%~zk==0 del %%k
    )
    if exist StaticDownloadLinks-%%i-%%j-alg.txt (
      echo Processing file ..\static\StaticDownloadLinks-%%i-%%j-alg.txt
      if exist StaticDownloadLinks-%%i-%%j-alg.ori del StaticDownloadLinks-%%i-%%j-alg.ori
      ren StaticDownloadLinks-%%i-%%j-alg.txt StaticDownloadLinks-%%i-%%j-alg.ori  
      %SystemRoot%\System32\findstr.exe /L /I /V "deu. de." StaticDownloadLinks-%%i-%%j-alg.ori>StaticDownloadLinks-%%i-%%j-alg.txt
      del StaticDownloadLinks-%%i-%%j-alg.ori
      for %%k in (StaticDownloadLinks-%%i-%%j-alg.txt) do if %%~zk==0 del %%k
    )
  )
)
if exist StaticDownloadLinks-dotnet.txt (
  echo Processing file ..\static\StaticDownloadLinks-dotnet.txt
  if exist StaticDownloadLinks-dotnet.ori del StaticDownloadLinks-dotnet.ori
  ren StaticDownloadLinks-dotnet.txt StaticDownloadLinks-dotnet.ori  
  %SystemRoot%\System32\findstr.exe /L /I /V "deu. de." StaticDownloadLinks-dotnet.ori>StaticDownloadLinks-dotnet.txt
  del StaticDownloadLinks-dotnet.ori
  for %%k in (StaticDownloadLinks-dotnet.txt) do if %%~zk==0 del %%k
)
popd
goto EoF

:NoExtensions
echo.
echo ERROR: No command extensions / delayed variable expansion available.
echo.
goto EoF

:EoF
endlocal
