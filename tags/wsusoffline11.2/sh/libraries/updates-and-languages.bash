# This file will be sourced by the shell bash.
#
# Filename: updates-and-languages.bash
#
# Copyright (C) 2016-2018 Hartmut Buhrmester
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
#     This file defines menus and tables for the updates, languages and
#     available options.
#
#     Menus and tables basically provide the same information, but in a
#     different format: menus are indexed arrays, while tables are text
#     variables with multiple lines.
#
#
#     Menus for the script update-generator.bash
#
#     Menus are implemented as indexed arrays. They are used to create
#     simple selection dialogs with the bash builtin command "select".
#
#     Each array element consists of a name and description. It can be
#     split into single fields with "read -r". As usual with "read",
#     the last variable receives the remainder of the line. This is
#     used here to split the line into two fields, without needing any
#     additional field delimiters like commas or semicolons:
#
#     read -r update_name   update_description   <<< "${line}"
#     read -r language_name language_description <<< "${line}"
#     read -r option_name   option_description   <<< "${line}"
#
#
#     Tables for the script download-updates.bash
#
#     Tables can be searched with grep just like text files. To avoid
#     ambiguities, the search pattern should be anchored to the beginning
#     of the line and also include a trailing space. For example, the
#     first line of the updates table would be matched with:
#
#     grep "^w60 " <<< "${updates_table}"
#
#     Each line can then be split into single fields with read -r as
#     described above.

# ========== Version specific configuration ===============================

# This is the configuration file for the current version 11.1.1 of WSUS
# Offline Update.

localized_win_updates="disabled"
dynamic_win_updates="disabled"

# Supported updates
#
# Windows Server 2008, based on Windows Vista, is available in both
# 32-bit and 64-bit versions.
#
# Windows Server 2008 R2, based on Windows 7, "is the first 64-bit–only
# operating system released from Microsoft."
#
# - https://en.wikipedia.org/wiki/Windows_Server_2008
# - https://en.wikipedia.org/wiki/Windows_Server_2008_R2

updates_menu=(
    "w60           Windows Server 2008, 32-bit"
    "w60-x64       Windows Server 2008, 64-bit"
    "w61           Windows 7, 32-bit"
    "w61-x64       Windows 7 / Server 2008 R2, 64-bit"
    "w62-x64       Windows Server 2012, 64-bit"
    "w63           Windows 8.1, 32-bit"
    "w63-x64       Windows 8.1 / Server 2012 R2, 64-bit"
    "w100          Windows 10, 32-bit"
    "w100-x64      Windows 10 / Server 2016, 64-bit"
    "o2k10         Office 2010, 32-bit"
    "o2k10-x64     Office 2010, 32-bit and 64-bit"
    "o2k13         Office 2013, 32-bit"
    "o2k13-x64     Office 2013, 32-bit and 64-bit"
    "o2k16         Office 2016, 32-bit"
    "o2k16-x64     Office 2016, 32-bit and 64-bit"
    "all           All Windows and Office updates, 32-bit and 64-bit"
    "all-x86       All Windows and Office updates, 32-bit"
    "all-x64       All Windows and Office updates, 64-bit"
    "all-win       All Windows updates, 32-bit and 64-bit"
    "all-win-x86   All Windows updates, 32-bit"
    "all-win-x64   All Windows updates, 64-bit"
    "all-ofc       All Office updates, 32-bit and 64-bit"
    "all-ofc-x86   All Office updates, 32-bit"
)

# Internal Lists
list_all=( "w60" "w60-x64" "w61" "w61-x64" "w62-x64" "w63" "w63-x64" "w100" "w100-x64" "o2k10-x64" "o2k13-x64" "o2k16-x64" )
list_all_x86=( "w60" "w61" "w63" "w100" "o2k10" "o2k13" "o2k16" )
list_all_x64=( "w60-x64" "w61-x64" "w62-x64" "w63-x64" "w100-x64" "o2k10-x64" "o2k13-x64" "o2k16-x64" )
list_all_win=( "w60" "w60-x64" "w61" "w61-x64" "w62-x64" "w63" "w63-x64" "w100" "w100-x64" )
list_all_win_x86=( "w60" "w61" "w63" "w100" )
list_all_win_x64=( "w60-x64" "w61-x64" "w62-x64" "w63-x64" "w100-x64" )
list_all_ofc=( "o2k10-x64" "o2k13-x64" "o2k16-x64" )
list_all_ofc_x86=( "o2k10" "o2k13" "o2k16" )

# ========== Configuration of languages and optional downloads ============

# Languages for Windows XP and Office 2003 - 2013
languages_menu=(
    "deu   German"
    "enu   English"
    "ara   Arabic"
    "chs   Chinese (Simplified)"
    "cht   Chinese (Traditional)"
    "csy   Czech"
    "dan   Danish"
    "nld   Dutch"
    "fin   Finnish"
    "fra   French"
    "ell   Greek"
    "heb   Hebrew"
    "hun   Hungarian"
    "ita   Italian"
    "jpn   Japanese"
    "kor   Korean"
    "nor   Norwegian"
    "plk   Polish"
    "ptg   Portuguese"
    "ptb   Portuguese (Brazil)"
    "rus   Russian"
    "esn   Spanish"
    "sve   Swedish"
    "trk   Turkish"
)

# Languages for Windows Server 2003, 32-bit
languages_menu_w2k3=(
    "deu   German"
    "enu   English"
    "chs   Chinese (Simplified)"
    "cht   Chinese (Traditional)"
    "csy   Czech"
    "nld   Dutch"
    "fra   French"
    "hun   Hungarian"
    "ita   Italian"
    "jpn   Japanese"
    "kor   Korean"
    "plk   Polish"
    "ptg   Portuguese"
    "ptb   Portuguese (Brazil)"
    "rus   Russian"
    "esn   Spanish"
    "sve   Swedish"
    "trk   Turkish"
)

