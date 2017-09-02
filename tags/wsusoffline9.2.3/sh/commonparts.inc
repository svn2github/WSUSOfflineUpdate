# Variablen und Funktionen, die von
# DownloadUpdates.sh und CreateISOImage.sh
# gemeinsam benutzt werden
# Start: 10.3.2013 Hullen

syslist="wxp wxp-x64 w2k3 w2k3-x64 w60 w60-x64 w61 w61-x64 w62 w62-x64 w63 w63-x64 all-x86 all-x64 o2k3 o2k7 o2k10 o2k13 ofc"
langlist="enu deu nld esn fra ptg ptb ita rus plk ell csy dan nor sve fin jpn kor chs cht hun trk ara heb"

printusage()
{
Iso='/proxy     - define proxy server (/proxy http://[username:password@]<server>:<port>)
/makeiso   - create ISO image'
case $0 in
    CreateISOImage.sh)
	Iso=""
    ;;
esac

cat << END
  Invalid parameter: $Cmdline

Usage: `basename $0` [system] [language] [parameter]

Supported systems:
$syslist

Supported languages:
$langlist

Parameters:
/excludesp - do not download servicepacks
/dotnet    - download .NET framework
/msse      - download Microsoft Security Essentials files
/wddefs    - download Windows Defender definition files
/nocleanup - do not cleanup client directory
$Iso

Example: bash `basename $0` wxp deu /dotnet /excludesp
END
exit 1
}

evaluateparams()
{
Cmdline="$@"
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
grep -q -w $1 <<< $syslist && sys=$1
test "$sys" || {
    echo system $1 does not exist.
    exit 1
    }

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

test "$2" || {
    echo language is not set.
    exit 1
    }
grep -q -w $2 <<< $langlist && lang=$2
test "$lang" || {
    echo language $2 does not exist.
    exit 1
    }
Origlang=$lang

case $sys in
    w6[0-2]*)
    echo "Setting language to glb..."
    lang="glb"
    ;;
esac

sys_old=""
case $sys in
    o2k*)
    sys_old=$sys
    sys="ofc"
    ;;
esac

case "$lang" in
  enu)    LANG_SHORT=en    ;;
  fra)    LANG_SHORT=fr    ;;
  esn)    LANG_SHORT=es    ;;
  jpn)    LANG_SHORT=ja    ;;
  kor)    LANG_SHORT=ko    ;;
  rus)    LANG_SHORT=ru    ;;
  ptg)    LANG_SHORT=pt    ;;
  ptb)    LANG_SHORT=pt-br ;;
  deu)    LANG_SHORT=de    ;;
  nld)    LANG_SHORT=nl    ;;
  ita)    LANG_SHORT=it    ;;
  chs)    LANG_SHORT=zh-cn    ;;
  cht)    LANG_SHORT=zh-tw    ;;
  plk)    LANG_SHORT=pl    ;;
  hun)    LANG_SHORT=hu    ;;
  csy)    LANG_SHORT=cs    ;;
  sve)    LANG_SHORT=sv    ;;
  trk)    LANG_SHORT=tr    ;;
  ell)    LANG_SHORT=el    ;;
  ara)    LANG_SHORT=ar    ;;
  heb)    LANG_SHORT=he    ;;
  dan)    LANG_SHORT=da    ;;
  nor)    LANG_SHORT=no    ;;
  fin)    LANG_SHORT=fi    ;;
esac

#determining parameters
  if grep -q /makeiso <<< $Cmdline ; then
    param1=/makeiso
    createiso="1"
  fi
  if grep -q /dotnet <<< $Cmdline ; then
    param2=/dotnet
    dotnet="1"
  fi
  if grep -q /excludesp <<< $Cmdline ; then
    param3=/excludesp
    EXCLUDE_SP="1"
  fi
  if grep -q /nocleanup <<< $Cmdline ; then
    param4=/nocleanup
    CLEANUP_DOWNLOADS="0"
  fi
  if grep -q /msse <<< $Cmdline ; then
    param5=/msse
    msse="1"
  fi
  if grep -q /wddefs <<< $Cmdline ; then
    case $sys in
	w62*)
	param5=/msse
	msse="1"
	;;
	*)
	param7=/wddefs
	wddefs="1"
	;;
    esac
  fi

if [ "$sys" == "w2k3" -o "$sys" == "w2k3-x64" ]; then
  msse="0"
fi

#determining proxy
shift 2
while [ "$1" != "" ]
  do
if [ "$1" == "/proxy" ]; then
  http_proxy="$2"
  param6="$1 $2"
  break
else
    shift
fi
  done

if [ "$sys" == "" -o "$lang" == "" ]; then
  printusage $Cmdline
fi
} # Ende "evaluateparams"

doWget()
{
echo "wget -nv -N --timeout=120 $*" | tee -a ../temp/wget.$mydate
wget -nv -N --timeout=120 $* 2>>../temp/wget.$mydate
return $?
}


