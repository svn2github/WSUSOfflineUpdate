#!/bin/bash

##########################################################
###           WSUS Offline Update ISO maker            ###
###                  for Linux systems                 ###
###                                                    ###
###   http://www.wsusoffline.net/                      ###
###   Authors: Stefan Joehnke, Walter Schiessberg      ###
##########################################################

#set working directory
cd $( dirname $0 )
rm ../temp/ExcludeListISO*

printusage()
{
cat << END
Invalid or missing parameter: "$@"

Usage: `basename $0` [system] [language] [parameter]

Supported systems:
w2k, wxp, wxp-x64, w2k3, w2k3-x64, w60, w60-x64, w61, w61-x64, oxp, o2k3, o2k7, all-x64, all-x86

Supported languages:
enu, deu, nld, esn, fra, ptg, ptb, ita, rus, plk, ell, csy
dan, nor, sve, fin, jpn, kor, chs, cht, hun, trk, ara, heb

Parameter:
/excludesp - exclude servicepacks
/dotnet    - include .Net-Framework

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
syslist=("w2k" "wxp" "wxp-x64" "w2k3" "w2k3-x64" "w60" "w60-x64" "w61" "w61-x64" "oxp" "o2k3" "o2k7" "all-x64" "all-x86")
langlist=("enu" "deu" "nld" "esn" "fra" "ptg" "ptb" "ita" "rus" "plk" "ell" "csy" "dan" "nor" "sve" "fin" "jpn" "kor" "chs" "cht" "hun" "trk" "ara" "heb")
paramlist=("/excludesp" "/dotnet")
EXCLUDE_SP="0"
dotnet="0"
param1=""
param2=""
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

if [ "$sys" == "" -o "$lang" == "" ]; then
 	printusage
fi
 
#determining parameters
n=1
for i in ${paramlist[@]}; do
	if echo $@ | grep $i > /dev/null 2>&1; then
		export param${n}=${i}
		n=`expr n + 1`
	fi
done

if [ "$param1" == "/dotnet" ]; then
	dotnet="1"
fi
if [ "$param2" == "/dotnet" ]; then
	dotnet="1"
fi
if [ "$param1" == "/excludesp" ]; then
	EXCLUDE_SP="1"
fi
if [ "$param2" == "/excludesp" ]; then
	EXCLUDE_SP="1"
fi
}

evaluateparams $1 $2 $3 $4

echo "Creating ISO filter..."

excludeiso1="../exclude/ExcludeListISO-${sys}.txt"
excludeiso2="../exclude/ExcludeListISO-${sys}-x86.txt"

echo "Writing builddate.txt..."
date > ../client/builddate.txt

if [ -f "$excludeiso1" ]; then
	cp ../exclude/ExcludeListISO-${sys}.txt ../temp/ExcludeListISO-${sys}.txt
fi
if [ -f "$excludeiso2" ]; then
	cp ../exclude/ExcludeListISO-${sys}-x86.txt ../temp/ExcludeListISO-${sys}.txt
fi
if [ "$EXCLUDE_SP" == "1" ]; then
	cat ../exclude/ExcludeList-SPs.txt | while read line; do echo \*${line}\* >> ../temp/ExcludeListISO-${sys}.txt; done;
fi
if [ "$dotnet" != "1" ]; then
	echo "dotnet*" >> ../temp/ExcludeListISO-${sys}.txt
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
$iso_tool -iso-level 4 -joliet -joliet-long -rational-rock -exclude-list ../temp/ExcludeListISO-${sys}.txt -output ../iso/wsusoffline-${sys}-$lang.iso -volid ctou_${sys}_${lang} ../client
rm ../client/builddate.txt
echo "done."

exit 0

# EOF
