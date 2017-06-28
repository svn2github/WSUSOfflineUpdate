#!/usr/bin/env bash
#
# Filename: get-all-updates.bash
# Version: 1.0-beta-3
# Release date: 2017-03-30
# Intended compatibility: WSUS Offline Update Version 10.9.1 - 10.9.2
#
# Copyright (C) 2016-2017 Hartmut Buhrmester
#                         <zo3xaiD8-eiK1iawa@t-online.de>
#
# License
#
#     This file is free software: you can redistribute it and/or modify
#     it under the terms of the GNU General Public License as published
#     by the Free Software Foundation, either version 3 of the License,
#     or (at your option) any later version.
#
#     This file is distributed in the hope that it will be useful,
#     but WITHOUT ANY WARRANTY; without even the implied warranty of
#     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
#     General Public License for more details.
#
#     You should have received a copy of the GNU General
#     Public License along with this program.  If not, see
#     <http://www.gnu.org/licenses/>.
#
# Description
#
#     An example script to download all updates for the languages German
#     and English. This script should give the same result as the Windows
#     script DownloadUpdates.cmd, if Office x64 support is enabled for
#     German and English by running:
#
#     AddOffice2010x64Support.cmd deu
#     AddOffice2010x64Support.cmd enu
#
#     It may also serve as a template to be customized.


# Exit this script, if one of download runs exits with an error
set -o errexit

# Resolving the installation path with GNU readlink is very reliable,
# but it may only work in Linux and FreeBSD. Remove the option -f for
# BSD readlink on Mac OS X. If there are problems with resolving the
# installation path, change directly into the installation directory of
# this script and run it script from there.
cd "$(dirname "$(readlink -f "$0")")"

# Windows Vista and Windows 7
#
# Setting the language is needed to get localized installers for Internet
# Explorer 9 for Windows Vista, Internet Explorer 11 for Windows 7,
# and for the optional downloads dotnet and msse.
for update in w60 w60-x64 w61 w61-x64; do
    for language in deu enu; do
        ./download-updates.bash ${update} ${language} -includesp -includecpp -includedotnet -includewddefs -includemsse
    done
done

# Windows 8 - 10
#
# Updates for Windows 8 to 10 are really global, und they are only
# evaluated once for all specified languages. The language parameters
# deu and enu are still needed for the .Net Framework downloads. Without
# this optional download, one language (any one) would be sufficient.
#
# To be precise, the English installers for .Net Frameworks are always
# downloaded, and they are accomplished by Language Packs for other
# languages. So, you could actually remove the language "enu" here. On
# the other hand, if you like to get other "custom" languages, they must
# be listed here.
for update in w62-x64 w63 w63-x64 w100 w100-x64; do
    for language in deu enu; do
        ./download-updates.bash ${update} ${language} -includesp -includecpp -includedotnet -includewddefs8
    done
done


# Office 2007 - 2013
#
# o2k10-x64 and o2k13-x64 include both 32-bit and 64-bit downloads,
# just like the Windows script DownloadUpdates.cmd, if 64-bit Office
# support is enabled by running the script AddOffice2010x64Support.cmd.
for update in o2k7 o2k10-x64 o2k13-x64; do
    for language in deu enu; do
        ./download-updates.bash ${update} ${language} -includesp
    done
done

# Office 2016
#
# o2k16-x64 includes both 32-bit and 64-bit downloads. One language
# (any one) is sufficient.
./download-updates.bash o2k16-x64 deu -includesp

exit 0
