@echo off
rem *** Author: T. Wittrock, Kiel ***

if "%OS_RAM_GB%"=="" (
  if /i "%OS_ARCH%"=="x86" (set UPDATES_PER_STAGE=60) else (set UPDATES_PER_STAGE=40)
) else (
  if /i "%OS_ARCH%"=="x86" (set /A UPDATES_PER_STAGE=OS_RAM_GB*60) else (set /A UPDATES_PER_STAGE=OS_RAM_GB*40)
)
if exist .\custom\SetUpdatesPerStage.cmd call .\custom\SetUpdatesPerStage.cmd
if %UPDATES_PER_STAGE% LSS 40 set UPDATES_PER_STAGE=40

set MSI_VER_TARGET_BUILD=0
set MSI_VER_TARGET_REVIS=0

set WSH_VER_TARGET_BUILD=0
set WSH_VER_TARGET_REVIS=0

set IE_VER_TARGET_BUILD=0
set IE_VER_TARGET_REVIS=0

set DOTNET35_VER_TARGET_MAJOR=3
set DOTNET35_VER_TARGET_MINOR=5
set DOTNET35_VER_TARGET_BUILD=30729
set DOTNET35_VER_TARGET_REVIS=1

set DOTNET4_VER_TARGET_MAJOR=4
set DOTNET4_VER_TARGET_MINOR=6
set DOTNET4_VER_TARGET_BUILD=01500
set DOTNET4_VER_TARGET_REVIS=0

set PSH_VER_TARGET_MAJOR=2
set PSH_VER_TARGET_MINOR=0
set PSH_TARGET_ID=968930

set WMF_VER_TARGET_MAJOR=5
set WMF_VER_TARGET_MINOR=1

set TSC_VER_TARGET_BUILD=0
set TSC_VER_TARGET_REVIS=0

if %OS_VER_MAJOR% LSS 5 goto SetOfficeName
if %OS_VER_MAJOR% GTR 10 goto SetOfficeName
if %OS_VER_MINOR% GTR 3 goto SetOfficeName
goto Windows%OS_VER_MAJOR%.%OS_VER_MINOR%

:Windows5.0
rem *** Windows 2000 ***
set OS_NAME=w2k
goto SetOfficeName

:Windows5.1
rem *** Windows XP ***
set OS_NAME=wxp
goto SetOfficeName

:Windows5.2
rem *** Windows Server 2003 ***
set OS_NAME=w2k3
goto SetOfficeName

:Windows6.0
rem *** Windows Server 2008 ***
set OS_NAME=w60
set MSI_VER_TARGET_MAJOR=4
set MSI_VER_TARGET_MINOR=5
set WSH_VER_TARGET_MAJOR=5
set WSH_VER_TARGET_MINOR=7
set IE_VER_TARGET_MAJOR=9
set IE_VER_TARGET_MINOR=0
if %OS_DOMAIN_ROLE% LEQ 1 (
  set TSC_VER_TARGET_MAJOR=6
  set TSC_VER_TARGET_MINOR=1
  set TSC_TARGET_ID=969084
) else (
  set TSC_VER_TARGET_MAJOR=6
  set TSC_VER_TARGET_MINOR=0
)
set DOTNET4_VER_TARGET_BUILD=00081
set WMF_VER_TARGET_MAJOR=3
set WMF_VER_TARGET_MINOR=0
set WMF_TARGET_ID=2506146
set WOU_ENDLESS=9
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
set IE_VER_TARGET_MAJOR=9
set IE_VER_TARGET_MINOR=11
set WMF_TARGET_ID=3191566
set TSC_VER_TARGET_MAJOR=6
set TSC_VER_TARGET_MINOR=3
set TSC_TARGET_ID_FILE=..\static\StaticUpdateIds-rdc-w61.txt
set WOU_ENDLESS=9
goto SetOfficeName

:Windows6.2
rem *** Windows Server 2012 ***
set OS_NAME=w62
set OS_SP_VER_TARGET_MAJOR=0
set MSI_VER_TARGET_MAJOR=5
set MSI_VER_TARGET_MINOR=0
set WSH_VER_TARGET_MAJOR=5
set WSH_VER_TARGET_MINOR=8
set IE_VER_TARGET_MAJOR=9
set IE_VER_TARGET_MINOR=10
set WMF_TARGET_ID=3191565
set TSC_VER_TARGET_MAJOR=6
set TSC_VER_TARGET_MINOR=2
set WOU_ENDLESS=6
goto SetOfficeName

:Windows6.3
rem *** Windows 8.1 / Server 2012 R2 ***
set OS_NAME=w63
set OS_SP_VER_TARGET_MAJOR=0
set OS_SP_PREREQ_ID=2975061
set OS_SP_TARGET_ID=2919355
set OS_UPD1_TARGET_REVIS=17041
set OS_UPD2_TARGET_REVIS=17415
set MSI_VER_TARGET_MAJOR=5
set MSI_VER_TARGET_MINOR=0
set WSH_VER_TARGET_MAJOR=5
set WSH_VER_TARGET_MINOR=8
set IE_VER_TARGET_MAJOR=9
set IE_VER_TARGET_MINOR=11
set WMF_TARGET_ID=3191564
set TSC_VER_TARGET_MAJOR=6
set TSC_VER_TARGET_MINOR=3
set WOU_ENDLESS=6
goto SetOfficeName

:Windows10.0
rem *** Windows 10.0 / Server 2016 ***
set OS_NAME=w100
set OS_SP_VER_TARGET_MAJOR=0
set MSI_VER_TARGET_MAJOR=5
set MSI_VER_TARGET_MINOR=0
set WSH_VER_TARGET_MAJOR=5
set WSH_VER_TARGET_MINOR=8
set IE_VER_TARGET_MAJOR=9
set IE_VER_TARGET_MINOR=11
set TSC_VER_TARGET_MAJOR=10
set TSC_VER_TARGET_MINOR=0
set WOU_ENDLESS=3
goto SetOfficeName

:SetOfficeName
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
if "%O2K16_VER_MAJOR%"=="" goto NoO2k16
rem *** Office 2016 ***
set OFC_NAME=o2k16
set OFC_ARCH=%O2K16_ARCH%
set OFC_LANG=%O2K16_LANG%
set O2K16_SP_VER_TARGET=0
:NoO2k16
goto EoF

:EoF
