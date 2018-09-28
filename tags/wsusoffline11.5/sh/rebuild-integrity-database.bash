#!/usr/bin/env bash
#
# Filename: rebuild-integrity-database.bash
#
# Copyright (C) 2018 Hartmut Buhrmester <zo3xaiD8-eiK1iawa@t-online.de>
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
#     This is a standalone script to recreate the integrity database
#     of hashdeep checksum files. It may be useful, if the usage of the
#     integrity database was disabled in the preferences file.

# ========== Shell options ================================================

set -o nounset
set -o errexit
set -o errtrace
set -o pipefail
shopt -s nocasematch
#set -o xtrace

# ========== Configuration ================================================

# All paths in this script are relative to the directory ../client/md,
# because hashdeep uses this directory to create the checksum files.
#
# Note, that WSUS Offline Update was once designed to create custom
# update CDs and DVDs. The wsusoffline/client directory becomes
# the root directory on these media. The parent directories won't
# be accessible anymore. The Windows port hashdeep.exe is installed
# in wsusoffline/client/bin and will be executed from the directory
# wsusoffline/client/md. The creation of the integrity database must
# be done from the same directory for the relative paths to be valid
# during installation.
#
# TODO: The handling of directories could be much simplified with the
# hashdeep bare mode (-b), which simply strips all leading directory
# information from the filenames. But this had to be changed in the
# Windows batch files as well.

global_directories="\
../cpp               hashes-cpp.txt
../dotnet            hashes-dotnet.txt
../dotnet/x64-glb    hashes-dotnet-x64-glb.txt
../dotnet/x86-glb    hashes-dotnet-x86-glb.txt
../msse              hashes-msse.txt
../o2k16/glb         hashes-o2k16-glb.txt
../w60/glb           hashes-w60-glb.txt
../w60-x64/glb       hashes-w60-x64-glb.txt
../w61/glb           hashes-w61-glb.txt
../w61-x64/glb       hashes-w61-x64-glb.txt
../w62/glb           hashes-w62-glb.txt
../w62-x64/glb       hashes-w62-x64-glb.txt
../w63/glb           hashes-w63-glb.txt
../w63-x64/glb       hashes-w63-x64-glb.txt
../w100/glb          hashes-w100-glb.txt
../w100-x64/glb      hashes-w100-x64-glb.txt
../wddefs            hashes-wddefs.txt
../wsus              hashes-wsus.txt"

localized_directories=(o2k3 o2k7 o2k10 o2k13 ofc w2k3 w2k3-x64 win wxp)
languages=(deu enu ara chs cht csy dan nld fin fra ell heb hun ita jpn kor nor plk ptg ptb rus esn sve trk glb)

# ========== Functions ====================================================

function parse_global_directories ()
{
    local hashed_dir=""
    local hashes_file=""
    local skip_rest=""

    echo "Parsing global directories..."
    while read -r hashed_dir hashes_file skip_rest
    do
        validate_directory "${hashed_dir}" "${hashes_file}"
    done <<< "${global_directories}"

    return 0
}

function parse_localized_directories ()
{
    local update=""
    local language=""
    local hashed_dir=""
    local hashes_file=""

    echo "Parsing localized directories..."
    for update in "${localized_directories[@]}"
    do
        for language in "${languages[@]}"
        do
            hashed_dir="../${update}/${language}"
            hashes_file="hashes-${update}-${language}.txt"
            validate_directory "${hashed_dir}" "${hashes_file}"
        done
    done
    return 0
}

# The function validate_directory tests if the specified directory
# exists, either as a real directory or a symbolic link. It does not
# try to resolve symbolic links, because hashdeep uses relative paths
# to create the hashes files.
#
# Only a few of the available languages for Office will be used, and
# some Windows versions may be missing as well. Thus, it is not an error,
# if many of the tested directories do not exist.

function validate_directory ()
{
    local hashed_dir="$1"
    local hashes_file="$2"

    if [[ -d "${hashed_dir}" || -h "${hashed_dir}" ]]
    then
        create_hashdeep_files "${hashed_dir}" "${hashes_file}"
        validate_embedded_hashes "${hashed_dir}" "${hashes_file}"
    fi

    return 0
}

# The function todos_line_endings is used as a filter: it reads from
# standard input and writes to standard output. It is used to change
# the output of hashdeep to DOS line endings on the fly.

function todos_line_endings ()
{
    local line=""

    while IFS="" read -r line
    do
        printf '%s\r\n' "${line}"
    done

    return 0
}


