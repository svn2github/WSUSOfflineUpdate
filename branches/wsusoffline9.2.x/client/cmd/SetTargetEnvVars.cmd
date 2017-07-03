@echo off
rem *** Author: T. Wittrock, Kiel ***

if "%OS_VER_MAJOR%"=="" goto NoOSVersion

set WUA_VER_TARGET_MAJOR=7
set WUA_VER_TARGET_MINOR=4
set WUA_VER_TARGET_BUILD=7600
set WUA_VER_TARGET_REVIS=226

set MSI_VER_TARGET_BUILD=0
set MSI_VER_TARGET_REVIS=0

set WSH_VER_TARGET_BUILD=0
set WSH_VER_TARGET_REVIS=0

set DX_CORE_VER_TARGET_MAJOR=4
set DX_CORE_VER_TARGET_MINOR=09
set DX_CORE_VER_TARGET_BUILD=00
set DX_CORE_VER_TARGET_REVIS=0904
set DX_DLL_LATEST=%SystemRoot%\System32\D3DX9_43.dll

set IE_VER_TARGET_BUILD=0
set IE_VER_TARGET_REVIS=0

set WMP_VER_TARGET_MINOR=0
set WMP_VER_TARGET_BUILD=0
set WMP_VER_TARGET_REVIS=0

set TSC_VER_TARGET_BUILD=0
set TSC_VER_TARGET_REVIS=0

set DOTNET35_VER_TARGET_MAJOR=3
set DOTNET35_VER_TARGET_MINOR=5
set DOTNET35_VER_TARGET_BUILD=30729
set DOTNET35_VER_TARGET_REVIS=1

set DOTNET4_VER_TARGET_MAJOR=4
set DOTNET4_VER_TARGET_REVIS=0

set PSH_VER_TARGET_MAJOR=2
set PSH_VER_TARGET_MINOR=0
set PSH_TARGET_ID=968930

if %OS_VER_MAJOR% LSS 5 goto SetOfficeName
if %OS_VER_MAJOR% GTR 6 goto SetOfficeName
if %OS_VER_MINOR% GTR 3 goto SetOfficeName
goto Windows%OS_VER_MAJOR%.%OS_VER_MINOR%

:Windows5.0
rem *** Windows 2000 ***
set OS_NAME=w2k
goto SetOfficeName

:Windows5.1
rem *** Windows XP ***
set OS_NAME=wxp
set OS_SP_VER_TARGET_MAJOR=3
set OS_SP_TARGET_ID=936929
set MSI_VER_TARGET_MAJOR=4
set MSI_VER_TARGET_MINOR=5
set MSI_TARGET_ID=942288
set WSH_VER_TARGET_MAJOR=5
set WSH_VER_TARGET_MINOR=7
if /i "%INSTALL_IE%"=="/instielatest" set INSTALL_IE=/instie8
if /i "%INSTALL_IE%"=="/instie8" (set IE_VER_TARGET_MAJOR=8) else (
  if /i "%INSTALL_IE%"=="/instie7" (set IE_VER_TARGET_MAJOR=7) else (set IE_VER_TARGET_MAJOR=6)
)
set IE_VER_TARGET_MINOR=0
set DOTNET4_VER_TARGET_MINOR=0
set DOTNET4_VER_TARGET_BUILD=30319
set WMP_VER_TARGET_MAJOR=11
set WMP_TARGET_ID=wmp11-windowsxp-x86
set TSC_VER_TARGET_MAJOR=6
set TSC_VER_TARGET_MINOR=1
set TSC_TARGET_ID=969084
set WOU_ENDLESS=3
goto SetOfficeName

