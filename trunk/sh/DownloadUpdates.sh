#!/bin/bash

# WSUS Offline Update Downloader for Linux Systems
# http://www.heise.de/ct/projekte/offlineupdate/
# Authors: Tobias Breitling, Stefan Joehnke

printusage()
{
echo ERROR Invalid parameter: $1 $2 $3 $4 $5 $6 $7 $8
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
echo "/excludesp - do not download servicepacks"
echo "/makeiso   - create ISO-Image"
echo "/dotnet    - download .NET-Framework"
echo "/nocleanup - do not cleanup client directory"
echo "/proxy     - define proxyserver( /proxy http://[username:password@]<server>:<port>)"
echo
echo "Example: $0 wxp deu /dotnet /makeiso"
echo
exit
}


checkconfig()
{
C=`which cabextract`
S=`which xmlstarlet`
T=`which xml`
D=`which dos2unix`
xml=""

if [ ! -x "$C" ]
then
 echo
 echo Please install cabextract.
 echo
 echo Command in debian:
 echo apt-get install cabextract
 echo
 echo Command in Suse:
 echo zypper install cabextract
 echo
 exit
fi

if [ ! -x "$S" ] && [ ! -x "$T" ]
then
 echo
 echo Please install xmlstarlet.
 echo
 echo Command in debian:
 echo apt-get install xmlstarlet
 echo
 echo Command in Suse:
 echo zypper install xmlstarlet
 echo
 exit
else
	if [ -x "$S" ]
	then
		xml="xmlstarlet"
	fi
	if [ -x "$T" ]		
	then		
		xml="xml"
	fi
fi

if [ ! -x "$D" ]
then
 echo
 echo Please install dos2unix.
 echo
 echo Command in debian:
 echo apt-get install tofrodos
 echo
 echo Command in Suse:
 echo zypper install dos2unix
 echo
 exit
fi
}

printtimeout()
{
echo
echo No connection could be established
echo Please check your internet connection.
echo
exit
}


evaluateparams()
{
syslist=("w2k" "wxp" "wxp-x64" "w2k3" "w2k3-x64" "w60" "w60-x64" "oxp" "o2k" "o2k3" "o2k7" "all-x64" "all-x86")
langlist=("enu" "deu" "nld" "esn" "fra" "ptg" "ptb" "ita" "rus" "plk" "ell" "csy" "dan" "nor" "sve" "fin" "jpn" "kor" "chs" "cht" "hun" "trk" "ara" "heb")
EXCLUDE_SP="0"
EXCLUDE_STATICS="0"
CLEANUP_DOWNLOADS="1"
dotnet="0"
param1=""
param2=""
param3=""
param4=""
param5=""

 for i in ${syslist[@]}
  do
   if [ "$1" == "$i" ]
    then
     sys="$1"
   fi
 done

if [ "$sys" == "w2k" ]
then
	dotnet=0
fi

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
 if [ "$3" == "/makeiso" ]
  then
   createiso="1"
   param1="$3"
 fi

if [ "$4" == "/makeiso" ]
  then
   createiso="1"
   param1="$4"
 fi
 
 if [ "$5" == "/makeiso" ]
  then
   createiso="1"
   param1="$5"
 fi  

  if [ "$6" == "/makeiso" ]
  then
   createiso="1"
   param1="$6"
 fi
 
 if [ "$7" == "/makeiso" ]
  then
   createiso="1"
   param1="$7"
 fi
 
 if [ "$8" == "/makeiso" ]
  then
   createiso="1"
   param1="$8"
 fi
 
 if [ "$3" == "/dotnet" ]
  then
   dotnet="1"
   param2="$3"
 fi

if [ "$4" == "/dotnet" ]
  then
   dotnet="1"
   param2="$4"
 fi
 
 if [ "$5" == "/dotnet" ]
  then
   dotnet="1"
   param2="$5"
 fi  

  if [ "$6" == "/dotnet" ]
  then
   dotnet="1"
   param2="$6"
 fi
 
 if [ "$7" == "/dotnet" ]
  then
   dotnet="1"
   param2="$7"
 fi
 
 if [ "$8" == "/dotnet" ]
  then
   dotnet="1"
   param2="$8"
 fi

if [ "$3" == "/excludesp" ]
  then
   EXCLUDE_SP="1"
   param3="$3"
 fi

  if [ "$4" == "/excludesp" ]
  then
   EXCLUDE_SP="1"
   param3="$4"
 fi

if [ "$5" == "/excludesp" ]
  then
   EXCLUDE_SP="1"
   param3="$5"
 fi
 
 if [ "$6" == "/excludesp" ]
  then
   EXCLUDE_SP="1"
   param3="$6"
 fi
 
 if [ "$7" == "/excludesp" ]
  then
   EXCLUDE_SP="1"
   param3="$7"
 fi
 
 if [ "$8" == "/excludesp" ]
  then
   EXCLUDE_SP="1"
   param3="$8"
 fi

if [ "$3" == "/nocleanup" ]
  then
   CLEANUP_DOWNLOADS="0"
   param4="$3"
 fi

 if [ "$4" == "/nocleanup" ]
  then
   CLEANUP_DOWNLOADS="0"
   param4="$4"
 fi

 if [ "$5" == "/nocleanup" ]
  then
   CLEANUP_DOWNLOADS="0"
   param4="$5"
 fi
 
if [ "$6" == "/nocleanup" ]
  then
   CLEANUP_DOWNLOADS="0"
   param4="$6"
 fi 
 
 if [ "$7" == "/nocleanup" ]
  then
   CLEANUP_DOWNLOADS="0"
   param4="$7"
 fi 
 
 if [ "$8" == "/nocleanup" ]
  then
   CLEANUP_DOWNLOADS="0"
   param4="$8"
 fi 
 
if [ "$3" == "/proxy" ]
  then
   http_proxy="$4"
   param5="$3 $4"
 fi
  
  if [ "$4" == "/proxy" ]
  then
   http_proxy="$5"
   param5="$4 $5"
 fi

  if [ "$5" == "/proxy" ]
  then
   http_proxy="$6"
   param5="$5 $6"
 fi

 if [ "$6" == "/proxy" ]
  then
   http_proxy="$7"
   param5="$6 $7"
 fi

 if [ "$7" == "/proxy" ]
  then
   http_proxy="$8"
   param5="$7 $8"
 fi

 if [ "$sys" == "" -o "$lang" == "" ]
 then
  printusage $1 $2 $3 $4 $5 $6 $7
 fi
	
 }

