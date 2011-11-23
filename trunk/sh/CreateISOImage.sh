#!/bin/bash

##########################################################
###           WSUS Offline Update ISO maker            ###
###                  for Linux systems                 ###
###                    v. 7.1+ (r315)                  ###
###                                                    ###
###   http://www.wsusoffline.net/                      ###
###   Authors: Stefan Joehnke, Walter Schiessberg      ###
###   modified by T. Wittrock                          ###
##########################################################

#set working directory
cd "$( dirname "$(readlink -f "$0")" )"
rm -f ../temp/ExcludeListISO*

printusage()
{
cat << END
Invalid or missing parameter: "$@"

Usage: `basename $0` [system] [language] [parameter]

Supported systems:
wxp, w2k3, w2k3-x64, w60, w60-x64, w61, w61-x64, o2k3, o2k7, o2k10, ofc, all-x64, all-x86

Supported languages:
enu, deu, nld, esn, fra, ptg, ptb, ita, rus, plk, ell, csy
dan, nor, sve, fin, jpn, kor, chs, cht, hun, trk, ara, heb

Parameter:
/excludesp - exclude servicepacks
/dotnet    - include .Net-Framework
/msse      - include Microsoft Security Essentials installation files
/wddefs    - include Windows Defender definition files

Example: `basename $0` wxp deu /dotnet

END
exit 1
}

printheader()
{
clear
cat << END
**********************************************************
***           WSUS Offline Update ISO maker            ***
***                  for Linux systems                 ***
***                    v. 7.1+ (r315)                  ***
***                                                    ***
***   http://www.wsusoffline.net/                      ***
***   Authors: Stefan Joehnke, Walter Schiessberg      ***
**********************************************************

END
}

printheader

#check config
X=`which mkisofs`
Y=`which genisoimage`
iso_tool=""
if [ ! -x "$X" ] && [ ! -x "$Y" ]; then
	cat << END
Please install mkisofs.

Command in Fedora:
yum install genisoimage

Command in Debian:
apt-get install mkisofs
or
apt-get install genisoimage

Command in SuSE:
zypper install genisoimage

END
fi

if [ -x "$X" ]; then
	iso_tool="mkisofs"
else
	iso_tool="genisoimage"
fi

evaluateparams()
{
syslist=("wxp" "w2k3" "w2k3-x64" "w60" "w60-x64" "w61" "w61-x64" "o2k3" "o2k7" "o2k10" "ofc" "all-x64" "all-x86")
langlist=("enu" "deu" "nld" "esn" "fra" "ptg" "ptb" "ita" "rus" "plk" "ell" "csy" "dan" "nor" "sve" "fin" "jpn" "kor" "chs" "cht" "hun" "trk" "ara" "heb")
paramlist=("/excludesp" "/dotnet" "/msse" "/wddefs")
EXCLUDE_SP="0"
dotnet="0"
msse="0"
wddefs="0"

#determining system
for i in ${syslist[@]}; do
	if [ "$1" == "$i" ]; then
		sys="$1"
	fi
done

#determining language
for i in ${langlist[@]}; do
	if [ "$2" == "$i" ]; then
		lang="$2"
	fi
done

if [ "$sys" == "w60" -o "$sys" == "w60-x64" -o "$sys" == "w61" -o "$sys" == "w61-x64" ]; then
	echo "Setting language to glb..."
	lang="glb"
fi

sys_old=""
if [ "$sys" == "o2k3" -o "$sys" == "o2k7" -o "$sys" == "o2k10" ]; then
	sys_old=$sys
  sys="ofc"
fi
if [ "$sys" == "" -o "$lang" == "" ]; then
 	printusage
fi
 
#determining parameters
for i in ${paramlist[@]}; do
	if echo $@ | grep /dotnet > /dev/null 2>&1; then
		dotnet="1"
	fi
	if echo $@ | grep /excludesp > /dev/null 2>&1; then
		EXCLUDE_SP="1"
	fi
	if echo $@ | grep /nocleanup > /dev/null 2>&1; then
		CLEANUP_DOWNLOADS="0"
	fi
	if echo $@ | grep /msse > /dev/null 2>&1; then
		msse="1"
	fi
	if echo $@ | grep /wddefs > /dev/null 2>&1; then
		wddefs="1"
	fi
done
}

evaluateparams $1 $2 $3 $4

echo "Creating ISO filter..."

excludeiso1="../exclude/ExcludeListISO-${sys}.txt"
excludeiso2="../exclude/ExcludeListISO-${sys}-x86.txt"
if [ "$sys" == "ofc" ]; then
  excludeiso3="../exclude/ExcludeListISO-${sys_old}.txt"
  excludeiso4="../exclude/ExcludeListISO-${sys_old}-x86.txt"  
  if [ -f "$excludeiso3" ]; then
    tr -d '\r' < ../exclude/ExcludeListISO-${sys_old}.txt > ../temp/ExcludeListISO-${sys}.txt
  fi
  if [ -f "$excludeiso4" ]; then
    tr -d '\r' < ../exclude/ExcludeListISO-${sys_old}-x86.txt > ../temp/ExcludeListISO-${sys}.txt
  fi  
fi

echo "Writing builddate.txt..."
date +%d.%m.%Y > ../client/builddate.txt

if [ -f "$excludeiso1" ]; then
  tr -d '\r' < ../exclude/ExcludeListISO-${sys}.txt >> ../temp/ExcludeListISO-${sys}.txt
fi
if [ -f "$excludeiso2" ]; then
  tr -d '\r' < ../exclude/ExcludeListISO-${sys}-x86.txt >> ../temp/ExcludeListISO-${sys}.txt
fi
if [ "$EXCLUDE_SP" == "1" ]; then
	cat ../exclude/ExcludeList-SPs.txt | while read line; do echo \*${line}\* >> ../temp/ExcludeListISO-${sys}.txt; done;
fi
if [ "$dotnet" != "1" ]; then
	echo "dotnet*" >> ../temp/ExcludeListISO-${sys}.txt
fi
if [ "$msse" != "1" ]; then
	echo "msse*" >> ../temp/ExcludeListISO-${sys}.txt
fi
if [ "$wddefs" != "1" ]; then
	echo "wddefs*" >> ../temp/ExcludeListISO-${sys}.txt
fi

x=0
langlist=("enu" "deu" "nld" "esn" "fra" "ptg" "ptb" "ita" "rus" "plk" "ell" "csy" "dan" "nor" "sve" "fin" "jpn" "kor" "chs" "cht" "hun" "trk" "ara" "heb")
for i in ${langlist[@]}; do
	if [ "${langlist[x]}" == "enu" ]; then
		echo ${langlist[x]}* | grep -v $lang >> ../temp/ExcludeListISO-${sys}.txt
	else
		echo *${langlist[x]}* | grep -v $lang >> ../temp/ExcludeListISO-${sys}.txt
	fi
	x=$x+1
done
cp ../temp/ExcludeListISO-${sys}.txt ../temp/ExcludeListISOtmp-${sys}.txt
cat ../temp/ExcludeListISOtmp-${sys}.txt | grep "\/" | sed 's/\\\/\*//' | sed 's;*;;' >> ../temp/ExcludeListISO-${sys}.txt
rm ../temp/ExcludeListISOtmp-${sys}.txt

echo "Creating ISO image for $sys $lang..."
$iso_tool -iso-level 4 -joliet -joliet-long -rational-rock -exclude-list ../temp/ExcludeListISO-${sys}.txt -output ../iso/wsusoffline-${sys}-$lang.iso -volid wou_${sys}_${lang} ../client
rm ../client/builddate.txt
echo "done."

exit 0

# EOF
