#!/bin/bash

# Author: Tobias Breitling, Stefan Jöhnke

cd ..

GetFileSize()
{
FileSize=$(ls -l "$1"| tr -s " " | cut -d " " -f 5)
}

InValidParam()
{
cat << END

ERROR: Invalid parameter "$1"
Usage: $0 language
Supported languages:
enu, deu, nld, esn, fra, ptg, ptb, ita, rus, plk, ell, csy
dan, nor, sve, fin, jpn, kor, chs, cht, hun, trk, ara, heb

END
exit 1
}

deu()
{
LANGUAGE_CODE="0407"
LANGUAGE_SYM="DE"
SCRIPT_FILENAME="SCRIPT$LANGUAGE_SYM.CAB"
}

enu()
{
LANGUAGE_CODE="0409"
LANGUAGE_SYM="EN"
SCRIPT_FILENAME="SCRIPT$LANGUAGE_SYM.CAB"
}

nld()
{
LANGUAGE_CODE=0413
LANGUAGE_SYM=NL
SCRIPT_FILENAME="SCRIPT$LANGUAGE_SYM.CAB"
}

esn()
{
LANGUAGE_CODE="040A"
LANGUAGE_SYM="ES"
SCRIPT_FILENAME="SCRIPT$LANGUAGE_SYM.CAB"
}

fra()
{
LANGUAGE_CODE="040C"
LANGUAGE_SYM="FR"
SCRIPT_FILENAME="SCRIPT$LANGUAGE_SYM.CAB"
}

ptg()
{
LANGUAGE_CODE="0816"
LANGUAGE_SYM="PT"
SCRIPT_FILENAME="SCRIPPTG.CAB"
}

ptb()
{
LANGUAGE_CODE="0416"
LANGUAGE_SYM="BR"
SCRIPT_FILENAME="SCRIPPTB.CAB"
}

ita()
{
LANGUAGE_CODE="0410"
LANGUAGE_SYM="IT"
SCRIPT_FILENAME="SCRIPT$LANGUAGE_SYM.CAB"
}

rus()
{
LANGUAGE_CODE="0419"
LANGUAGE_SYM="RU"
SCRIPT_FILENAME="SCRIPT$LANGUAGE_SYM.CAB"
}

plk()
{
LANGUAGE_CODE="0415"
LANGUAGE_SYM="PL"
SCRIPT_FILENAME="SCRIPT$LANGUAGE_SYM.CAB"
}

ell()
{
LANGUAGE_CODE="0408"
LANGUAGE_SYM="EL"
SCRIPT_FILENAME="SCRIPT$LANGUAGE_SYM.CAB"
}

csy()
{
LANGUAGE_CODE="0405"
LANGUAGE_SYM="CS"
SCRIPT_FILENAME="SCRIPT$LANGUAGE_SYM.CAB"
}

dan()
{
LANGUAGE_CODE="0406"
LANGUAGE_SYM="DA"
SCRIPT_FILENAME="SCRIPT$LANGUAGE_SYM.CAB"
}

nor()
{
LANGUAGE_CODE="0414"
LANGUAGE_SYM="NO"
SCRIPT_FILENAME="SCRIPT$LANGUAGE_SYM.CAB"
}

sve()
{
LANGUAGE_CODE="041D"
LANGUAGE_SYM="SV"
SCRIPT_FILENAME="SCRIPT$LANGUAGE_SYM.CAB"
}

fin()
{
LANGUAGE_CODE="040B"
LANGUAGE_SYM="FI"
SCRIPT_FILENAME="SCRIPT$LANGUAGE_SYM.CAB"
}

jpn()
{
LANGUAGE_CODE="0411"
LANGUAGE_SYM="JA"
SCRIPT_FILENAME="SCRIPT$LANGUAGE_SYM.CAB"
}

kor()
{
LANGUAGE_CODE="0412"
LANGUAGE_SYM="KO"
SCRIPT_FILENAME="SCRIPT$LANGUAGE_SYM.CAB"
}

chs()
{
LANGUAGE_CODE="0004"
LANGUAGE_SYM="CN"
SCRIPT_FILENAME="SCRIPT$LANGUAGE_SYM.CAB"
}

cht()
{
LANGUAGE_CODE="0404"
LANGUAGE_SYM="TW"
SCRIPT_FILENAME="SCRIPT$LANGUAGE_SYM.CAB"
}

hun()
{
LANGUAGE_CODE="040E"
LANGUAGE_SYM="HU"
SCRIPT_FILENAME="SCRIPT$LANGUAGE_SYM.CAB"
}

trk()
{
LANGUAGE_CODE="041F"
LANGUAGE_SYM="TR"
SCRIPT_FILENAME="SCRIPT$LANGUAGE_SYM.CAB"
}

ara()
{
LANGUAGE_CODE="0401"
LANGUAGE_SYM="AR"
SCRIPT_FILENAME="SCRIPT$LANGUAGE_SYM.CAB"
}