checkconnection()
{
wget -q --connect-timeout=1 --tries=1 http://www.google.de/index.html
if [ !  -e "index.html" ]
 then
  rm -f index.html
  printtimeout
fi
rm -f index.html
}

getsystem()
{
syslist=("w2k" "wxp" "wxp-x64" "w2k3" "w2k3-x64" "w60" "w60-x64" "oxp" "o2k" "o2k3" "o2k7" "all-x86" "all-x64")
 echo -e "Please select your OS:"
 echo
 echo "[1] Windows 2000               [8] Office XP"         
 echo "[2] Windows XP                 [9] Office 2000"
 echo "[3] Windowx XP 64bit           [10] Office 2003"
 echo "[4] Windows Server 2003        [11] Office 2007"
 echo "[5] Windows Server 2003 64bit"
 echo "[6] Windows Vista              [12] All 32bit"
 echo "[7] Windows Vista 64bit        [13] All 64bit"  
 echo 
 read syschoice
 echo
 let syschoice=syschoice-1

 for i in ${!syslist[@]}
  do
   if [ "$syschoice" == "$i" ]
    then
     sys=${syslist[i]}
   fi
 done
 if [ "$sys" == "wxp-x64" ]
 then
 	sys="w2k3-x64"
 fi

 if [ "$sys" == "" ]
  then
   echo Program aborted.
   echo
   exit
 fi
}

getlanguage()
{
langlist=("enu" "deu" "nld" "esn" "fra" "ptg" "ptb" "ita" "rus" "plk" "ell" "csy" "dan" "nor" "sve" "fin" "jpn" "kor" "chs" "cht" "hun" "trk" "ara" "heb")
langindex=("a" "b" "c" "d" "e" "f" "g" "h" "i" "j" "k" "l" "m" "n" "o" "p" "q" "r" "s" "t" "u" "v" "w" "x")

 if [ "$sys" == "w60" -o "$sys" == "w60-x64" ]
  then
   lang="glb"
  else
   echo -e "Please select your OS language: "
   echo
   echo [a] enu           [b] deu         [c] nld         [d] esn
   echo [e] fra           [f] ptg         [g] ptb         [h] ita
   echo [i] rus           [j] plk         [k] ell         [l] csy
   echo [m] dan           [n] nor         [o] sve         [p] fin
   echo [q] jpn           [r] kor         [s] chs         [t] cht
   echo [u] hun           [v] trk         [w] ara         [x] heb
   echo
   read -n 1 langchoice
   echo

   for i in ${!langindex[@]}
   do
    if [ "$langchoice" == "${langindex[i]}" ]
     then
      langnr=$i
      lang=${langlist[i]}
    fi
   done
   if [ "$lang" == "" ]
   then
    echo Program aborted.
    echo
    exit
   fi
  fi
}

