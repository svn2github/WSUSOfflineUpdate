#!/bin/bash

#########################################################################
###         WSUS Offline Update Downloader for Linux systems          ###
###                          v. 9.7+ (r672)                           ###
###                                                                   ###
###   http://www.wsusoffline.net/                                     ###
###   Authors: Tobias Breitling, Stefan Joehnke, Walter Schiessberg   ###
###   maintained by H. Hullen                                         ###
#########################################################################
# Exit codes:
# 0 - success
# 1 - file error
# 2 - connection error

export LC_ALL=C

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

# test operating system
OpSys=$(uname -s)

test "$OpSys" || {
    echo unknown Operating System
    exit 1
    }

case "$OpSys" in
    Linux)
    #set working directory
    cd $( dirname $(readlink -f "$0") )
    ;;
    *BSD|Darwin)
    echo "Operating System $OpSys not yet supported"
    echo "Maybe something doesn't work as expected"
    sleep 10
    #set working directory
    cd $( dirname $(readlink "$0") )
    ;;
    *)
    echo "unknown Operating System"
    exit 1
    ;;
esac

#set working directory
PATH_PWD="$( pwd )"

source commonparts.inc || {
    echo commonparts.inc fehlt
    exit 1
    }

checkconfig()
{
C=$(which cabextract 2> /dev/null)
M=$(which md5deep 2> /dev/null)
S=$(which xmlstarlet 2> /dev/null)
T=$(which xml 2> /dev/null)
xml=""

Missing=0

for Datei in cabextract md5deep
  do
    Nomiss=$(which $Datei 2>/dev/null)
    test -x "$Nomiss" && continue
  cat << END

Please install $Datei

Command in Fedora:
yum install $Datei

Command in Debian:
apt-get install $Datei

Command in SuSE:
zypper install $Datei
END
    Missing=1
  done

test -x "$S" && xml="xmlstarlet"
test -x "$T" && xml="xml"

test "$xml" || {
for Datei in xmlstarlet xml
  do
  cat << END

Please install $Datei

Command in Fedora:
yum install $Datei

Command in Debian:
apt-get install $Datei

Command in SuSE:
zypper install $Datei
END
    Missing=1
  done
}

test $Missing -eq 0 || exit 1

} # Ende "checkconfig"

printtimeout()
{
cat << END

No connection could be established
Please check your internet connection.
END
exit 2
}

checkconnection()
{
OUT=`wget --connect-timeout=1 --tries=1 http://www.wsusoffline.net/index.html 2>&1`
if [ $? -ne 0 ]; then
  printf "failed to download:\n"
  printf -- "$OUT"
#   exit 2
  ping -c1 8.8.8.8 > /dev/null && return 0
else
  if [ !  -e "index.html" ]; then
    rm -f index.html
    printtimeout
  fi
fi
rm -f index.html
}

getsystem()
{
cat << END
Please select your OS:
[1] Windows Server 2003		[2] Windows Server 2003		    64 bit
[3] Windows Vista / Server 2008	[4] Windows Vista / Server 2008     64 bit
[5] Windows 7   (w61)		[6] Windows 7     / Server 2008 R2  64 bit
[7] Windows 8   (w62)		[8] Windows 8     / Server 2012     64 bit
[9] Windows 8.1 (w63)		[10] Windows 8.1		    64 bit

[11] All Windows 32 bit		[12] All Windows 64 bit

[13] Office 2007 	[14] Office 2010	[15] Office 2013
[16] All Office updates (2007 - 2013)

[17] all Windows 7	[18] all Windows 8	[19] all Windows 8.1

END
read -p "which number? " syschoice
    sysmax=$(wc -w <<< $syslist)
    test "$syschoice" || exit 1
    if [ $syschoice -lt 1 -o $syschoice -gt $sysmax ]; then
      echo "Program aborted."
      echo
      exit 1
    fi

sys_old=""
set -- $(echo $syslist)
shift $((syschoice -1))
sys=$1

if [ "$sys" == "wxp-x64" ]; then
  sys="w2k3-x64"
fi

case $sys in
    *-x64)
	OS_ARCH=x64
	OS_sys=$sys
	;;
    *)
	OS_ARCH=x86
	OS_sys=${sys}-x86
	;;
esac

}

getlanguage()
{
if [ "$lang" != "glb" ] ; then
  cat << END
Please select your OS language:

[a] enu           [b] deu         [c] nld         [d] esn
[e] fra           [f] ptg         [g] ptb         [h] ita
[i] rus           [j] plk         [k] ell         [l] csy
[m] dan           [n] nor         [o] sve         [p] fin
[q] jpn           [r] kor         [s] chs         [t] cht
[u] hun           [v] trk         [w] ara         [x] heb
END
  read -p "which letter? " langchoice
    langmax=$(($(wc -w <<< $langlist) - 1 ))
    test "$langchoice" || {
	echo "Program aborted"
	exit 1
	}
  echo
    langnr=$(($(printf '%d' "'$langchoice'") - 97))
  if [ $langnr -lt 0 -o $langnr -gt $langmax ]; then
    echo "Program aborted."
    exit 1
  fi
    set -- $(echo $langlist)
    shift $langnr
    lang=$1
    Origlang=$lang
fi

}

getservicepack()
{
EXCLUDE_SP="1"
read -p "Download Service Packs? [y/n] " addsp
if [ "$addsp" == "y" ]; then
  EXCLUDE_SP="0"
else
  param3="/excludesp"
fi
}

getdotnet()
{
dotnet="0"
read -p "Download .Net framework? [y/n] " adddotnet
if [ "$adddotnet" == "y" ]; then
  dotnet="1"
  param2="/dotnet"
fi
}

getmsse()
{
msse="0"
if [ "$sys" != "w2k3" -a "$sys" != "w2k3-x64" ]; then
  read -p "Download Microsoft Security Essentials files? [y/n] " addmsse
  if [ "$addmsse" == "y" ]; then
    msse="1"
    param5="/msse"
  fi
fi
}

