# This file will be sourced by the shell bash.
#
# Filename: files-and-folders.bash
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
#     This library provides functions to work with files and folders.
#
#     The functions sort_in_place and remove_duplicates are simple
#     wrappers for "sort" and "uniq".
#
#     The functions require_directory, require_file,
#     require_non_empty_file and ensure_non_empty_file test the
#     preconditions and postconditions of other functions. They could
#     be replaced by simple tests, but they produce useful diagnostic
#     output when needed, and they also recognize the placeholder
#     "not-available", which is often used to initialize variables for
#     files and directories.


function sort_in_place ()
{
    if [[ -f "$1" ]]
    then
        sort -u "$1" > "$1.tmp" &&
        mv "$1.tmp" "$1"
    else
        log_debug_message "${FUNCNAME[0]}: File $1 was not found."
    fi
    return 0
}


function remove_duplicates ()
{
    if [[ -f "$1" ]]
    then
        uniq "$1" > "$1.tmp" &&
        mv "$1.tmp" "$1"
    else
        log_debug_message "${FUNCNAME[0]}: File $1 was not found."
    fi
    return 0
}


# Require an existing directory
#
# Result codes:
#   0 if the directory was found
#   1 otherwise
function require_directory ()
{
    local pathname="$1"
    local result_code=0

    if [[ -z "${pathname}" ]]
    then
        log_debug_message "${FUNCNAME[1]}: The pathname is empty"
        result_code=1
    elif [[ "${pathname}" == "not-available" ]]
    then
        log_debug_message "${FUNCNAME[1]}: The pathname is set to \"not-available\""
        result_code=1
    elif [[ -d "${pathname}" ]]
    then
        log_debug_message "${FUNCNAME[1]}: Found directory \"${pathname}\""
        result_code=0
    else
        log_debug_message "${FUNCNAME[1]}: Directory \"${pathname}\" was not found"
        result_code=1
    fi
    return ${result_code}
}

# Require an input file, which can possibly be empty
#
# Result codes:
#   0 if the file was found
#   1 otherwise
function require_file ()
{
    local pathname="$1"
    local result_code=0

    if [[ -z "${pathname}" ]]
    then
        log_debug_message "${FUNCNAME[1]}: The pathname is empty"
        result_code=1
    elif [[ "${pathname}" == "not-available" ]]
    then
        log_debug_message "${FUNCNAME[1]}: The pathname is set to \"not-available\""
        result_code=1
    elif [[ -f "${pathname}" ]]
    then
        log_debug_message "${FUNCNAME[1]}: Found file \"${pathname}\""
        result_code=0
    else
        log_debug_message "${FUNCNAME[1]}: File \"${pathname}\" was not found"
        result_code=1
    fi
    return ${result_code}
}

# Require an input file, which is not empty. Empty files are reported to
# debug output but not deleted.
#
# Result codes:
#   0 if the file was found and is not empty
#   1 otherwise
function require_non_empty_file ()
{
    local pathname="$1"
    local result_code=0

    if [[ -z "${pathname}" ]]
    then
        log_debug_message "${FUNCNAME[1]}: The pathname is empty"
        result_code=1
    elif [[ "${pathname}" == "not-available" ]]
    then
        log_debug_message "${FUNCNAME[1]}: The pathname is set to \"not-available\""
        result_code=1
    elif [[ -s "${pathname}" ]]
    then
        log_debug_message "${FUNCNAME[1]}: Found non-empty file \"${pathname}\""
        result_code=0
    elif [[ -f "${pathname}" ]]
    then
        log_debug_message "${FUNCNAME[1]}: Found empty file \"${pathname}\""
        result_code=1
    else
        log_debug_message "${FUNCNAME[1]}: File \"${pathname}\" was not found"
        result_code=1
    fi
    return ${result_code}
}

