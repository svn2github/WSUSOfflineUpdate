#!/bin/bash

#########################################################################
###          WSUS Offline Update ISO maker for Linux systems          ###
###                           v. 8.0b (r424)                          ###
###                                                                   ###
###   http://www.wsusoffline.net/                                     ###
###   Authors: Stefan Joehnke, Walter Schiessberg                     ###
###   maintained by H. Hullen                                         ###
#########################################################################

#set working directory
cd $( dirname $(readlink -f "$0") )
rm -f ../temp/ExcludeListISO*

syslist="wxp w2k3 w2k3-x64 w60 w60-x64 w61 w61-x64 w62 w62-64 o2k3 o2k7 o2k10 ofc all-x64 all-x86"
langlist="enu deu nld esn fra ptg ptb ita rus plk ell csy dan nor sve fin jpn kor chs cht hun trk ara heb"

printusage()
{
cat <<END
  Invalid or missing parameter: "$@"

Usage: `basename $0` [system] [language] [parameter]

Supported systems:
$syslist

Supported languages:
$langlist

Parameter:
/excludesp - exclude servicepacks
/dotnet    - include .Net-Framework
/msse      - include Microsoft Security Essentials installation files
/wddefs    - include Windows Defender definition files

Example: `basename $0` wxp deu /dotnet

END
exit 1
}

clear
head -20 $0 | grep '^###'

#check config
X=`which mkisofs 2>/dev/null`
Y=`which genisoimage 2>/dev/null`
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
  exit 1
fi

if [ -x "$X" ]; then
  iso_tool="mkisofs"
else
  iso_tool="genisoimage"
fi

evaluateparams()
{
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

if [ "$sys" == "w60" -o "$sys" == "w60-x64" -o "$sys" == "w61" \
    -o "$sys" == "w61-x64" -o $sys == w62 -o $sys == w62-x64 ]; then
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
  if echo $@ | grep -q /dotnet ; then
    dotnet="1"
  fi
  if echo $@ | grep -q /excludesp ; then
    EXCLUDE_SP="1"
  fi
  if echo $@ | grep -q /nocleanup ; then
    CLEANUP_DOWNLOADS="0"
  fi

  if echo $@ | grep -q /msse ; then
    msse="1"
  fi

  if echo $@ | grep -q /wddefs ; then
    case $sys in
	w62*)
	msse="1"
	;;
	*)
	wddefs="1"
	;
    esac
  fi
done
}

test "$1" || printusage
evaluateparams $1 $2 $3 $4

echo "Creating ISO filter..."

excludeiso1="../exclude/ExcludeListISO-${sys}.txt"
excludeiso2="../exclude/ExcludeListISO-${sys}-x86.txt"
if [ "$sys" == "ofc" ]; then
  excludeiso3="../exclude/ExcludeListISO-${sys_old}.txt"
  excludeiso4="../exclude/ExcludeListISO-${sys_old}-x86.txt"
  if [ -f "$excludeiso3" ]; then
    tr -d '\r' < "$excludeiso3" > ../temp/ExcludeListISO-${sys}.txt
  fi
  if [ -f "$excludeiso4" ]; then
    tr -d '\r' < "$excludeiso4" > ../temp/ExcludeListISO-${sys}.txt
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

# ============================================================================
# $Id: CreateISOImage.sh,v 1.4 2012-12-10 11:35:13+01 HHullen Exp $
# $Log: CreateISOImage.sh,v $
# Revision 1.4  2012-12-10 11:35:13+01  HHullen
# msse/wddefs fuer Windows 8 erweitert
#
# Revision 1.2  2012-10-25 13:33:00+02  HHullen
# verschlankt; Windows 8 ergaenzt
#
# Revision 1.1  2012-09-20 15:10:43+02  HHullen
# Initial revision
#