getservicepack()
{
EXCLUDE_SP="1"
  echo Download Service Packs? [y/n]
  read addsp
 if [ "$addsp" == "y" ] 
  then
   EXCLUDE_SP="0"
   else
   param3="/excludesp"
 fi
}

getdotnet()
{
dotnet="0"
if [ "$sys" != "o2k" -o "$sys" != "oxp" -o "$sys" != "o2k3" -o "$sys" != "o2k7" -o "$sys" != "w2k" ]
then
	echo Download .Net-Framework? [y/n]
	read adddotnet
	if [ "$adddotnet" == "y" ]
	then 
		dotnet="1"
		param2="/dotnet"
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
	echo Create ISO-Image after download? [y/n]
	read addiso
if [ "$addiso" == "y" ]
then
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
for i in $(ls -l "$path"| tr -s " " | cut -d " " -f 9|grep "\b")
 do
  result=$(cat "$file"|grep "$i")
  if [ "$result" == "" ] && [ "$i" != "ie6setup" ]
   then
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
echo "**********************************************************"
echo "***            WSUS Offline Update Downloader          ***"
echo "***                  for Linux Systems                 ***"
echo "***                                                    ***"
echo "***   http://www.heise.de/ct/projekte/offlineupdate/   ***"
echo "***   Authors: Tobias Breitling, Stefan Joehnke        ***"
echo "**********************************************************"
echo
}


printheader

#set workdir
cd $( dirname $0 )

#check for required packages
checkconfig
printheader
#check if params are valid
if [ "$1" != "" ]
 then 
  externparam="1"
  evaluateparams $1 $2 $3 $4 $5 $6 $7 $8
fi

#get params
if [ "$1" == "" ]
 then
  getsystem
  getlanguage
  getservicepack
  getdotnet
  getproxy
  makeiso
fi

#set proxy
if [ "$http_proxy" != "" ]
 then
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

