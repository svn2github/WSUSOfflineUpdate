#!/bin/bash

##########################################################
###           WSUS Offline Update Downloader           ###
###                  for Linux systems                 ###
###                   v. 6.51+ (r109)                  ###
###                                                    ###
###   http://www.wsusoffline.net/                      ###
###   Authors: Tobias Breitling, Stefan Joehnke,       ###
###            Walter Schiessberg                      ###
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
w2k, wxp, wxp-x64, w2k3, w2k3-x64, w60, w60-x64, w61, w61-x64, oxp, o2k3, o2k7, all-x64, all-x86

Supported languages:
enu, deu, nld, esn, fra, ptg, ptb, ita, rus, plk, ell, csy
dan, nor, sve, fin, jpn, kor, chs, cht, hun, trk, ara, heb

Parameters:
/excludesp - do not download servicepacks
/makeiso   - create ISO image
/dotnet    - download .NET framework
/mssedefs  - download Microsoft Security Essentials definition files
/nocleanup - do not cleanup client directory
/proxy     - define proxy server (/proxy http://[username:password@]<server>:<port>)

Example: `basename $0` wxp deu /dotnet /makeiso
END
exit 1
}

checkconfig()
{
C=`which cabextract 2> /dev/null`
S=`which xmlstarlet 2> /dev/null`
T=`which xml 2> /dev/null`
D=`which dos2unix 2> /dev/null`
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

if [ ! -x "$D" ]; then

# neu, fuer Slackware
alias $D >/dev/null 2>&1 && return 0

test -s /etc/slackware-version && {
    alias dos2unix='recode ibmpc..lat1'
    return 0
    }

# Ende Slackware-Einschub
cat << END

Please install dos2unix.

Command in Fedora:
yum install dos2unix

Command in Debian:
apt-get install tofrodos

Command in SuSE:
zypper install dos2unix

END
	exit 1
fi
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
syslist=("w2k" "wxp" "wxp-x64" "w2k3" "w2k3-x64" "w60" "w60-x64" "w61" "w61-x64" "oxp" "o2k3" "o2k7" "all-x64" "all-x86")
langlist=("enu" "deu" "nld" "esn" "fra" "ptg" "ptb" "ita" "rus" "plk" "ell" "csy" "dan" "nor" "sve" "fin" "jpn" "kor" "chs" "cht" "hun" "trk" "ara" "heb")
paramlist=("/excludesp" "/dotnet" "/mssedefs" "/makeiso" "/nocleanup" "/proxy")
EXCLUDE_SP="0"
EXCLUDE_STATICS="0"
CLEANUP_DOWNLOADS="1"
createiso="0"
dotnet="0"
mssedefs="0"
param1=""
param2=""
param3=""
param4=""
param5=""
param6=""

#determining system
for i in ${syslist[@]}; do
	if [ "$1" == "$i" ]; then
		sys="$1"
	fi
done

if [ "$sys" == "w2k" ]; then
	dotnet="0"
fi

if [ "$sys" == "w2k" -o "$sys" == "w2k3" -o "$sys" == "w2k3-x64" ]; then
	mssedefs="0"
fi

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
	if echo $@ | grep /mssedefs > /dev/null 2>&1; then
		param5=/mssedefs
		mssedefs="1"
	fi
done

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

if [ "$sys" == "" -o "$lang" == "" ]; then
	printusage $@
fi
}

doWget()
{
mydate=`date +%Y%m%d`
echo "wget --no-cache -nv -N --timeout=120 $*" | tee -a /tmp/wget.$mydate
wget --no-cache -nv -N --timeout=120 $* 2>>/tmp/wget.$mydate
return $?
}

checkconnection()
{
wget -q --connect-timeout=1 --tries=1 http://www.wsusoffline.net/index.html
if [ !  -e "index.html" ]; then
	rm -f index.html
	printtimeout
fi
rm -f index.html
}

