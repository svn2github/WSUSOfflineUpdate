@echo off
rem *** Authors: N. Winkler; T. Wittrock, RZ Uni Kiel ***

verify other 2>nul
setlocal enableextensions
if errorlevel 1 goto NoExtensions

if "%DIRCMD%" NEQ "" set DIRCMD=

for %%i in (enu fra esn jpn kor rus ptg ptb deu nld ita chs cht plk hun csy sve trk ell ara heb dan nor fin) do (if /i "%1"=="%%i" goto %%i)
goto InvalidParam

:enu
set LANGUAGE_CODE=0409
set LANGUAGE_SYM=EN
set SCRIPT_FILENAME=SCRIPT%LANGUAGE_SYM%.CAB
goto CreateFiles

:fra
set LANGUAGE_CODE=040C
set LANGUAGE_SYM=FR
set SCRIPT_FILENAME=SCRIPT%LANGUAGE_SYM%.CAB
goto CreateFiles

:esn
set LANGUAGE_CODE=040A
set LANGUAGE_SYM=ES
set SCRIPT_FILENAME=SCRIPT%LANGUAGE_SYM%.CAB
goto CreateFiles

:jpn
set LANGUAGE_CODE=0411
set LANGUAGE_SYM=JA
set SCRIPT_FILENAME=SCRIPTJP.CAB
goto CreateFiles

:kor
set LANGUAGE_CODE=0412
set LANGUAGE_SYM=KO
set SCRIPT_FILENAME=SCRIPT%LANGUAGE_SYM%.CAB
goto CreateFiles

:rus
set LANGUAGE_CODE=0419
set LANGUAGE_SYM=RU
set SCRIPT_FILENAME=SCRIPT%LANGUAGE_SYM%.CAB
goto CreateFiles

:ptg
set LANGUAGE_CODE=0816
set LANGUAGE_SYM=PT
set SCRIPT_FILENAME=SCRIPPTG.CAB
goto CreateFiles

:ptb
set LANGUAGE_CODE=0416
set LANGUAGE_SYM=BR
set SCRIPT_FILENAME=SCRIPPTB.CAB
goto CreateFiles

:deu
set LANGUAGE_CODE=0407
set LANGUAGE_SYM=DE
set SCRIPT_FILENAME=SCRIPT%LANGUAGE_SYM%.CAB
goto CreateFiles

:nld
set LANGUAGE_CODE=0413
set LANGUAGE_SYM=NL
set SCRIPT_FILENAME=SCRIPT%LANGUAGE_SYM%.CAB
goto CreateFiles

:ita
set LANGUAGE_CODE=0410
set LANGUAGE_SYM=IT
set SCRIPT_FILENAME=SCRIPT%LANGUAGE_SYM%.CAB
goto CreateFiles

:chs
set LANGUAGE_CODE=0004
set LANGUAGE_SYM=CN
set SCRIPT_FILENAME=SCRIPCHS.CAB
goto CreateFiles

:cht
set LANGUAGE_CODE=0404
set LANGUAGE_SYM=TW
set SCRIPT_FILENAME=SCRIPCHT.CAB
goto CreateFiles

:plk
set LANGUAGE_CODE=0415
set LANGUAGE_SYM=PL
set SCRIPT_FILENAME=SCRIPT%LANGUAGE_SYM%.CAB
goto CreateFiles

:hun
set LANGUAGE_CODE=040E
set LANGUAGE_SYM=HU
set SCRIPT_FILENAME=SCRIPT%LANGUAGE_SYM%.CAB
goto CreateFiles

:csy
set LANGUAGE_CODE=0405
set LANGUAGE_SYM=CS
set SCRIPT_FILENAME=SCRIPT%LANGUAGE_SYM%.CAB
goto CreateFiles

:sve
set LANGUAGE_CODE=041D
set LANGUAGE_SYM=SV
set SCRIPT_FILENAME=SCRIPT%LANGUAGE_SYM%.CAB
goto CreateFiles

