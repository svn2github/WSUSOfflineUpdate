# This file will be sourced by the shell bash.
#
# Filename: 60-check-script-version.bash
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
#     This script checks for new versions of the Linux scripts and install
#     them on demand, using a similar approach as used for WSUS Offline
#     Update self-updates.
#
#     By default, the installation of new versions must be
#     confirmed. Setting the option "unattended_updates" to "enabled"
#     in the preferences file will enable automatic updates.
#
#     The online test for new versions of the Linux scripts can be
#     disabled by setting the variable check_for_self_updates to
#     "disabled".
#
#     Remove this file, if you don't really like the idea at all.

# ========== Global variables =============================================

sh_installed_version="not-available"
ignored_fields="not-available"

sh_available_version="not-available"
sh_available_archive="not-available"  # The URL of the archive
sh_available_hashes="not-available"   # The URL of the hashes file
sh_expanded_dir="not-available"       # The name of the expanded directory

# The expanded directory is the name of the directory, which is created
# by expanding the archive. It usually includes the version as part of
# the name.
#
# The actual installation directory can be of any name, for example
# "sh_new" without the version, or simply "sh". This is achieved by
# copying only the contents of the expanded directory to the current
# working directory, as in:
#
# cp -a -t "." "${current_item}"

sh_timestamp_file="${timestamp_dir}/check-sh-version.txt"

# ========== Functions ====================================================

# The function compare_sh_versions does an online check for new versions
# of the Linux scripts. It works quite similar to the online check for
# new versions of WSUS Offline Update:
#
# The current version is in the file installed-version.txt, which is
# installed with the tar.gz archive.
#
# The available version is in the file available-version.txt, which will
# be downloaded from "http://downloads.hartmut-buhrmester.de/".
#
# If these files are different, then a new version is available.
#
# Both files contain several fields, which can be read into
# variables. These are:
# - the version
# - the URL of the archive
# - the URL of the hashes file
# - the name of the expanded directory

function compare_sh_versions ()
{
    local -i initial_errors="${runtime_errors}"

    if [[ "${check_for_self_updates}" == "disabled" ]]; then
        log_info_message "Searching for new versions of the Linux scripts is disabled in preferences.bash"
    elif same_day "${sh_timestamp_file}"; then
        log_info_message "Skipped searching for new versions of the Linux scripts, because it has already been done in the last 24 hours"
    else
        log_info_message "Searching for new versions of the Linux scripts..."

        # Get the installed version
        read -r sh_installed_version ignored_fields < ./versions/installed-version.txt

        # Get the available version
        download_single_file "./versions" "http://downloads.hartmut-buhrmester.de/available-version.txt"
        if (( runtime_errors == initial_errors )); then
            # Appending the variable "ignored_fields" to the end allows
            # future extensions of the file format.
            read -r sh_available_version sh_available_archive sh_available_hashes sh_expanded_dir ignored_fields < ./versions/available-version.txt

            # Compare versions
            if [[ "${sh_installed_version}" == "${sh_available_version}" ]]; then
                log_info_message "No newer version of the Linux scripts found"
            else
                log_info_message "A new version of the Linux scripts is available:
- Installed version: ${sh_installed_version}
- Available version: ${sh_available_version}"
                confirm_sh_self_update
            fi

            update_timestamp "${sh_timestamp_file}"
        else
            log_error_message "Online check for new versions of the Linux scripts failed"
        fi
    fi
    return 0
}


function confirm_sh_self_update ()
{
    local answer=""

    log_info_message "Do you want to install the new version now?"
    if [[ "${unattended_updates:-disabled}" == enabled ]]; then
        cat <<EOF
---------------------------------------------------------------------------
Note: This question automatically selects "Yes" after 30 seconds, to
install the new version and then restart the script. This is also the
default answer, if you simply hit return.
---------------------------------------------------------------------------
EOF
        read -r -p "[Y|n]: " -t 30 answer || true
        case "${answer:-Y}" in
            [Yy]*)
                sh_self_update
            ;;
            [Nn]*)
                log_info_message "Update of Linux scripts not confirmed."
            ;;
            *)
                log_info_message "Unknown answer. Update of Linux scripts not confirmed."
            ;;
        esac
    else
        cat <<EOF