getwddefs()
{
wddefs="0"
read -p "Download Microsoft Windows Defender definition files? [y/n] " addwddefs
if [ "$addwddefs" == "y" ]; then
  wddefs="1"
  param7="/wddefs"
fi
}

getwle()
{
wle="0"
read -p "Download Windows Essentials? [y/n] " addwle
if [ "$addwle" == "y" ]; then
  wle="1"
  param8="/wle"
fi
}
getproxy()
{
read -p "Please specify your proxy (default: none, http://[username:password@]<server>:<port>]) " http_proxy
test "$http_proxy" || http_proxy="none"
case "$http_proxy" in
    http:*|none|n)
    ;;
    *)
    echo wrong syntax for proxy server
    exit 1
    ;;
esac
}

makeiso()
{
createiso="0"
read -p "Create ISO-Image after download? [y/n] " addiso
if [ "$addiso" == "y" ]; then 
  createiso="1"
  param1="/makeiso"
fi
}

cleanup()
{
file="$1"
path="$2"
> ../temp/cleanup.txt
for i in $(ls "$path"); do
  test "$i" == "ie6setup" && continue
  grep "${i}" "${file}" || echo "$i" 
  echo rm -f ${path}/"$i"
done > ../temp/cleanup.txt
    }

printheader() {
echo " "
head -20 "$0" | grep '^###'
    }

# gilt auch für dotnet und wddefs
down_msse_cpp() {
    case $Vz in
	cpp)
	Zielverz=$Vz
	Datei=$Vz-${OS_ARCH}-glb
	;;
	wle)
	Zielverz=$Vz
	Datei=$Vz-glb
	;;
	msse|wddefs)
	Zielverz=$Vz/${OS_ARCH}-glb
        Datei=$Vz-${OS_ARCH}-glb
	;;
	dotnet)
	Zielverz=$Vz/${OS_ARCH}-glb
	Datei=$Vz
	;;
    esac

   mkdir -p ../client/$Zielverz
   echo "Downloading $Txt files..."
   while read x
    do
    case $Vz in
	cpp|msse|wle|dotnet)
	grep -q ',' <<< "$x" && {
      oldname=${x%,*}
      newname=${x#*,}
      test "$newname" && tmpname=${oldname##*/}
	}
      if [ -f "../client/$Zielverz/$newname" ]; then
        mv -f "../client/$Zielverz/$newname" "../client/$Zielverz/$tmpname"
      fi
      doWget $oldname -P ../client/$Zielverz
      if [ -f "../client/$Zielverz/$tmpname" ]; then
        mv -f "../client/$Zielverz/$tmpname" "../client/$Zielverz/$newname"
      fi
	;;
	wddefs)
	doWget $x -P ../client/$Zielverz
	;;
    esac
    done < ../temp/StaticUrls-${Datei}.txt

  echo "Creating integrity database for $Txt ..."
  (cd ../client/md; hashdeep -c md5,sha1,sha256 -l -r ../$Vz | tr '/' '\\' > hashes-${Vz}.txt)
    }

crlf2lf() {
    test -f "$1" || return 0
    grep -q -m1 $'\r' "$1" || return 0
    tr -d '\r' < "$1" > "$1.tmp" &&
	touch -r "$1" "$1.tmp" &&
	mv "$1.tmp" "$1" 
    # POSIX-konforme Lösung von Stefan Reuther, de.comp.unix.shell 5.8.14
    }
# ist derzeit nur für GNU/Linux


# ------------- end of functions -------------

clear
printheader

#check for required packages
checkconfig
printheader

#check if parameters are valid
if [ "$1" != "" ]; then
  externparam="1"
  evaluateparams $@
else
#get parameters
  getsystem
  getlanguage
  getservicepack
  getdotnet
  getmsse
  getwddefs
  getwle
  getproxy
  makeiso
fi

#set proxy
if [ "$http_proxy" != "" ] && [ "$http_proxy" != "none" ]; then
  export http_proxy=$http_proxy
fi

#check internet connection
checkconnection

