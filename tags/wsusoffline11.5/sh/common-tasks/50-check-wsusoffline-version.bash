# This file will be sourced by the shell bash.
#
# Filename: 50-check-wsusoffline-version.bash
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
#     This script checks for new versions of WSUS Offline Update and
#     installs them on demand.
#
#     By default, it doesn't install new versions without
#     confirmation. Therefore, the question to ask for confirmation
#     defaults to "no" after 30 seconds.
#
#     This behavior can be reversed by setting the variable
#     "unattended_updates" to "enabled" in the file preferences.bash. Then
#     the script will still notify the user about new versions and ask
#     for confirmation, but this time the question defaults to "yes"
#     after 30 seconds.
#
#     Sometimes, it may be preferable, to keep WSUS Offline Update at
#     a certain version, for example to support downloads which are no
#     longer supported by more recent versions. Then all updates can
#     be disabled by setting "check_for_self_updates" to "disabled"
#     in the preferences file.

# ========== Global variables =============================================

wou_installed_version="not-available"
wou_installed_archive="not-available"

wou_available_version="not-available"
wou_available_archive="not-available"  # The URL of the archive
wou_available_hashes="not-available"   # The URL of the hashes file

wou_timestamp_file="${timestamp_dir}/check-wsusoffline-version.txt"

# ========== Functions ====================================================

# The current version is in the file
# ../static/StaticDownloadLink-this.txt, which is installed with the
# zip archive of WSUS Offline Update.
#
# This file may not exist yet. In this case, the Linux scripts can do
# an initial installation of the WSUS Offline Update archive.

function get_wou_installed_version ()
{
    if require_non_empty_file "../static/StaticDownloadLink-this.txt"
    then
        wou_installed_archive="$(cat_dos ../static/StaticDownloadLink-this.txt)"
        wou_installed_version="$(basename "${wou_installed_archive}" '.zip')"
    else
        log_warning_message "The file StaticDownloadLink-this.txt was not found."
    fi
    return 0
}


# The most recent available version is in the file
# StaticDownloadLink-recent.txt, which will be downloaded from
# "http://download.wsusoffline.net/" to the ../static/ directory.

function get_wou_available_version ()
{
    local -i initial_errors="0"
    initial_errors="$(get_error_count)"

    log_info_message "Searching for the most recent version of WSUS Offline Update..."
    download_single_file "../static" "http://download.wsusoffline.net/StaticDownloadLink-recent.txt"
    if same_error_count "${initial_errors}"
    then
        if require_non_empty_file "../static/StaticDownloadLink-recent.txt"
        then
            wou_available_archive="$(cat_dos ../static/StaticDownloadLink-recent.txt)"
            wou_available_version="$(basename "${wou_available_archive}" '.zip')"
            wou_available_hashes="${wou_available_archive/.zip/_hashes.txt}"
        else
            log_warning_message "The file StaticDownloadLink-recent.txt was not found."
        fi
    else
        log_warning_message "The online test for the most recent version of WSUS Offline Update failed."
    fi
    return 0
}


# The function wsusoffline_initial_installation downloads and installs
# the most recent version of WSUS Offline Update, if there is no version
# installed yet.
#
# Since the Linux download scripts depend on the configuration files
# in the static, exclude and xslt directories, this test should always
# be done first.

function wsusoffline_initial_installation
{
    local current_dir=""
    local target_dir=""
    local answer=""

    current_dir="$(pwd)"
    target_dir="$(dirname "${current_dir}")"

    if ! require_non_empty_file "../static/StaticDownloadLink-this.txt"
    then
        log_info_message "There is no version of WSUS Offline Update installed yet."

        # Search for the most recent available version of WSUS Offline
        # Update
        get_wou_available_version
        if [[ "${wou_available_version}" != "not-available" ]]
        then
            log_info_message "The most recent version of WSUS Offline Update is ${wou_available_version}."
            log_warning_message "Note, that the wsusoffline archive will be unpacked OUTSIDE of the Linux scripts directory. At this point, you should have created an enclosing directory, which contains the Linux scripts directory, and which will also get the contents of the wsusoffline archive."
            log_warning_message "The target directory, to which the wsusoffline archive will be extracted, is \"${target_dir}\". Do you wish to proceed and install the wsusoffline archive into this directory?"
            read -r -p "[Y|n]: " answer || true
            case "${answer:-Y}" in
                [Yy]*)
                    log_info_message "Starting an initial installation of WSUS Offline Update..."
                    wsusoffline_self_update
                ;;
                [Nn]*)
                    log_info_message "The initial installation of WSUS Offline Update was not confirmed. The script will quit now."
                    exit 0
                ;;
                *)
                    log_warning_message "Unknown answer. The initial installation of WSUS Offline Update was not confirmed. The script will quit now."
                    exit 0
                ;;
            esac
        else
            log_error_message "The most recent version of WSUS Offline Update could not be evaluated. The script will quit now."
            exit 1
        fi
    fi
    return 0
}