# The function ensure_non_empty_file is called at the end of a function,
# to make sure, that an output file larger than 0 was created. Empty
# files will be deleted. The function itself only prints debugging output.
#
# Result codes:
#   0 if the file was created and is not empty
#   1 otherwise
function ensure_non_empty_file ()
{
    local pathname="$1"
    local result_code=0

    if [[ -z "${pathname}" ]]
    then
        log_debug_message "${FUNCNAME[1]}: The pathname is empty"
        result_code=1
    elif [[ "${pathname}" == "not-available" ]]
    then
        log_debug_message "${FUNCNAME[1]}: The pathname is set to \"not-available\""
        result_code=1
    elif [[ -s "${pathname}" ]]
    then
        log_debug_message "${FUNCNAME[1]}: Found non-empty file \"${pathname}\""
        result_code=0
    elif [[ -f "${pathname}" ]]
    then
        log_debug_message "${FUNCNAME[1]}: Deleted file \"${pathname##*/}\", because it was empty"
        log_warning_message "Deleted file \"${pathname##*/}\", because it was empty"
        rm "${pathname}"
        result_code=1
    else
        log_debug_message "${FUNCNAME[1]}: File \"${pathname}\" was not found"
        result_code=1
    fi
    return ${result_code}
}

# The function apply_exclude_lists applies one or more exclude lists to
# an input file with static or dynamic links to create the output file
# with valid static or dynamic links.
#
# The exclude lists usually contain the KB numbers only. Therefore, a
# grep --inverted-match must be used to remove lines with these numbers
# from the input file.
#
# The exclude list for superseded updates is handled more efficiently
# with the utility "join".
#
# Parameters:
#
# 1. The input file, for example "all_dynamic_links"
# 2. The output file, for example "valid_dynamic_links", after applying
#    the exclude lists
# 3. The name of the temporary file combining all exclude lists. This
#    is often the name of the first exclude list, which is copied to
#    the temporary directory as a first step.
# 4. The remaining parameters are the single exclude lists. These files
#    must be specified with their relative paths, e.g. ../exclude and
#    ../exclude/custom must both be specified. This is different from
#    the version in beta-1.