---------------------------------------------------------------------------
Note: This question automatically selects "No" after 30 seconds, to skip
the pending update and let the script continue. This is also the default
answer, if you simply hit return.
---------------------------------------------------------------------------
EOF
        read -r -p "[y|N]: " -t 30 answer || true
        case "${answer:-N}" in
            [Yy]*)
                sh_self_update
            ;;
            [Nn]*)
                log_info_message "Update of Linux scripts not confirmed."
            ;;
            *)
                log_info_message "Unknown answer. Update of Linux scripts not confirmed."
            ;;
        esac
    fi

    return 0
}


function sh_self_update ()
{
    local archive_file="${sh_available_archive##*/}"
    local hashes_file="${sh_available_hashes##*/}"
    local -i initial_errors="${runtime_errors}"
    local -a file_list=()
    local current_item=""

    log_info_message "Starting update of the Linux scripts..."

    log_info_message "Downloading tar.gz archive and accompanying hashes file..."
    download_single_file "${temp_dir}" "${sh_available_archive}"
    download_single_file "${temp_dir}" "${sh_available_hashes}"
    (( runtime_errors == initial_errors )) || exit 1

    log_info_message "Verifying downloaded files..."
    if [[ -f "${temp_dir}/${archive_file}" ]]; then
        log_info_message "Found archive file: ${temp_dir}/${archive_file}"
    else
        log_error_message "Archive file ${archive_file} was not found"
        exit 1
    fi
    if [[ -f "${temp_dir}/${hashes_file}" ]]; then
        log_info_message "Found hashes file:  ${temp_dir}/${hashes_file}"
    else
        log_error_message "Hashes file ${hashes_file} was not found"
        exit 1
    fi

    # Validate archive file using hashdeep in audit mode (-a). The bare
    # mode (-b) removes any leading directory information. This enables us
    # to check single files without changing directories with pushd/popd.
    log_info_message "Verifying the integrity of the archive file..."
    if hashdeep -a -b -v -v -v -k "${temp_dir}/${hashes_file}" "${temp_dir}/${archive_file}"; then
        log_info_message "Validated file: ${archive_file}"
    else
        log_error_message "Validation failed"
        exit 1
    fi

    # The tar.gz archive should be unpacked to a new directory; any
    # existing directories are removed first
    if [[ -d "${temp_dir}/${sh_expanded_dir}" ]]; then
        rm -r "${temp_dir}/${sh_expanded_dir}"
    fi

    log_info_message "Unpacking tar.gz archive..."
    tar -x -v -z -C "${temp_dir}" -f "${temp_dir}/${archive_file}" || exit 1

    log_info_message "Verifying unpacked directory..."
    if [[ -d "${temp_dir}/${sh_expanded_dir}" ]]; then
        log_info_message "Found directory: ${temp_dir}/${sh_expanded_dir}"
    else
        log_error_message "Directory ${temp_dir}/${sh_expanded_dir} was not found"
        exit 1
    fi

    log_info_message "Copying new files ..."
    # Build file list as suggested in
    # http://mywiki.wooledge.org/BashFAQ/004
    shopt -s nullglob
    file_list=("${temp_dir}/${sh_expanded_dir}"/*)
    shopt -u nullglob

    if (( ${#file_list[@]} > 0 )); then
        for current_item in "${file_list[@]}"; do
            log_info_message "Copying ${current_item} ..."
            cp -a -t "." "${current_item}"
        done
    fi

    # Verify result
    log_info_message "Recomparing versions..."
    # Get the installed version
    read -r sh_installed_version ignored_fields < ./versions/installed-version.txt
    log_info_message "- Installed version: ${sh_installed_version}"
    log_info_message "- Available version: ${sh_available_version}"
    if [[ "${sh_installed_version}" == "${sh_available_version}" ]]; then
        log_info_message "Update of the Linux scripts was successful"
    else
        log_error_message "Update of the Linux scripts failed for unknown reasons"
        exit 1
    fi

    # Rebuild all updates after version updates
    reevaluate_all_updates
    rm -f "../exclude/ExcludeList-superseded.txt"
    rm -f "../exclude/ExcludeList-superseded-seconly.txt"
    rm -f "../timestamps/update-configuration-files.txt"

    # The timestamp must be updated here, in addition to the function
    # compare_sh_versions, because the script will be restarted at the
    # end of this function.
    update_timestamp "${sh_timestamp_file}"

    log_info_message "Restarting script ${script_name} ..."
    echo ""
    echo "--------------------------------------------------------------------------------"
    echo ""
    if (( ${#command_line_parameters[@]} > 0 )); then
        exec "./${script_name}" "${command_line_parameters[@]}"
    else
        exec "./${script_name}"
    fi
}

# ========== Commands =====================================================

compare_sh_versions
echo ""
return 0 # for sourced files
