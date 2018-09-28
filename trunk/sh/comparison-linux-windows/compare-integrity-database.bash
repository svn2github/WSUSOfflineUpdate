#!/usr/bin/env bash
#
# Filename: compare-integrity-database.bash
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
#     with hashdeep checksum files. Since each hashdeep file corresponds
#     to one download directory and contains a fingerprint of each
#     downloaded file, this is a simple but in-depth comparison of the
#     downloads on both platforms.
#
#     For cross-platform compatibility, trailing carriage returns are
#     deleted and the files are sorted in a generic order. The first
#     four lines of the hashdeep files are comments, which can be
#     safely omitted.
#
#     The file example-results-md.txt shows a typical result. Most
#     directories should be the same, but the virus definition files
#     for Windows Defender and Microsoft Security Essentials are updated
#     every two hours. Therefore, the files mpas-fe.exe, mpas-feX64.exe,
#     mpam-fe.exe and mpam-fex64.exe are often different.
#
#     Note: To really get the same results, language settings and the
#     settings for 64-bit Office downloads must be the same.
#
#     The Windows script DownloadUpdates.cmd downloads a default set
#     of German and English installers for Internet Explorer, Microsoft
#     Security Essentials and .NET Frameworks. With the Linux scripts,
#     these downloads must be repeated for both languages, deu and enu.
#
#     On the other hand, you can directly select 64-bit Office
#     downloads in the script update-generator.bash. For the Windows
#     version, these downloads must be enabled by running the script
#     AddOffice2010x64Support.cmd twice, for deu and enu.
#
# Usage
#
#     Specify the complete path to the directory wsusoffline/client/md
#     for both Linux and Windows. The Windows partition is usually mounted
#     in one of the directories /mnt, /media, or /media/<username>.
#
#     Then run the script with ./compare-integrity-database.bash .


# ========== Configuration ================================================

# Absolute paths to wsusoffline/client/md on Windows and Linux
source_md_windows="/media/$(whoami)/Windows/wsusoffline_current/client/md"
source_md_linux="/home/$(whoami)/Projekte/wsusoffline_current/client/md"

# Paths to temporary directories
temp_md_windows="/tmp/md-windows"
temp_md_linux="/tmp/md-linux"

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
    rm -f "${temp_directory}"/*.txt

    pushd "${source_directory}" > /dev/null
    for filename in ./*.txt
    do
        printf '%s\n' "Processing: ${filename}"
        # Skip the first five lines with hashdeep comments
        tail -n +6 "${filename}" | tr -d '\r' | sort > "${temp_directory}/${filename}"
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
create_diff_files "${source_md_windows}" "${temp_md_windows}"
create_diff_files "${source_md_linux}" "${temp_md_linux}"
echo "Comparing diff files..."
diff --report-identical-files "${temp_md_windows}" "${temp_md_linux}"

rm -r -f "${temp_md_windows}"
rm -r -f "${temp_md_linux}"
exit 0