# The function compare_wsusoffline_versions does an online check for
# new versions of WSUS Offline Update, similar to the Windows script
# CheckOUVersion.cmd.
#
# If these files are different, then a new version is available.
#
# This test is done once daily, and it can be disabled by setting the
# variable check_for_self_updates to "disabled".

function compare_wsusoffline_versions ()
{
    local -i interval_length="${interval_length_configuration_files}"
    local interval_description="${interval_description_configuration_files}"

    if [[ "${check_for_self_updates}" == "disabled" ]]
    then
        log_info_message "Searching for new versions of WSUS Offline Update is disabled in preferences.bash"
    elif same_day "${wou_timestamp_file}" "${interval_length}"
    then
        log_info_message "Skipped searching for new versions of WSUS Offline Update, because it has already been done less than ${interval_description} ago"
    else
        # Get the installed version of WSUS Offline Update
        get_wou_installed_version
        if [[ "${wou_installed_version}" != "not-available" ]]
        then
            # Search for the most recent version of WSUS Offline Update
            get_wou_available_version
            if [[ "${wou_available_version}" != "not-available" ]]
            then
                # Compare versions
                if [[ "${wou_installed_version}" == "${wou_available_version}" ]]
                then
                    log_info_message "No newer version of WSUS Offline Update found"
                    # The timestamp is updated here, to do the version
                    # check only once daily.
                    update_timestamp "${wou_timestamp_file}"
                else
                    log_info_message "A new version of WSUS Offline Update is available:"
                    log_info_message "- Installed version: ${wou_installed_version}"
                    log_info_message "- Available version: ${wou_available_version}"
                    confirm_wsusoffline_self_update
                fi
            else
                log_warning_message "The most recent version of WSUS Offline Update could not be evaluated."
                # The timestamp is not updated, if there was an error
                # with the online check. Then the online check will be
                # repeated on the next run.
            fi
        else
            log_error_message "The installed version of WSUS Offline Update could not be evaluated. The script will quit now."
            exit 1
        fi
    fi
    return 0
}


function confirm_wsusoffline_self_update ()
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
                log_info_message "Starting wsusoffline self update..."
                wsusoffline_self_update
            ;;
            [Nn]*)
                log_info_message "Self update not confirmed."
                # If the installation was explicitly canceled, then the
                # timestamp will be updated. The online check will be
                # repeated after one day.
                update_timestamp "${wou_timestamp_file}"
            ;;
            *)
                log_warning_message "Unknown answer. Self update not confirmed."
                # The timestamp will not be updated for unknown
                # answers. Then the online check will be repeated on
                # the next run.
            ;;
        esac
    else
        cat <<EOF
---------------------------------------------------------------------------
Note: This question automatically selects "No" after 30 seconds, to skip
the pending self-update and let the script continue. This is also the
default answer, if you simply hit return.
---------------------------------------------------------------------------
EOF
        read -r -p "[y|N]: " -t 30 answer || true
        case "${answer:-N}" in
            [Yy]*)
                log_info_message "Starting wsusoffline self update..."
                wsusoffline_self_update
            ;;
            [Nn]*)
                log_info_message "Self update not confirmed."
                update_timestamp "${wou_timestamp_file}"
            ;;
            *)
                log_warning_message "Unknown answer. Self update not confirmed."
            ;;
        esac
    fi

    return 0
}