#set up needed directories
mkdir -p ../client
mkdir -p ../client/wsus
mkdir -p ../client/msse
mkdir -p ../client/cpp
mkdir -p ../client/wle
mkdir -p ../temp
rm -f ../temp/*

printheader

cat << END
  Your choice
  System: $sys
  Language: $Origlang
  Parameter: $param1 $param2 $param3 $param4 $param5 $param7 $param8
  Proxy: $http_proxy
END

if [ "$externparam" != "1" ]; then
  echo
  read -p "Do you want to download now? [y/n] " response
else
  response="y"
fi

if [ "$response" != "y" ]; then
  echo
  echo "Program aborted."
  echo
  exit 1
fi

echo "
Thank you - now I start working!"

mydate=$(date +%Y%m%d)

#convert files to Linux format
for Datei in ../{exclude,static}/*.txt ../{exclude,static}/custom/*.txt
  do
    crlf2lf "$Datei"
  done

Liste=""
case $sys in
    all-x64) Liste="w2k3-x64 w60-x64 w61-x64 w62-x64 w63-x64" ;;
    all-x86) Liste="w2k3     w60     w61     w62     w63" ;;
    all-61)  Liste="w61 w61-x64" ;;
    all-62)  Liste="w62 w62-x64" ;;
    all-63)  Liste="w63 w63-x64" ;;
    ofc) test "$sys_old" || Liste="o2k7 o2k10 o2k13" ;;
esac
test "$Liste" && {
  for OS in $Liste
    do
    /bin/bash DownloadUpdates.sh $OS $Origlang $param2 $param3 $param4 $param5 $param6 $param7 $param8
    done
    if [ "$param1" == "/makeiso" ]; then
	/bin/bash ./CreateISOImage.sh $sys $Origlang $param2 $param3
	rc=$?
    fi
    exit $rc
    }

echo "Downloading most recent Windows Update Agent and catalog file..."
doWget -i ../static/StaticDownloadLinks-wsus.txt -P ../client/wsus

echo "Determining static URLs for ${sys} ..."

if [ "$sys" == "ofc" ] && [ "$sys_old" != "" ]; then
  echo "Determining static URLs for ${sys_old} ..."
  for Lang in $lang glb; do
  for static in "../static/StaticDownloadLinks-${sys_old}-${OS_ARCH}-${Lang}.txt" "../static/StaticDownloadLinks-${sys_old}-${Lang}.txt"
  do 
    test -f "$static" || continue
     if [ "$EXCLUDE_SP" == "0" ]; then
      cat $static >> ../temp/StaticUrls-${sys_old}-${Lang}.txt
     fi
    if [ "$EXCLUDE_SP" == "1" ]; then
     grep -i -v -f ../exclude/ExcludeList-SPs.txt $static > ../temp/StaticUrls-${sys_old}-${Lang}.txt
    fi
    done
   done # Lang
fi # Ende Office

> ../temp/StaticUrls-${sys}-${lang}.txt

for static in "../static/StaticDownloadLinks-${OS_sys}-${lang}.txt" "../static/StaticDownloadLinks-${OS_sys}.txt"
  do
  test -f "$static" || continue
  if [ "$EXCLUDE_SP" == "0" ]; then
    cat $static >> ../temp/StaticUrls-${sys}-${lang}.txt
  else
   grep -i -v -f ../exclude/ExcludeList-SPs.txt $static >> ../temp/StaticUrls-${sys}-${lang}.txt
  fi
  done

if [ -f ../static/custom/StaticDownloadLinks-${OS_sys}-${lang}.txt ]; then
    cat ../static/custom/StaticDownloadLinks-${OS_sys}-${lang}.txt >> ../temp/StaticUrls-${sys}-${lang}.txt
fi

for Pfad in static static/custom; do
# test "$lang" != glb -a "$sys" != "w2k3-x64" || continue
  static="../$Pfad/StaticDownloadLinks-win-${OS_ARCH}-${Origlang}.txt"
  if [ -f "$static" ]; then
    cat $static >> ../temp/StaticUrls-${Origlang}.txt
  fi
  static="../$Pfad/StaticDownloadLinks-win-${OS_ARCH}-glb.txt"
  if [ -f "$static" ]; then
    cat $static >> ../temp/StaticUrls-glb.txt
  fi
done

for Pfad in static static/custom; do
if [ $lang != glb  ]; then
  static="../$Pfad/StaticDownloadLinks-${OS_sys}-glb.txt"
  if [ -f "$static" ]; then
    cat $static >> ../temp/StaticUrls-${sys}-glb.txt
  fi
fi
done

# Optionen

# cp ../static/StaticDownloadLinks-dotnet.txt ../temp/StaticUrls-dotnet.txt
> ../temp/StaticUrls-dotnet-${OS_ARCH}-$lang.txt
> ../temp/Urls-dotnet-${OS_ARCH}.txt
for Pfad in static static/custom; do
if [ "$dotnet" == "1" ]; then
    Vz=dotnet
    test -f ../$Pfad/StaticDownloadLinks-$Vz-${OS_ARCH}-$Origlang.txt && {
    grep -F -i -v -f ../exclude/ExcludeList-$Vz-${OS_ARCH}.txt ../$Pfad/StaticDownloadLinks-$Vz-${OS_ARCH}-$Origlang.txt \
	>> ../temp/Urls-$Vz-${OS_ARCH}.txt
    }
    cat ../$Pfad/StaticDownloadLinks-$Vz.txt >> ../temp/StaticUrls-$Vz.txt 2>/dev/null

    Vz=cpp
    cat ../$Pfad/StaticDownloadLinks-$Vz-${OS_ARCH}-glb.txt >> ../temp/StaticUrls-$Vz-${OS_ARCH}-glb.txt 2>/dev/null
fi

if [ "$wddefs" == "1" ]; then
    Vz=wddefs
    cat ../$Pfad/StaticDownloadLink-$Vz-${OS_ARCH}-glb.txt >> ../temp/StaticUrls-$Vz-${OS_ARCH}-glb.txt 2>/dev/null
# anderer Dateiname: ...Link
fi

if [ "$msse" == "1" ]; then
    Vz=msse
    cat ../$Pfad/StaticDownloadLinks-$Vz-${OS_ARCH}-glb.txt >> ../temp/StaticUrls-$Vz-${OS_ARCH}-glb.txt 2>/dev/null
    cat ../$Pfad/StaticDownloadLinks-$Vz-${OS_ARCH}-$Origlang.txt >> ../temp/StaticUrls-$Vz-${OS_ARCH}-glb.txt 2>/dev/null
fi

if [ "$wle" == "1" ]; then
    Vz=wle
    cat ../$Pfad/StaticDownloadLinks-$Vz-glb.txt >> ../temp/StaticUrls-$Vz-glb.txt 2>/dev/null
    cat ../$Pfad/StaticDownloadLinks-$Vz-$Origlang.txt >> ../temp/StaticUrls-$Vz-glb.txt 2>/dev/null
fi

done # Pfad

test $debug -eq 0 && set +x

# echo "Adding Custom-Links..."

cd ../temp
echo "Extracting Windows update catalogue file package.xml..."
cp ../client/wsus/wsusscn2.cab ../client/wsus/wsusscn2_1.cab
cabextract -q -F package.cab ../client/wsus/wsusscn2_1.cab 2>/dev/null
cabextract -q -F package.xml package.cab
rm -f package.cab
rm -f ../client/wsus/wsusscn2_1.cab
cd ../sh

# superseded

supersed="0"
if [ -f ../exclude/ExcludeList-superseded.txt ]; then
  if [ ../client/wsus/wsusscn2.cab -nt ../exclude/ExcludeList-superseded.txt ]; then
    supersed="1"
    #  %WGET_PATH% -N -P ..\exclude http://download.wsusoffline.net/ExcludeList-superseded-exclude.txt
    doWget http://download.wsusoffline.net/ExcludeList-superseded-exclude.txt -P ../exclude
    Datei=../exclude/ExcludeList-superseded-exclude.txt
    crlf2lf "$Datei"
  else
    echo "Found valid list of superseded updates..."
  fi
else
  supersed="1"
fi

test $debug -ne 0 && supersed="1"

if [ "$supersed" == "1" ]; then
echo "Determining superseded updates (please be patient, this will take a while)..."
$xml tr ../xslt/ExtractUpdateRevisionIds.xsl ../temp/package.xml > ../temp/ValidUpdateRevisionIds.txt
$xml tr ../xslt/ExtractSupersedingRevisionIds.xsl ../temp/package.xml | sort -u > ../temp/SupersedingRevisionIds.txt
grep -F -f ../temp/SupersedingRevisionIds.txt ../temp/ValidUpdateRevisionIds.txt >> ../temp/ValidSupersedingRevisionIds.txt
rm -f ../temp/ValidUpdateRevisionIds*.txt
rm -f ../temp/SupersedingRevisionIds*.txt
$xml tr ../xslt/ExtractSupersededUpdateRelations.xsl ../temp/package.xml > ../temp/SupersededUpdateRelations.txt
grep -F -f ../temp/ValidSupersedingRevisionIds.txt ../temp/SupersededUpdateRelations.txt > ../temp/ValidSupersededUpdateRelations.txt
rm -f ../temp/SupersededUpdateRelations.txt
rm -f ../temp/ValidSupersedingRevisionIds.txt
$xml tr ../xslt/ExtractUpdateRevisionAndFileIds.xsl ../temp/package.xml > ../temp/UpdateRevisionAndFileIds.txt

REVISION_ID=""
  while IFS=',' read Platz0 Platz1 Rest
  do
    read temp0 Rest <<< ${Platz1//;/ }
    if [ "${temp0}" == "" ]; then
      REVISION_ID=${Platz0}
      echo "${Platz0}" >> ../temp/BundledUpdateRevisionAndFileIds.txt
    else
      echo "${Platz0},${temp0};$REVISION_ID" >> ../temp/BundledUpdateRevisionAndFileIds.txt
    fi
  done < ../temp/UpdateRevisionAndFileIds.txt

  while IFS=',' read ValidRevID Rest
  do
  echo "${ValidRevID}" >> ../temp/ValidSupersededRevisionIds.txt
  done < ../temp/ValidSupersededUpdateRelations.txt
grep -F -f ../temp/ValidSupersededRevisionIds.txt ../temp/BundledUpdateRevisionAndFileIds.txt > ../temp/SupersededRevisionAndFileIds.txt

  while IFS=',' read Platz0 Platz1 Rest
  do
    test "$Platz1" || continue
    read temp0 Rest <<< ${Platz1//;/ }
   test "${temp0}" && echo "${temp0}" >> ../temp/SupersededFileIds.txt
  done < ../temp/SupersededRevisionAndFileIds.txt

test $debug -eq 0 && rm -f ../temp/SupersededRevisionAndFileIds.txt
test -s ../temp/SupersededFileIds.txt && {
sort -u ../temp/SupersededFileIds.txt | grep -v '#' > ../temp/SupersededFileIdsUnique.txt
    }
test $debug -eq 0 && rm -f ../temp/SupersededFileIds.txt
$xml tr ../xslt/ExtractUpdateCabExeIdsAndLocations.xsl ../temp/package.xml | sort -u > ../temp/UpdateCabExeIdsAndLocations.txt
grep -F -f ../temp/SupersededFileIdsUnique.txt ../temp/UpdateCabExeIdsAndLocations.txt >> ../temp/SupersededCabExeIdsAndLocations.txt
rm -f ../temp/SupersededFileIdsUnique.txt
test $debug -eq 0 && rm -f ../temp/UpdateCabExeIdsAndLocations.txt
rm -f ../exclude/ExcludeList-superseded.txt

  while IFS=',' read dummy temp Rest
  do
  temp=$(basename $temp .exe)
  echo "${temp%\.cab}" >> ../exclude/ExcludeList-superseded.txt
  done < ../temp/SupersededCabExeIdsAndLocations.txt
echo "Done."
fi

# test $debug -gt 0 && read -p "Pause nach supersede in Zeile $LINENO " dummy

# ------- Ende superseded

echo "Determining update URLs for ${sys} ..."
# verify="../temp/tmpUrls-${sys}-${lang}.txt"

mkdir -p ../client/win/glb ../client/win/glb ../client/$sys/$lang ../client/$sys/glb

test -f ../xslt/ExtractDownloadLinks-${OS_sys}-${lang}.xsl \
    && $xml tr ../xslt/ExtractDownloadLinks-${OS_sys}-${lang}.xsl ../temp/package.xml > ../temp/Urls-${OS_sys}-${lang}.txt

test "$dotnet" == "1" && $xml tr ../xslt/ExtractDownloadLinks-dotnet-${OS_ARCH}-glb.xsl ../temp/package.xml >> ../temp/Urls-dotnet-${OS_ARCH}.txt

test -f ../temp/Urls-${OS_sys}-${lang}.txt && \
  cp ../temp/Urls-${OS_sys}-${lang}.txt ../temp/tmpUrls-${OS_sys}-${lang}.txt

> ../temp/tmpExcludeList-${sys}.txt

for Pfad in exclude exclude/custom; do
test -f ../$Pfad/ExcludeList-${OS_sys}.txt && \
    cat ../$Pfad/ExcludeList-${OS_sys}.txt >> ../temp/tmpExcludeList-${sys}.txt
  done

test -f ../exclude/ExcludeList-superseded.txt && \
    cat ../exclude/ExcludeList-superseded.txt >> ../temp/tmpExcludeList-${sys}.txt
test -f ../temp/tmpUrls-${OS_sys}-${lang}.txt && \
    grep -F -i -v -f ../temp/tmpExcludeList-${sys}.txt ../temp/tmpUrls-${OS_sys}-${lang}.txt > ../temp/ValidUrls-${sys}-${lang}.txt

test $lang == glb || {
  test -f ../xslt/ExtractDownloadLinks-${OS_sys}-glb.xsl && \
    $xml tr ../xslt/ExtractDownloadLinks-${OS_sys}-glb.xsl ../temp/package.xml > ../temp/Urls-${sys}-glb.txt
  test -f ../xslt/ExtractDownloadLinks-${OS_sys}-glb.xsl && \
    $xml tr ../xslt/ExtractDownloadLinks-${OS_sys}-glb.xsl ../temp/package.xml > ../temp/Urls-${sys}-glb.txt
  test -f ../temp/Urls-${sys}-glb.txt && {
    cp ../temp/Urls-${sys}-glb.txt ../temp/tmpValidUrls-${sys}-glb.txt
    grep -F -i -v -f ../temp/tmpExcludeList-${sys}.txt ../temp/tmpValidUrls-${sys}-glb.txt > ../temp/ValidUrls-${sys}-glb.txt
    }
#  rm -f ../temp/Urls-${sys}-glb.txt ../temp/tmpValidUrls-${sys}-glb.txt
  }

> ../temp/tmpExcludeList-win-${OS_ARCH}.txt

if [ $lang != glb -a $sys != "w2k3-x64" -a "$sys" != "ofc" ]; then
  echo "Determining update URLs for win ..."
  test -f ../xslt/ExtractDownloadLinks-win-x86-${lang}.xsl && \
    $xml tr ../xslt/ExtractDownloadLinks-win-x86-${lang}.xsl ../temp/package.xml >> ../temp/Urls-win-${OS_ARCH}-${lang}.txt
  cat ../exclude/ExcludeList-win-x86.txt >> ../temp/tmpExcludeList-win-${OS_ARCH}.txt
  test -f ../exclude/custom/ExcludeList-win-x86.txt && \
    cat ../exclude/custom/ExcludeList-win-x86.txt >> ../temp/tmpExcludeList-win-${OS_ARCH}.txt
  test -f ../exclude/ExcludeList-superseded.txt && \
    cat ../exclude/ExcludeList-superseded.txt >> ../temp/tmpExcludeList-win-${OS_ARCH}.txt
  test -f ../temp/Urls-win-${OS_ARCH}-${lang}.txt && \
    grep -F -i -v -f ../temp/tmpExcludeList-win-${OS_ARCH}.txt ../temp/Urls-win-${OS_ARCH}-${lang}.txt >> ../temp/ValidUrls-win-${OS_ARCH}-${lang}.txt
fi

if [ $lang == glb ]; then
  echo "Determining update URLs for win ..."
  test -f ../xslt/ExtractDownloadLinks-win-x86-${lang}.xsl && \
    $xml tr ../xslt/ExtractDownloadLinks-win-x86-${lang}.xsl ../temp/package.xml >> ../temp/Urls-win-${OS_ARCH}-${lang}.txt
  cat ../exclude/ExcludeList-win-x86.txt >> ../temp/tmpExcludeList-win-${OS_ARCH}.txt
  test -f ../exclude/custom/ExcludeList-win-x86.txt && \
    cat ../exclude/custom/ExcludeList-win-x86.txt >> ../temp/tmpExcludeList-win-${OS_ARCH}.txt
  test -f ../exclude/ExcludeList-superseded.txt && \
    cat ../exclude/ExcludeList-superseded.txt >> ../temp/tmpExcludeList-win-${OS_ARCH}.txt
  test -f ../temp/Urls-win-${OS_ARCH}-${lang}.txt && \
    grep -F -i -v -f ../temp/tmpExcludeList-win-${OS_ARCH}.txt ../temp/Urls-win-${OS_ARCH}-${lang}.txt >> ../temp/ValidUrls-win-${OS_ARCH}-${lang}.txt
fi

# ------------- Office -------------

if [ "$sys" == "ofc" ]; then
echo "Determining dynamic update urls for ${sys}..."

for Datei in ExcludeList-${sys}.txt custom/ExcludeList-${sys}.txt ExcludeList-superseded.txt
  do
     test -f ../exclude/$Datei && cat ../exclude/$Datei
  done | sort -u > ../temp/ExcludeList-${sys}.txt

$xml tr ../xslt/ExtractUpdateCategoriesAndFileIds.xsl ../temp/package.xml > ../temp/UpdateCategoriesAndFileIds.txt
$xml tr ../xslt/ExtractUpdateCabExeIdsAndLocations.xsl ../temp/package.xml > ../temp/UpdateCabExeIdsAndLocations.txt

oldlang=$Origlang
for lang in $oldlang glb
do
  echo "Determining dynamic update urls for ${sys} (please be patient, this will take a while)..."
  UPDATE_ID=""
  UPDATE_CATEGORY=""
  UPDATE_LANGUAGES=""

    while IFS=';' read Platz1 cate Rest
    do
	read precat0 precat1 precat2 Rest <<<${Platz1//,/ }

      if [ "$cate" == "" ]; then
        if [ "$UPDATE_CATEGORY" == "477b856e-65c4-4473-b621-a8b230bb70d9" ]; then
          if [ "${precat1}" != "" ]; then
            if [ "$lang" == "glb" ]; then
              if [ "${precat2}" == "" ] && [ "$UPDATE_LANGUAGES" == "" ]; then
                echo "$UPDATE_ID,${precat1}" >> ../temp/OfficeUpdateAndFileIds.txt
              fi
              if [ "${precat2}" == "en" ] && [ "$UPDATE_LANGUAGES" == "en" ]; then
                echo "$UPDATE_ID,${precat1}" >> ../temp/OfficeUpdateAndFileIds.txt
              fi
            else
              if [ "${precat2}" == "$LANG_SHORT" ]; then
                echo "$UPDATE_ID,${precat1}" >> ../temp/OfficeUpdateAndFileIds.txt
              fi
            fi
          fi
        fi
      else
	UPDATE_ID=${precat0}
	read UPDATE_CATEGORY UPDATE_LANGUAGES Rest <<< ${cate//,/ }
	UPDATE_lang=$(cut -d',' -f2- <<< ${cate})
	test "$UPDATE_LANGUAGES" && {
	grep -w -q "en" <<< ${UPDATE_lang} && UPDATE_LANGUAGES=en
	grep -w -q "$LANG_SHORT" <<< ${UPDATE_lang} && UPDATE_LANGUAGES=$LANG_SHORT
	}
      fi
    done < ../temp/UpdateCategoriesAndFileIds.txt

  cut -d',' -f2 ../temp/OfficeUpdateAndFileIds.txt | sort -u > ../temp/OfficeFileIds.txt 

  grep -F -f ../temp/OfficeFileIds.txt ../temp/UpdateCabExeIdsAndLocations.txt > ../temp/OfficeUpdateCabExeIdsAndLocations.txt
  mkdir -p ../client/ofc
  rm -f ../client/ofc/UpdateTable-${sys}-${lang}.csv

   while IFS=',' read Platz1 temp_linkid Rest
    do
      test "${temp_linkid}" || continue
	# Brechstange
      Line=$(grep "^${temp_linkid}," ../temp/OfficeUpdateCabExeIdsAndLocations.txt)
	test "$Line" || continue

      Line=(${Line//,/ })
          if [ "${Line[0]}" != "" -a "${Line[0]}" == "$temp_linkid" ]; then
            echo "${Line[1]}" >> ../temp/DynamicDownloadLinks-${sys}-${lang}.txt
            filename=${Line[1]%.exe}
            echo "$Platz1,${filename%.cab}" >> ../client/ofc/UpdateTable-${sys}-${lang}.csv
          fi
    done < ../temp/OfficeUpdateAndFileIds.txt

    test $debug -ne 0 && rm -f ../temp/OfficeFileIds.txt
    test $debug -ne 0 && rm -f ../temp/OfficeUpdateAndFileIds.txt
    test $debug -ne 0 && rm -f ../temp/OfficeUpdateCabExeIdsAndLocations.txt
    grep -F -i -v -f ../temp/ExcludeList-${sys}.txt ../temp/DynamicDownloadLinks-${sys}-${lang}.txt > ../temp/ValidDynamicLinks-${sys}-${lang}.txt
    cat ../temp/ValidDynamicLinks-${sys}-${lang}.txt >> ../temp/ValidUrls-${sys}-${lang}.txt
done

lang=$oldlang
 fi

# ---------- Ende Office -------------

test $debug -ne 0 && echo "Office ist fertig"

rm -f ../temp/package.xml
touch ../temp/ValidDynamicLinks-${sys}-${lang}.txt ../temp/StaticUrls-${sys}-${lang}.txt ../temp/StaticUrls-ie6-${lang}.txt ../temp/ValidUrls-${sys}-${lang}.txt ../temp/ValidUrls-${sys}-glb.txt ../temp/ValidUrls-win-${OS_ARCH}-${lang}.txt ../temp/StaticUrls-ofc-glb.txt ../temp/StaticUrls-ofc-${lang}.txt ../temp/StaticUrls-${sys}-glb.txt ../temp/StaticUrls-${lang}.txt ../temp/StaticUrls-glb.txt ../temp/StaticUrls-dotnet.txt ../temp/StaticUrls-cpp-${OS_ARCH}-glb.txt ../temp/StaticUrls-msse-${OS_ARCH}-glb.txt ../temp/StaticUrls-wddefs-${OS_ARCH}-glb.txt

test "$sys_old" && {
    touch ../temp/StaticUrls-${sys_old}-${lang}.txt ../temp/StaticUrls-${sys_old}-glb.txt
    }

rm -f ../temp/urls.txt

test $lang != glb && {
    cat ../temp/StaticUrls-${sys}-${lang}.txt >> ../temp/urls.txt
    cat ../temp/ValidUrls-${sys}-${lang}.txt >> ../temp/urls.txt
    cat ../temp/StaticUrls-ofc-${lang}.txt >> ../temp/urls.txt
    cat ../temp/StaticUrls-${lang}.txt >> ../temp/urls.txt
    }

cat ../temp/StaticUrls-ie6-${lang}.txt >> ../temp/urls.txt
cat ../temp/ValidUrls-${sys}-glb.txt >> ../temp/urls.txt
cat ../temp/ValidUrls-win-${OS_ARCH}-${lang}.txt >> ../temp/urls.txt
cat ../temp/StaticUrls-ofc-glb.txt >> ../temp/urls.txt
cat ../temp/StaticUrls-${sys}-glb.txt >> ../temp/urls.txt
cat ../temp/StaticUrls-glb.txt >> ../temp/urls.txt
cat ../temp/StaticUrls-dotnet.txt >> ../temp/urls.txt
cat ../temp/StaticUrls-dotnet-${OS_ARCH}-${lang}.txt >> ../temp/urls.txt
cat ../temp/StaticUrls-cpp-${OS_ARCH}-glb.txt >> ../temp/urls.txt
cat ../temp/StaticUrls-msse-${OS_ARCH}-glb.txt >> ../temp/urls.txt
cat ../temp/StaticUrls-wle-${OS_ARCH}-glb.txt >> ../temp/urls.txt 2>/dev/null
cat ../temp/StaticUrls-wddefs-${OS_ARCH}-glb.txt >> ../temp/urls.txt
test "$sys_old" && {
    cat ../temp/StaticUrls-${sys_old}-${lang}.txt >> ../temp/urls.txt
    cat ../temp/StaticUrls-${sys_old}-glb.txt >> ../temp/urls.txt
    }

echo "
***************************************
Found $(grep -c http: ../temp/urls.txt) patches...
"

#create needed directories
mkdir -p ../client/${sys}/glb ../client/${sys}/${lang} ../client/md

printheader

echo "Downloading patches for ${sys}..."
echo "Downloading static patches..."
if [ $lang != "glb" -a $sys != "w2k3-x64" ]; then
  doWget -i ../temp/StaticUrls-${sys}-${lang}.txt -P ../client/${sys}/${lang}
  doWget -i ../temp/StaticUrls-${lang}.txt -P ../client/win/${lang}
fi
doWget -i ../temp/StaticUrls-glb.txt -P ../client/win/glb
doWget -i ../temp/StaticUrls-${sys}-glb.txt -P ../client/${sys}/glb

if [ "$sys" == "ofc" ] && [ "$sys_old" != "" ]; then
   doWget -i ../temp/StaticUrls-${sys_old}-${lang}.txt -P ../client/${sys_old}/${lang}
   doWget -i ../temp/StaticUrls-${sys_old}-glb.txt -P ../client/${sys_old}/glb
fi

# dotnet/cpp
if [ "$dotnet" == "1" ]; then
    Vz=dotnet
    Txt=".Net "
#    down_msse_cpp
  echo "Downloading .Net framework..."

# combine ExcludeList-${Vz}-${OS_ARCH}.txt and ExcludeList-superseded.txt
  > ../temp/tmpExcludeList-${Vz}-${OS_ARCH}.txt

  test -f ../exclude/ExcludeList-${Vz}-${OS_ARCH}.txt && \
      cat ../exclude/ExcludeList-${Vz}-${OS_ARCH}.txt >> \
          ../temp/tmpExcludeList-${Vz}-${OS_ARCH}.txt

  test -f ../exclude/ExcludeList-superseded.txt && \
      cat ../exclude/ExcludeList-superseded.txt >> \
          ../temp/tmpExcludeList-${Vz}-${OS_ARCH}.txt

# substract tmpExcludeList-${Vz}-${OS_ARCH}.txt from Urls-${Vz}-${OS_ARCH}.txt
  > ../temp/ValidUrls-${Vz}-${OS_ARCH}.txt

  test -f ../temp/Urls-${Vz}-${OS_ARCH}.txt && \
    grep -F -i -v -f ../temp/tmpExcludeList-${Vz}-${OS_ARCH}.txt \
    ../temp/Urls-${Vz}-${OS_ARCH}.txt > \
    ../temp/ValidUrls-${Vz}-${OS_ARCH}.txt

# create download directory and get downloads
  mkdir -p ../client/${Vz}/${OS_ARCH}-glb
  doWget -i ../temp/StaticUrls-${Vz}.txt -P ../client/${Vz}
  doWget -i ../temp/ValidUrls-${Vz}-${OS_ARCH}.txt -P ../client/${Vz}/${OS_ARCH}-glb

  echo "Creating integrity database for ${Txt} ..."
    for Datei in ${Vz}/*.exe
    do
        test -s "$Datei" || rm -f "$Datei"
    done
    (cd ../client/md; hashdeep -c md5,sha1,sha256 -l ../${Vz}/*.exe | tr '/' '\\' > hashes-${Vz}.txt)

  echo "Creating integrity database for ${Txt}-${OS_ARCH}-glb ..."
  (cd ../client/md; hashdeep -c md5,sha1,sha256 -l -r ../${Vz}/${OS_ARCH}-glb | tr '/' '\\' > hashes-${Vz}-${OS_ARCH}-glb.txt)

    Vz=cpp
    Txt=CPP
    down_msse_cpp
fi


# MSSE
if [ "$msse" == "1" ]; then
    Vz=msse
    Txt=MSSE
    down_msse_cpp
fi

# wddefs
if [ "$wddefs" == "1" ]; then
    Vz=wddefs
    Txt="Windows Defender definition"
    down_msse_cpp
fi

# WLE
if [ "$wle" == "1" ]; then
    Vz=wle
    Txt="Windows Essentials"
    down_msse_cpp
fi

echo "Downloading patches for $sys $Origlang"
if [ $lang != glb -a "$sys" != "w2k3-x64" ]; then
  doWget -i ../temp/ValidUrls-${sys}-${lang}.txt -P ../client/${sys}/${lang}
  doWget -i ../temp/ValidUrls-win-${OS_ARCH}-${lang}.txt -P ../client/win/${lang}
fi
doWget -i ../temp/ValidUrls-${sys}-glb.txt -P ../client/${sys}/glb

printheader

echo "Validating patches for ${sys}..."
echo "Validating static patches..."

if [ $lang != glb -a $sys != "w2k3-x64" ]; then
  doWget -i ../temp/StaticUrls-${sys}-${lang}.txt -P ../client/${sys}/${lang}
  doWget -i ../temp/StaticUrls-${lang}.txt -P ../client/win/${lang}
fi
doWget -i ../temp/StaticUrls-${sys}-glb.txt -P ../client/${sys}/glb
doWget -i ../temp/StaticUrls-glb.txt -P ../client/win/glb

if [ "$sys" == "ofc" ] && [ "$sys_old" != "" ]; then
   doWget -i ../temp/StaticUrls-${sys_old}-${lang}.txt -P ../client/${sys_old}/${lang}
   doWget -i ../temp/StaticUrls-${sys_old}-glb.txt -P ../client/${sys_old}/glb
   echo "Creating integrity database for ${sys_old} ${lang}..."
   (cd ../client/md; hashdeep -c md5,sha1,sha256 -l -r ../${sys_old}/${lang} | tr '/' '\\' > hashes-${sys_old}-${lang}.txt)
   (cd ../client/md; hashdeep -c md5,sha1,sha256 -l -r ../${sys_old}/glb | tr '/' '\\' > hashes-${sys_old}-glb.txt)
fi

echo "Validating patches for $sys ${lang}..."
if [ $lang != glb ]; then
  doWget -i ../temp/ValidUrls-${sys}-${lang}.txt -P ../client/${sys}/${lang}
  echo "Creating integrity database for $sys-$lang ..."
  (cd ../client/md; hashdeep -c md5,sha1,sha256 -l -r ../${sys}/${lang} | tr '/' '\\' > hashes-${sys}-${lang}.txt)
fi
doWget -i ../temp/ValidUrls-${sys}-glb.txt -P ../client/${sys}/glb
if [ -d ../client/${sys}/glb ]; then
  echo "Creating integrity database for $sys-glb ..."
  (cd ../client/md; hashdeep -c md5,sha1,sha256 -l -r ../${sys}/glb | tr '/' '\\' > hashes-${sys}-glb.txt)
fi

if [ $lang != glb -a $sys != "w2k3-x64" ] ; then
  doWget -i ../temp/ValidUrls-win-${OS_ARCH}-${lang}.txt -P ../client/win/${lang}
fi
if [ $lang == glb ] ; then
  doWget -i ../temp/ValidUrls-win-${OS_ARCH}-${lang}.txt -P ../client/win/${lang}
fi

if [ -d ../client/win/${lang} -a $lang != glb  ]; then
  echo "Creating integrity database for win-$lang ..."
  (cd ../client/md; hashdeep -c md5,sha1,sha256 -l -r ../win/${lang} | tr '/' '\\' > hashes-win-${lang}.txt)
fi
if [ -d ../client/win/glb ]; then
  echo "Creating integrity database for win-glb ..."
  (cd ../client/md; hashdeep -c md5,sha1,sha256 -l -r ../win/glb | tr '/' '\\' > hashes-win-glb.txt)
fi

if [ -d ../client/wsus ]; then
  echo "Creating integrity database for WSUS ..."
  (cd ../client/md; hashdeep -c md5,sha1,sha256 -l -r ../wsus | tr '/' '\\' > hashes-wsus.txt)
fi

echo "**************************************
$(grep -c http: ../temp/urls.txt) patches successfully downloaded.
"

if [ "$CLEANUP_DOWNLOADS" != "0" ]; then
  echo "Cleaning up ..."
  echo "Cleaning up client directory for $sys $Origlang"
  cat ../temp/StaticUrls-${sys}-${lang}.txt >> ../temp/ValidUrls-${sys}-${lang}.txt
  cleanup "../temp/ValidUrls-${sys}-${lang}.txt" "../client/${sys}/${lang}"
  echo "Cleaning up client directory for $sys glb"
  cat ../temp/StaticUrls-${sys}-glb.txt >> ../temp/ValidUrls-${sys}-glb.txt
  cleanup "../temp/ValidUrls-${sys}-glb.txt" "../client/${sys}/glb"
  case $sys in
    w6[0-3]*|w2k3-x64)
    ;;
    *)
    echo "Cleaning up client directory for win $Origlang"
    cat ../temp/StaticUrls-${lang}.txt > ../temp/ValidUrls-${lang}.txt
    cat ../temp/ValidUrls-win-${OS_ARCH}-${lang}.txt >> ../temp/ValidUrls-${lang}.txt
    cleanup "../temp/ValidUrls-${lang}.txt" "../client/win/${lang}"
    ;;
  esac
fi

echo "Writing builddate.txt file..."
date +%d.%m.%Y > ../client/builddate.txt

if [ "$createiso" == "1" ]; then
  bash ./CreateISOImage.sh $sys $Origlang $param2 $param3 $param5 $param7 $param8
fi

exit 0

# 

# ========================================================================
# $Id: DownloadUpdates.sh,v 1.15 2014-12-21 17:03:31+01 HHullen Exp $
# $Log: DownloadUpdates.sh,v $
# Revision 1.15  2014-12-21 17:03:31+01  HHullen
# Fehler beim Befüllen des win-Verzeichnisses korrigiert
#
# Revision 1.14  2014-12-16 17:47:18+01  hhullen
# kleine Korrekturen
#
# Revision 1.13  2014-12-16 16:44:51+01  hhullen
# wle eingearbeitet, Static-Liste überarbeitet, ISO überarbeitet
#
# Revision 1.12  2014-12-11 15:25:16+01  hhullen
# w6x-all eingearbeitet, wle vorbereitet
#
# Revision 1.11  2014-09-01 17:16:38+02  HHullen
# REVISION_ID ergänzt
#
# Revision 1.10  2014-08-06 11:47:01+02  HHullen
# Umwandlung von DOS-Datei nach Linux mit POSIX-konformen Befehlen
#
# Revision 1.9.1 2014-03-05 09:52:00+01  twittrock
# builddate.txt-Erzeugung eingefügt
#
# Revision 1.9  2013-12-27 17:25:29+01  HHullen
# Windows 8.1 (w63) ergänzt
#
# Revision 1.8  2013-11-27 16:24:00+01  HHullen
# Burmeister-Patch
#
# Revision 1.7  2013-11-27 16:04:58+01  HHullen
# Version 8.8
#
# Revision 1.6  2013-10-06 13:42:48+02  HHullen
# Prüfung, ob in custom Dateien liegen
#
# Revision 1.5  2013-04-18 15:06:07+02  HHullen
# Vergleichs-Liste von talou abgearbeitet
#
# Revision 1.4  2013-04-11 11:21:19+02  HHullen
# Sprach-Meldung korrigiert
#
# Revision 1.3  2013-03-10 15:27:16+01  HHullen
# verkuerzt
#
# Revision 1.2  2013-03-04 18:08:34+01  HHullen
# OS_Arch korrigiert, Fehlermeldungen sauber abgefangen
#
# Revision 1.4  2012-12-17 16:53:26+01  HHullen
# UPDATE_LANGUAGES korrigiert
#
# Revision 1.3  2012-12-17 14:23:01+01  HHullen
# array gekuerzt
#
# Revision 1.2  2012-12-17 13:34:27+01  HHullen
# altes OfficeUpdate
#
# Revision 1.1  2012-12-14 12:34:46+01  HHullen
# ofc ok
#
# Revision 1.5  2012-10-29 18:29:30+01  HHullen
# verschlankt
#
# Revision 1.4  2012-10-26 12:59:00+02  HHullen
# OS-Auswahl ueberarbeitet
#
# Revision 1.3  2012-10-25 17:00:21+02  HHullen
# verschlankt; Windows 8 ergaenzt
#