:trk
set LANGUAGE_CODE=041F
set LANGUAGE_SYM=TR
set SCRIPT_FILENAME=SCRIPT%LANGUAGE_SYM%.CAB
goto CreateFiles

:ell
set LANGUAGE_CODE=0408
set LANGUAGE_SYM=EL
set SCRIPT_FILENAME=SCRIPT%LANGUAGE_SYM%.CAB
goto CreateFiles

:ara
set LANGUAGE_CODE=0401
set LANGUAGE_SYM=AR
set SCRIPT_FILENAME=SCRIPT%LANGUAGE_SYM%.CAB
goto CreateFiles

:heb
set LANGUAGE_CODE=040D
set LANGUAGE_SYM=HE
set SCRIPT_FILENAME=SCRIPT%LANGUAGE_SYM%.CAB
goto CreateFiles

:dan
set LANGUAGE_CODE=0406
set LANGUAGE_SYM=DA
set SCRIPT_FILENAME=SCRIPT%LANGUAGE_SYM%.CAB
goto CreateFiles

:nor
set LANGUAGE_CODE=0414
set LANGUAGE_SYM=NO
set SCRIPT_FILENAME=SCRIPT%LANGUAGE_SYM%.CAB
goto CreateFiles

:fin
set LANGUAGE_CODE=040B
set LANGUAGE_SYM=FI
set SCRIPT_FILENAME=SCRIPT%LANGUAGE_SYM%.CAB
goto CreateFiles

:CreateFiles
pushd ..\client\win\%1\ie6setup

rem *** Create iesetup.dir file ***
echo Creating iesetup.dir file...
echo.>iesetup.dir

rem *** Create filelist.dat file ***
echo Creating filelist.dat file...
echo [General] >filelist.dat
echo Version=1 >>filelist.dat
echo [BASEIE40_W2K] >>filelist.dat
echo Version=6,0,2800,1106 >>filelist.dat
echo Locale=%LANGUAGE_SYM% >>filelist.dat
echo GUID={89820200-ECBD-11cf-8B85-00AA005B4383} >>filelist.dat
call :GetFileSize CRLUPD.CAB
echo URL0=%FileSize%,CRLUPD.CAB >>filelist.dat
call :GetFileSize IEW2K_1.CAB
echo URL1=%FileSize%,IEW2K_1.CAB >>filelist.dat
call :GetFileSize IEW2K_2.CAB
echo URL2=%FileSize%,IEW2K_2.CAB >>filelist.dat
call :GetFileSize IEW2K_3.CAB
echo URL3=%FileSize%,IEW2K_3.CAB >>filelist.dat
call :GetFileSize IEW2K_4.CAB
echo URL4=%FileSize%,IEW2K_4.CAB >>filelist.dat
echo [IEEX] >>filelist.dat
echo Version=6,0,2800,1106 >>filelist.dat
echo Locale=%LANGUAGE_SYM% >>filelist.dat
echo GUID={0fde1f56-0d59-4fd7-9624-e3df6b419d0f} >>filelist.dat
call :GetFileSize IEEXINST.CAB
echo URL0=%FileSize%,IEEXINST.CAB >>filelist.dat
echo [BRANDING.CAB] >>filelist.dat
echo Version=6,0,2800,1106 >>filelist.dat
echo Locale=en >>filelist.dat
echo GUID=^>{60B49E34-C7CC-11D0-8953-00A0C90347FF}MICROS >>filelist.dat
call :GetFileSize BRANDING.CAB
echo URL0=%FileSize%,BRANDING.CAB >>filelist.dat
echo [MailNews_W2K] >>filelist.dat
echo Version=6,0,2800,1106 >>filelist.dat
echo Locale=%LANGUAGE_SYM% >>filelist.dat
echo GUID={44BBA840-CC51-11CF-AAFA-00AA00B6015C} >>filelist.dat
call :GetFileSize MAILNEWS.CAB
echo URL0=%FileSize%,MAILNEWS.CAB >>filelist.dat
call :GetFileSize WAB.CAB
echo URL1=%FileSize%,WAB.CAB >>filelist.dat
call :GetFileSize OEEXCEP.CAB
echo URL2=%FileSize%,OEEXCEP.CAB >>filelist.dat
echo [mediaplayer_W2K] >>filelist.dat
echo Version=6,4,9,1121 >>filelist.dat
echo Locale=EN >>filelist.dat
echo GUID={22d6f312-b0f6-11d0-94ab-0080c74c7e95} >>filelist.dat
call :GetFileSize MPLAY2U.CAB
echo URL0=%FileSize%,MPLAY2U.CAB >>filelist.dat
echo [MSVBScript_W2K] >>filelist.dat
echo Version=5,6,0,7426 >>filelist.dat
echo Locale=%LANGUAGE_SYM% >>filelist.dat
echo GUID={4f645220-306d-11d2-995d-00c04f98bbc9} >>filelist.dat
call :GetFileSize %SCRIPT_FILENAME%
echo URL0=%FileSize%,%SCRIPT_FILENAME% >>filelist.dat
echo [IEReadme] >>filelist.dat
echo Version=6,0,2800,1106 >>filelist.dat
echo Locale=* >>filelist.dat
echo GUID={0fde1f56-0d59-4fd7-9624-e3df6b419d0e} >>filelist.dat
call :GetFileSize README.CAB
echo URL0=%FileSize%,README.CAB >>filelist.dat