function wsusoffline_self_update ()
{
    local archive_filename="${wou_available_archive##*/}"
    local -a file_list=()
    local current_item=""

    download_and_verify "${temp_dir}" "${wou_available_archive}" "${wou_available_hashes}"

    # The zip archive should be unpacked to a new directory; any existing
    # directories are removed first
    if [[ -d "${temp_dir}/wsusoffline" ]]
    then
        rm -r "${temp_dir}/wsusoffline"
    fi

    log_info_message "Unpacking zip archive..."
    unzip -q "${temp_dir}/${archive_filename}" -d "${temp_dir}" || exit 1

    log_info_message "Searching unpacked directory..."
    if [[ -d "${temp_dir}/wsusoffline" ]]
    then
        log_info_message "Found directory: ${temp_dir}/wsusoffline"
    else
        log_error_message "Directory ${temp_dir}/wsusoffline was not found"
        exit 1
    fi

    log_info_message "Copying new files..."
    shopt -s nullglob
    file_list=("${temp_dir}"/wsusoffline/*)
    shopt -u nullglob

    if (( ${#file_list[@]} > 0 ))
    then
        for current_item in "${file_list[@]}"
        do
            log_info_message "Copying ${current_item} ..."
            cp -a -t ".." "${current_item}"
        done
    fi

    # Verify installation of the most recent version of WSUS Offline
    # Update
    get_wou_installed_version
    if [[ "${wou_installed_version}" != "not-available" ]]
    then
        log_info_message "Recomparing WSUS Offline Update versions:"
        log_info_message "- Installed version: ${wou_installed_version}"
        log_info_message "- Available version: ${wou_available_version}"

        if [[ "${wou_installed_version}" == "${wou_available_version}" ]]
        then
            log_info_message "The most recent version of WSUS Offline Update was installed successfully"

            # Postprocessing
            check_custom_static_links
            normalize_file_permissions
            reschedule_updates_after_wou_update
            update_timestamp "${wou_timestamp_file}"
            restart_script
        else
            log_error_message "The installaton of the most recent version of WSUS Offline Update failed for unknown reasons."
            exit 1
        fi
    else
        log_error_message "The installed version of WSUS Offline Update could not be evaluated."
        exit 1
    fi
    return 0
}


# function check_custom_static_links
#
# Custom static download files are usually created by the Windows scripts
# AddCustomLanguageSupport.cmd and AddOffice2010x64Support.cmd. These
# scripts copy download links from the ../static to the ../static/custom
# directory, to enable custom languages and Office 64-bit versions.
#
# Therefore, links in the ../static/custom directory can usually be
# validated by searching for the links in the parent directory ../static.

function check_custom_static_links ()
{
    local -a file_list=()
    local current_file=""
    local static_download_link=""

    log_info_message "Checking links in custom static download files..."
    shopt -s nullglob
    file_list=(../static/custom/*.txt)
    shopt -u nullglob

    if (( ${#file_list[@]} > 0 ))
    then
        for current_file in "${file_list[@]}"
        do
            cut_dos -d ',' -f 1 "${current_file}" | while read -r static_download_link
            do
                if ! grep -F -i -q "${static_download_link}" ../static/*.txt
                then
                    log_warning_message "The following download link was not found anymore: ${static_download_link} from file ${current_file}"
                fi
            done
        done
    fi
    return 0
}


# function normalize_file_permissions
#
# Ensure, that Linux scripts are executable (excluding libraries, tasks
# and the preferences file, since these files are sourced)

function normalize_file_permissions ()
{
    log_info_message "Normalize file permissions..."
    chmod +x \
        ./copy-to-target.bash \
        ./download-updates.bash \
        ./fix-file-permissions.bash \
        ./get-all-updates.bash \
        ./rebuild-integrity-database.bash \
        ./update-generator.bash \
        ./comparison-linux-windows/compare-integrity-database.bash \
        ./comparison-linux-windows/compare-update-tables.bash

    return 0
}


function reschedule_updates_after_wou_update ()
{
    log_info_message "Reschedule updates..."
    # The function reevaluate_all_updates removes the timestamps for
    # all updates, so that they are reevaluated on the next run.
    reevaluate_all_updates
    rm -f "../timestamps/check-sh-version.txt"
    rm -f "../timestamps/update-configuration-files.txt"
    # Lists of superseded updates, Windows version
    rm -f "../exclude/ExcludeList-superseded.txt"
    rm -f "../exclude/ExcludeList-superseded-seconly.txt"
    # Lists of superseded updates, Linux version
    rm -f "../exclude/ExcludeList-Linux-superseded.txt"
    rm -f "../exclude/ExcludeList-Linux-superseded-seconly.txt"

    return 0
}

# ========== Commands =====================================================

wsusoffline_initial_installation
compare_wsusoffline_versions
echo ""
return 0