getsystem()
{
syslist=("w2k" "wxp" "wxp-x64" "w2k3" "w2k3-x64" "w60" "w60-x64" "w61" "w61-x64" "oxp" "o2k3" "o2k7" "all-x86" "all-x64")
cat << END
Please select your OS:
[1] Windows 2000               [10] Office XP
[2] Windows XP                 [11] Office 2003
[3] Windowx XP 64 bit          [12] Office 2007
[4] Windows Server 2003
[5] Windows Server 2003 64 bit
[6] Windows Vista
[7] Windows Vista 64 bit
[8] Windows 7                  [13] All 32 bit
[9] Windows 7 64 bit           [14] All 64 bit
END
read syschoice
echo
let syschoice=syschoice-1

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
if [ "$sys" != "oxp" -o "$sys" != "o2k3" -o "$sys" != "o2k7" -o "$sys" != "w2k" ]; then
	echo "Download .Net framework? [y/n]"
	read adddotnet
	if [ "$adddotnet" == "y" ]; then
		dotnet="1"
		param2="/dotnet"
	fi
fi
}

getmssedefs()
{
mssedefs="0"
if [ "$sys" != "oxp" -o "$sys" != "o2k3" -o "$sys" != "o2k7" -o "$sys" != "w2k" -o "$sys" != "w2k3" -o "$sys" != "w2k3-x64" ]; then
	echo "Download Microsoft Security Essentials definition files? [y/n]"
	read addmssedefs
	if [ "$addmssedefs" == "y" ]; then
		mssedefs="1"
		param5="/mssedefs"
	fi
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
cd $path
rm -f `cat $currentpath/../temp/cleanup.txt`
cd $currentpath
}

printheader()
{
clear
cat << END
**********************************************************
***           WSUS Offline Update Downloader           ***
***                  for Linux systems                 ***
***                   v. 6.51+ (r109)                  ***
***                                                    ***
***   http://www.wsusoffline.net/                      ***
***   Authors: Tobias Breitling, Stefan Joehnke,       ***
***            Walter Schiessberg                      ***
**********************************************************

END
}


printheader

#set working directory
cd $( dirname $0 )

#check for required packages
checkconfig
printheader

#check if parameters are valid
if [ "$1" != "" ]; then
	externparam="1"
	evaluateparams $1 $2 $3 $4 $5 $6 $7 $8
fi

#get parameters
if [ "$1" == "" ]; then
	getsystem
	getlanguage
	getservicepack
	getdotnet
	getmssedefs
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
mkdir -p ../client/msi
mkdir -p ../client/bin

