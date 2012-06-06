#!/bin/bash

##########################################################
###           WSUS Offline Update Downloader           ###
###                  for Linux systems                 ###
###                   v. 7.3.2+ (r363)                 ###
###                                                    ###
###   http://www.wsusoffline.net/                      ###
###   Authors: Tobias Breitling, Stefan Joehnke,       ###
###            Walter Schiessberg                      ###
###   modified by T. Wittrock                          ###
##########################################################
# Exit codes:
# 0 - success
# 1 - file error
# 2 - connection error

printusage()
{
cat << END
  Invalid parameter: $@

Usage: `basename $0` [system] [language] [parameter]

Supported systems:
wxp, wxp-x64, w2k3, w2k3-x64, w60, w60-x64, w61, w61-x64, o2k3, o2k7, o2k10, ofc, all-x64, all-x86

Supported languages:
enu, deu, nld, esn, fra, ptg, ptb, ita, rus, plk, ell, csy
dan, nor, sve, fin, jpn, kor, chs, cht, hun, trk, ara, heb

Parameters:
/excludesp - do not download servicepacks
/makeiso   - create ISO image
/dotnet    - download .NET framework
/msse      - download Microsoft Security Essentials installation files
/wddefs    - download Windows Defender definition files
/nocleanup - do not cleanup client directory
/proxy     - define proxy server (/proxy http://[username:password@]<server>:<port>)

Example: `basename $0` wxp deu /dotnet /makeiso
END
exit 1
}

checkconfig()
{
C=`which cabextract 2> /dev/null`
M=`which md5deep 2> /dev/null`
S=`which xmlstarlet 2> /dev/null`
T=`which xml 2> /dev/null`
D=`which dos2unix 2> /dev/null`
D2=$(which fromdos 2> /dev/null)
xml=""

if [ ! -x "$C" ]; then
  cat << END

Please install cabextract.

Command in Fedora:
yum install cabextract

Command in Debian:
apt-get install cabextract

Command in SuSE:
zypper install cabextract
END
  exit 1
fi

if [ ! -x "$M" ]; then
  cat << END

Please install md5deep.

Command in Fedora:
yum install md5deep

Command in Debian/Ubuntu:
apt-get install md5deep

Command in SuSE:
zypper install md5deep
END
  exit 1
fi

if [ ! -x "$S" ] && [ ! -x "$T" ]; then
  cat << END

Please install xmlstarlet.

Command in Fedora:
yum install xmlstarlet

Command in Debian:
apt-get install xmlstarlet

Command in SuSE:
zypper install xmlstarlet

END
  exit 1
else
  if [ -x "$S" ]; then
    xml="xmlstarlet"
  fi
  if [ -x "$T" ]; then
    xml="xml"
  fi
fi

if [ ! -x "$D" ] && [ ! -x "$D2" ]; then
# neu, fuer Slackware
test -s /etc/slackware-version && {
  alias dos2unix='recode ibmpc..lat1'
  return 0
}
# Ende Slackware-Einschub
cat << END

Please install dos2unix.

Command in Fedora:
yum install dos2unix

Command in Debian/Ubuntu:
apt-get install tofrodos

Command in SuSE:
zypper install dos2unix

END
  exit 1
fi
# fromdos vorhanden --> alias anlegen
if [[ "$D{2}" && ! -x "${D}" ]]
 then
  alias dos2unix=$(which fromdos)
  # alias-Ausfuehrung in shell erlauben
  shopt -s expand_aliases
fi
# Ende alias
}

printtimeout()
{
cat << END

No connection could be established
Please check your internet connection.
END
exit 2
}

evaluateparams()
{
syslist=("wxp" "wxp-x64" "w2k3" "w2k3-x64" "w60" "w60-x64" "w61" "w61-x64" "o2k3" "o2k7" "o2k10" "ofc" "all-x86" "all-x64")
langlist=("enu" "deu" "nld" "esn" "fra" "ptg" "ptb" "ita" "rus" "plk" "ell" "csy" "dan" "nor" "sve" "fin" "jpn" "kor" "chs" "cht" "hun" "trk" "ara" "heb")
paramlist=("/excludesp" "/dotnet" "/msse" "/makeiso" "/nocleanup" "/proxy" "/wddefs")
EXCLUDE_SP="0"
EXCLUDE_STATICS="0"
CLEANUP_DOWNLOADS="1"
createiso="0"
dotnet="0"
msse="0"
wddefs="0"
param1=""
param2=""
param3=""
param4=""
param5=""
param6=""
param7=""

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
case "$lang" in
  enu)
    LANG_SHORT=en
    ;;
  fra)
    LANG_SHORT=fr
    ;;
  esn)
    LANG_SHORT=es
    ;;
  jpn)
    LANG_SHORT=ja
    ;;
  kor)
    LANG_SHORT=ko
    ;;
  rus)
    LANG_SHORT=ru
    ;;
  ptg)
    LANG_SHORT=pt
    ;;
  ptb)
    LANG_SHORT=pt-br
    ;;
  deu)
    LANG_SHORT=de
    ;;
  nld)
    LANG_SHORT=nl
    ;;
  ita)
    LANG_SHORT=it
    ;;
  chs)
    LANG_SHORT=zh-cn
    ;;
  cht)
    LANG_SHORT=zh-tw
    ;;
  plk)
    LANG_SHORT=pl
    ;;
  hun)
    LANG_SHORT=hu
    ;;
  csy)
    LANG_SHORT=cs
    ;;
  sve)
    LANG_SHORT=sv
    ;;
  trk)
    LANG_SHORT=tr
    ;;
  ell)
    LANG_SHORT=el
    ;;
  ara)
    LANG_SHORT=ar
    ;;
  heb)
    LANG_SHORT=he
    ;;
  dan)
    LANG_SHORT=da
    ;;
  nor)
    LANG_SHORT=no
    ;;
  fin)
    LANG_SHORT=fi
    ;;
esac

#determining parameters
for i in ${paramlist[@]}; do
  if echo $@ | grep /makeiso > /dev/null 2>&1; then
    param1=/makeiso
    createiso="1"
  fi
  if echo $@ | grep /dotnet > /dev/null 2>&1; then
    param2=/dotnet
    dotnet="1"
  fi
  if echo $@ | grep /excludesp > /dev/null 2>&1; then
    param3=/excludesp
    EXCLUDE_SP="1"
  fi
  if echo $@ | grep /nocleanup > /dev/null 2>&1; then
    param4=/nocleanup
    CLEANUP_DOWNLOADS="0"
  fi
  if echo $@ | grep /msse > /dev/null 2>&1; then
    param5=/msse
    msse="1"
  fi
  if echo $@ | grep /wddefs > /dev/null 2>&1; then
    param7=/wddefs
    wddefs="1"
  fi
done

if [ "$sys" == "w2k3" -o "$sys" == "w2k3-x64" ]; then
  msse="0"
fi

#determining proxy
if [ "$3" == "/proxy" ]; then
  http_proxy="$4"
  param6="$3 $4"
fi

if [ "$4" == "/proxy" ]; then
  http_proxy="$5"
  param6="$4 $5"
fi

if [ "$5" == "/proxy" ]; then
  http_proxy="$6"
  param6="$5 $6"
fi

if [ "$6" == "/proxy" ]; then
  http_proxy="$7"
  param6="$6 $7"
fi

if [ "$7" == "/proxy" ]; then
  http_proxy="$8"
  param6="$7 $8"
fi

if [ "$8" == "/proxy" ]; then
  http_proxy="$9"
  param6="$8 $9"
fi

if [ "$sys" == "" -o "$lang" == "" ]; then
  printusage $@
fi
}

doWget()
{
mydate=`date +%Y%m%d`
echo "wget -nv -N --timeout=120 $*" | tee -a ../temp/wget.$mydate
wget -nv -N --timeout=120 $* 2>>../temp/wget.$mydate
return $?
}