rem *** Create iesetup.ini file ***
echo Creating iesetup.ini file...
echo [Options] >iesetup.ini
echo Language=%LANGUAGE_CODE% >>iesetup.ini
echo Shell_Integration=0 >>iesetup.ini
echo Win95=0 >>iesetup.ini
echo Millen=0 >>iesetup.ini
echo NTx86=0 >>iesetup.ini
echo W2K=6.0.2800.1411 >>iesetup.ini
echo NTalpha=0 >>iesetup.ini
echo [Version] >>iesetup.ini
echo Signature=Active Setup >>iesetup.ini
echo [Downloaded Files] >>iesetup.ini
echo BRANDING.CAB=1 >>iesetup.ini
echo CRLUPD.CAB=1 >>iesetup.ini
echo filelist.dat=1 >>iesetup.ini
echo ie6setup.exe=1 >>iesetup.ini
echo IEEXINST.CAB=1 >>iesetup.ini
echo iesetup.dir=1 >>iesetup.ini
echo iesetup.ini=1 >>iesetup.ini
echo IEW2K_1.CAB=1 >>iesetup.ini
echo IEW2K_2.CAB=1 >>iesetup.ini
echo IEW2K_3.CAB=1 >>iesetup.ini
echo IEW2K_4.CAB=1 >>iesetup.ini
echo MAILNEWS.CAB=1 >>iesetup.ini
echo MPLAY2U.CAB=1 >>iesetup.ini
echo OEEXCEP.CAB=1 >>iesetup.ini
echo README.CAB=1 >>iesetup.ini
echo %SCRIPT_FILENAME%=1 >>iesetup.ini
echo WAB.CAB=1 >>iesetup.ini

popd
goto EoF

:GetFileSize
for /F "tokens=3,4" %%i in ('dir /-C /N %1 ^| %SystemRoot%\system32\find.exe /I "%1"') do (
  if /i %%j==%1 (set FileSize=%%i) else (set FileSize=%%j)
)
goto :eof

:NoExtensions
echo.
echo ERROR: No command extensions available.
echo.
goto Error

:InvalidParam
echo.
echo ERROR: Invalid parameter %1
echo Usage: %~n0 {enu ^| fra ^| esn ^| jpn ^| kor ^| rus ^| ptg ^| ptb ^| deu ^| nld ^| ita ^| chs ^| cht ^| plk ^| hun ^| csy ^| sve ^| trk ^| ell ^| ara ^| heb ^| dan ^| nor ^| fin}
echo.
goto Error

:Error
endlocal
exit /b 1

:EoF
endlocal
