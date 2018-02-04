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
#     This file defines menus and tables, which are used to create the
#     selection menus for the script update-generator.bash, and to parse
#     the command-line options in the script download-updates.bash.
#
#     Menus and tables basically provide the same information, but in a
#     different format: menus are indexed arrays, as used by the "select"
#     command of the bash, while tables are text variables with multiple
#     lines, which can be parsed by grep.


# ========== Configuration ================================================

# Menus for the script update-generator.bash
#
# Menus are implemented as indexed arrays. They can be used to create
# simple selection dialogs with the bash builtin command "select".
#
# Each array element consists of a name and description. It can be
# split into single fields with "read -r". As usual with "read", the
# last variable receives the remainder of the line. This is used here to
# split the line into two fields, without needing any additional field
# delimiters like commas or semicolons:
#
# read -r update_name   update_description   <<< "${line}"
# read -r language_name language_description <<< "${line}"
# read -r option_name   option_description   <<< "${line}"

# Windows Server 2008, based on Windows Vista, is available in both
# 32-bit and 64-bit versions.
#
# Windows Server 2008 R2, based on Windows 7, "is the first 64-bit–only
# operating system released from Microsoft."
#
# - https://en.wikipedia.org/wiki/Windows_Server_2008
# - https://en.wikipedia.org/wiki/Windows_Server_2008_R2

updates_menu=(
    "w60         Windows Server 2008, 32-bit"
    "w60-x64     Windows Server 2008, 64-bit"
    "w61         Windows 7, 32-bit"
    "w61-x64     Windows 7 / Server 2008 R2, 64-bit"
    "w62-x64     Windows Server 2012, 64-bit"
    "w63         Windows 8.1, 32-bit"
    "w63-x64     Windows 8.1 / Server 2012 R2, 64-bit"
    "w100        Windows 10, 32-bit"
    "w100-x64    Windows 10 / Server 2016, 64-bit"
    "o2k10       Office 2010, 32-bit"
    "o2k10-x64   Office 2010, 32-bit and 64-bit"
    "o2k13       Office 2013, 32-bit"
    "o2k13-x64   Office 2013, 32-bit and 64-bit"
    "o2k16       Office 2016, 32-bit"
    "o2k16-x64   Office 2016, 32-bit and 64-bit"
)

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

# Options for Windows Vista and Windows 7
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


# Tables for the script download-updates.bash
#
# Tables can be searched with grep just like text files. The search
# pattern should be anchored to the beginning of the line and also include
# a trailing space to avoid ambiguities. For example, the first line
# "w60" would be matched with:
#
# grep "^w60 " <<< "${updates_table}"
#
# Each line can then be split into single fields with read -r as
# described above.

updates_table="\
w60         x86   Windows Server 2008, 32-bit
w60-x64     x64   Windows Server 2008, 64-bit
w61         x86   Windows 7, 32-bit
w61-x64     x64   Windows 7 / Server 2008 R2, 64-bit
w62-x64     x64   Windows Server 2012, 64-bit
w63         x86   Windows 8.1, 32-bit
w63-x64     x64   Windows 8.1 / Server 2012 R2, 64-bit
w100        x86   Windows 10, 32-bit
w100-x64    x64   Windows 10 / Server 2016, 64-bit
o2k10       x86   Office 2010, 32-bit
o2k10-x64   x64   Office 2010, 32-bit and 64-bit
o2k13       x86   Office 2013, 32-bit
o2k13-x64   x64   Office 2013, 32-bit and 64-bit
o2k16       x86   Office 2016, 32-bit
o2k16-x64   x64   Office 2016, 32-bit and 64-bit
"

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

# The remaining tables are created from the indexed arrays above.
options_table_windows_vista="$(printf '%s\n' "${options_menu_windows_vista[@]}")"
options_table_windows_8="$(printf '%s\n' "${options_menu_windows_8[@]}")"
options_table_office="$(printf '%s\n' "${options_menu_office[@]}")"

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