heb()
{
LANGUAGE_CODE="040D"
LANGUAGE_SYM="HE"
SCRIPT_FILENAME="SCRIPT$LANGUAGE_SYM.CAB"
}

lang=""
langlist=("enu" "deu" "nld" "esn" "fra" "ptg" "ptb" "ita" "rus" "plk" "ell" "csy" "dan" "nor" "sve" "fin" "jpn" "kor" "chs" "cht" "hun" "trk" "ara" "heb")
for i in ${langlist[@]}; do
	if [ "$1" == "$i" ]; then
		lang="$1"
	fi
done

if [ "$lang" == "" ]; then
	InValidParam
fi

"$lang"

cd client/win/$lang/ie6setup
echo Creating iesetup.dir file...
echo > iesetup.dir

# Create filelist.dat
echo "Creating filelist.dat file..."

cat << END > filelist.dat
[General]
Version=1
[BASEIE40_W2K]
Version=6,0,2800,1106
Locale=$LANGUAGE_SYM
GUID={89820200-ECBD-11cf-8B85-00AA005B4383}
END

GetFileSize CRLUPD.CAB
echo "URL0=$FileSize,CRLUPD.CAB" >> filelist.dat
GetFileSize IEW2K_1.CAB
echo "URL1=$FileSize,IEW2K_1.CAB" >> filelist.dat
GetFileSize IEW2K_2.CAB
echo "URL2=$FileSize,IEW2K_2.CAB" >> filelist.dat
GetFileSize IEW2K_3.CAB
echo "URL3=$FileSize,IEW2K_3.CAB" >> filelist.dat
GetFileSize IEW2K_4.CAB
echo "URL4=$FileSize,IEW2K_4.CAB" >> filelist.dat

cat << END >> filelist.dat
[IEEX]
Version=6,0,2800,1106
Locale=$LANGUAGE_SYM
GUID={0fde1f56-0d59-4fd7-9624-e3df6b419d0f}
END

GetFileSize IEEXINST.CAB

cat << END >> filelist.dat
URL0=$FileSize,IEEXINST.CAB
[BRANDING.CAB]
Version=6,0,2800,1106
Locale=en
GUID=\>{60B49E34-C7CC-11D0-8953-00A0C90347FF}MICROS
END

GetFileSize BRANDING.CAB

cat << END >> filelist.dat
URL0=$FileSize,BRANDING.CAB
[MailNews_W2K]
Version=6,0,2800,1106
Locale=$LANGUAGE_SYM
GUID={44BBA840-CC51-11CF-AAFA-00AA00B6015C}
END

GetFileSize MAILNEWS.CAB
echo "URL0=$FileSize,MAILNEWS.CAB" >> filelist.dat
GetFileSize WAB.CAB
echo "URL1=$FileSize,WAB.CAB" >> filelist.dat
GetFileSize OEEXCEP.CAB

cat << END >> filelist.dat
URL2=$FileSize,OEEXCEP.CAB
[mediaplayer_W2K]
Version=6,4,9,1121
Locale=EN
GUID={22d6f312-b0f6-11d0-94ab-0080c74c7e95}
END

GetFileSize MPLAY2U.CAB

cat << END >> filelist.dat
URL0=$FileSize,MPLAY2U.CAB
[MSVBScript_W2K]
Version=5,6,0,7426
Locale=$LANGUAGE_SYM
GUID={4f645220-306d-11d2-995d-00c04f98bbc9}
END

GetFileSize $SCRIPT_FILENAME

cat << END >> filelist.dat
URL0=$FileSize,$SCRIPT_FILENAME
[IEReadme]
eVersion=6,0,2800,1106
Locale=*
GUID={0fde1f56-0d59-4fd7-9624-e3df6b419d0e}
END

GetFileSize README.CAB
echo "URL0=$FileSize,README.CAB" >> filelist.dat

# Create iesetup.ini
echo "Creating iesetup.ini file..."

cat << END > iesetup.ini
[Options]
Language=$LANGUAGE_CODE
Shell_Integration=0
Win95=0
Millen=0
NTx86=0
W2K=6.0.2800.1411
NTalpha=0
[Version]
Signature=Active Setup
[Downloaded Files]
BRANDING.CAB=1
CRLUPD.CAB=1
filelist.dat=1
ie6setup.exe=1
IEEXINST.CAB=1
iesetup.dir=1
iesetup.ini=1
IEW2K_1.CAB=1
IEW2K_2.CAB=1
IEW2K_3.CAB=1
IEW2K_4.CAB=1
MAILNEWS.CAB=1
MPLAY2U.CAB=1
OEEXCEP.CAB=1
README.CAB=1
$SCRIPT_FILENAME=1
WAB.CAB=1
END

cd ../../../../sh

exit 0

# EOF