mkdir -p ../temp
rm -f ../temp/*

#convert files to Linux format
dos2unix ../exclude/* > /dev/null 2>&1
dos2unix ../xslt/* > /dev/null 2>&1
dos2unix ../static/* > /dev/null 2>&1

printheader

cat << END
	Your choice
	System: $sys
	Language: $lang
	Parameter: $param1 $param2 $param3 $param4 $param5
	Proxy: $http_proxy
END

if [ "$sys" == "w2k" ];	then
	regexe="../client/bin/reg.exe"
	if [ ! -f "$regexe" ]; then
		cat << END
ERROR: ../client/bin/reg.exe not found!
Please manually copy that file from a Windows 2000 or XP system
to the directory ../client/bin.
END
exit
	fi
fi 

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
	/bin/bash $0 w2k3-x64 $lang $param2 $param3 $param4 $param5 $param6
	/bin/bash $0 w60-x64 $lang $param2 $param3 $param4 $param5 $param6
	/bin/bash $0 w61-x64 $lang $param2 $param3 $param4 $param5 $param6
	if [ "$param1" == "/makeiso" ]; then
		/bin/bash ./CreateISOImage.sh $sys $lang $param2 $param3
		rc=$?
	fi
	exit $rc
fi

if [ "$sys" == "all-x86" ]; then
	/bin/bash $0 w2k3 $lang $param2 $param3 $param4 $param5 $param6
	/bin/bash $0 wxp $lang $param2 $param3 $param4 $param5 $param6
	/bin/bash $0 w2k $lang $param2 $param3 $param4 $param5 $param6
	/bin/bash $0 w60 $lang $param2 $param3 $param4 $param5 $param6
	/bin/bash $0 w61 $lang $param2 $param3 $param4 $param5 $param6
	/bin/bash $0 oxp $lang $param2 $param3 $param4 $param5 $param6
	/bin/bash $0 o2k3 $lang $param2 $param3 $param4 $param5 $param6
	/bin/bash $0 o2k7 $lang $param2 $param3 $param4 $param5 $param6
	if [ "$param1" == "/makeiso" ]; then
		/bin/bash ./CreateISOImage.sh $sys $lang $param2 $param3
		rc=$?
	fi
	exit $rc
fi

echo "Downloading most recent Windows Update Agent and catalog file..."
doWget -c -i ../static/StaticDownloadLinks-wsus.txt -P ../client/wsus
if [ "$sys" == "oxp" -o "$sys" == "o2k3" -o "$sys" == "o2k7" ]; then
	echo "Downloading most recent files for Office inventory functionality..."
	doWget -c -i ../static/StaticDownloadLinks-inventory.txt -P ../client/wsus
fi

echo "Determining static URLs for ${sys} ${lang}..."

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
if [ "$sys" != "w60" ] && [ "$sys" != "$w60-x64" ] && [ "$sys" != "w61" ] && [ "$sys" != "$w61-x64" ] && [ "$sys" != "oxp" ] && [ "$sys" != "o2k3" ] && [ "$sys" != "o2k7" ] && [ "$sys" != "w2k3-x64" ]; then
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
fi

if [ "$mssedefs" == "1" ]; then
	cp ../static/StaticDownloadLink-mssedefs-x86-glb.txt ../temp/StaticUrls-mssedefs-x86-glb.txt
	cp ../static/StaticDownloadLink-mssedefs-x64-glb.txt ../temp/StaticUrls-mssedefs-x64-glb.txt
fi

if [ "$sys" == "w2k" ]; then
	echo "Determining URLs for IE6 ${lang}..."
	cat ../static/StaticDownloadLinks-ie6-${lang}.txt > ../temp/StaticUrls-ie6-${lang}.txt
fi

if [ "$sys" == "oxp" -o "$sys" == "o2k3" -o "$sys" == "o2k7" ]; then
	echo "Determining static urls for ofc glb..."
	cat ../static/StaticDownloadLinks-ofc-glb.txt > ../temp/StaticUrls-ofc-glb.txt
	echo "Determining static urls for ofc ${lang}..."
	cat ../static/StaticDownloadLinks-ofc-${lang}.txt > ../temp/StaticUrls-ofc-${lang}.txt
fi

cd ../temp
if [ "$sys" == "oxp" -o "$sys" == "o2k3" -o "$sys" == "o2k7" ]; then
	echo "Extracting Office update catalogue file package.xml..."
	cabextract -q -F patchdata.xml ../client/wsus/invcif.exe
	mv patchdata.xml package.xml
else
	echo "Extracting Windows update catalogue file package.xml..."
	cp ../client/wsus/wsusscn2.cab ../client/wsus/wsusscn2_1.cab
	cabextract -q -F package.cab ../client/wsus/wsusscn2_1.cab
	cabextract -q -F package.xml package.cab
	rm package.cab
	rm ../client/wsus/wsusscn2_1.cab
fi
cd ../sh

echo "Determining update URLs for ${sys} ${lang}..."
download1="../xslt/ExtractDownloadLinks-${sys}-${lang}.xsl"
download2="../xslt/ExtractDownloadLinks-${sys}-x86-${lang}.xsl"
valid1="../xslt/ExtractValidIds-${sys}.xsl"
valid2="../xslt/ExtractValidIds-${sys}-x86.xsl"
expired1="../xslt/ExtractExpiredIds-${sys}.xsl"
expired2="../xslt/ExtractExpiredIds-${sys}-x86.xsl"
exclude1="../exclude/ExcludeList-${sys}.txt"
exclude2="../exclude/ExcludeList-${sys}-x86.txt"
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
	$xml tr ../xslt/ExtractDownloadLinks-dotnet-x86-glb.xsl ../temp/package.xml > ../temp/Urls-dotnet-x86.txt
	$xml tr ../xslt/ExtractDownloadLinks-dotnet-x64-glb.xsl ../temp/package.xml > ../temp/Urls-dotnet-x64.txt
fi
if [ -f "$valid1" -o -f "$valid2" ] && [ -f "$expired1" -o -f "$expired2" ]; then
	grep -i -v -f ../temp/Expiredid-${sys}.txt ../temp/Urls-${sys}-${lang}.txt > ../temp/tmpUrls-${sys}-${lang}.txt
	grep -i -f ../temp/Validid-${sys}.txt ../temp/Urls-${sys}-${lang}.txt >> ../temp/tmpUrls-${sys}-${lang}.txt
else
	cp ../temp/Urls-${sys}-${lang}.txt ../temp/tmpUrls-${sys}-${lang}.txt
fi
if [ -f "$exclude1" ]; then
	grep -i -v -f ../exclude/ExcludeList-${sys}.txt ../temp/tmpUrls-${sys}-${lang}.txt > ../temp/ValidUrls-${sys}-${lang}.txt
fi
if [ -f "$exclude2" ]; then
	grep -i -v -f ../exclude/ExcludeList-${sys}-x86.txt ../temp/tmpUrls-${sys}-${lang}.txt > ../temp/ValidUrls-${sys}-${lang}.txt
fi
if [ -f "$glb1" ] && [ "$lang" != "glb" ]; then
	$xml tr ../xslt/ExtractDownloadLinks-${sys}-glb.xsl ../temp/package.xml > ../temp/Urls-${sys}-glb.txt
	if [ -f "$valid1" -o -f "$valid2" ] && [ -f "$expired1" -o -f "$expired2" ]; then
		grep -i -f ../temp/Validid-${sys}.txt ../temp/Urls-${sys}-glb.txt > ../temp/tmpValidUrls-${sys}-glb.txt
		grep -i -v -f ../temp/Expiredid-${sys}.txt ../temp/Urls-${sys}-glb.txt >> ../temp/tmpValidUrls-${sys}-glb.txt
	else
		cp ../temp/Urls-${sys}-glb.txt ../temp/tmpValidUrls-${sys}-glb.txt
	fi
	grep -i -v -f ../exclude/ExcludeList-${sys}.txt ../temp/tmpValidUrls-${sys}-glb.txt > ../temp/ValidUrls-${sys}-glb.txt
	rm ../temp/Urls-${sys}-glb.txt ../temp/tmpValidUrls-${sys}-glb.txt
fi

if [ -f "$glb2" ] && [ "$lang" != "glb" ]; then
	$xml tr ../xslt/ExtractDownloadLinks-${sys}-x86-glb.xsl ../temp/package.xml > ../temp/Urls-${sys}-glb.txt
	if [ -f "$valid1" -o -f "$valid2" ] && [ -f "$expired1" -o -f "$expired2" ]; then
		grep -i -f ../temp/Validid-${sys}.txt ../temp/Urls-${sys}-glb.txt > ../temp/tmpValidUrls-${sys}-glb.txt
		grep -i -v -f ../temp/Expiredid-${sys}.txt ../temp/Urls-${sys}-glb.txt >> ../temp/tmpValidUrls-${sys}-glb.txt
	else
		cp ../temp/Urls-${sys}-glb.txt ../temp/tmpValidUrls-${sys}-glb.txt
	fi
	grep -i -v -f ../exclude/ExcludeList-${sys}-x86.txt ../temp/tmpValidUrls-${sys}-glb.txt > ../temp/ValidUrls-${sys}-glb.txt
	rm ../temp/Urls-${sys}-glb.txt ../temp/tmpValidUrls-${sys}-glb.txt
fi

if [ "$sys" != "w60" ] && [ "$sys" != "w60-x64" ] && [ "$sys" != "w61" ] && [ "$sys" != "w61-x64" ] && [ "$sys" != "oxp" ] && [ "$sys" != "o2k3" ] && [ "$sys" != "o2k7" ] && [ "$sys" != "w2k3-x64" ]; then
	echo "Determining update URLs for win ${lang}..."
	$xml tr ../xslt/ExtractDownloadLinks-win-x86-${lang}.xsl ../temp/package.xml > ../temp/Urls-win-x86-${lang}.txt
	grep -i -v -f ../exclude/ExcludeList-win-x86.txt ../temp/Urls-win-x86-${lang}.txt > ../temp/ValidUrls-win-x86-${lang}.txt
	$xml tr ../xslt/ExtractDownloadLinks-win-x86-glb.xsl ../temp/package.xml > ../temp/Urls-win-x86-glb.txt
	grep -i -v -f ../exclude/ExcludeList-win-x86.txt ../temp/Urls-win-x86-glb.txt > ../temp/ValidUrls-win-x86-glb.txt
	rm ../temp/Urls-win-x86-${lang}.txt
fi
rm ../temp/package.xml

touch ../temp/StaticUrls-${sys}-${lang}.txt ../temp/StaticUrls-ie6-${lang}.txt ../temp/ValidUrls-${sys}-${lang}.txt ../temp/ValidUrls-win-x86-${lang}.txt ../temp/ValidUrls-win-x86-glb.txt ../temp/ValidUrls-${sys}-glb.txt ../temp/StaticUrls-ofc-glb.txt ../temp/StaticUrls-ofc-${lang}.txt ../temp/StaticUrls-${sys}-glb.txt ../temp/StaticUrls-${lang}.txt ../temp/StaticUrls-glb.txt ../temp/StaticUrls-dotnet.txt ../temp/StaticUrls-mssedefs-x86-glb.txt ../temp/StaticUrls-mssedefs-x64-glb.txt

cat ../temp/StaticUrls-${sys}-${lang}.txt >> ../temp/urls.txt
cat ../temp/StaticUrls-ie6-${lang}.txt >> ../temp/urls.txt
cat ../temp/ValidUrls-${sys}-${lang}.txt >> ../temp/urls.txt
cat ../temp/ValidUrls-win-x86-${lang}.txt >> ../temp/urls.txt
cat ../temp/ValidUrls-win-x86-glb.txt >> ../temp/urls.txt
cat ../temp/ValidUrls-${sys}-glb.txt >> ../temp/urls.txt
cat ../temp/StaticUrls-ofc-glb.txt >> ../temp/urls.txt
cat ../temp/StaticUrls-ofc-${lang}.txt >> ../temp/urls.txt
cat ../temp/StaticUrls-${sys}-glb.txt >> ../temp/urls.txt
cat ../temp/StaticUrls-glb.txt >> ../temp/urls.txt
cat ../temp/StaticUrls-${lang}.txt >> ../temp/urls.txt
cat ../temp/StaticUrls-dotnet.txt >> ../temp/urls.txt
cat ../temp/StaticUrls-mssedefs-x86-glb.txt >> ../temp/urls.txt
cat ../temp/StaticUrls-mssedefs-x64-glb.txt >> ../temp/urls.txt

cat << END

***************************************
Found `grep -c http: ../temp/urls.txt` patches...

END

#create needed directories
mkdir -p ../client/win/${lang} ../client/${sys}/ ../client/${sys}/glb ../client/${sys}/${lang} ../client/win/${lang}/ie6setup
if [ "$sys" == "oxp" -o "$sys" == "o2k3" -o "$sys" == "o2k7" ]; then
	mkdir -p ../client/ofc ../client/ofc/glb ../client/ofc/${lang}
fi

printheader
echo "Downloading patches for ${sys}..."
echo "Downloading static patches..."
doWget -c -i ../temp/StaticUrls-${sys}-${lang}.txt -P ../client/${sys}/${lang}
if [ "$sys" != "w60" ] && [ "$sys" != "w60-x64" ] && [ "$sys" != "w61" ] && [ "$sys" != "w61-x64" ] && [ "$sys" != "oxp" ] && [ "$sys" != "o2k3" ] && [ "$sys" != "o2k7" ] && [ "$sys" != "w2k3-x64" ]; then
	doWget -c -i ../temp/StaticUrls-${lang}.txt -P ../client/win/${lang}
	doWget -c -i ../temp/StaticUrls-glb.txt -P ../client/win/glb
fi
doWget -c -i ../temp/StaticUrls-${sys}-glb.txt -P ../client/${sys}/glb
if [ "$sys" == "oxp" -o "$sys" == "o2k3" -o "$sys" == "o2k7" ]; then
  doWget -c -i ../temp/StaticUrls-ofc-glb.txt -P ../client/ofc/glb
  doWget -c -i ../temp/StaticUrls-ofc-${lang}.txt -P ../client/ofc/${lang}
fi

if [ "$sys" == "w2k" ]; then
	doWget -c -i ../temp/StaticUrls-ie6-${lang}.txt -P ../client/win/${lang}/ie6setup
	/bin/bash ./FIXIE6SetupDir.sh $lang
fi
if [ "$dotnet" == "1" ]; then
	echo "Downloading .Net framework..."
	doWget -c -i ../temp/StaticUrls-dotnet.txt -P ../client/dotnet
	doWget -c -i ../temp/Urls-dotnet-x86.txt -P ../client/dotnet/x86-glb
	doWget -c -i ../temp/Urls-dotnet-x64.txt -P ../client/dotnet/x64-glb
fi
if [ "$mssedefs" == "1" ]; then
	echo "Downloading MSSE defs..."
	doWget -c -i ../temp/StaticUrls-mssedefs-x86-glb.txt -P ../client/mssedefs/x86-glb
	doWget -c -i ../temp/StaticUrls-mssedefs-x64-glb.txt -P ../client/mssedefs/x64-glb
fi

echo "Downloading patches for $sys $lang"
doWget -c -i ../temp/ValidUrls-${sys}-${lang}.txt -P ../client/${sys}/${lang}
doWget -c -i ../temp/ValidUrls-${sys}-glb.txt -P ../client/${sys}/glb
if [ "$sys" != "w60" ] && [ "$sys" != "w60-x64" ] && [ "$sys" != "w61" ] && [ "$sys" != "w61-x64" ] && [ "$sys" != "oxp" ] && [ "$sys" != "o2k3" ] && [ "$sys" != "o2k7" ] && [ "$sys" != "w2k3-x64" ]; then
	doWget -c -i ../temp/ValidUrls-win-x86-${lang}.txt -P ../client/win/${lang}
	doWget -c -i ../temp/ValidUrls-win-x86-glb.txt -P ../client/win/glb
fi

printheader
echo "Validating patches for ${sys}..."
echo "Validating static patches..."
doWget -c -i ../temp/StaticUrls-${sys}-${lang}.txt -P ../client/${sys}/${lang}
if [ "$sys" != "w60" ] && [ "$sys" != "w60-x64" ] && [ "$sys" != "w61" ] && [ "$sys" != "w61-x64" ] && [ "$sys" != "oxp" ] && [ "$sys" != "o2k3" ] && [ "$sys" != "o2k7" ] && [ "$sys" != "w2k3-x64" ]; then
	doWget -c -i ../temp/StaticUrls-${lang}.txt -P ../client/win/${lang}
	doWget -c -i ../temp/StaticUrls-glb.txt -P ../client/win/glb
fi
doWget -c -i ../temp/StaticUrls-${sys}-glb.txt -P ../client/${sys}/glb
if [ "$sys" == "oxp" -o "$sys" == "o2k3" -o "$sys" == "o2k7" ]; then
	 doWget -c -i ../temp/StaticUrls-ofc-glb.txt -P ../client/ofc/glb
	 doWget -c -i ../temp/StaticUrls-ofc-${lang}.txt -P ../client/ofc/${lang}
fi
if [ "$dotnet" == "1" ]; then
	echo "Validating .Net framework..."
	doWget -c -i ../temp/StaticUrls-dotnet.txt -P ../client/dotnet
	doWget -c -i ../temp/Urls-dotnet-x86.txt -P ../client/dotnet/x86-glb
	doWget -c -i ../temp/Urls-dotnet-x64.txt -P ../client/dotnet/x64-glb
fi
if [ "$mssedefs" == "1" ]; then
	echo "Validating MSSE defs..."
	doWget -c -i ../temp/StaticUrls-mssedefs-x86-glb.txt -P ../client/mssedefs/x86-glb
	doWget -c -i ../temp/StaticUrls-mssedefs-x64-glb.txt -P ../client/mssedefs/x64-glb
fi

echo "Validating patches for $sys ${lang}..."
doWget -c -i ../temp/ValidUrls-${sys}-${lang}.txt -P ../client/${sys}/${lang}
doWget -c -i ../temp/ValidUrls-${sys}-glb.txt -P ../client/${sys}/glb
if [ "$sys" != "w60" ] && [ "$sys" != "w60-x64" ] && [ "$sys" != "w61" ] && [ "$sys" != "w61-x64" ] && [ "$sys" != "oxp" ] && [ "$sys" != "o2k3" ] && [ "$sys" != "o2k7" ] && [ "$sys" != "w2k3-x64" ]; then
	doWget -c -i ../temp/ValidUrls-win-x86-${lang}.txt -P ../client/win/${lang}
	doWget -c -i ../temp/ValidUrls-win-x86-glb.txt -P ../client/win/glb
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
	if [ "$sys" == "oxp" -o "$sys" == "o2k3" -o "$sys" == "o2k7" ]; then
		echo "Cleaning up client directory for ofc $lang"
		cat ../temp/StaticUrls-ofc-${lang}.txt > ../temp/ValidUrls-ofc-${lang}.txt
		cleanup "../temp/ValidUrls-ofc-${lang}.txt" "../client/ofc/${lang}"
		echo "Cleaning up client directory for ofc glb"
		cat ../temp/StaticUrls-ofc-glb.txt > ../temp/ValidUrls-ofc-glb.txt
		cleanup "../temp/ValidUrls-ofc-glb.txt" "../client/ofc/glb"
	fi
	if [ "$sys" != "w60" ] && [ "$sys" != "w60-x64" ] && [ "$sys" != "w61" ] && [ "$sys" != "w61-x64" ] && [ "$sys" != "oxp" ] && [ "$sys" != "o2k3" ] && [ "$sys" != "o2k7" ] && [ "$sys" != "w2k3-x64" ]; then
		echo "Cleaning up client directory for win $lang"
		cat ../temp/StaticUrls-${lang}.txt > ../temp/ValidUrls-${lang}.txt
		cat ../temp/ValidUrls-win-x86-${lang}.txt >> ../temp/ValidUrls-${lang}.txt
		cleanup "../temp/ValidUrls-${lang}.txt" "../client/win/${lang}"
		echo "Cleaning up client directory for win glb"
		cat ../temp/StaticUrls-glb.txt > ../temp/ValidUrls-glb.txt
		cat ../temp/ValidUrls-win-x86-glb.txt >> ../temp/ValidUrls-glb.txt
		cleanup "../temp/ValidUrls-glb.txt" "../client/win/glb"
	fi
fi

if [ "$createiso" == "1" ]; then
	/bin/bash ./CreateISOImage.sh $sys $lang $param2 $param3
fi

exit 0

# EOF
