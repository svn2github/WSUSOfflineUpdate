#!/bin/bash

#########################################################################
###          WSUS Offline Update ISO maker for Linux systems          ###
###                               v. 9.2.2                            ###
###                                                                   ###
###   http://www.wsusoffline.net/                                     ###
###   Authors: Stefan Joehnke, Walter Schiessberg                     ###
###   maintained by H. Hullen                                         ###
#########################################################################

Prog=$(basename $0)
case $BASH in
    *bin/bash)
    ;;
    *)
    echo "
Please start this program with

        bash $Prog
"
    exit 1
    ;;
esac

debug=0
test $debug -eq 1 && set -x
export SHELLOPTS
export TERM=xterm

source $(dirname $0)/commonparts.inc || {
    echo commonparts.sh fehlt
    exit 1
    }

#set working directory
cd $( dirname $(readlink -f "$0") )
rm -f ../temp/ExcludeListISO*

clear
head -20 $0 | grep '^###'

#check config
X=$(which mkisofs 2>/dev/null)
Y=$(which genisoimage 2>/dev/null)
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

# -------

test "$1" || printusage
evaluateparams $@
# $1 = sys, $2 = lang; $3 = /dotnet; $4 = /excludesp (o.ä.)

echo "Creating ISO filter..."
if [ "$sys" == "ofc" ]; then
    for Datei in ../exclude/ExcludeListISO-${sys_old}*.txt
      do
	if [ -f "$Datei" ]; then
        tr -d '\r' < "$Datei" > ../temp/ExcludeListISO-${sys}.txt
	fi
      done
fi

for Datei in ../exclude/ExcludeListISO-${sys}*.txt
  do
    if [ -f "$Datei" ]; then
    tr -d '\r' < "$Datei" > ../temp/ExcludeListISO-${sys}.txt
    fi
  done

if [ "$EXCLUDE_SP" == "1" ]; then
  cat ../exclude/ExcludeList-SPs.txt | while read line; do echo \*${line}\* >> ../temp/ExcludeListISO-${sys}.txt; done;
fi
if [ "$dotnet" != "1" ]; then
  echo "dotnet/*" >> ../temp/ExcludeListISO-${sys}.txt
fi
if [ "$msse" != "1" ]; then
  echo "msse/*" >> ../temp/ExcludeListISO-${sys}.txt
fi
if [ "$wddefs" != "1" ]; then
  echo "wddefs/*" >> ../temp/ExcludeListISO-${sys}.txt
fi

for skip in $langlist
  do
    case $skip in
	enu|$Origlang)
	;;
	*)
        echo "*${skip}*" 
    esac
  done >> ../temp/ExcludeListISO-${sys}.txt

cp ../temp/ExcludeListISO-${sys}.txt ../temp/ExcludeListISOtmp-${sys}.txt
tr -d '\\' < ../temp/ExcludeListISOtmp-${sys}.txt > ../temp/ExcludeListISO-${sys}.txt
rm ../temp/ExcludeListISOtmp-${sys}.txt

sed -i 's#^\*/##' ../temp/ExcludeListISO-${sys}.txt
sed -i 's#/\*$##' ../temp/ExcludeListISO-${sys}.txt
# Verzeichnisse passend reduzieren; 11.4.14

echo "Creating ISO image for $sys $Origlang..."
$iso_tool -iso-level 4 -udf -exclude-list ../temp/ExcludeListISO-${sys}.txt \
    -quiet -output ../iso/wsusoffline-${sys}-$Origlang.iso -volid wou_${sys}_${lang} ../client/
echo "done."

exit 0

# EOF

# ============================================================================
# $Id: CreateISOImage.sh,v 1.6 2013-03-11 13:17:24+01 HHullen Exp $
# $Log: CreateISOImage.sh,v $
# Revision 1.7  2013-03-05 09:52:00+01  twittrock
# builddate.txt-Erzeugung entfernt
#
# Revision 1.6  2013-03-11 13:17:24+01  HHullen
# exclude-Erzeugung korrigiert
#
# Revision 1.5  2013-03-10 15:27:16+01  HHullen
# verkuerzt
#
# Revision 1.4  2012-12-10 11:35:13+01  HHullen
# msse/wddefs fuer Windows 8 erweitert
#
# Revision 1.2  2012-10-25 13:33:00+02  HHullen
# verschlankt; Windows 8 ergaenzt
#
# Revision 1.1  2012-09-20 15:10:43+02  HHullen
# Initial revision
#
