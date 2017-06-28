# This file will be sourced by the shell bash.
#
# Filename: usage.bash
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
#     The usage page should not replace the complete manual, but rather
#     show a short overview, which fits in a 80 x 22 window. Then both
#     the previous and the next command prompt can be seen. This allows
#     an easy correction of the command line.
#
#     The complete documentation is in the file documentation/usage.txt.


function show_usage ()
{
    cat << EOF
Usage: ./download-updates.bash <update> <language> [<options>...]

<update>
   w60 | w60-x64 | w61 | w61-x64 | w62-x64 | w63 | w63-x64 | w100 | w100-x64 |
   o2k7 | o2k10 | o2k10-x64 | o2k13 | o2k13-x64 | o2k16 | o2k16-x64

<language>
   deu | enu | ara | chs | cht | csy | dan | nld | fin | fra | ell | heb |
   hun | ita | jpn | kor | nor | plk | ptg | ptb | rus | esn | sve | trk

<options>
 * for Windows Vista (w60 | w60-x64):
   -includesp -includecpp -includedotnet -includewddef -includemsse
 * for Windows 7 (w61 | w61-x64):
   -includesp -includecpp -includedotnet -includewddef -includemsse
 * for Windows 8 - 10 (w62-x64 | w63 | w63-x64 | w100 | w100-x64):
   -includesp -includecpp -includedotnet -includewddefs8
 * for all Office updates:
   -includesp
EOF
}

return 0