# Languages for Windows XP / Server 2003, 64-bit
languages_menu_w2k3_x64=(
    "deu   German"
    "enu   English"
    "fra   French"
    "ita   Italian"
    "jpn   Japanese"
    "kor   Korean"
    "ptb   Portuguese (Brazil)"
    "rus   Russian"
    "esn   Spanish"
)

# Options for Windows XP
#
# The latest installers for Windows Security Essentials don't support
# Windows XP anymore, but maybe the virus definition files still work.
options_menu_windows_xp=(
    "-includesp        Service Packs"
    "-includecpp       Visual C++ Runtime Libraries"
    "-includedotnet    .NET Frameworks"
    "-includewddefs    Windows Defender Definitions for Windows XP, Vista and 7"
    "-includemsse      Microsoft Security Essentials"
)

# Options for Windows Server 2003
#
# The original Windows Defender may still be supported, but Microsoft
# Security Essentials was never supported on Windows Server 2003.
options_menu_windows_w2k3=(
    "-includesp        Service Packs"
    "-includecpp       Visual C++ Runtime Libraries"
    "-includedotnet    .NET Frameworks"
    "-includewddefs    Windows Defender Definitions for Windows XP, Vista and 7"
)

# Options for Windows Vista and Windows 7.
#
# The original Windows Defender is preinstalled in Windows Vista and
# 7. It can be replaced by Security Essentials.
#
# These options are also used as a common delimiter for the internal
# lists all, all-x86, all-x64, all-win, all-win-x86, and all-win-x64.
options_menu_windows_vista=(
    "-includesp        Service Packs"
    "-includecpp       Visual C++ Runtime Libraries"
    "-includedotnet    .NET Frameworks"
    "-includewddefs    Windows Defender Definitions for Windows Vista and 7"
    "-includemsse      Microsoft Security Essentials"
)

# Options for Windows 8, 8.1 and 10
options_menu_windows_8=(
    "-includesp        Service Packs"
    "-includecpp       Visual C++ Runtime Libraries"
    "-includedotnet    .NET Frameworks"
    "-includewddefs8   Windows Defender Definitions for Windows 8 - 10"
)

# Options for all Office versions
options_menu_office=(
    "-includesp        Service Packs"
)

# All options
options_menu_all=(
    "-includesp        Service Packs"
    "-includecpp       Visual C++ Runtime Libraries"
    "-includedotnet    .NET Frameworks"
    "-includewddefs    Windows Defender Definitions for Windows Vista and 7"
    "-includemsse      Microsoft Security Essentials"
    "-includewddefs8   Windows Defender Definitions for Windows 8 - 10"
)

languages_table="\
deu   de      German
enu   en      English
ara   ar      Arabic
chs   zh-cn   Chinese (Simplified)
cht   zh-tw   Chinese (Traditional)
csy   cs      Czech
dan   da      Danish
nld   nl      Dutch
fin   fi      Finnish
fra   fr      French
ell   el      Greek
heb   he      Hebrew
hun   hu      Hungarian
ita   it      Italian
jpn   ja      Japanese
kor   ko      Korean
nor   no      Norwegian
plk   pl      Polish
ptg   pt      Portuguese
ptb   pt-br   Portuguese (Brazil)
rus   ru      Russian
esn   es      Spanish
sve   sv      Swedish
trk   tr      Turkish
"

languages_table_w2k3="\
deu   de      German
enu   en      English
chs   zh-cn   Chinese (Simplified)
cht   zh-tw   Chinese (Traditional)
csy   cs      Czech
nld   nl      Dutch
fra   fr      French
hun   hu      Hungarian
ita   it      Italian
jpn   ja      Japanese
kor   ko      Korean
plk   pl      Polish
ptg   pt      Portuguese
ptb   pt-br   Portuguese (Brazil)
rus   ru      Russian
esn   es      Spanish
sve   sv      Swedish
trk   tr      Turkish
"

languages_table_w2k3_x64="\
deu   de      German
enu   en      English
fra   fr      French
ita   it      Italian
jpn   ja      Japanese
kor   ko      Korean
ptb   pt-br   Portuguese (Brazil)
rus   ru      Russian
esn   es      Spanish
"

# The remaining tables are created from the indexed arrays above.
updates_table="$(printf '%s\n' "${updates_menu[@]}")"
options_table_windows_xp="$(printf '%s\n' "${options_menu_windows_xp[@]}")"
options_table_windows_w2k3="$(printf '%s\n' "${options_menu_windows_w2k3[@]}")"
options_table_windows_vista="$(printf '%s\n' "${options_menu_windows_vista[@]}")"
options_table_windows_8="$(printf '%s\n' "${options_menu_windows_8[@]}")"
options_table_office="$(printf '%s\n' "${options_menu_office[@]}")"
options_table_all="$(printf '%s\n' "${options_menu_all[@]}")"

# ========== Functions ====================================================

# Convert language names like deu and enu to the locales de and en. The
# result will be printed to standard output.

function language_name_to_locale ()
{
    local language_name="$1"
    local language_record=""
    local ignored_field_1=""
    local language_locale=""
    local ignored_field_2=""

    if [[ "${language_name}" == "glb" ]]
    then
        echo "not-available"
    elif language_record="$(grep -- "^${language_name} " <<< "${languages_table}")"
    then
        read -r ignored_field_1 language_locale ignored_field_2 <<< "${language_record}"
        echo "${language_locale}"
    else
        log_error_message "The language ${language_name} was not found."
    fi
    return 0
}

return 0