function apply_exclude_lists ()
{
    local input_file="$1"
    local output_file="$2"
    local combined_exclude_list="$3"
    local current_file=""

    rm -f "${output_file}"
    rm -f "${combined_exclude_list}"
    require_non_empty_file "${input_file}" || return 0

    shift 3
    if (( $# > 0 ))
    then
        for current_file in "$@"
        do
            if [[ -s "${current_file}" ]]
            then
                log_debug_message "Appending ${current_file} to ${combined_exclude_list}"
                # Some input files, like StaticUpdateIds-w61-seconly.txt
                # and HideList-seconly.txt, combine the kb number and a
                # description, separated by a comma. In these files, only
                # the first field is extracted. If there is no comma, the
                # whole line is used. This is the default behavior of cut.
                cut_dos -d ',' -f '1' "${current_file}" >> "${combined_exclude_list}"
            fi
        done
    fi

    if [[ -s "${combined_exclude_list}" ]]
    then
        # Remove the combined exclude list from the input file using a
        # grep --inverted-match (grep -v). The result code of grep is
        # "1", if the output is empty. This must be masked to not cause
        # an error, if the shell option errexit or a trap on ERR is used.
        grep -F -i -v -f "${combined_exclude_list}" \
            "${input_file}" > "${output_file}" || true
    else
        # Rename the input file to the output file
        mv "${input_file}" "${output_file}"
    fi

    # In some cases, the output file may be empty. For example,
    # static download links are typically used for service packs. If
    # service packs are excluded from download, then the list of valid
    # static links may be empty. This may happen with the localized
    # directories for Office 2010 and 2013, e.g. client/o2k10/deu/
    # or client/o2k10/enu/.
    ensure_non_empty_file "${output_file}" || true
    return 0
}


# The function verify_cabinet_file uses cabextract -t, to ensure that all
# archive contents can be extracted. If some files could not extracted,
# cabextract will report checksum errors and set the result code to 1.

function verify_cabinet_file ()
{
    local pathname="$1"
    local filename="${pathname##*/}"

    log_info_message "Testing the integrity of the cabinet file ${filename} (ignore any warnings about extra bytes at end of file)..."
    if [[ -f "${pathname}" ]]
    then
        echo ""
        if cabextract -t "${pathname}"
        then
            log_info_message "The integrity test of cabinet file ${filename} succeeded."
        else
            log_error_message "Trashing/deleting cabinet file ${filename}, because the integrity test failed."
            trash_file "${pathname}"
        fi
    else
        log_warning_message "The cabinet file ${pathname} was not found."
    fi
    return 0
}


# The function create_backup_copy makes a backup copy of an existing file,
# preserving the file modification date and other metadata.
#
# TODO: For recent versions of Wget, this copy could actually be a hard
# link. Wget can delete existing files first with the option --unlink,
# which is explicitly meant for directories with hard links. But this
# option is missing in older version of Wget. Aria 2 also has different
# options for the allocation of files.

function create_backup_copy ()
{
    local pathname="$1"

    if [[ -f "${pathname}" ]]
    then
        log_info_message "Creating a backup copy of ${pathname##*/} ..."
        cp -a "${pathname}" "${pathname}.bak"
    else
        # The file may not exist yet, it the download is running for
        # the first time. This is not an error.
        log_debug_message "create_backup_copy: The file ${pathname} was not found."
    fi
    return 0
}


# The function restore_backup_copy restores the backup copy, if the
# original file does not exist.
#
# If both files exist, then the modification date will be compared and
# the newer file will be kept.
#
# Otherwise, the backup copy (if any) will be deleted.
#
# Usually, the newly downloaded file is expected to be the newer file,
# but this is not necessarily true for the virus definition files, if
# they are downloaded with old versions of GNU Wget: These files change
# every two hours, and there may be up to three different versions in
# the Microsoft delivery network.
#
# This is not handled well by GNU Wget up to version 1.16:
#
# - GNU Wget 1.16 always use two server requests, HEAD and GET, for
#   timestamping. The first request is used to get the file headers
#   and to compare the file length and modification dates. The second
#   request is used to download the file. But in a content delivery
#   network, different servers may give different answers. The first
#   server may offer a newer file, but when Wget tries to download it,
#   it may get a different version: sometimes an older file, or it may
#   just download the existing file again.
# - GNU Wget 1.16 will always download a file, whenever the file size
#   changes, regardless of the file modification date. This may replace
#   a newer file with an older version of the same file.
#
# This is only a problem with the specific combination of the virus
# definition files and old versions of GNU Wget, if these downloads are
# retried within a few hours.
#
# GNU Wget 1.18 and late use a single server request for timestamping,
# a GET query with the conditional header If-Modified-Since. Then the
# server can decide, if the file needs to be downloaded. (I never tried
# GNU Wget 1.17, since this version was never used by Debian Linux).

function restore_backup_copy ()
{
    local pathname="$1"

    if [[ -f "${pathname}.bak" ]]
    then
        # According to the bash manual, the operator -nt is true, if file1
        # is newer than file2, or if file1 exists and file2 does not.
        if [[ "${pathname}.bak" -nt "${pathname}" ]]
        then
            log_info_message "Restoring backup copy of ${pathname##*/}"
            mv "${pathname}.bak" "${pathname}"
        else
            rm "${pathname}.bak"
        fi
    fi
    return 0
}


# The function restart_script is called after a successful self update
# of WSUS Offline Update or the Linux scripts.

function restart_script ()
{
    log_info_message "Restarting script ${script_name} ..."
    echo ""
    echo "--------------------------------------------------------------------------------"
    echo ""
    # The scripts update-generator.bash and downloadupdates.bash create
    # new temporary directories with random names on each run. The
    # existing temporary directory must be removed at this point.
    if [[ -d "${temp_dir}" ]]
    then
        #echo "Cleaning up temporary files ..."
        rm -r "${temp_dir}"
    fi
    if (( ${#command_line_parameters[@]} > 0 ))
    then
        exec "./${script_name}" "${command_line_parameters[@]}"
    else
        exec "./${script_name}"
    fi
    return 0
}

return 0