function create_hashdeep_files ()
{
    local hashed_dir="$1"
    local hashes_file="$2"

    # Preconditions
    [[ -d "${hashed_dir}" || -h "${hashed_dir}" ]] || return 0

    echo "Calculating hashes for directory ${hashed_dir} ..."
    # Remove existing files
    rm -f "${hashes_file}"

    if [[ "${hashed_dir}" == "../dotnet" ]]
    then
        # The recursive option can not be used for ../dotnet because of
        # the two subdirectories
        hashdeep -c md5,sha1,sha256 -l ../dotnet/*.exe | tr '/' '\\' | todos_line_endings > "${hashes_file}"
    else
        hashdeep -c md5,sha1,sha256 -l -r "${hashed_dir}" | tr '/' '\\' | todos_line_endings > "${hashes_file}"
    fi

    # Remove empty hashdeep files
    [[ -s "${hashes_file}" ]] || rm -f "${hashes_file}"

    return 0
}

function validate_embedded_hashes ()
{
    local hashed_dir="$1"
    local hashes_file="$2"
    local file_size=""          # field 1 in the CSV-formatted hashes file
    local md5_calculated=""     # field 2
    local sha1_calculated=""    # field 3 calculated SHA-1 hash
    local sha256_calculated=""  # field 4
    local file_path=""          # field 5
    local sha1_embedded=""      # SHA-1 hash embedded in the filename

    # Preconditions
    [[ -d "${hashed_dir}" || -h "${hashed_dir}" ]] || return 0
    [[ -s "${hashes_file}" ]] || return 0

    echo "Verifying embedded SHA-1 hashes for directory ${hashed_dir}..."

    # Skip the comments and read the hashes file starting at line 6.
    # Only records with embedded SHA-1 hashes (a hexadecimal number of
    # 40 digits length) are extracted.
    tail -n +6 "${hashes_file}" |
        tr '\\' '/' |
        tr -d '\r' |
        grep -E '_[[:xdigit:]]{40}[.][[:alpha:]]{3}' \
            > "${temp_dir}/sha-1-${hashes_file}" || true

    while IFS=',' read -r file_size md5_calculated sha1_calculated \
                       sha256_calculated file_path
    do
        # Extract the SHA-1 hash from the filename.
        sha1_embedded="$(sed 's/.*_\([[:xdigit:]]\{40\}\).*/\1/g' <<< "${file_path}" || true)"
        if [[ "${sha1_calculated}" != "${sha1_embedded}" ]]
        then
            echo "Deleting ${file_path} due to mismatching SHA-1 message digest...."
            # Use the Linux trash handler trash-put, if
            # available. trash-put is installed by the package trash-cli
            # in Debian and related distributions.
            if type -P trash-put >/dev/null
            then
                # The trash works best within the home directory of the
                # user. On external drives, it may not be possible to
                # create a trash directory.
                if ! trash-put "${file_path}"
                then
                    # Delete the file directly
                    rm "${file_path}"
                fi
            else
                rm "${file_path}"
            fi
            echo "Deleted ${file_path}"

            # Rewrite the original hashes file (not the copy in the
            # temporary directory) without the deleted file
            mv "${hashes_file}" "${hashes_file}.bak"
            grep -F -v "${sha1_calculated}" "${hashes_file}.bak" > "${hashes_file}" || true
            rm "${hashes_file}.bak"
        fi
    done < "${temp_dir}/sha-1-${hashes_file}"

    return 0
}

# ========== Commands =====================================================

# Check requirements. Obviously, hashdeep is required.
if ! type -P hashdeep >/dev/null
then
    echo "hashdeep is needed for the creation of the integrity database."
    exit 0
fi

# Setup working directory
#
# Resolving the installation path with GNU readlink is very reliable,
# but it may only work in Linux and FreeBSD. Remove the option -f for
# BSD readlink on Mac OS X. If there are any problems with resolving
# the installation path, change directly to the installation directory
# of this script and run it from there.
cd "$(dirname "$(readlink -f "$0")")"

# Create a temporary directory
if type -P mktemp >/dev/null
then
    temp_dir="$(mktemp -d -p "/tmp" rebuild-integrity-database.XXXXXXXXXX)"
else
    temp_dir="/tmp/rebuild-integrity-database"
    mkdir -p "${temp_dir}"
fi

# Create the hashes directory for the integrity database
mkdir -p ../client/md

# Rebuild integrity database
pushd ../client/md >/dev/null
parse_global_directories
parse_localized_directories
popd >/dev/null

# Cleanup temporary directory
rm -r "${temp_dir}"

exit 0