#convert files to linux format
dos2unix ../exclude/*
dos2unix ../xslt/*
dos2unix ../static/*

printheader

echo Your choice
echo System: $sys
echo Language: $lang
echo Parameter: $param1 $param2 $param3
echo Proxy: $http_proxy

if [ "$sys" == "w2k" ]
 	then
 		regexe="../client/bin/reg.exe"
 		if [ ! -f "$regexe" ]
 			then
 				echo "ERROR: ../client/bin/reg.exe not found!"
 				echo "Please manually copy that file from a Windows 2000 or XP system"
 				echo "to the directory ../client/bin."
 				exit
 		fi
fi 
 
if [ "$externparam" != "1" ]
 then 
  echo
  echo Do you want to download now? [y/n] 
  read response
 else
  response="y"
fi

if [ "$response" = "y" ] ;
then
if [ "$sys" == "all-x64" ]
	then
		./DownloadUpdates.sh w2k3-x64 $lang $param2 $param3 $param4 $param5
		./DownloadUpdates.sh w60-x64 $lang $param2 $param3 $param4 $param5
		if [ "$param1" == "/makeiso" ]
			then
			/bin/bash ./CreateISOImage.sh $sys $lang $param2 $param3
		fi
		exit
fi

if [ "$sys" == "all-x86" ]
	then
		./DownloadUpdates.sh w2k3 $lang $param2 $param3 $param4 $param5
		./DownloadUpdates.sh wxp $lang $param2 $param3 $param4 $param5
		./DownloadUpdates.sh w2k $lang $param2 $param3 $param4 $param5
		./DownloadUpdates.sh w60 $lang $param2 $param3 $param4 $param5
		./DownloadUpdates.sh o2k $lang $param2 $param3 $param4 $param5
		./DownloadUpdates.sh oxp $lang $param2 $param3 $param4 $param5
		./DownloadUpdates.sh o2k3 $lang $param2 $param3 $param4 $param5
		./DownloadUpdates.sh o2k7 $lang $param2 $param3 $param4 $param5
		if [ "$param1" == "/makeiso" ]
			then
				/bin/bash ./CreateISOImage.sh $sys $lang $param2 $param3
		fi
		exit
fi
echo
echo Downloading IfAdmin tool...
wget -nv -c -N -i ../static/StaticDownloadLink-ifadmin.txt -P ../client/bin

echo Downloading most recent files for WSUS functionality...

rm -f ../client/wsus/wsusscn2*
wget -nv -c -N -i ../static/StaticDownloadLinks-wsus.txt -P ../client/wsus

if [ "$sys" == "o2k" -o "$sys" == "oxp" -o "$sys" == "o2k3" -o "$sys" == "o2k7" ]
then
echo Downloading most recent files for Office inventory functionality...
wget -nv -c -N -i ../static/StaticDownloadLinks-inventory.txt -P ../client/wsus
fi

echo Extracting Windows Update Agent catalog file wuredist.xml...
cd ../client/wsus
cabextract -q -F wuredist.xml wuredist.cab
cd ../../sh
rm ../client/wsus/wuredist.cab

echo Determining update urls for Windows Update Agent...
if [ "$sys" != "w2k3-x64" ] && [ "$sys" != "w60-x64" ]
then
	$xml tr ../xslt/ExtractDownloadLinks-wua-x86.xsl ../client/wsus/wuredist.xml > ../temp/DownloadLinks-wua.txt
else
	$xml tr ../xslt/ExtractDownloadLinks-wua-x64.xsl ../client/wsus/wuredist.xml > ../temp/DownloadLinks-wua.txt
fi
rm ../client/wsus/wuredist.xml

echo Downloading most recent Windows Update Agent...
wget -nv -c -N -i ../temp/DownloadLinks-wua.txt -P ../client/wsus
rm ../temp/DownloadLinks-wua.txt

#echo Downloading most recent Microsoft Installer...
#wget -nv -c -N -i ../static/StaticDownloadLink-msi-x86.txt -P ../client/msi

echo Determining static urls for $sys $lang ...

static1="../static/StaticDownloadLinks-$sys-x86-$lang.txt"
if [ -f "$static1" ]
then 
 if [ "$EXCLUDE_SP" == "0" ]
 then
  cat $static1 >> ../temp/StaticUrls-$sys-$lang.txt
 fi
 if [ "$EXCLUDE_SP" == "1" ]
 then
  cat $static1|grep -v -f ../exclude/ExcludeList-SPs.txt > ../temp/StaticUrls-$sys-$lang.txt
 fi 
fi

static2="../static/StaticDownloadLinks-$sys-$lang.txt"
if [ -f "$static2" ]
then
	if [ "$EXCLUDE_SP" == "0" ]
 		then
 			cat $static2 >> ../temp/StaticUrls-$sys-$lang.txt
 	fi
 	if [ "$EXCLUDE_SP" == "1" ]
 		then
  			cat $static2|grep -v -f ../exclude/ExcludeList-SPs.txt > ../temp/StaticUrls-$sys-$lang.txt
  	fi 
fi

static3="../static/StaticDownloadLinks-win-x86-$lang.txt"
static4="../static/StaticDownloadLinks-win-x86-glb.txt"
if [ "$sys" != "w60" ] && [ "$sys" != "$w60-x64" ] && [ "$sys" != "o2k" ] && [ "$sys" != "oxp" ] && [ "$sys" != "o2k3" ] && [ "$sys" != "o2k7" ] && [ "$sys" != "w2k3-x64" ];
then
 if [ -f "$static3" ] 
  then
   cat $static3 > ../temp/StaticUrls-$lang.txt
 fi
 if [ -f "$static4" ]
 	then
 		cat $static4 > ../temp/StaticUrls-glb.txt
 fi
fi

if [ "$sys" != "w60" ] && [ "$sys" != "w60-x64" ]
then 
	static4="../static/StaticDownloadLinks-$sys-x86-glb.txt"
	if [ -f "$static4" ]
	then
		cat $static4 > ../temp/StaticUrls-$sys-glb.txt
	fi
fi

static5="../static/StaticDownloadLinks-$sys-glb.txt"
if [ -f "$static5" ]
	then
		cat $static5 > ../temp/StaticUrls-$sys-glb.txt
fi

if [ "$dotnet" == "1" ]
then
	cp ../static/StaticDownloadLink-dotnet.txt ../temp/StaticUrls-dotnet.txt
fi

if [ "$sys" == "w2k" ] ;
then
 echo Determining Urls for IE6 $lang ...
 cat ../static/StaticDownloadLinks-ie6-$lang.txt > ../temp/StaticUrls-ie6-$lang.txt
fi

if [ "$sys" == "o2k" -o "$sys" == "oxp" -o "$sys" == "o2k3" ] ;
then
	echo Determining static urls for ofc glb...
	cat ../static/StaticDownloadLinks-ofc-glb.txt > ../temp/StaticUrls-ofc-glb.txt
	echo Determining static urls for ofc $lang...
	cat ../static/StaticDownloadLinks-ofc-$lang.txt > ../temp/StaticUrls-ofc-$lang.txt
fi

cd ../temp
if [ "$sys" == "o2k" -o "$sys" == "oxp" -o "$sys" == "o2k3" -o "$sys" == "o2k7" ] ;
then
	echo Extracting Office update catalog file package.xml...
	cabextract -q -F patchdata.xml ../client/wsus/invcif.exe
	mv patchdata.xml package.xml	
	else
	echo Extracting Windows update catalog file package.xml...
	cp ../client/wsus/wsusscn2.cab ../client/wsus/wsusscn2_1.cab	
	cabextract -q -F package.cab ../client/wsus/wsusscn2_1.cab
	cabextract -q -F package.xml package.cab
	rm package.cab	
	rm ../client/wsus/wsusscn2_1.cab
	fi
cd ../sh

echo Determining update urls for $sys $lang...
download1="../xslt/ExtractDownloadLinks-$sys-$lang.xsl"
download2="../xslt/ExtractDownloadLinks-$sys-x86-$lang.xsl"
valid1="../xslt/ExtractValidIds-$sys.xsl"
valid2="../xslt/ExtractValidIds-$sys-x86.xsl"
expired1="../xslt/ExtractExpiredIds-$sys.xsl"
expired2="../xslt/ExtractExpiredIds-$sys-x86.xsl"
exclude1="../exclude/ExcludeList-$sys.txt"
exclude2="../exclude/ExcludeList-$sys-x86.txt"
glb1="../xslt/ExtractDownloadLinks-$sys-glb.xsl"
glb2="../xslt/ExtractDownloadLinks-$sys-x86-glb.xsl"
verify="../temp/tmpUrls-$sys-$lang.txt"
	if [ -f "$valid1" ]
		then
			$xml tr ../xslt/ExtractValidIds-$sys.xsl ../temp/package.xml > ../temp/Validid-$sys.txt
		fi
	if [ -f "$valid2" ]
		then
			$xml tr ../xslt/ExtractValidIds-$sys-x86.xsl ../temp/package.xml > ../temp/Validid-$sys.txt
		fi
	if [ -f "$expired1" ]
		then
			$xml tr ../xslt/ExtractExpiredIds-$sys.xsl ../temp/package.xml > ../temp/Expiredid-$sys.txt
		fi
	if [ -f "$expired2" ]
		then
			$xml tr ../xslt/ExtractExpiredIds-$sys-x86.xsl ../temp/package.xml > ../temp/Expiredid-$sys.txt
		fi
	if [ -f "$download1" ]
		then
			$xml tr ../xslt/ExtractDownloadLinks-$sys-$lang.xsl ../temp/package.xml > ../temp/Urls-$sys-$lang.txt
		fi
	if [ -f "$download2" ]
		then
			$xml tr ../xslt/ExtractDownloadLinks-$sys-x86-$lang.xsl ../temp/package.xml > ../temp/Urls-$sys-$lang.txt
		fi
	if [ -f "$valid1" -o -f "$valid2" ] && [ -f "$expired1" -o -f "$expired2" ]
		then	
			cat ../temp/Urls-$sys-$lang.txt|grep -v -f ../temp/Expiredid-$sys.txt > ../temp/tmpUrls-$sys-$lang.txt
			cat ../temp/Urls-$sys-$lang.txt|grep -f ../temp/Validid-$sys.txt >> ../temp/tmpUrls-$sys-$lang.txt
		else
			cp ../temp/Urls-$sys-$lang.txt ../temp/tmpUrls-$sys-$lang.txt
	fi
	if [ -f "$exclude1" ]
		then
			cat ../temp/tmpUrls-$sys-$lang.txt|grep -v -f ../exclude/ExcludeList-$sys.txt > ../temp/ValidUrls-$sys-$lang.txt	
		fi
	if [ -f "$exclude2" ]
		then
			cat ../temp/tmpUrls-$sys-$lang.txt|grep -v -f ../exclude/ExcludeList-$sys-x86.txt > ../temp/ValidUrls-$sys-$lang.txt
		fi
if [ -f "$glb1" ] && [ "$lang" != "glb" ]
	then
		$xml tr ../xslt/ExtractDownloadLinks-$sys-glb.xsl ../temp/package.xml > ../temp/Urls-$sys-glb.txt
		if [ -f "$valid1" -o -f "$valid2" ] && [ -f "$expired1" -o -f "$expired2" ]
		then
			cat ../temp/Urls-$sys-glb.txt|grep -f ../temp/Validid-$sys.txt > ../temp/tmpValidUrls-$sys-glb.txt
			cat ../temp/Urls-$sys-glb.txt|grep -v -f ../temp/Expiredid-$sys.txt >> ../temp/tmpValidUrls-$sys-glb.txt
		else
			cp ../temp/Urls-$sys-glb.txt ../temp/tmpValidUrls-$sys-glb.txt
		fi
		cat ../temp/tmpValidUrls-$sys-glb.txt|grep -v -f ../exclude/ExcludeList-$sys.txt > ../temp/ValidUrls-$sys-glb.txt
		rm ../temp/Urls-$sys-glb.txt
		rm ../temp/tmpValidUrls-$sys-glb.txt
	fi
	
if [ -f "$glb2" ] && [ "$lang" != "glb" ]
	then
		$xml tr ../xslt/ExtractDownloadLinks-$sys-x86-glb.xsl ../temp/package.xml > ../temp/Urls-$sys-glb.txt
		if [ -f "$valid1" -o -f "$valid2" ] && [ -f "$expired1" -o -f "$expired2" ]
		then
			cat ../temp/Urls-$sys-glb.txt|grep -f ../temp/Validid-$sys.txt > ../temp/tmpValidUrls-$sys-glb.txt
			cat ../temp/Urls-$sys-glb.txt|grep -v -f ../temp/Expiredid-$sys.txt >> ../temp/tmpValidUrls-$sys-glb.txt
		else
			cp ../temp/Urls-$sys-glb.txt ../temp/tmpValidUrls-$sys-glb.txt
		fi
		cat ../temp/tmpValidUrls-$sys-glb.txt|grep -v -f ../exclude/ExcludeList-$sys-x86.txt > ../temp/ValidUrls-$sys-glb.txt
		rm ../temp/Urls-$sys-glb.txt
		rm ../temp/tmpValidUrls-$sys-glb.txt
	fi	


if [ "$sys" != "w60" ] && [ "$sys" != "w60-x64" ] && [ "$sys" != "o2k" ] && [ "$sys" != "oxp" ] && [ "$sys" != "o2k3" ] && [ "$sys" != "o2k7" ] && [ "$sys" != "w2k3-x64" ]
then
 echo Determining update urls for win $lang...
 $xml tr ../xslt/ExtractDownloadLinks-win-x86-$lang.xsl ../temp/package.xml > ../temp/Urls-win-x86-$lang.txt
 cat ../temp/Urls-win-x86-$lang.txt|grep -v -f ../exclude/ExcludeList-win-x86.txt > ../temp/ValidUrls-win-x86-$lang.txt
 $xml tr ../xslt/ExtractDownloadLinks-win-x86-glb.xsl ../temp/package.xml > ../temp/Urls-win-x86-glb.txt
 cat ../temp/Urls-win-x86-glb.txt|grep -v -f ../exclude/ExcludeList-win-x86.txt > ../temp/ValidUrls-win-x86-glb.txt
 rm ../temp/Urls-win-x86-$lang.txt
fi
rm ../temp/package.xml

touch ../temp/StaticUrls-$sys-$lang.txt
touch ../temp/StaticUrls-ie6-$lang.txt
touch ../temp/ValidUrls-$sys-$lang.txt
touch ../temp/ValidUrls-win-x86-$lang.txt
touch ../temp/ValidUrls-win-x86-glb.txt
touch ../temp/ValidUrls-$sys-glb.txt
touch ../temp/StaticUrls-ofc-glb.txt
touch ../temp/StaticUrls-ofc-$lang.txt
touch ../temp/StaticUrls-$sys-glb.txt
touch ../temp/StaticUrls-$lang.txt
touch ../temp/StaticUrls-glb.txt
touch ../temp/StaticUrls-dotnet.txt
	
cat ../temp/StaticUrls-$sys-$lang.txt >> ../temp/Urls.txt
cat ../temp/StaticUrls-ie6-$lang.txt >> ../temp/Urls.txt
cat ../temp/ValidUrls-$sys-$lang.txt >> ../temp/Urls.txt
cat ../temp/ValidUrls-win-x86-$lang.txt >> ../temp/Urls.txt
cat ../temp/ValidUrls-win-x86-glb.txt >> ../temp/Urls.txt
cat ../temp/ValidUrls-$sys-glb.txt >> ../temp/Urls.txt
cat ../temp/StaticUrls-ofc-glb.txt >> ../temp/Urls.txt
cat ../temp/StaticUrls-ofc-$lang.txt >> ../temp/Urls.txt
cat ../temp/StaticUrls-$sys-glb.txt >> ../temp/Urls.txt
cat ../temp/StaticUrls-glb.txt >> ../temp/Urls.txt
cat ../temp/StaticUrls-$lang.txt >> ../temp/Urls.txt
cat ../temp/StaticUrls-dotnet.txt >> ../temp/Urls.txt
echo 
echo "***************************************"
echo Found `cat ../temp/Urls.txt|grep -c http:` patches ...
 
 #create needed dirs
 mkdir -p ../client/win/$lang
 mkdir -p ../client/$sys/
 mkdir -p ../client/$sys/glb
 mkdir -p ../client/$sys/$lang
 mkdir -p ../client/win/$lang/ie6setup
if [ "$sys" == "o2k" -o "$sys" == "oxp" -o "$sys" == "o2k3" ] ;
then
	mkdir -p ../client/ofc
	mkdir -p ../client/ofc/glb
	mkdir -p ../client/ofc/$lang
fi
 
 printheader
 echo Downloading patches for $sys...
 echo Downloading static patches...
 wget -nv -c -N -i ../temp/StaticUrls-$sys-$lang.txt -P ../client/$sys/$lang
 if [ "$sys" != "w60" ] && [ "$sys" != "w60-x64" ] && [ "$sys" != "o2k" ] && [ "$sys" != "oxp" ] && [ "$sys" != "o2k3" ] && [ "$sys" != "o2k7" ] && [ "$sys" != "w2k3-x64" ]
 then
 	wget -nv -c -N -i ../temp/StaticUrls-$lang.txt -P ../client/win/$lang
 	wget -nv -c -N -i ../temp/StaticUrls-glb.txt -P ../client/win/glb
 fi
 wget -nv -c -N -i ../temp/StaticUrls-$sys-glb.txt -P ../client/$sys/glb
if [ "$sys" == "o2k" -o "$sys" == "oxp" -o "$sys" == "o2k3" ] ;
then
	 wget -nv -c -N -i ../temp/StaticUrls-ofc-glb.txt -P ../client/ofc/glb
	 wget -nv -c -N -i ../temp/StaticUrls-ofc-$lang.txt -P ../client/ofc/$lang
fi
 
 if [ "$sys" == "w2k" ] ;
  then
   wget -nv -c -N -i ../temp/StaticUrls-ie6-$lang.txt -P ../client/win/$lang/ie6setup
   /bin/bash ./FIXIE6SetupDir.sh $lang
 fi
if [ "$dotnet" == "1" ]
then 	
	echo Downloading .Net-Framework...
 	wget -nv -c -N -i ../temp/StaticUrls-dotnet.txt -P ../client/dotnet
fi

 echo Downloading patches for $sys $lang
 wget -nv -c -N -i ../temp/ValidUrls-$sys-$lang.txt -P ../client/$sys/$lang
 wget -nv -c -N -i ../temp/ValidUrls-$sys-glb.txt -P ../client/$sys/glb
if [ "$sys" != "w60" ] && [ "$sys" != "w60-x64" ] && [ "$sys" != "o2k" ] && [ "$sys" != "oxp" ] && [ "$sys" != "o2k3" ] && [ "$sys" != "o2k7" ] && [ "$sys" != "w2k3-x64" ]
 then 
 wget -nv -c -N -i ../temp/ValidUrls-win-x86-$lang.txt -P ../client/win/$lang
 wget -nv -c -N -i ../temp/ValidUrls-win-x86-glb.txt -P ../client/win/glb
fi
 
printheader
 echo Validating patches for $sys...
 echo Validating static patches...
 wget -nv -c -N -i ../temp/StaticUrls-$sys-$lang.txt -P ../client/$sys/$lang
 if [ "$sys" != "w60" ] && [ "$sys" != "w60-x64" ] && [ "$sys" != "o2k" ] && [ "$sys" != "oxp" ] && [ "$sys" != "o2k3" ] && [ "$sys" != "o2k7" ] && [ "$sys" != "w2k3-x64" ]
 then
 	wget -nv -c -N -i ../temp/StaticUrls-$lang.txt -P ../client/win/$lang
 	wget -nv -c -N -i ../temp/StaticUrls-glb.txt -P ../client/win/glb
 fi
 wget -nv -c -N -i ../temp/StaticUrls-$sys-glb.txt -P ../client/$sys/glb
if [ "$sys" == "o2k" -o "$sys" == "oxp" -o "$sys" == "o2k3" ] ;
then
	 wget -nv -c -N -i ../temp/StaticUrls-ofc-glb.txt -P ../client/ofc/glb
	 wget -nv -c -N -i ../temp/StaticUrls-ofc-$lang.txt -P ../client/ofc/$lang
fi
if [ "$dotnet" == "1" ]
then 	
	echo Validating .Net-Framework...
 	wget -nv -c -N -i ../temp/StaticUrls-dotnet.txt -P ../client/dotnet
fi

 echo Validating patches for $sys $lang ...
 wget -nv -c -N -i ../temp/ValidUrls-$sys-$lang.txt -P ../client/$sys/$lang
 wget -nv -c -N -i ../temp/ValidUrls-$sys-glb.txt -P ../client/$sys/glb
if [ "$sys" != "w60" ] && [ "$sys" != "w60-x64" ] && [ "$sys" != "o2k" ] && [ "$sys" != "oxp" ] && [ "$sys" != "o2k3" ] && [ "$sys" != "o2k7" ] && [ "$sys" != "w2k3-x64" ]
 then 
 wget -nv -c -N -i ../temp/ValidUrls-win-x86-$lang.txt -P ../client/win/$lang
 wget -nv -c -N -i ../temp/ValidUrls-win-x86-glb.txt -P ../client/win/glb
fi
 echo "**************************************"
 echo `cat ../temp/Urls.txt|grep -c http:` patches successfully downloaded.
 echo
else
 echo 
 echo Program aborted.
 echo
 exit 
fi
if [ "$CLEANUP_DOWNLOADS" != "0" ]
then
 echo Cleaning up ...
 echo Cleaning up client directory for $sys $lang 
 cat ../temp/StaticUrls-$sys-$lang.txt >> ../temp/ValidUrls-$sys-$lang.txt
 cleanup "../temp/ValidUrls-$sys-$lang.txt" "../client/$sys/$lang"
 echo Cleaning up client directory for $sys glb 
 cat ../temp/StaticUrls-$sys-glb.txt >> ../temp/ValidUrls-$sys-glb.txt
 cleanup "../temp/ValidUrls-$sys-glb.txt" "../client/$sys/glb"
if [ "$sys" == "o2k" -o "$sys" == "oxp" -o "$sys" == "o2k3" ]
	then 
 		echo Cleaning up client directory for ofc $lang
 		cat ../temp/StaticUrls-ofc-$lang.txt > ../temp/ValidUrls-ofc-$lang.txt
 		cleanup "../temp/ValidUrls-ofc-$lang.txt" "../client/ofc/$lang"
 		echo Cleaning up client directory for ofc glb
 		cat ../temp/StaticUrls-ofc-glb.txt > ../temp/ValidUrls-ofc-glb.txt
 		cleanup "../temp/ValidUrls-ofc-glb.txt" "../client/ofc/glb"
fi
if [ "$sys" != "w60" ] && [ "$sys" != "w60-x64" ] && [ "$sys" != "o2k" ] && [ "$sys" != "oxp" ] && [ "$sys" != "o2k3" ] && [ "$sys" != "o2k7" ] && [ "$sys" != "w2k3-x64" ]
then 
 echo Cleaning up client directory for win $lang
 cat ../temp/StaticUrls-$lang.txt > ../temp/ValidUrls-$lang.txt
 cat ../temp/ValidUrls-win-x86-$lang.txt >> ../temp/ValidUrls-$lang.txt
 cleanup "../temp/ValidUrls-$lang.txt" "../client/win/$lang"
 echo Cleaning up client directory for win glb
 cat ../temp/StaticUrls-glb.txt > ../temp/ValidUrls-glb.txt
 cat ../temp/ValidUrls-win-x86-glb.txt >> ../temp/ValidUrls-glb.txt
 cleanup "../temp/ValidUrls-glb.txt" "../client/win/glb"
fi
fi

if [ "$createiso" == "1" ]
	then
		/bin/bash ./CreateISOImage.sh $sys $lang $param2 $param3
fi 

