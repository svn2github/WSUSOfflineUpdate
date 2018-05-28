# This file will be sourced by the shell bash.
#
# Filename: 60-check-script-version.bash
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
#     This script checks for new versions of the Linux scripts and
#     installs them on demand, using a similar approach as used for WSUS
#     Offline Update self-updates.
#
#     By default, the installation of new versions must be
#     confirmed. Setting the option "unattended_updates" to "enabled"
#     in the preferences file will enable automatic updates.
#
#     The online test for new versions of the Linux scripts can be
#     disabled by setting the variable check_for_self_updates to
#     "disabled".
#
#     This file has been moved to the directory available-tasks and is
#     not initially enabled. To enable it, move it to the directory
#     common-tasks, or create a symbolic link within the directory
#     common-tasks with:
#
#     ln -s ../available-tasks/60-check-script-version.bash
#
#     Remove this file, if you don't really like the idea at all.

# ========== Global variables =============================================

sh_installed_version="not-available"
ignored_fields="not-available"

sh_available_version="not-available"
sh_available_archive="not-available"  # The URL of the archive
sh_available_hashes="not-available"   # The URL of the hashes file
sh_expanded_dirname="not-available"   # The name of the expanded directory

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
# The current version is in the file ./versions/installed-version.txt,
# which is installed with the tar.gz archive.
#
# The available version is in the file available-version.txt, which
# will be downloaded from "http://downloads.hartmut-buhrmester.de/"
# to the same directory.
#
# If these files are different, then a new version is available.
#
# Both files contain several fields, which can be read into variables
# with read -r. These are:
#
# - the version
# - the URL of the archive
# - the URL of the hashes file
# - the name of the expanded directory

function compare_sh_versions ()
{
    local -i interval_length="${interval_length_configuration_files}"
    local interval_description="${interval_description_configuration_files}"
    local -i initial_errors="0"
    initial_errors="$(get_error_count)"

    if [[ "${check_for_self_updates}" == "disabled" ]]
    then
        log_info_message "Searching for new versions of the Linux scripts is disabled in preferences.bash"
    elif same_day "${sh_timestamp_file}" "${interval_length}"
    then
        log_info_message "Skipped searching for new versions of the Linux scripts, because it has already been done less than ${interval_description} ago"
    else
        log_info_message "Searching for new versions of the Linux scripts..."

        # Get the installed version of the Linux scripts
        read -r sh_installed_version ignored_fields < ./versions/installed-version.txt

        # Search for the most recent version of the Linux scripts
        download_single_file "./versions" "http://downloads.hartmut-buhrmester.de/available-version.txt"
        if same_error_count "${initial_errors}"
        then
            if require_non_empty_file "./versions/available-version.txt"
            then
                # Appending the variable "ignored_fields" to the end
                # allows future extensions of the file format.
                read -r sh_available_version sh_available_archive sh_available_hashes sh_expanded_dirname ignored_fields < ./versions/available-version.txt

                # Compare versions
                if [[ "${sh_installed_version}" == "${sh_available_version}" ]]
                then
                    log_info_message "No newer version of the Linux scripts found"
                    # The timestamp is updated here, to do the version check
                    # only once daily.
                    update_timestamp "${sh_timestamp_file}"
                else
                    log_info_message "A new version of the Linux scripts is available:"
                    log_info_message "- Installed version: ${sh_installed_version}"
                    log_info_message "- Available version: ${sh_available_version}"
                    confirm_sh_self_update
                fi
            else
                log_warning_message "The file available-version.txt was not found."
            fi
        else
            log_warning_message "The online check for the most recent version of the Linux scripts failed"
            # The timestamp is not updated, if there was an error with
            # the online check. Then the online check will be repeated
            # on the next run.
        fi
    fi
    return 0
}


function confirm_sh_self_update ()
{
    local answer=""

    log_info_message "Do you want to install the new version now?"
    if [[ "${unattended_updates:-disabled}" == enabled ]]
    then
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
                log_info_message "Starting update of the Linux scripts..."
                sh_self_update
            ;;
            [Nn]*)
                log_info_message "Update of Linux scripts not confirmed."
                # If the installation was explicitly canceled, then the
                # timestamp will be updated. The online check will be
                # repeated after one day.
                update_timestamp "${sh_timestamp_file}"
            ;;
            *)
                log_info_message "Unknown answer. Update of Linux scripts not confirmed."
                # The timestamp will not be updated for unknown
                # answers. Then the online check will be repeated on
                # the next run.
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
                log_info_message "Starting update of the Linux scripts..."
                sh_self_update
            ;;
            [Nn]*)
                log_info_message "Update of Linux scripts not confirmed."
                update_timestamp "${sh_timestamp_file}"
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
    local archive_filename="${sh_available_archive##*/}"
    local -a file_list=()
    local current_item=""

    download_and_verify "${temp_dir}" "${sh_available_archive}" "${sh_available_hashes}"

    # The tar.gz archive should be unpacked to a new directory; any
    # existing directories are removed first
    #
    # Both directory names must be set

    if [[ -d "${temp_dir}/${sh_expanded_dirname}" ]]
    then
        rm -r "${temp_dir:?variable_not_set}/${sh_expanded_dirname:?variable_not_set}"
    fi

    log_info_message "Unpacking tar.gz archive..."
    tar -x -v -z -C "${temp_dir}" -f "${temp_dir}/${archive_filename}" || exit 1

    log_info_message "Searching unpacked directory..."
    if [[ -d "${temp_dir}/${sh_expanded_dirname}" ]]
    then
        log_info_message "Found directory: ${temp_dir}/${sh_expanded_dirname}"
    else
        log_error_message "Directory ${temp_dir}/${sh_expanded_dirname} was not found"
        exit 1
    fi

    log_info_message "Copying new files..."
    # Build file list as suggested in
    # http://mywiki.wooledge.org/BashFAQ/004
    shopt -s nullglob
    file_list=("${temp_dir}/${sh_expanded_dirname}"/*)
    shopt -u nullglob

    if (( ${#file_list[@]} > 0 ))
    then
        for current_item in "${file_list[@]}"
        do
            log_info_message "Copying ${current_item} ..."
            cp -a -t "." "${current_item}"
        done
    fi

    # Verify the update of the Linux scripts
    read -r sh_installed_version ignored_fields < ./versions/installed-version.txt
    log_info_message "Recomparing versions of the Linux scripts:"
    log_info_message "- Installed version: ${sh_installed_version}"
    log_info_message "- Available version: ${sh_available_version}"
    if [[ "${sh_installed_version}" == "${sh_available_version}" ]]
    then
        log_info_message "The update of the Linux scripts was successful"

        # Postprocessing
        reschedule_updates_after_sh_update
        update_timestamp "${sh_timestamp_file}"
        restart_script
    else
        log_error_message "The update of the Linux scripts failed for unknown reasons"
        exit 1
    fi
    return 0
}


function reschedule_updates_after_sh_update ()
{
    # The function reevaluate_all_updates removes the timestamps for
    # all updates, so that they are reevaluated on the next run.
    reevaluate_all_updates
    rm -f "../timestamps/update-configuration-files.txt"
    # Lists of superseded updates, Linux version
    rm -f "../exclude/ExcludeList-Linux-superseded.txt"
    rm -f "../exclude/ExcludeList-Linux-superseded-seconly.txt"

    return 0
}


# ========== Commands =====================================================

compare_sh_versions
echo ""
return 0 # for sourced files
