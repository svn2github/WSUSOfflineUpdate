# This file will be sourced by the shell bash.
#
# Filename: integrity-database.bash
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
#     This file uses hashdeep to maintain an integrity database.
#
#     It also allows an easy check for the integrity of downloaded
#     files: for all security updates, the SHA-1 checksum is
#     embedded into the filename. For example, if the filename is
#     "ndp35sp1-kb958484-x64_e69006433c1006c53da651914dc8162bbdd80d41.exe",
#     then "e69006433c1006c53da651914dc8162bbdd80d41" is the SHA-1 hash,
#     consisting of 40 hexadecimal digits. hashdeep calculates the
#     MD5, SHA-1 and SHA-256 checksums itself, and then the calculated
#     checksums can be compared to those in the filenames.


function verify_integrity_database ()
{
    local hashed_dir="$1"
    local hashes_file="$2"
    # Delete the element "client/" from the pathname, because hashdeep
    # will be called from wsusoffline/client/md/. These directory changes
    # could probably be omitted by using the bare option (-b) in hashdeep,
    # which simply strips any leading directory information. This would
    # not cause problems, since every hashdeep file corresponds to one
    # download directory only. Only for wddefs and msse, there are two
    # subdirectories.
    local hashed_dir_truncated="${hashed_dir/'client/'/}"
    local hashes_file_basename="${hashes_file##*/}"
    local hashdeep_output=""
    local -i initial_errors="0"
    initial_errors="$(get_error_count)"
    mkdir -p "../client/md"

    # Preconditions
    #
    # If the verification of the integrity database is disabled by
    # preferences settings, then this function returns 0 and any existing
    # checksum files will be deleted (since they will be invalid after
    # new downloads).
    if [[ "${use_integrity_database}" == "disabled" ]]
    then
        log_info_message "Verification of integrity database is disabled in preferences.bash"
        rm -f "${hashes_file}"
        return 0
    fi

    log_info_message "Verifying the integrity of existing files in the directory ${hashed_dir} ..."

    # When the script is first run, neither the hashed directory nor
    # the hashes file exists yet. This is not an error; it only means,
    # that the download task must be run once to create the file.
    if ! require_directory "${hashed_dir}"
    then
        log_info_message "The download directory ${hashed_dir} does not exist yet. This is normal during the first run of the script."
        return 0
    fi
    if ! require_non_empty_file "${hashes_file}"
    then
        log_info_message "The checksum file ${hashes_file} does not exist yet. This is normal during the first run of the script."
        return 0
    fi

    # Create a copy of the hashes file in Linux format
    cat_dos "${hashes_file}" | tr '\\' '/' > "${temp_dir}/${hashes_file_basename}"

    pushd "../client/md" > /dev/null
    if [[ "${hashed_dir_truncated}" == "../dotnet" ]]
    then
        if ! hashdeep_output="$(hashdeep -a -vv -k "${temp_dir}/${hashes_file_basename}" -l ../dotnet/*.exe 2>&1)"
        then
            increment_error_count
        fi
    else
        if ! hashdeep_output="$(hashdeep -a -vv -k "${temp_dir}/${hashes_file_basename}" -l -r "${hashed_dir_truncated}" 2>&1)"
        then
            increment_error_count
        fi
    fi
    popd > /dev/null

    if same_error_count "${initial_errors}"
    then
        log_info_message "${hashdeep_output}"
        log_info_message "Verified the integrity of existing files in the directory ${hashed_dir}"
    else
        log_error_message "${hashdeep_output}"
        log_error_message "The directory ${hashed_dir} has changed since last creating the integrity database"
        rm "${hashes_file}"
    fi

    # Integrity database verification errors are only reported and
    # written to the logfile. The script may just go on, because the
    # hashdeep files will be deleted and rebuilt anyway.
    return 0
}


