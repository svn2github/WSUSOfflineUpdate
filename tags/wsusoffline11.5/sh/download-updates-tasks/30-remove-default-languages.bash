# This file will be sourced by the shell bash.
#
# Filename: 30-remove-default-languages.bash
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
#     This script removes the default German and English
#     installers from global static download files, similar to
#     the Windows scripts RemoveGermanLanguageSupport.cmd and
#     RemoveEnglishLanguageSupport.cmd.
#
#     This task should be run after checking for possible updates to
#     the static download files.

# ========== Configuration ================================================

german_source_files=(
    "../static/StaticDownloadLinks-dotnet.txt"
    "../static/StaticDownloadLinks-dotnet-x86-glb.txt"
    "../static/StaticDownloadLinks-dotnet-x64-glb.txt"
    "../static/StaticDownloadLinks-msse-x86-glb.txt"
    "../static/StaticDownloadLinks-msse-x64-glb.txt"
    "../static/StaticDownloadLinks-w60-x86-glb.txt"
    "../static/StaticDownloadLinks-w60-x64-glb.txt"
    "../static/StaticDownloadLinks-w61-x86-glb.txt"
    "../static/StaticDownloadLinks-w61-x64-glb.txt"
)


english_source_files=(
    "../static/StaticDownloadLinks-msse-x86-glb.txt"
    "../static/StaticDownloadLinks-msse-x64-glb.txt"
    "../static/StaticDownloadLinks-w60-x86-glb.txt"
    "../static/StaticDownloadLinks-w60-x64-glb.txt"
    "../static/StaticDownloadLinks-w61-x86-glb.txt"
    "../static/StaticDownloadLinks-w61-x64-glb.txt"
)

# ========== Functions ====================================================

function remove_german_language_support ()
{
    local pathname=""

    log_debug_message "Removing German language support..."
    for pathname in "${german_source_files[@]}"
    do
        if grep -F -i -q -e 'deu.' -e 'de.' "${pathname}"
        then
            log_debug_message "Removing German installers from ${pathname}"
            mv "${pathname}" "${pathname}.bak"
            grep -F -i -v -e 'deu.' -e 'de.' "${pathname}.bak" > "${pathname}" || true
            # Keep file modification date
            touch -r "${pathname}.bak" "${pathname}"
            rm "${pathname}.bak"
        fi
    done
    return 0
}


function remove_english_language_support ()
{
    local pathname=""

    log_debug_message "Removing English language support..."
    for pathname in "${english_source_files[@]}"
    do
        if grep -F -i -q -e 'enu.' -e 'us.' "${pathname}"
        then
            log_debug_message "Removing English installers from ${pathname}"
            mv "${pathname}" "${pathname}.bak"
            grep -F -i -v -e 'enu.' -e 'us.' "${pathname}.bak" > "${pathname}" || true
            # Keep file modification date
            touch -r "${pathname}.bak" "${pathname}"
            rm "${pathname}.bak"
        fi
    done
    return 0
}

# ========== Commands =====================================================

remove_german_language_support
remove_english_language_support
return 0