checkconnection()
{
OUT=`wget --connect-timeout=1 --tries=1 http://www.wsusoffline.net/index.html 2>&1`
if [ $? -ne 0 ]; then
  printf "failed to download:\n"
  printf -- "$OUT"
  exit 2
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
syslist=("wxp" "wxp-x64" "w2k3" "w2k3-x64" "w60" "w60-x64" "w61" "w61-x64" "o2k3" "o2k7" "o2k10" "ofc" "all-x86" "all-x64")
cat << END
Please select your OS:
[1] Windows XP                   [5] Windows Vista / Server 2008
[2] Windowx XP 64 bit            [6] Windows Vista / Server 2008 64 bit
[3] Windows Server 2003          [7] Windows 7
[4] Windows Server 2003 64 bit   [8] Windows 7 / Server 2008 R2 64 bit

[9] Office 2003                 [10] Office 2007
[11] Office 2010                [12] Office updates only (2003 - 2010)

[13] All 32 bit                 [14] All 64 bit
END
read syschoice
echo
let syschoice=syschoice-1
sys_old=""
for i in ${!syslist[@]}; do
  if [ "$syschoice" == "$i" ]; then
    sys=${syslist[i]}
  fi
done
if [ "$sys" == "wxp-x64" ]; then
  sys="w2k3-x64"
fi
if [ "$sys" == "" ]; then
  echo "Program aborted."
  echo
  exit 1
fi
}

getlanguage()
{
langlist=("enu" "deu" "nld" "esn" "fra" "ptg" "ptb" "ita" "rus" "plk" "ell" "csy" "dan" "nor" "sve" "fin" "jpn" "kor" "chs" "cht" "hun" "trk" "ara" "heb")
langindex=("a" "b" "c" "d" "e" "f" "g" "h" "i" "j" "k" "l" "m" "n" "o" "p" "q" "r" "s" "t" "u" "v" "w" "x")

if [ "$sys" == "w60" -o "$sys" == "w60-x64" -o "$sys" == "w61" -o "$sys" == "w61-x64" ]; then
  lang="glb"
else
  cat << END
Please select your OS language:

[a] enu           [b] deu         [c] nld         [d] esn
[e] fra           [f] ptg         [g] ptb         [h] ita
[i] rus           [j] plk         [k] ell         [l] csy
[m] dan           [n] nor         [o] sve         [p] fin
[q] jpn           [r] kor         [s] chs         [t] cht
[u] hun           [v] trk         [w] ara         [x] heb
END
  read langchoice
  echo
  for i in ${!langindex[@]}; do
    if [ "$langchoice" == "${langindex[i]}" ]; then
      langnr=$i
      lang=${langlist[i]}
    fi
  done
  if [ "$lang" == "" ]; then
    echo "Program aborted."
  exit 1
  fi
fi
}

getservicepack()
{
EXCLUDE_SP="1"
echo "Download Service Packs? [y/n]"
read addsp
if [ "$addsp" == "y" ]; then
  EXCLUDE_SP="0"
else
  param3="/excludesp"
fi
}

getdotnet()
{
dotnet="0"
echo "Download .Net framework? [y/n]"
read adddotnet
if [ "$adddotnet" == "y" ]; then
  dotnet="1"
  param2="/dotnet"
fi
}

getmsse()
{
msse="0"
if [ "$sys" != "w2k3" -o "$sys" != "w2k3-x64" ]; then
  echo "Download Microsoft Security Essentials installation files? [y/n]"
  read addmsse
  if [ "$addmsse" == "y" ]; then
    msse="1"
    param5="/msse"
  fi
fi
}

getwddefs()
{
wddefs="0"
echo "Download Microsoft Windows Defender definition files? [y/n]"
read addwddefs
if [ "$addwddefs" == "y" ]; then
  wddefs="1"
  param7="/wddefs"
fi
}

getproxy()
{
echo
echo "Please specify your proxy (default: none, http://[username:password@]<server>:<port>])"
read http_proxy
}

makeiso()
{
createiso="0"
echo "Create ISO-Image after download? [y/n]"
read addiso
if [ "$addiso" == "y" ]; then
  createiso="1"
  param1="/makeiso"
fi
}

cleanup()
{
file="$1"
path="$2"
rm -f ../temp/cleanup.txt
touch ../temp/cleanup.txt
for i in $(ls -l "$path" | tr -s " " | cut -d " " -f 9 | grep "\b"); do
  result=$(grep "${i}" "${file}")
  if [ "$result" == "" ] && [ "$i" != "ie6setup" ]; then
    echo "$i" >> ../temp/cleanup.txt
  fi
done
currentpath=$(pwd)
cd "$path"
rm -f `cat "$currentpath/../temp/cleanup.txt"`
cd "$currentpath"
}

printheader()
{
clear
cat << END
**********************************************************
***           WSUS Offline Update Downloader           ***
***                  for Linux systems                 ***
***                   v. 7.3.2+ (r363)                 ***
***                                                    ***
***   http://www.wsusoffline.net/                      ***
***   Authors: Tobias Breitling, Stefan Joehnke,       ***
***            Walter Schiessberg                      ***
**********************************************************

END
}


printheader

#set working directory
cd "$( dirname "$(readlink -f "$0")" )"
PATH_PWD="$( pwd )"

#check for required packages
checkconfig
printheader

#check if parameters are valid
if [ "$1" != "" ]; then
  externparam="1"
  evaluateparams $1 $2 $3 $4 $5 $6 $7 $8 $9
fi