function create_integrity_database ()
{
    local hashed_dir="$1"
    local hashes_file="$2"
    # Delete the element "client/" from the pathname, because hashdeep
    # will be called from wsusoffline/client/md/.
    local hashed_dir_truncated="${hashed_dir/'client/'/}"
    local hashes_file_basename="${hashes_file##*/}"
    local -a file_list=()
    local -i filecount="0"
    local hashdeep_error_output=""
    local -i initial_errors="0"
    initial_errors="$(get_error_count)"

    mkdir -p "../client/md"
    rm -f "${hashes_file}"

    # Preconditions
    if [[ "${use_integrity_database}" == "disabled" ]]
    then
        log_info_message "Creation of integrity database is disabled in preferences.bash"
        return 0
    fi
    if ! require_directory "${hashed_dir}"
    then
        log_warning_message "Aborted creation of integrity database, because the directory \"${hashed_dir}\" does not exist"
        return 0
    fi

    # Count files to prevent errors and the creation of empty hashdeep
    # files
    case "${hashed_dir}" in
        "../client/msse" | "../client/wddefs")
            shopt -s nullglob
            file_list=(
                "${hashed_dir}/x64-glb"/*.*
                "${hashed_dir}/x86-glb"/*.*
            )
            shopt -u nullglob
            filecount="${#file_list[@]}"
        ;;
        *)
            shopt -s nullglob
            file_list=( "${hashed_dir}"/*.* )
            shopt -u nullglob
            filecount="${#file_list[@]}"
        ;;
    esac
    if (( filecount == 0 ))
    then
        log_warning_message "Aborted creation of integrity database, because the directory \"${hashed_dir}\" is empty"
        return 0
    fi

    log_info_message "Creating integrity database for directory ${hashed_dir} ..."

    # The two subdirectories dotnet/x86-glb and dotnet/x64-glb are not
    # included in the hashes file. Therefore, the recursive option for
    # hashdeep can not be used for the dotnet directory.
    #
    # Note: standard output is written to the hashes file, but error
    # output can be caught in a variable for reference.

    pushd "../client/md" > /dev/null
    if [[ "${hashed_dir}" == "../client/dotnet" ]]
    then
        if ! hashdeep_error_output="$( { hashdeep -c md5,sha1,sha256 -l ../dotnet/*.exe | tr '/' '\\' | todos_line_endings > "${hashes_file_basename}"; } 2>&1 )"
        then
            increment_error_count
        fi
    else
        if ! hashdeep_error_output="$( { hashdeep -c md5,sha1,sha256 -l -r "${hashed_dir_truncated}" | tr '/' '\\' | todos_line_endings > "${hashes_file_basename}"; } 2>&1 )"
        then
            increment_error_count
        fi
    fi
    popd > /dev/null

    if same_error_count "${initial_errors}"
    then
        if ensure_non_empty_file "${hashes_file}"
        then
            log_info_message "Created file ${hashes_file##*/}"
        else
            log_warning_message "File ${hashes_file##*/} was empty"
        fi
    else
        log_error_message "${hashdeep_error_output}"
        log_error_message "Creation of hashes file failed"
        rm -f "${hashes_file}"
    fi
    return 0
}


function verify_embedded_checksums ()
{
    local hashed_dir="$1"
    local hashes_file="$2"
    # Delete the element "client/" from the pathname
    local hashed_dir_truncated="${hashed_dir/'client/'/}"
    local hashes_file_basename="${hashes_file##*/}"
    local file_size=""          # field 1 in the CSV-formatted hashes file
    local md5_calculated=""     # field 2
    local sha1_calculated=""    # field 3
    local sha256_calculated=""  # field 4
    local file_path=""          # field 5
    local sha1_embedded=""      # checksum embedded in the filename
    local extended_path=""
    local -i initial_errors="0"
    initial_errors="$(get_error_count)"

    mkdir -p "../client/md"

    # Preconditions
    if [[ "${use_integrity_database}" == "disabled" ]]
    then
        log_info_message "Verification of embedded file checksums is disabled in preferences.bash"
        rm -f "${hashes_file}"
        return 0
    fi

    require_directory "${hashed_dir}" || return 0
    require_non_empty_file "${hashes_file}" || return 0

    log_info_message "Verifying embedded SHA1 hashes for directory ${hashed_dir} ..."

    # Skip the comments and read the hashes file starting at line 6.
    # Extract only records with embedded SHA-1 hashes (a string of
    # 40 hexadecimal digits).
    tail -n +6 "${hashes_file}" |
        tr '\\' '/' |
        grep_dos -E '_[[:xdigit:]]{40}[.][[:alpha:]]{3}' \
            > "${temp_dir}/sha-1-${hashes_file_basename}" || true

    while IFS=',' read -r file_size md5_calculated sha1_calculated \
                       sha256_calculated file_path
    do
        # GNU grep can conveniently use:
        #
        # grep -E --only-matching '[[:xdigit:]]{40}'
        #
        # to extract the SHA-1 hash, but this was replaced with sed
        # for compatibility.
        sha1_embedded="$(sed 's/.*_\([[:xdigit:]]\{40\}\).*/\1/g' <<< "${file_path}" || true)"
        if [[ "${sha1_calculated}" != "${sha1_embedded}" ]]
        then
            increment_error_count
            log_error_message "Trashing/deleting file ${file_path##*/} due to mismatching SHA-1 message digests..."

            # The paths in the hashdeep files are calculated relative
            # to the ../client/md directory. They must be corrected
            # again. The previous solution of changing directories with
            # pushd/popd does not work anymore, because the log_message
            # function will not find the log file, if the working
            # directory is changed.
            extended_path="${file_path/'../'/'../client/'}"
            trash_file "${extended_path}"

            # Rewrite the original hashes file (not the copy in the
            # temporary directory) without the deleted file
            mv "${hashes_file}" "${hashes_file}.bak"
            grep -F -v "${sha1_calculated}" "${hashes_file}.bak" > "${hashes_file}" || true
            rm "${hashes_file}.bak"
        fi
    done < "${temp_dir}/sha-1-${hashes_file_basename}"

    if same_error_count "${initial_errors}"
    then
        log_info_message "Verified embedded SHA1 hashes"
    else
        log_error_message "Verification of embedded SHA1 hashes detected $(get_error_difference "${initial_errors}") errors"
    fi
    return 0
}

return 0
