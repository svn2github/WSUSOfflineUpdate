# This file will be sourced by the shell bash.
#
# Filename: usage.bash
# Version: 1.0-beta-4
# Release date: 2017-06-23
# Intended compatibility: WSUS Offline Update Version 10.9.2 and newer
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
#     The usage page is shown, if too less or wrong parameters are
#     entered on the command line.
#
#     Optimally, the usage page should be a short overview, which fits in
#     a 80 x 22 window. Then both the previous and the next command prompt
#     can be seen. This allows an easy correction of the command line.
#
#     The complete documentation is in the file documentation/usage.txt.


function show_usage ()
{
    cat << EOF
USAGE
   ./download-updates.bash UPDATE LANGUAGE[,LANGUAGE...] [OPTIONS]

UPDATE
    w60          Windows Server 2008, 32-bit
    w60-x64      Windows Server 2008, 64-bit
    w61          Windows 7, 32-bit
    w61-x64      Windows 7 / Server 2008 R2, 64-bit
    w62-x64      Windows Server 2012, 64-bit
    w63          Windows 8.1, 32-bit
    w63-x64      Windows 8.1 / Server 2012 R2, 64-bit
    w100         Windows 10, 32-bit
    w100-x64     Windows 10 / Server 2016, 64-bit
    o2k7         Office 2007, 32-bit
    o2k10        Office 2010, 32-bit
    o2k10-x64    Office 2010, 32-bit and 64-bit
    o2k13        Office 2013, 32-bit
    o2k13-x64    Office 2013, 32-bit and 64-bit
    o2k16        Office 2016, 32-bit
    o2k16-x64    Office 2016, 32-bit and 64-bit

LANGUAGE
    deu    German
    enu    English
    ara    Arabic
    chs    Chinese (Simplified)
    cht    Chinese (Traditional)
    csy    Czech
    dan    Danish
    nld    Dutch
    fin    Finnish
    fra    French
    ell    Greek
    heb    Hebrew
    hun    Hungarian
    ita    Italian
    jpn    Japanese
    kor    Korean
    nor    Norwegian
    plk    Polish
    ptg    Portuguese
    ptb    Portuguese (Brazil)
    rus    Russian
    esn    Spanish
    sve    Swedish
    trk    Turkish

    Note: Multiple languages can be joined to a comma-separated list like
    "deu,enu".

OPTIONS
   -includesp
        Include Service Packs

   -includecpp
        Include Visual C++ runtime libraries

   -includedotnet
        Include .NET Frameworks: localized installation files and updates

   -includewddefs
        Virus definition files for Windows Vista and 7. These virus
        definition files are only compatible with the original Windows
        Defender, which was included in Windows Vista and 7.

   -includemsse
        Microsoft Security Essentials: localized installation files and
        virus definition updates. Microsoft Security Essentials is an
        optional installation for Windows Vista and 7.

   -includewddefs8
        Virus definition files for Windows 8 and higher. These are
        the same virus definition updates as for Microsoft Security
        Essentials, but without the localized installers.
EOF
}

return 0