#get parameters
if [ "$1" == "" ]; then
  getsystem
  getlanguage
  getservicepack
  getdotnet
  getmsse
  getwddefs
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
mkdir -p ../client/bin
mkdir -p ../client/wsus
mkdir -p ../temp
rm -f ../temp/*

#convert files to Linux format
find ../exclude/ -type f -exec dos2unix "{}" + 2>&1 \; || echo find has a problem with exclude
find ../xslt/ -type f -exec dos2unix "{}" + 2>&1 \; || echo find has a problem with xslt
find ../static/ -type f -exec dos2unix "{}" + 2>&1 \; || echo find has a problem with static

printheader

cat << END
  Your choice
  System: $sys
  Language: $lang
  Parameter: $param1 $param2 $param3 $param4 $param5 $param7
  Proxy: $http_proxy
END

if [ "$externparam" != "1" ]; then
  echo
  echo "Do you want to download now? [y/n]"
  read response
else
  response="y"
fi

if [ "$response" != "y" ]; then
  echo
  echo "Program aborted."
  echo
  exit 1
fi

if [ "$sys" == "all-x64" ]; then
  /bin/bash DownloadUpdates.sh w2k3-x64 $lang $param2 $param3 $param4 $param5 $param6 $param7
  /bin/bash DownloadUpdates.sh w60-x64 $lang $param2 $param3 $param4 $param5 $param6 $param7
  /bin/bash DownloadUpdates.sh w61-x64 $lang $param2 $param3 $param4 $param5 $param6 $param7
  if [ "$param1" == "/makeiso" ]; then
    /bin/bash ./CreateISOImage.sh $sys $lang $param2 $param3
    rc=$?
  fi
  exit $rc
fi

if [ "$sys" == "all-x86" ]; then
  /bin/bash DownloadUpdates.sh wxp $lang $param2 $param3 $param4 $param5 $param6 $param7
  /bin/bash DownloadUpdates.sh w2k3 $lang $param2 $param3 $param4 $param5 $param6 $param7
  /bin/bash DownloadUpdates.sh w60 $lang $param2 $param3 $param4 $param5 $param6 $param7
  /bin/bash DownloadUpdates.sh w61 $lang $param2 $param3 $param4 $param5 $param6 $param7
  if [ "$param1" == "/makeiso" ]; then
    /bin/bash ./CreateISOImage.sh $sys $lang $param2 $param3
    rc=$?
  fi
  exit $rc
fi

echo "Downloading most recent Windows Update Agent and catalog file..."
doWget -i ../static/StaticDownloadLinks-wsus.txt -P ../client/wsus

echo "Determining static URLs for ${sys} ${lang}..."

if [ "$sys" == "ofc" ] && [ "$sys_old" != "" ]; then
  echo "Determining static URLs for ${sys_old} ${lang}..."
   static1="../static/StaticDownloadLinks-${sys_old}-x86-${lang}.txt"
  if [ -f "$static1" ]; then
     if [ "$EXCLUDE_SP" == "0" ]; then
      cat $static1 >> ../temp/StaticUrls-${sys_old}-${lang}.txt
     fi
    if [ "$EXCLUDE_SP" == "1" ]; then
     grep -i -v -f ../exclude/ExcludeList-SPs.txt $static1 > ../temp/StaticUrls-${sys_old}-${lang}.txt
    fi
  fi

  static2="../static/StaticDownloadLinks-${sys_old}-${lang}.txt"
  if [ -f "$static2" ]; then
    if [ "$EXCLUDE_SP" == "0" ]; then
      cat $static2 >> ../temp/StaticUrls-${sys_old}-${lang}.txt
    fi
    if [ "$EXCLUDE_SP" == "1" ]; then
      grep -i -v -f ../exclude/ExcludeList-SPs.txt $static2 > ../temp/StaticUrls-${sys_old}-${lang}.txt
    fi
  fi
     static1="../static/StaticDownloadLinks-${sys_old}-x86-glb.txt"
  if [ -f "$static1" ]; then
     if [ "$EXCLUDE_SP" == "0" ]; then
      cat $static1 >> ../temp/StaticUrls-${sys_old}-glb.txt
     fi
    if [ "$EXCLUDE_SP" == "1" ]; then
     grep -i -v -f ../exclude/ExcludeList-SPs.txt $static1 > ../temp/StaticUrls-${sys_old}-glb.txt
    fi
  fi

  static2="../static/StaticDownloadLinks-${sys_old}-glb.txt"
  if [ -f "$static2" ]; then
    if [ "$EXCLUDE_SP" == "0" ]; then
      cat $static2 >> ../temp/StaticUrls-${sys_old}-glb.txt
    fi
    if [ "$EXCLUDE_SP" == "1" ]; then
      grep -i -v -f ../exclude/ExcludeList-SPs.txt $static2 > ../temp/StaticUrls-${sys_old}-glb.txt
    fi
  fi
fi

static1="../static/StaticDownloadLinks-${sys}-x86-${lang}.txt"
if [ -f "$static1" ]; then
  if [ "$EXCLUDE_SP" == "0" ]; then
    cat $static1 >> ../temp/StaticUrls-${sys}-${lang}.txt
  fi
  if [ "$EXCLUDE_SP" == "1" ]; then
   grep -i -v -f ../exclude/ExcludeList-SPs.txt $static1 > ../temp/StaticUrls-${sys}-${lang}.txt
  fi
fi

static2="../static/StaticDownloadLinks-${sys}-${lang}.txt"
if [ -f "$static2" ]; then
  if [ "$EXCLUDE_SP" == "0" ]; then
    cat $static2 >> ../temp/StaticUrls-${sys}-${lang}.txt
  fi
  if [ "$EXCLUDE_SP" == "1" ]; then
    grep -i -v -f ../exclude/ExcludeList-SPs.txt $static2 > ../temp/StaticUrls-${sys}-${lang}.txt
  fi
fi

static3="../static/StaticDownloadLinks-win-x86-${lang}.txt"
static4="../static/StaticDownloadLinks-win-x86-glb.txt"
if [ "$sys" != "w60" ] && [ "$sys" != "$w60-x64" ] && [ "$sys" != "w61" ] && [ "$sys" != "$w61-x64" ] && [ "$sys" != "w2k3-x64" ]; then
  if [ -f "$static3" ]; then
    cat $static3 > ../temp/StaticUrls-${lang}.txt
  fi
  if [ -f "$static4" ]; then
    cat $static4 > ../temp/StaticUrls-glb.txt
  fi
fi

if [ "$sys" != "w60" ] && [ "$sys" != "w60-x64" ] && [ "$sys" != "w61" ] && [ "$sys" != "w61-x64" ]; then
  static4="../static/StaticDownloadLinks-${sys}-x86-glb.txt"
  if [ -f "$static4" ]; then
    cat $static4 > ../temp/StaticUrls-${sys}-glb.txt
  fi
fi

static5="../static/StaticDownloadLinks-${sys}-glb.txt"
if [ -f "$static5" ]; then
    cat $static5 > ../temp/StaticUrls-${sys}-glb.txt
fi

if [ "$dotnet" == "1" ]; then
  cp ../static/StaticDownloadLinks-dotnet.txt ../temp/StaticUrls-dotnet.txt
  cp ../static/StaticDownloadLinks-cpp-x86-glb.txt ../temp/StaticUrls-cpp-x86-glb.txt
  cp ../static/StaticDownloadLinks-cpp-x64-glb.txt ../temp/StaticUrls-cpp-x64-glb.txt
fi

if [ "$msse" == "1" ]; then
  if echo $sys | grep x64 > /dev/null 2>&1; then
    cp ../static/StaticDownloadLinks-msse-x64-glb.txt ../temp/StaticUrls-msse-x64-glb.txt
  else
    cp ../static/StaticDownloadLinks-msse-x86-glb.txt ../temp/StaticUrls-msse-x86-glb.txt
  fi
fi
if [ "$wddefs" == "1" ]; then
  if echo $sys | grep x64 > /dev/null 2>&1; then
    cp ../static/StaticDownloadLink-wddefs-x64-glb.txt ../temp/StaticUrls-wddefs-x64-glb.txt
  else
    cp ../static/StaticDownloadLink-wddefs-x86-glb.txt ../temp/StaticUrls-wddefs-x86-glb.txt
  fi
fi

echo "Adding Custom-Links..."
if [ -f ../static/custom/StaticDownloadLinks-${sys}-x86-${lang}.txt ]; then
    cat ../static/custom/StaticDownloadLinks-${sys}-x86-${lang}.txt >> ../temp/StaticUrls-${sys}-${lang}.txt
fi
if [ -f ../static/custom/StaticDownloadLinks-${sys}-${lang}.txt ]; then
   cat ../static/custom/StaticDownloadLinks-${sys}-${lang}.txt >> ../temp/StaticUrls-${sys}-${lang}.txt
fi
if [ "$sys" != "w60" ] && [ "$sys" != "$w60-x64" ] && [ "$sys" != "w61" ] && [ "$sys" != "$w61-x64" ] && [ "$sys" != "w2k3-x64" ]; then
  if [ -f ../static/custom/StaticDownloadLinks-win-x86-${lang}.txt ]; then
    cat ../static/custom/StaticDownloadLinks-win-x86-${lang}.txt >> ../temp/StaticUrls-${lang}.txt
  fi
  if [ -f ../static/custom/StaticDownloadLinks-win-x86-glb.txt ]; then
    cat ../static/custom/StaticDownloadLinks-win-x86-glb.txt >> ../temp/StaticUrls-glb.txt
  fi
fi
if [ "$sys" != "w60" ] && [ "$sys" != "w60-x64" ] && [ "$sys" != "w61" ] && [ "$sys" != "w61-x64" ]; then
  if [ -f ../static/custom/StaticDownloadLinks-${sys}-x86-glb.txt ]; then
    cat ../static/custom/StaticDownloadLinks-${sys}-x86-glb.txt >> ../temp/StaticUrls-${sys}-glb.txt
  fi
fi
if [ -f ../static/custom/StaticDownloadLinks-${sys}-glb.txt ]; then
    cat ../static/custom/StaticDownloadLinks-${sys}-glb.txt >> ../temp/StaticUrls-${sys}-glb.txt
fi
if [ "$dotnet" == "1" ]; then
  if [ -f ../static/custom/StaticDownloadLinks-dotnet.txt ]; then
    cat ../static/custom/StaticDownloadLinks-dotnet.txt >> ../temp/StaticUrls-dotnet.txt
  fi
  if [ -f ../static/custom/StaticDownloadLinks-cpp-x86-glb.txt ]; then
    cat ../static/custom/StaticDownloadLinks-cpp-x86-glb.txt >> ../temp/StaticUrls-cpp-x86-glb.txt
  fi
  if [ -f ../static/custom/StaticDownloadLinks-cpp-x64-glb.txt ]; then
    cat ../static/custom/StaticDownloadLinks-cpp-x64-glb.txt >> ../temp/StaticUrls-cpp-x64-glb.txt
  fi
fi
if [ "$msse" == "1" ]; then
  if [ -f ../static/custom/StaticDownloadLinks-msse-x64-glb.txt ]; then
    cat ../static/custom/StaticDownloadLinks-msse-x64-glb.txt >> ../temp/StaticUrls-msse-x64-glb.txt
  fi
  if [ -f ../static/custom/StaticDownloadLinks-msse-x86-glb.txt ]; then
    cat ../static/custom/StaticDownloadLinks-msse-x86-glb.txt >> ../temp/StaticUrls-msse-x86-glb.txt
  fi
fi
if [ "$wddefs" == "1" ]; then
  if [ -f ../static/custom/StaticDownloadLink-wddefs-x64-glb.txt ]; then
    cat ../static/custom/StaticDownloadLink-wddefs-x64-glb.txt >> ../temp/StaticUrls-wddefs-x64-glb.txt
  fi
  if [ -f ../static/custom/StaticDownloadLink-wddefs-x86-glb.txt ]; then
    cat ../static/custom/StaticDownloadLink-wddefs-x86-glb.txt >> ../temp/StaticUrls-wddefs-x86-glb.txt
  fi
fi


cd ../temp
echo "Extracting Windows update catalogue file package.xml..."
cp ../client/wsus/wsusscn2.cab ../client/wsus/wsusscn2_1.cab
cabextract -q -F package.cab ../client/wsus/wsusscn2_1.cab
cabextract -q -F package.xml package.cab
rm package.cab
rm ../client/wsus/wsusscn2_1.cab
cd ../sh

supersed="0"
if [ -f ../exclude/ExcludeList-superseded.txt ]; then
  if [ "`stat -c %Y ../client/wsus/wsusscn2.cab`" -gt "`stat -c %Y ../exclude/ExcludeList-superseded.txt`" ]; then
    supersed="1"
  else
    echo "Found valid list of superseded updates..."
  fi
else
  supersed="1"
fi
if [ "$supersed" == "1" ]; then
echo "Determining superseded updates (please be patient, this will take a while)..."
$xml tr ../xslt/ExtractUpdateRevisionIds.xsl ../temp/package.xml > ../temp/ValidUpdateRevisionIds.txt
$xml tr ../xslt/ExtractSupersedingRevisionIds.xsl ../temp/package.xml > ../temp/SupersedingRevisionIds.txt
sort -u ../temp/SupersedingRevisionIds.txt -o ../temp/SupersedingRevisionIds.txt
grep -F -f ../temp/SupersedingRevisionIds.txt ../temp/ValidUpdateRevisionIds.txt >> ../temp/ValidSupersedingRevisionIds.txt
rm ../temp/ValidUpdateRevisionIds*.txt
rm ../temp/SupersedingRevisionIds*.txt
$xml tr ../xslt/ExtractSupersededUpdateRelations.xsl ../temp/package.xml > ../temp/SupersededUpdateRelations.txt
grep -F -f ../temp/ValidSupersedingRevisionIds.txt ../temp/SupersededUpdateRelations.txt > ../temp/ValidSupersededUpdateRelations.txt
rm ../temp/SupersededUpdateRelations.txt
rm ../temp/ValidSupersedingRevisionIds.txt
$xml tr ../xslt/ExtractBundledUpdateRelationsAndFileIds.xsl ../temp/package.xml > ../temp/BundledUpdateRelationsAndFileIds.txt
supersed=`cat ../temp/ValidSupersededUpdateRelations.txt`
arr=$(echo $supersed | tr " " "\n")
for x in $arr
  do
  temp=(${x//,/ })
  echo "${temp[0]}" >> ../temp/ValidSupersededRevisionIds.txt
  done
grep -F -f ../temp/ValidSupersededRevisionIds.txt ../temp/BundledUpdateRelationsAndFileIds.txt > ../temp/SupersededRevisionAndFileIds.txt
supersed=`cat ../temp/SupersededRevisionAndFileIds.txt`
arr=$(echo $supersed | tr " " "\n")
for x in $arr
  do
  temp=(${x//,/ })
  temp=(${temp[1]//;/ })
   if [ "${temp[0]}" != "" ]; then
    echo "${temp[0]}" >> ../temp/SupersededFileIds.txt
  fi
  done
rm ../temp/SupersededRevisionAndFileIds.txt
sort -u ../temp/SupersededFileIds.txt > ../temp/SupersededFileIdsSorted.txt
rm ../temp/SupersededFileIds.txt
grep -v '#' ../temp/SupersededFileIdsSorted.txt > ../temp/SupersededFileIdsUnique.txt
rm ../temp/SupersededFileIdsSorted.txt
$xml tr ../xslt/ExtractUpdateCabExeIdsAndLocations.xsl ../temp/package.xml > ../temp/UpdateCabExeIdsAndLocations.txt
sort -u ../temp/UpdateCabExeIdsAndLocations.txt -o ../temp/UpdateCabExeIdsAndLocations.txt
grep -F -f ../temp/SupersededFileIdsUnique.txt ../temp/UpdateCabExeIdsAndLocations.txt >> ../temp/SupersededCabExeIdsAndLocations.txt
rm ../temp/SupersededFileIdsUnique.txt
rm ../temp/UpdateCabExeIdsAndLocations.txt
if [ -f ../exclude/ExcludeList-superseded.txt ]; then
  rm ../exclude/ExcludeList-superseded.txt
fi
supersed=`cat ../temp/SupersededCabExeIdsAndLocations.txt`
arr=$(echo $supersed | tr " " "\n")
for x in $arr
  do
  temp=(${x//,/ })
  temp=`basename ${temp[1]} .exe`
  temp=`basename $temp .cab`
  echo "$temp" >> ../exclude/ExcludeList-superseded.txt
  done
echo "Done."
fi


echo "Determining update URLs for ${sys} ${lang}..."
download1="../xslt/ExtractDownloadLinks-${sys}-${lang}.xsl"
download2="../xslt/ExtractDownloadLinks-${sys}-x86-${lang}.xsl"
valid1="../xslt/ExtractValidIds-${sys}.xsl"
valid2="../xslt/ExtractValidIds-${sys}-x86.xsl"
expired1="../xslt/ExtractExpiredIds-${sys}.xsl"
expired2="../xslt/ExtractExpiredIds-${sys}-x86.xsl"
exclude1="../temp/tmpExcludeList-${sys}.txt"
exclude2="../temp/tmpExcludeList-${sys}-x86.txt"
glb1="../xslt/ExtractDownloadLinks-${sys}-glb.xsl"
glb2="../xslt/ExtractDownloadLinks-${sys}-x86-glb.xsl"
verify="../temp/tmpUrls-${sys}-${lang}.txt"

if [ -f "$valid1" ]; then
  $xml tr ../xslt/ExtractValidIds-${sys}.xsl ../temp/package.xml > ../temp/Validid-${sys}.txt
fi
if [ -f "$valid2" ]; then
  $xml tr ../xslt/ExtractValidIds-${sys}-x86.xsl ../temp/package.xml > ../temp/Validid-${sys}.txt
fi
if [ -f "$expired1" ]; then
  $xml tr ../xslt/ExtractExpiredIds-${sys}.xsl ../temp/package.xml > ../temp/Expiredid-${sys}.txt
fi
if [ -f "$expired2" ]; then
  $xml tr ../xslt/ExtractExpiredIds-${sys}-x86.xsl ../temp/package.xml > ../temp/Expiredid-${sys}.txt
fi
if [ -f "$download1" ]; then
  $xml tr ../xslt/ExtractDownloadLinks-${sys}-${lang}.xsl ../temp/package.xml > ../temp/Urls-${sys}-${lang}.txt
fi
if [ -f "$download2" ]; then
  $xml tr ../xslt/ExtractDownloadLinks-${sys}-x86-${lang}.xsl ../temp/package.xml > ../temp/Urls-${sys}-${lang}.txt
fi
if [ "$dotnet" == "1" ]; then
  if echo $sys | grep x64 > /dev/null 2>&1; then
    $xml tr ../xslt/ExtractDownloadLinks-dotnet-x64-glb.xsl ../temp/package.xml > ../temp/Urls-dotnet-x64.txt
  else
    $xml tr ../xslt/ExtractDownloadLinks-dotnet-x86-glb.xsl ../temp/package.xml > ../temp/Urls-dotnet-x86.txt
  fi
fi

if [ -f "$valid1" -o -f "$valid2" ] && [ -f "$expired1" -o -f "$expired2" ]; then
  grep -F -i -v -f ../temp/Expiredid-${sys}.txt ../temp/Urls-${sys}-${lang}.txt > ../temp/tmpUrls-${sys}-${lang}.txt
  grep -F -i -f ../temp/Validid-${sys}.txt ../temp/Urls-${sys}-${lang}.txt >> ../temp/tmpUrls-${sys}-${lang}.txt
else
  touch ../temp/Urls-${sys}-${lang}.txt
  cp ../temp/Urls-${sys}-${lang}.txt ../temp/tmpUrls-${sys}-${lang}.txt
fi

if [ -f ../exclude/ExcludeList-${sys}.txt ]; then
  cat ../exclude/ExcludeList-${sys}.txt > ../temp/tmpExcludeList-${sys}.txt
fi
if [ -f ../exclude/ExcludeList-${sys}-x86.txt ]; then
  cat ../exclude/ExcludeList-${sys}-x86.txt > ../temp/tmpExcludeList-${sys}.txt
fi
if [ -f ../exclude/custom/ExcludeList-${sys}.txt ]; then
  cat ../exclude/custom/ExcludeList-${sys}.txt >> ../temp/tmpExcludeList-${sys}.txt
fi
if [ -f ../exclude/custom/ExcludeList-${sys}-x86.txt ]; then
  cat ../exclude/custom/ExcludeList-${sys}-x86.txt >> ../temp/tmpExcludeList-${sys}.txt
fi
  cat ../exclude/ExcludeList-superseded.txt >> ../temp/tmpExcludeList-${sys}.txt
  grep -F -i -v -f ../temp/tmpExcludeList-${sys}.txt ../temp/tmpUrls-${sys}-${lang}.txt > ../temp/ValidUrls-${sys}-${lang}.txt

if [ -f "$glb1" ] && [ "$lang" != "glb" ]; then
  $xml tr ../xslt/ExtractDownloadLinks-${sys}-glb.xsl ../temp/package.xml > ../temp/Urls-${sys}-glb.txt
  if [ -f "$valid1" -o -f "$valid2" ] && [ -f "$expired1" -o -f "$expired2" ]; then
    grep -F -i -f ../temp/Validid-${sys}.txt ../temp/Urls-${sys}-glb.txt > ../temp/tmpValidUrls-${sys}-glb.txt
    grep -F -i -v -f ../temp/Expiredid-${sys}.txt ../temp/Urls-${sys}-glb.txt >> ../temp/tmpValidUrls-${sys}-glb.txt
  else
    cp ../temp/Urls-${sys}-glb.txt ../temp/tmpValidUrls-${sys}-glb.txt
  fi
  grep -F -i -v -f ../temp/tmpExcludeList-${sys}.txt ../temp/tmpValidUrls-${sys}-glb.txt > ../temp/ValidUrls-${sys}-glb.txt
  rm ../temp/Urls-${sys}-glb.txt ../temp/tmpValidUrls-${sys}-glb.txt
fi

if [ -f "$glb2" ] && [ "$lang" != "glb" ]; then
  $xml tr ../xslt/ExtractDownloadLinks-${sys}-x86-glb.xsl ../temp/package.xml > ../temp/Urls-${sys}-glb.txt
  if [ -f "$valid1" -o -f "$valid2" ] && [ -f "$expired1" -o -f "$expired2" ]; then
    grep -F -i -f ../temp/Validid-${sys}.txt ../temp/Urls-${sys}-glb.txt > ../temp/tmpValidUrls-${sys}-glb.txt
    grep -F -i -v -f ../temp/Expiredid-${sys}.txt ../temp/Urls-${sys}-glb.txt >> ../temp/tmpValidUrls-${sys}-glb.txt
  else
    cp ../temp/Urls-${sys}-glb.txt ../temp/tmpValidUrls-${sys}-glb.txt
  fi
  grep -F -i -v -f ../temp/tmpExcludeList-${sys}.txt ../temp/tmpValidUrls-${sys}-glb.txt > ../temp/ValidUrls-${sys}-glb.txt
  rm ../temp/Urls-${sys}-glb.txt ../temp/tmpValidUrls-${sys}-glb.txt
fi
if [ "$sys" != "w60" ] && [ "$sys" != "w60-x64" ] && [ "$sys" != "w61" ] && [ "$sys" != "w61-x64" ] && [ "$sys" != "w2k3-x64" ] && [ "$sys" != "ofc" ]; then
  echo "Determining update URLs for win ${lang}..."
  $xml tr ../xslt/ExtractDownloadLinks-win-x86-${lang}.xsl ../temp/package.xml > ../temp/Urls-win-x86-${lang}.txt
  cat ../exclude/ExcludeList-win-x86.txt > ../temp/tmpExcludeList-win-x86.txt
  cat ../exclude/custom/ExcludeList-win-x86.txt >> ../temp/tmpExcludeList-win-x86.txt
    cat ../exclude/ExcludeList-superseded.txt >> ../temp/tmpExcludeList-win-x86.txt
  grep -F -i -v -f ../temp/tmpExcludeList-win-x86.txt ../temp/Urls-win-x86-${lang}.txt > ../temp/ValidUrls-win-x86-${lang}.txt
  rm ../temp/Urls-win-x86-${lang}.txt
fi

if [ "$sys" == "ofc" ]; then

echo "Determining dynamic update urls for ${sys}..."
if [ -f ../exclude/ExcludeList-${sys}.txt ]; then
  cat ../exclude/ExcludeList-${sys}.txt >> ../temp/ExcludeList-${sys}.txt
fi
if [ -f ../exclude/custom/ExcludeList-${sys}.txt ]; then
  cat ../exclude/custom/ExcludeList-${sys}.txt >> ../temp/ExcludeList-${sys}.txt
fi
cat ../exclude/ExcludeList-superseded.txt >> ../temp/ExcludeList-${sys}.txt


$xml tr ../xslt/ExtractUpdateCategoriesAndFileIds.xsl ../temp/package.xml > ../temp/UpdateCategoriesAndFileIds.txt
$xml tr ../xslt/ExtractUpdateCabExeIdsAndLocations.xsl ../temp/package.xml > ../temp/UpdateCabExeIdsAndLocations.txt

oldlang=$lang
for (( c=0; c<2; c++ ))
do
if [ $c == 1 ]; then
  lang="glb"
fi
  echo "Determining dynamic update urls for ${sys} ${lang} (please be patient, this will take a while)..."
  UPDATE_ID=""
  UPDATE_CATEGORY=""
  UPDATE_LANGUAGES=""

  officestring=`cat ../temp/UpdateCategoriesAndFileIds.txt`
  arr=$(echo $officestring  | tr " " "\n")
  for x in $arr
    do
      temp=(${x//;/ })
      pre_cat=${temp[0]}
      pre_cat=(${pre_cat//,/ })
      cate=${temp[1]}
      if [ "$cate" == "" ]; then
        if [ "$UPDATE_CATEGORY" == "477b856e-65c4-4473-b621-a8b230bb70d9" ]; then
          if [ "${pre_cat[1]}" != "" ]; then
            if [ "$lang" == "glb" ]; then
              if [ "${pre_cat[2]}" == "" ] && [ "$UPDATE_LANGUAGES" == "" ]; then
                echo "$UPDATE_ID,${pre_cat[1]}" >> ../temp/OfficeUpdateAndFileIds.txt
                echo "${pre_cat[1]}" >> ../temp/OfficeFileIds.txt
              fi
              if [ "${pre_cat[2]}" == "en" ] && [ "$UPDATE_LANGUAGES" == "en" ]; then
                echo "$UPDATE_ID,${pre_cat[1]}" >> ../temp/OfficeUpdateAndFileIds.txt
                echo "${pre_cat[1]}" >> ../temp/OfficeFileIds.txt
              fi
            else
              if [ "${pre_cat[2]}" == "$LANG_SHORT" ]; then
                echo "$UPDATE_ID,${pre_cat[1]}" >> ../temp/OfficeUpdateAndFileIds.txt
                echo "${pre_cat[1]}" >> ../temp/OfficeFileIds.txt
              fi
            fi
          fi
        fi
      else
          UPDATE_ID=${pre_cat[0]}
          UPDATE_CATEGORY=`echo $cate | awk -F"," '{print $1}'`
          UPDATE_LANGUAGES=`echo $cate | awk -F"," '{print $2}'`
      fi
    done

  grep -F -f ../temp/OfficeFileIds.txt ../temp/UpdateCabExeIdsAndLocations.txt > ../temp/OfficeUpdateCabExeIdsAndLocations.txt
  if [ ! -d "../client/ofc" ]; then
    mkdir ../client/ofc
  fi
  if [ -f ../client/ofc/UpdateTable-${sys}-${lang}.csv ]; then
    rm  ../client/ofc/UpdateTable-${sys}-${lang}.csv
  fi
  linkstring=`cat ../temp/OfficeUpdateAndFileIds.txt`
  arr=$(echo $linkstring | tr " " "\n")
  for x in $arr
    do
      temp_linkid=`echo $x | awk -F"," '{print $2}'`
      line=`grep $temp_linkid ../temp/OfficeUpdateCabExeIdsAndLocations.txt`
      line=(${line//,/ })
          if [ "${line[0]}" != "" ] && [ "${line[0]}" == "$temp_linkid" ]; then
            echo "${line[1]}" >> ../temp/DynamicDownloadLinks-${sys}-${lang}.txt
            filename=${line[1]}
            filename=`basename $filename .exe`
            filename=`basename $filename .cab`
            echo "`echo $x | awk -F"," '{print $1}'`,$filename" >> ../client/ofc/UpdateTable-${sys}-${lang}.csv
          fi
    done

    rm ../temp/OfficeFileIds.txt
    rm ../temp/OfficeUpdateAndFileIds.txt
    rm ../temp/OfficeUpdateCabExeIdsAndLocations.txt
    grep -F -i -v -f ../temp/ExcludeList-${sys}.txt ../temp/DynamicDownloadLinks-${sys}-${lang}.txt > ../temp/ValidDynamicLinks-${sys}-${lang}.txt
    cat ../temp/ValidDynamicLinks-${sys}-${lang}.txt >> ../temp/ValidUrls-${sys}-${lang}.txt
done
lang=$oldlang
fi

rm ../temp/package.xml

touch ../temp/ValidDynamicLinks-${sys}-${lang}.txt ../temp/StaticUrls-${sys_old}-${lang}.txt ../temp/StaticUrls-${sys_old}-glb.txt ../temp/StaticUrls-${sys}-${lang}.txt ../temp/StaticUrls-ie6-${lang}.txt ../temp/ValidUrls-${sys}-${lang}.txt ../temp/ValidUrls-${sys}-glb.txt ../temp/ValidUrls-win-x86-${lang}.txt ../temp/StaticUrls-ofc-glb.txt ../temp/StaticUrls-ofc-${lang}.txt ../temp/StaticUrls-${sys}-glb.txt ../temp/StaticUrls-${lang}.txt ../temp/StaticUrls-glb.txt ../temp/StaticUrls-dotnet.txt ../temp/StaticUrls-cpp-x86-glb.txt ../temp/StaticUrls-cpp-x64-glb.txt ../temp/StaticUrls-msse-x86-glb.txt ../temp/StaticUrls-msse-x64-glb.txt ../temp/StaticUrls-wddefs-x86-glb.txt ../temp/StaticUrls-wddefs-x64-glb.txt

cat ../temp/StaticUrls-${sys}-${lang}.txt >> ../temp/urls.txt
cat ../temp/StaticUrls-ie6-${lang}.txt >> ../temp/urls.txt
cat ../temp/ValidUrls-${sys}-${lang}.txt >> ../temp/urls.txt
cat ../temp/ValidUrls-${sys}-glb.txt >> ../temp/urls.txt
cat ../temp/ValidUrls-win-x86-${lang}.txt >> ../temp/urls.txt
cat ../temp/StaticUrls-ofc-glb.txt >> ../temp/urls.txt
cat ../temp/StaticUrls-ofc-${lang}.txt >> ../temp/urls.txt
cat ../temp/StaticUrls-${sys}-glb.txt >> ../temp/urls.txt
cat ../temp/StaticUrls-glb.txt >> ../temp/urls.txt
cat ../temp/StaticUrls-${lang}.txt >> ../temp/urls.txt
cat ../temp/StaticUrls-dotnet.txt >> ../temp/urls.txt
cat ../temp/StaticUrls-cpp-x86-glb.txt >> ../temp/urls.txt
cat ../temp/StaticUrls-cpp-x64-glb.txt >> ../temp/urls.txt
cat ../temp/StaticUrls-msse-x86-glb.txt >> ../temp/urls.txt
cat ../temp/StaticUrls-msse-x64-glb.txt >> ../temp/urls.txt
cat ../temp/StaticUrls-wddefs-x86-glb.txt >> ../temp/urls.txt
cat ../temp/StaticUrls-wddefs-x64-glb.txt >> ../temp/urls.txt
cat ../temp/StaticUrls-${sys_old}-${lang}.txt >> ../temp/urls.txt
cat ../temp/StaticUrls-${sys_old}-glb.txt >> ../temp/urls.txt

cat << END

***************************************
Found `grep -c http: ../temp/urls.txt` patches...

END

#create needed directories
mkdir -p ../client/${sys}/ ../client/${sys}/glb ../client/${sys}/${lang} ../client/md

printheader
echo "Downloading patches for ${sys}..."
echo "Downloading static patches..."
doWget -i ../temp/StaticUrls-${sys}-${lang}.txt -P ../client/${sys}/${lang}
if [ "$sys" != "w60" ] && [ "$sys" != "w60-x64" ] && [ "$sys" != "w61" ] && [ "$sys" != "w61-x64" ] && [ "$sys" != "w2k3-x64" ]; then
  doWget -i ../temp/StaticUrls-${lang}.txt -P ../client/win/${lang}
  doWget -i ../temp/StaticUrls-glb.txt -P ../client/win/glb
fi
doWget -i ../temp/StaticUrls-${sys}-glb.txt -P ../client/${sys}/glb

if [ "$sys" == "ofc" ] && [ "$sys_old" != "" ]; then
   doWget -i ../temp/StaticUrls-${sys_old}-${lang}.txt -P ../client/${sys_old}/${lang}
   doWget -i ../temp/StaticUrls-${sys_old}-glb.txt -P ../client/${sys_old}/glb
fi

if [ "$dotnet" == "1" ]; then
  echo "Downloading .Net framework..."
  doWget -i ../temp/StaticUrls-dotnet.txt -P ../client/dotnet
  if echo $sys | grep x64 > /dev/null 2>&1; then
   doWget -i ../temp/Urls-dotnet-x64.txt -P ../client/dotnet/x64-glb
  else
   doWget -i ../temp/Urls-dotnet-x86.txt -P ../client/dotnet/x86-glb
  fi
  echo "Downloading CPP files..."
  cppstring=`cat ../temp/StaticUrls-cpp-x86-glb.txt | grep ,`
  arr=$(echo $cppstring | tr " " "\n")
  for x in $arr
  do
    oldname=`echo $x | awk -F"," '{print $1}'`
    newname=`echo $x | awk -F"," '{print $2}'`
    tmpname=`basename $oldname`
    mkdir -p ../client/cpp
    if [ "$newname" != "" ] && [ -f "../client/cpp/$newname" ]; then
      mv -f "../client/cpp/$newname" "../client/cpp/$tmpname"
    fi
    doWget $oldname -P ../client/cpp
    if [ "$newname" != "" ] && [ -f "../client/cpp/$tmpname" ]; then
      mv -f "../client/cpp/$tmpname" "../client/cpp/$newname"
    fi
  done
  if echo $sys | grep x64 > /dev/null 2>&1; then
   cppstring=`cat ../temp/StaticUrls-cpp-x64-glb.txt | grep ,`
   arr=$(echo $cppstring | tr " " "\n")
   for x in $arr
    do
      oldname=`echo $x | awk -F"," '{print $1}'`
      newname=`echo $x | awk -F"," '{print $2}'`
      tmpname=`basename $oldname`
      if [ "$newname" != "" ] && [ -f "../client/cpp/$newname" ]; then
        mv -f "../client/cpp/$newname" "../client/cpp/$tmpname"
      fi
      doWget $oldname -P ../client/cpp
      if [ "$newname" != "" ] && [ -f "../client/cpp/$tmpname" ]; then
        mv -f "../client/cpp/$tmpname" "../client/cpp/$newname"
      fi
    done
  fi
fi
if [ "$msse" == "1" ]; then
  echo "Downloading MSSE files..."
  if echo $sys | grep x64 > /dev/null 2>&1; then
   mssestring=`cat ../temp/StaticUrls-msse-x64-glb.txt`
   arr=$(echo $mssestring | tr " " "\n")
   for x in $arr
    do
      oldname=`echo $x | awk -F"," '{print $1}'`
      newname=`echo $x | awk -F"," '{print $2}'`
      tmpname=`basename $oldname`
      mkdir -p ../client/msse/x64-glb
      if [ "$newname" != "" ] && [ -f "../client/msse/x64-glb/$newname" ]; then
        mv -f "../client/msse/x64-glb/$newname" "../client/msse/x64-glb/$tmpname"
      fi
      doWget $oldname -P ../client/msse/x64-glb
      if [ "$newname" != "" ] && [ -f "../client/msse/x64-glb/$tmpname" ]; then
        mv -f "../client/msse/x64-glb/$tmpname" "../client/msse/x64-glb/$newname"
      fi
    done
  else
   mssestring=`cat ../temp/StaticUrls-msse-x86-glb.txt`
   arr=$(echo $mssestring | tr " " "\n")
   for x in $arr
    do
      oldname=`echo $x | awk -F"," '{print $1}'`
      newname=`echo $x | awk -F"," '{print $2}'`
      tmpname=`basename $oldname`
      mkdir -p ../client/msse/x86-glb
      if [ "$newname" != "" ] && [ -f "../client/msse/x86-glb/$newname" ]; then
        mv -f "../client/msse/x86-glb/$newname" "../client/msse/x86-glb/$tmpname"
      fi
      doWget $oldname -P ../client/msse/x86-glb
      if [ "$newname" != "" ] && [ -f "../client/msse/x86-glb/$tmpname" ]; then
        mv -f "../client/msse/x86-glb/$tmpname" "../client/msse/x86-glb/$newname"
      fi
    done
  fi
fi
if [ "$wddefs" == "1" ]; then
  echo "Downloading Windows Defender definition files..."
  if echo $sys | grep x64 > /dev/null 2>&1; then
    mkdir -p ../client/wddefs/x64-glb
    doWget -i ../temp/StaticUrls-wddefs-x64-glb.txt -P ../client/wddefs/x64-glb
  else
    mkdir -p ../client/wddefs/x86-glb
    doWget -i ../temp/StaticUrls-wddefs-x86-glb.txt -P ../client/wddefs/x86-glb
  fi
fi

echo "Downloading patches for $sys $lang"
doWget -i ../temp/ValidUrls-${sys}-${lang}.txt -P ../client/${sys}/${lang}
doWget -i ../temp/ValidUrls-${sys}-glb.txt -P ../client/${sys}/glb
if [ "$sys" != "w60" ] && [ "$sys" != "w60-x64" ] && [ "$sys" != "w61" ] && [ "$sys" != "w61-x64" ] && [ "$sys" != "w2k3-x64" ]; then
  doWget -i ../temp/ValidUrls-win-x86-${lang}.txt -P ../client/win/${lang}
fi

printheader
echo "Validating patches for ${sys}..."
echo "Validating static patches..."
doWget -i ../temp/StaticUrls-${sys}-${lang}.txt -P ../client/${sys}/${lang}
if [ "$sys" != "w60" ] && [ "$sys" != "w60-x64" ] && [ "$sys" != "w61" ] && [ "$sys" != "w61-x64" ] && [ "$sys" != "w2k3-x64" ]; then
  doWget -i ../temp/StaticUrls-${lang}.txt -P ../client/win/${lang}
  doWget -i ../temp/StaticUrls-glb.txt -P ../client/win/glb
fi
doWget -i ../temp/StaticUrls-${sys}-glb.txt -P ../client/${sys}/glb

if [ "$sys" == "ofc" ] && [ "$sys_old" != "" ]; then
   doWget -i ../temp/StaticUrls-${sys_old}-${lang}.txt -P ../client/${sys_old}/${lang}
   doWget -i ../temp/StaticUrls-${sys_old}-glb.txt -P ../client/${sys_old}/glb
   echo "Creating integrity database for ${sys_old} ${lang}..."
   cd ../client/bin
   hashdeep -c md5,sha1,sha256 -l -r ../${sys_old}/${lang} | sed 's/\//\\/g' > ../md/hashes-${sys_old}-${lang}.txt
   hashdeep -c md5,sha1,sha256 -l -r ../${sys_old}/glb | sed 's/\//\\/g' > ../md/hashes-${sys_old}-glb.txt
   cd "$PATH_PWD"
fi

if [ "$dotnet" == "1" ]; then
  echo "Validating .Net framework..."
  doWget -i ../temp/StaticUrls-dotnet.txt -P ../client/dotnet
  echo "Creating integrity database for .Net ..."
  cd ../client/bin
  hashdeep -c md5,sha1,sha256 -l ../dotnet/*.exe | sed 's/\//\\/g' > ../md/hashes-dotnet.txt
  cd "$PATH_PWD"
  if echo $sys | grep x64 > /dev/null 2>&1; then
    doWget -i ../temp/Urls-dotnet-x64.txt -P ../client/dotnet/x64-glb
    echo "Creating integrity database for .Net-x64-glb ..."
    cd ../client/bin
    hashdeep -c md5,sha1,sha256 -l -r ../dotnet/x64-glb | sed 's/\//\\/g' > ../md/hashes-dotnet-x64-glb.txt
    cd "$PATH_PWD"
  else
    doWget -i ../temp/Urls-dotnet-x86.txt -P ../client/dotnet/x86-glb
    echo "Creating integrity database for .Net-x86-glb ..."
    cd ../client/bin
    hashdeep -c md5,sha1,sha256 -l -r ../dotnet/x86-glb | sed 's/\//\\/g' > ../md/hashes-dotnet-x86-glb.txt
    cd "$PATH_PWD"
  fi
  echo "Validating CPP files..."
  cppstring=`cat ../temp/StaticUrls-cpp-x86-glb.txt | grep ,`
  arr=$(echo $cppstring | tr " " "\n")
  for x in $arr
  do
    oldname=`echo $x | awk -F"," '{print $1}'`
    newname=`echo $x | awk -F"," '{print $2}'`
    tmpname=`basename $oldname`
    mkdir -p ../client/cpp
    if [ "$newname" != "" ] && [ -f "../client/cpp/$newname" ]; then
      mv -f "../client/cpp/$newname" "../client/cpp/$tmpname"
    fi
    doWget $oldname -P ../client/cpp
    if [ "$newname" != "" ] && [ -f "../client/cpp/$tmpname" ]; then
      mv -f "../client/cpp/$tmpname" "../client/cpp/$newname"
    fi
  done
  if echo $sys | grep x64 > /dev/null 2>&1; then
   cppstring=`cat ../temp/StaticUrls-cpp-x64-glb.txt | grep ,`
   arr=$(echo $cppstring | tr " " "\n")
   for x in $arr
    do
      oldname=`echo $x | awk -F"," '{print $1}'`
      newname=`echo $x | awk -F"," '{print $2}'`
      tmpname=`basename $oldname`
      if [ "$newname" != "" ] && [ -f "../client/cpp/$newname" ]; then
        mv -f "../client/cpp/$newname" "../client/cpp/$tmpname"
      fi
      doWget $oldname -P ../client/cpp
      if [ "$newname" != "" ] && [ -f "../client/cpp/$tmpname" ]; then
        mv -f "../client/cpp/$tmpname" "../client/cpp/$newname"
      fi
    done
  fi
  echo "Creating integrity database for CPP ..."
  cd ../client/bin
  hashdeep -c md5,sha1,sha256 -l -r ../cpp | sed 's/\//\\/g' > ../md/hashes-cpp.txt
  cd "$PATH_PWD"
fi

if [ "$msse" == "1" ]; then
  echo "Validating MSSE defs..."
  if echo $sys | grep x64 > /dev/null 2>&1; then
   mssestring=`cat ../temp/StaticUrls-msse-x64-glb.txt`
   arr=$(echo $mssestring | tr " " "\n")
   for x in $arr
    do
      oldname=`echo $x | awk -F"," '{print $1}'`
      newname=`echo $x | awk -F"," '{print $2}'`
      tmpname=`basename $oldname`
      mkdir -p ../client/msse/x64-glb
      if [ "$newname" != "" ] && [ -f "../client/msse/x64-glb/$newname" ]; then
        mv -f "../client/msse/x64-glb/$newname" "../client/msse/x64-glb/$tmpname"
      fi
      doWget $oldname -P ../client/msse/x64-glb
      if [ "$newname" != "" ] && [ -f "../client/msse/x64-glb/$tmpname" ]; then
        mv -f "../client/msse/x64-glb/$tmpname" "../client/msse/x64-glb/$newname"
      fi
    done
  else
   mssestring=`cat ../temp/StaticUrls-msse-x86-glb.txt`
   arr=$(echo $mssestring | tr " " "\n")
   for x in $arr
    do
      oldname=`echo $x | awk -F"," '{print $1}'`
      newname=`echo $x | awk -F"," '{print $2}'`
      tmpname=`basename $oldname`
      mkdir -p ../client/msse/x86-glb
      if [ "$newname" != "" ] && [ -f "../client/msse/x86-glb/$newname" ]; then
        mv -f "../client/msse/x86-glb/$newname" "../client/msse/x86-glb/$tmpname"
      fi
      doWget $oldname -P ../client/msse/x86-glb
      if [ "$newname" != "" ] && [ -f "../client/msse/x86-glb/$tmpname" ]; then
        mv -f "../client/msse/x86-glb/$tmpname" "../client/msse/x86-glb/$newname"
      fi
    done
  fi
  echo "Creating integrity database for MSSE ..."
  cd ../client/bin
  hashdeep -c md5,sha1,sha256 -l -r ../msse | sed 's/\//\\/g' > ../md/hashes-msse.txt
  cd "$PATH_PWD"
fi

if [ "$wddefs" == "1" ]; then
  echo "Validating Windows Defender definition files..."
  if echo $sys | grep x64 > /dev/null 2>&1; then
    mkdir -p ../client/wddefs/x64-glb
    doWget -i ../temp/StaticUrls-wddefs-x64-glb.txt -P ../client/wddefs/x64-glb
  else
    mkdir -p ../client/wddefs/x86-glb
    doWget -i ../temp/StaticUrls-wddefs-x86-glb.txt -P ../client/wddefs/x86-glb
  fi
  if [ -d ../client/${sys}/glb ]; then
    echo "Creating integrity database for Windows Defender definition files ..."
    cd ../client/bin
    hashdeep -c md5,sha1,sha256 -l -r ../wddefs | sed 's/\//\\/g' > ../md/hashes-wddefs.txt
    cd "$PATH_PWD"
  fi
fi

echo "Validating patches for $sys ${lang}..."
doWget -i ../temp/ValidUrls-${sys}-${lang}.txt -P ../client/${sys}/${lang}
if [ -d ../client/${sys}/${lang} ]; then
  echo "Creating integrity database for $sys-$lang ..."
  cd ../client/bin
 hashdeep -c md5,sha1,sha256 -l -r ../${sys}/${lang} | sed 's/\//\\/g' > ../md/hashes-${sys}-${lang}.txt
 cd "$PATH_PWD"
fi
doWget -i ../temp/ValidUrls-${sys}-glb.txt -P ../client/${sys}/glb
if [ -d ../client/${sys}/glb ]; then
  echo "Creating integrity database for $sys-glb ..."
  cd ../client/bin
 hashdeep -c md5,sha1,sha256 -l -r ../${sys}/glb | sed 's/\//\\/g' > ../md/hashes-${sys}-glb.txt
 cd "$PATH_PWD"
fi
if [ "$sys" != "w60" ] && [ "$sys" != "w60-x64" ] && [ "$sys" != "w61" ] && [ "$sys" != "w61-x64" ] && [ "$sys" != "w2k3-x64" ]; then
  doWget -i ../temp/ValidUrls-win-x86-${lang}.txt -P ../client/win/${lang}
fi
if [ -d ../client/win/glb ]; then
  echo "Creating integrity database for win-glb ..."
  cd ../client/bin
 hashdeep -c md5,sha1,sha256 -l -r ../win/glb | sed 's/\//\\/g' > ../md/hashes-win-glb.txt
 cd "$PATH_PWD"
fi
if [ -d ../client/win/${lang} ]; then
  cd ../client/bin
  echo "Creating integrity database for win-$lang ..."
 hashdeep -c md5,sha1,sha256 -l -r ../win/${lang} | sed 's/\//\\/g' > ../md/hashes-win-${lang}.txt
 cd "$PATH_PWD"
fi
if [ -d ../client/wsus ]; then
  cd ../client/bin
  echo "Creating integrity database for WSUS ..."
 hashdeep -c md5,sha1,sha256 -l -r ../wsus | sed 's/\//\\/g' > ../md/hashes-wsus.txt
 cd "$PATH_PWD"
fi


echo "**************************************"
echo "`grep -c http: ../temp/urls.txt` patches successfully downloaded."
echo
if [ "$CLEANUP_DOWNLOADS" != "0" ]; then
  echo "Cleaning up ..."
  echo "Cleaning up client directory for $sys $lang"
  cat ../temp/StaticUrls-${sys}-${lang}.txt >> ../temp/ValidUrls-${sys}-${lang}.txt
  cleanup "../temp/ValidUrls-${sys}-${lang}.txt" "../client/${sys}/${lang}"
  echo "Cleaning up client directory for $sys glb"
  cat ../temp/StaticUrls-${sys}-glb.txt >> ../temp/ValidUrls-${sys}-glb.txt
  cleanup "../temp/ValidUrls-${sys}-glb.txt" "../client/${sys}/glb"
  if [ "$sys" != "w60" ] && [ "$sys" != "w60-x64" ] && [ "$sys" != "w61" ] && [ "$sys" != "w61-x64" ] && [ "$sys" != "w2k3-x64" ]; then
    echo "Cleaning up client directory for win $lang"
    cat ../temp/StaticUrls-${lang}.txt > ../temp/ValidUrls-${lang}.txt
    cat ../temp/ValidUrls-win-x86-${lang}.txt >> ../temp/ValidUrls-${lang}.txt
    cleanup "../temp/ValidUrls-${lang}.txt" "../client/win/${lang}"
    echo "Cleaning up client directory for win glb"
    cat ../temp/StaticUrls-glb.txt > ../temp/ValidUrls-glb.txt
    cleanup "../temp/ValidUrls-glb.txt" "../client/win/glb"
  fi
fi

if [ "$createiso" == "1" ]; then
  /bin/bash ./CreateISOImage.sh $sys $lang $param2 $param3
fi

exit 0

# EOF