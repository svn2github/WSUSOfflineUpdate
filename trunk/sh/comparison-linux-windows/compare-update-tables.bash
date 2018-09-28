#!/usr/bin/env bash
#
# Filename: compare-update-tables.bash
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
#     This script is used for development. It compares two directories
#     with office update tables.
#
#     For cross-platform compatibility, trailing carriage returns are
#     deleted and the files are sorted in a generic order. Then they
#     are compared with diff.
#
#     A typical result is shown in the file example-results-ofc.txt.
#
# Usage
#
#     Specify the path to the directory wsusoffline/client/ofc for both
#     platforms. Then run the script with:
#
#     ./compare-update-tables.bash


# ========== Configuration ================================================

# Absolute paths to wsusoffline/client/ofc on Windows and Linux
source_ofc_windows="/media/$(whoami)/Windows/wsusoffline_current/client/ofc"
source_ofc_linux="/home/$(whoami)/Projekte/wsusoffline_current/client/ofc"

# Paths to temporary directories
temp_ofc_windows="/tmp/ofc-windows"
temp_ofc_linux="/tmp/ofc-linux"

# ========== Environment variables ========================================

# Use English messages and a generic sort order
export LC_ALL=C

# ========== Functions ====================================================

function create_diff_files ()
{
    local source_directory="$1"
    local temp_directory="$2"
    local filename=""

    if [[ -d "${source_directory}" ]]
    then
        printf '%s\n' "Processing source directory: ${source_directory} ..."
    else
        printf '%s\n' "Source directory ${source_directory} is missing."
        exit 1
    fi

    mkdir -p "${temp_directory}"
    rm -f "${temp_directory}"/*.csv

    pushd "${source_directory}" > /dev/null
    for filename in ./*.csv
    do
        printf '%s\n' "Processing: ${filename}"
        tr -d '\r' < "${filename}" | sort > "${temp_directory}/${filename}"
        # Remove empty files
        if [[ ! -s "${temp_directory}/${filename}" ]]
        then
            rm -f "${temp_directory}/${filename}"
        fi
    done
    popd > /dev/null
}

# ========== Commands =====================================================

# Resolving the installation path with GNU readlink is very reliable,
# but it may only work in Linux and FreeBSD. Remove the option -f for
# BSD readlink on Mac OS X. If there are problems with resolving the
# installation path, change directly into the installation directory of
# this script and run it script from there.
#
# This may not really be necessary, since the script uses absolute
# paths internally.
cd "$(dirname "$(readlink -f "$0")")" || exit 1

echo "Creating diff files..."
create_diff_files "${source_ofc_windows}" "${temp_ofc_windows}"
create_diff_files "${source_ofc_linux}" "${temp_ofc_linux}"
echo "Comparing diff files..."
diff --report-identical-files "${temp_ofc_windows}" "${temp_ofc_linux}"

rm -r -f "${temp_ofc_windows}"
rm -r -f "${temp_ofc_linux}"
exit 0