:Windows5.2
rem *** Windows Server 2003 ***
set OS_NAME=w2k3
set OS_SP_VER_TARGET_MAJOR=2
set OS_SP_TARGET_ID=914961
set MSI_VER_TARGET_MAJOR=4
set MSI_VER_TARGET_MINOR=5
set MSI_TARGET_ID=942288
set WSH_VER_TARGET_MAJOR=5
if /i "%OS_ARCH%"=="x64" (
  set WSH_VER_TARGET_MINOR=6
) else (
  set WSH_VER_TARGET_MINOR=7
)
if /i "%INSTALL_IE%"=="/instielatest" set INSTALL_IE=/instie8
if /i "%INSTALL_IE%"=="/instie8" (set IE_VER_TARGET_MAJOR=8) else (
  if /i "%INSTALL_IE%"=="/instie7" (set IE_VER_TARGET_MAJOR=7) else (set IE_VER_TARGET_MAJOR=6)
)
set IE_VER_TARGET_MINOR=0
set DOTNET4_VER_TARGET_MINOR=0
set DOTNET4_VER_TARGET_BUILD=30319
set WMP_VER_TARGET_MAJOR=0
if /i "%OS_ARCH%"=="x64" (
  set TSC_VER_TARGET_MAJOR=5
  set TSC_VER_TARGET_MINOR=2
  set WOU_ENDLESS=3
) else (
  set TSC_VER_TARGET_MAJOR=6
  set TSC_VER_TARGET_MINOR=0
  set TSC_TARGET_ID=925876
  if exist "%TEMP%\wou_ie_kbids.txt" del "%TEMP%\wou_ie_kbids.txt"
  for /F %%i in ('dir /B /S ..\ie*-kb???????-*.exe') do (
    for /F "tokens=3 delims=-" %%j in ("%%~ni") do echo %%j>>"%TEMP%\wou_ie_kbids.txt"
  )
  if exist "%TEMP%\wou_ie_kbids.txt" (
    for %%i in ("%TEMP%\wou_ie_kbids.txt") do (
      if %%~zi==0 del %%i
    )
  )
  if exist "%TEMP%\wou_ie_kbids.txt" (
    %SystemRoot%\System32\sort.exe "%TEMP%\wou_ie_kbids.txt" /O "%TEMP%\wou_ie_kbids_sorted.txt"
    del "%TEMP%\wou_ie_kbids.txt"
    for /F "usebackq" %%i in ("%TEMP%\wou_ie_kbids_sorted.txt") do (
      set WUSCN_PREREQ_ID=%%i
    )
    del "%TEMP%\wou_ie_kbids_sorted.txt"
  ) else (
    set WUSCN_PREREQ_ID=kb2909921
  )
  set WOU_ENDLESS=4
)
if "%WUSCN_PREREQ_ID%" NEQ "" set WUSCN_PREREQ_ID=%WUSCN_PREREQ_ID:~2%
goto SetOfficeName

:Windows6.0
rem *** Windows Vista / Server 2008 ***
set OS_NAME=w60
set MSI_VER_TARGET_MAJOR=4
set MSI_VER_TARGET_MINOR=5
set WSH_VER_TARGET_MAJOR=5
set WSH_VER_TARGET_MINOR=7
if /i "%INSTALL_IE%"=="/instielatest" set INSTALL_IE=/instie9
if /i "%INSTALL_IE%"=="/instie9" (set IE_VER_TARGET_MAJOR=9) else (
  if /i "%INSTALL_IE%"=="/instie8" (set IE_VER_TARGET_MAJOR=8) else (set IE_VER_TARGET_MAJOR=7)
)
set IE_VER_TARGET_MINOR=0
set DOTNET4_VER_TARGET_MINOR=5
set DOTNET4_VER_TARGET_BUILD=50938
set WMP_VER_TARGET_MAJOR=11
if %OS_DOMAIN_ROLE% LEQ 1 (
  set TSC_VER_TARGET_MAJOR=6
  set TSC_VER_TARGET_MINOR=1
  set TSC_TARGET_ID=969084
) else (
  set TSC_VER_TARGET_MAJOR=6
  set TSC_VER_TARGET_MINOR=0
)
set WMF_VER_TARGET_MAJOR=3
set WMF_VER_TARGET_MINOR=0
set WMF_TARGET_ID=2506146
set WOU_ENDLESS=6
goto Windows%OS_VER_MAJOR%.%OS_VER_MINOR%.%OS_SP_VER_MAJOR%
:Windows6.0.
:Windows6.0.0
set OS_SP_VER_TARGET_MAJOR=1
set OS_SP_TARGET_ID=936330
goto SetOfficeName
:Windows6.0.1
:Windows6.0.2
set OS_SP_VER_TARGET_MAJOR=2
set OS_SP_TARGET_ID=948465
goto SetOfficeName

