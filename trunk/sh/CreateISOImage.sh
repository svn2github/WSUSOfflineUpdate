#!/bin/bash

# WSUS Offline Update ISO-Maker for Linux Systems
# http://www.heise.de/ct/projekte/offlineupdate/
# Author: Stefan Joehnke

printusage()
{
echo ERROR Invalid parameter: $1 $2 $3 $4
echo
echo "Usage: $0 [system] [language] [parameter]"
echo
echo "Supported systems:"
echo "w2k, wxp, wxp-x64, w2k3, w2k3-x64, w60, w60-x64, oxp, o2k, o2k3, o2k7, all-x64, all-x86"
echo
echo "Supported languages:"
echo enu, deu, nld, esn, fra, ptg, ptb, ita, rus, plk, ell, csy
echo dan, nor, sve, fin, jpn, kor, chs, cht, hun, trk, ara, heb
echo
echo "Parameter:"
echo "/excludesp - exclude servicepacks"
echo "/dotnet    - include .Net-Framework"
echo 
echo "Example: $0 wxp deu /dotnet"
echo
exit
}

printheader()
{
clear
echo "**********************************************************"
echo "***            WSUS Offline Update ISO-Maker           ***"
echo "***                  for Linux Systems                 ***"
echo "***                                                    ***"
echo "***   http://www.heise.de/ct/projekte/offlineupdate/   ***"
echo "***   Author: Stefan Joehnke                           ***"
echo "**********************************************************"
echo
}

printheader
#check config
X=`which mkisofs`
Y=`which genisoimage`
iso_tool=""
if [ ! -x "$X" ] && [ ! -x "$Y" ]
then
 echo
 echo Please install mkisofs.
 echo
 echo Command in debian:
 echo apt-get install mkisofs
 echo or
 echo apt-get install genisoimage
 echo
 echo Command in Suse:
 echo zypper install genisoimage
 echo
 exit
fi
if [ -x "$X" ]
	then
	iso_tool="mkisofs"
	else
	iso_tool="genisoimage"
fi

evaluateparams()
{
syslist=("w2k" "wxp" "wxp-x64" "w2k3" "w2k3-x64" "w60" "w60-x64" "oxp" "o2k" "o2k3" "o2k7" "all-x64" "all-x86")
langlist=("enu" "deu" "nld" "esn" "fra" "ptg" "ptb" "ita" "rus" "plk" "ell" "csy" "dan" "nor" "sve" "fin" "jpn" "kor" "chs" "cht" "hun" "trk" "ara" "heb")
EXCLUDE_SP="0"
dotnet="0"

 for i in ${syslist[@]}
  do
   if [ "$1" == "$i" ]
    then
     sys="$1"
   fi
 done
 for i in ${langlist[@]}
  do
   if [ "$2" == "$i" ]
    then
     lang="$2"
   fi
  done
 if [ "$sys" == "w60" -o "$sys" == "w60-x64" ]
  then
  	echo Setting language to glb...
   lang="glb"
 fi
 if [ "$sys" == "" -o "$lang" == "" ]
 	then
 		printusage
 fi
 
 if [ "$3" == "/excludesp" ]
  then
   EXCLUDE_SP="1"
 fi
 if [ "$4" == "/excludesp" ]
  then
   EXCLUDE_SP="1"
 fi
 if [ "$3" == "/dotnet" ]
  then
   dotnet="1"
 fi
 if [ "$4" == "/dotnet" ]
  then
   dotnet="1"
 fi
}

evaluateparams $1 $2 $3 $4

#set workdir
cd $( dirname $0 )
rm ../temp/ExcludeListISO*

echo "Creating ISO-Filter..."

excludeiso1="../exclude/ExcludeListISO-$sys.txt"
excludeiso2="../exclude/ExcludeListISO-$sys-x86.txt"

echo "Writing builddate.txt..."
date > ../client/builddate.txt

if [ -f "$excludeiso1" ]
	then
		cp ../exclude/ExcludeListISO-$sys.txt ../temp/ExcludeListISO-$sys.txt
fi
if [ -f "$excludeiso2" ]
	then
		cp ../exclude/ExcludeListISO-$sys-x86.txt ../temp/ExcludeListISO-$sys.txt
fi
if [ "$EXCLUDE_SP" == "1" ]
 	then
 		cat ../exclude/ExcludeList-SPs.txt >> ../temp/ExcludeListISO-$sys.txt
fi
if [ "$dotnet" != "1" ]
	then
		echo "dotnet*" >> ../temp/ExcludeListISO-$sys.txt
fi
x=0
langlist=("enu" "deu" "nld" "esn" "fra" "ptg" "ptb" "ita" "rus" "plk" "ell" "csy" "dan" "nor" "sve" "fin")
for i in ${langlist[@]}
	do
		if [ "${langlist[x]}" == "enu" ]
			then
				echo ${langlist[x]}* | grep -v $lang >> ../temp/ExcludeListISO-$sys.txt
			else
				echo *${langlist[x]}* | grep -v $lang >> ../temp/ExcludeListISO-$sys.txt
		fi
		x=$x+1
done
cp ../temp/ExcludeListISO-$sys.txt ../temp/ExcludeListISOtmp-$sys.txt
cat ../temp/ExcludeListISOtmp-$sys.txt | grep "\/" | sed 's/\\\/\*//' | sed 's;*;;' >> ../temp/ExcludeListISO-$sys.txt
rm ../temp/ExcludeListISOtmp-$sys.txt

echo "Creating ISO image for $sys $lang..."
$iso_tool -iso-level 4 -joliet -joliet-long -rational-rock -exclude-list ../temp/ExcludeListISO-$sys.txt -output ../iso/wsusoffline-$sys-$lang.iso -volid ctou_$sys_$lang ../client
rm ../client/builddate.txt
echo "done."

