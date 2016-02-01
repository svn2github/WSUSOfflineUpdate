#@echo off
#rem *** Author: T. Wittrock, Kiel ***

#verify other 2>nul
#setlocal enableextensions
#if errorlevel 1 goto NoExtensions

#cd /D "%~dp0"



#rem *** Remove support for deu from static URL files ***
pushd ../static
echo Removing support for deu from static URL files...
for Type in dotnet msse w60 w61 
do 
  for Arch in x86 x64 
  do
    if [ -r StaticDownloadLinks-$Type-$Arch-glb.txt ]; then
      echo Processing file ../static/StaticDownloadLinks-$Type-$Arch-glb.txt
      sed -i -e '/deu./d' -e '/de./d' -e '/enu./d' -e '/us./d' StaticDownloadLinks-$Type-$Arch-glb.txt
      if [ ! -s StaticDownloadLinks-$Type-$Arch-glb.txt ]; then
       rm StaticDownloadLinks-$Type-$Arch-glb.txt
      fi
    fi
    if [ -r StaticDownloadLinks-$Type-$Arch-5lg.txt ]; then
      echo Processing file ../static/StaticDownloadLinks-$Type-$Arch-5lg.txt
      sed -i -e '/deu./d' -e '/de./d' -e '/enu./d' -e '/us./d' StaticDownloadLinks-$Type-$Arch-5lg.txt
      if [ ! -s StaticDownloadLinks-$Type-$Arch-5lg.txt ]; then
       rm StaticDownloadLinks-$Type-$Arch-5lg.txt
      fi
    fi
    if [ -r StaticDownloadLinks-$Type-$Arch-alg.txt ]; then
      echo Processing file ../static/StaticDownloadLinks-$Type-$Arch-alg.txt
      sed -i -e '/deu./d' -e '/de./d' -e '/enu./d' -e '/us./d' StaticDownloadLinks-$Type-$Arch-alg.txt
      if [ ! -sStaticDownloadLinks-$Type-$Arch-alg.txt ]; then
        rm StaticDownloadLinks-$Type-$Arch-alg.txt
      fi
    fi
  done
done
if [ -r StaticDownloadLinks-dotnet.txt ]; then
  echo Processing file ../static/StaticDownloadLinks-dotnet.txt
  sed -i -e '/deu./d' -e '/de./d' -e '/enu./d' -e '/us./d' StaticDownloadLinks-dotnet.txt
  if [ ! -s StaticDownloadLinks-dotnet.txt ]; then
    rm StaticDownloadLinks-dotnet.txt
  fi
fi
popd
#goto EoF

#:NoExtensions
#echo.
#echo ERROR: No command extensions / delayed variable expansion available.
#echo.
#goto EoF

#:EoF
#endlocal

# ====================================================================

# $Id: RemoveGermanAndEnglishLanguageSupport.sh,v 1.1 2014-12-10 14:10:48+01 TWittrock Exp $
# $Log: RemoveGermanAndEnglishLanguageSupport.sh,v $
# Revision 1.1  2014-12-10 14:10:48+01  TWittrock
# Start des Skripts