:Windows6.1
rem *** Windows 7 / Server 2008 R2 ***
set OS_NAME=w61
set OS_SP_VER_TARGET_MAJOR=1
set OS_SP_TARGET_ID=976932
set MSI_VER_TARGET_MAJOR=5
set MSI_VER_TARGET_MINOR=0
set WSH_VER_TARGET_MAJOR=5
set WSH_VER_TARGET_MINOR=8
if /i "%INSTALL_IE%"=="/instielatest" set INSTALL_IE=/instie11
if /i "%INSTALL_IE%"=="/instie11" (
  set IE_VER_TARGET_MAJOR=9
  set IE_VER_TARGET_MINOR=11
) else (
  if /i "%INSTALL_IE%"=="/instie10" (
    set IE_VER_TARGET_MAJOR=9
    set IE_VER_TARGET_MINOR=10
  ) else (
    if /i "%INSTALL_IE%"=="/instie9" (
      set IE_VER_TARGET_MAJOR=9
      set IE_VER_TARGET_MINOR=0
    ) else (
      set IE_VER_TARGET_MAJOR=8
      set IE_VER_TARGET_MINOR=0
    )
  )
)
set DOTNET4_VER_TARGET_MINOR=5
set DOTNET4_VER_TARGET_BUILD=50938
set WMP_VER_TARGET_MAJOR=12
set TSC_VER_TARGET_MAJOR=6
set TSC_VER_TARGET_MINOR=3
set TSC_TARGET_ID_FILE=..\static\StaticUpdateIds-rdc-w61.txt
set WMF_VER_TARGET_MAJOR=4
set WMF_VER_TARGET_MINOR=0
set WMF_TARGET_ID=2819745
set WOU_ENDLESS=5
goto SetOfficeName

:Windows6.2
rem *** Windows 8 / Server 2012 ***
set OS_NAME=w62
set OS_SP_VER_TARGET_MAJOR=0
set MSI_VER_TARGET_MAJOR=5
set MSI_VER_TARGET_MINOR=0
set WSH_VER_TARGET_MAJOR=5
set WSH_VER_TARGET_MINOR=8
set IE_VER_TARGET_MAJOR=9
set IE_VER_TARGET_MINOR=10
set DOTNET4_VER_TARGET_MINOR=5
set DOTNET4_VER_TARGET_BUILD=50938
set WMP_VER_TARGET_MAJOR=12
set TSC_VER_TARGET_MAJOR=6
set TSC_VER_TARGET_MINOR=2
set WMF_VER_TARGET_MAJOR=4
set WMF_VER_TARGET_MINOR=0
set WMF_TARGET_ID=2799888
set WOU_ENDLESS=2
goto SetOfficeName

:Windows6.3
rem *** Windows 8.1 / Server 2012 R2 ***
set OS_NAME=w63
set OS_SP_VER_TARGET_MAJOR=0
set OS_SP_TARGET_ID=2919355
set MSI_VER_TARGET_MAJOR=5
set MSI_VER_TARGET_MINOR=0
set WSH_VER_TARGET_MAJOR=5
set WSH_VER_TARGET_MINOR=8
set IE_VER_TARGET_MAJOR=9
set IE_VER_TARGET_MINOR=11
set DOTNET4_VER_TARGET_MINOR=5
set DOTNET4_VER_TARGET_BUILD=50760
set WMP_VER_TARGET_MAJOR=12
set TSC_VER_TARGET_MAJOR=6
set TSC_VER_TARGET_MINOR=3
set WMF_VER_TARGET_MAJOR=4
set WMF_VER_TARGET_MINOR=0
set WOU_ENDLESS=2
goto SetOfficeName

:SetOfficeName
if "%O2K3_VER_MAJOR%"=="" goto NoO2k3
rem *** Office 2003 ***
set OFC_NAME=o2k3
set OFC_ARCH=%O2K3_ARCH%
set OFC_LANG=%O2K3_LANG%
set O2K3_SP_VER_TARGET=3
set O2K3_SP_TARGET_ID=923618
:NoO2k3
if "%O2K7_VER_MAJOR%"=="" goto NoO2k7
rem *** Office 2007 ***
set OFC_NAME=o2k7
set OFC_ARCH=%O2K7_ARCH%
set OFC_LANG=%O2K7_LANG%
set O2K7_SP_VER_TARGET=3
set O2K7_SP_TARGET_ID=2526086
:NoO2k7
if "%O2K10_VER_MAJOR%"=="" goto NoO2k10
rem *** Office 2010 ***
set OFC_NAME=o2k10
set OFC_ARCH=%O2K10_ARCH%
set OFC_LANG=%O2K10_LANG%
set O2K10_SP_VER_TARGET=2
set O2K10_SP_TARGET_ID=2687455-fullfile-%O2K10_ARCH%
:NoO2k10
if "%O2K13_VER_MAJOR%"=="" goto NoO2k13
rem *** Office 2013 ***
set OFC_NAME=o2k13
set OFC_ARCH=%O2K13_ARCH%
set OFC_LANG=%O2K13_LANG%
set O2K13_SP_VER_TARGET=1
set O2K13_SP_TARGET_ID=2817430-fullfile-%O2K13_ARCH%
:NoO2k13
goto EoF

:NoOSVersion
echo.
echo ERROR: Environment variable OS_VER_MAJOR not set.
echo.
exit /b 1

:EoF
