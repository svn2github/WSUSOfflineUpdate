# This file will be sourced by the shell bash.
#
# Filename: 50-check-wsusoffline-version.bash
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

# The function compare_wsusoffline_versions does an online check for
# new versions of WSUS Offline Update, similar to the Windows script
# CheckOUVersion.cmd.
#
# The current version is in the file StaticDownloadLink-this.txt, which
# is installed with the zip archive of WSUS Offline Update.
#
# The available version is in the file StaticDownloadLink-recent.txt,
# which will be downloaded from "http://download.wsusoffline.net/".
#
# If these files are different, then a new version is available.

function compare_wsusoffline_versions ()
{
    local -i initial_errors="${runtime_errors}"

    if [[ "${check_for_self_updates}" == "disabled" ]]; then
        log_info_message "Searching for new versions of WSUS Offline Update is disabled in preferences.bash"
    elif same_day "${wou_timestamp_file}"; then
        log_info_message "Skipped searching for new versions of WSUS Offline Update, because it has already been done in the last 24 hours"
    else
        log_info_message "Searching for new versions of WSUS Offline Update..."

        # Get the installed version
        wou_installed_archive="$(cat_dos ../static/StaticDownloadLink-this.txt)"
        wou_installed_version="$(basename "${wou_installed_archive}" '.zip')"

        # Get the available version
        download_single_file "../static" "http://download.wsusoffline.net/StaticDownloadLink-recent.txt"
        if (( runtime_errors == initial_errors )); then
            wou_available_archive="$(cat_dos ../static/StaticDownloadLink-recent.txt)"
            wou_available_version="$(basename "${wou_available_archive}" '.zip')"
            wou_available_hashes="${wou_available_archive/.zip/_hashes.txt}"

            # Compare versions
            if [[ "${wou_installed_version}" == "${wou_available_version}" ]]; then
                log_info_message "No newer version of WSUS Offline Update found"
            else
                log_info_message "A new version of WSUS Offline Update is available:
- Installed version: ${wou_installed_version}
- Available version: ${wou_available_version}"
                confirm_wsusoffline_self_update
            fi

            # The timestamp should be updated here, to do the version
            # check only once daily. This includes the cases:
            #
            # - There is no newer version available.
            #
            # - A new version is available, but the installation was
            #   canceled.
            #
            # - The function wsusoffline_self_update below will also
            #   update the timestamp, if the self-update was successful,
            #   and then restart the script.
            #
            # - The timestamp is not updated, if there was an error with
            #   the online check.
            update_timestamp "${wou_timestamp_file}"
        else
            log_error_message "Online check for new versions of WSUS Offline Update failed"
        fi
    fi
    return 0
}


function confirm_wsusoffline_self_update ()
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
                wsusoffline_self_update
            ;;
            [Nn]*)
                log_info_message "Self update not confirmed."
            ;;
            *)
                log_info_message "Unknown answer. Self update not confirmed."
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
                wsusoffline_self_update
            ;;
            [Nn]*)
                log_info_message "Self update not confirmed."
            ;;
            *)
                log_info_message "Unknown answer. Self update not confirmed."
            ;;
        esac
    fi

    return 0
}


function wsusoffline_self_update ()
{
    local archive_file="${wou_available_archive##*/}"
    local hashes_file="${wou_available_hashes##*/}"
    local -i initial_errors="${runtime_errors}"
    local -a file_list=()
    local current_item=""
    local current_file=""
    local static_download_link=""

    log_info_message "Starting wsusoffline self update..."

    log_info_message "Downloading zip archive and accompanying hashes file..."
    download_single_file "${temp_dir}" "${wou_available_archive}"
    download_single_file "${temp_dir}" "${wou_available_hashes}"
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

    # The zip archive should be unpacked to a new directory; any existing
    # directories are removed first
    if [[ -d "${temp_dir}/wsusoffline" ]]; then
        rm -r "${temp_dir}/wsusoffline"
    fi

    log_info_message "Unpacking zip archive..."
    unzip -q "${temp_dir}/${archive_file}" -d "${temp_dir}" || exit 1

    log_info_message "Verifying unpacked directory..."
    if [[ -d "${temp_dir}/wsusoffline" ]]; then
        log_info_message "Found directory: ${temp_dir}/wsusoffline"
    else
        log_error_message "Directory ${temp_dir}/wsusoffline was not found"
        exit 1
    fi

    log_info_message "Copying new files..."
    # Build file list as suggested in
    # http://mywiki.wooledge.org/BashFAQ/004
    shopt -s nullglob
    file_list=("${temp_dir}"/wsusoffline/*)
    shopt -u nullglob

    if (( ${#file_list[@]} > 0 )); then
        for current_item in "${file_list[@]}"; do
            log_info_message "Copying ${current_item} ..."
            cp -a -t ".." "${current_item}"
        done
    fi

    # Verify result
    log_info_message "Recomparing versions..."
    wou_installed_archive="$(cat_dos ../static/StaticDownloadLink-this.txt)"
    wou_installed_version="$(basename "${wou_installed_archive}" '.zip')"
    log_info_message "- Installed version: ${wou_installed_version}"
    log_info_message "- Available version: ${wou_available_version}"
    if [[ "${wou_installed_version}" == "${wou_available_version}" ]]; then
        log_info_message "Self update was successful"
    else
        log_error_message "Self update failed for unknown reasons"
        exit 1
    fi

    # Check custom static download files
    #
    # Custom static download files are usually created by
    # the Windows scripts AddCustomLanguageSupport.cmd and
    # AddOffice2010x64Support.cmd. These scripts copy download links
    # from the ../static to the ../static/custom directory, to enable
    # custom languages and Office 64-bit versions.
    #
    # Therefore, links in the ../static/custom directory can usually
    # be validated by searching for the links in the parent directory
    # ../static.

    log_info_message "Checking links in custom static download files..."

    # Build file list as suggested in http://mywiki.wooledge.org/BashFAQ/004
    shopt -s nullglob
    file_list=(../static/custom/*.txt)
    shopt -u nullglob

    if (( ${#file_list[@]} > 0 )); then
        for current_file in "${file_list[@]}"; do
            cut_dos -d ',' -f 1 "${current_file}" | while read -r static_download_link; do
                if ! grep -F -i -q "${static_download_link}" ../static/*.txt; then
                    log_warning_message "The following download link was not found anymore:
- ${static_download_link} from file ${current_file}"
                fi
            done
        done
    fi

    # Ensure, that Linux scripts are executable (excluding libraries,
    # tasks and the preferences file, since these files are sourced)
    chmod +x \
        ./download-updates.bash \
        ./fix-file-permissions.bash \
        ./get-all-updates.bash \
        ./update-generator.bash \
        ./comparison-linux-windows/compare-integrity-database.bash \
        ./comparison-linux-windows/compare-update-tables.bash

    # Rebuild all updates after version updates
    reevaluate_all_updates
    rm -f "../exclude/ExcludeList-superseded.txt"
    rm -f "../exclude/ExcludeList-superseded-seconly.txt"
    rm -f "../timestamps/check-sh-version.txt"
    rm -f "../timestamps/update-configuration-files.txt"

    # The timestamp for this task must be updated here (in addition to
    # the function compare_wsusoffline_versions), because the script
    # will be restarted at the end of this function.
    update_timestamp "${wou_timestamp_file}"

    log_info_message "Restarting script ${script_name} ..."
    echo ""
    echo "--------------------------------------------------------------------------------"
    echo ""
    if (( ${#command_line_parameters[@]} > 0 )); then
        exec "./${script_name}" "${command_line_parameters[@]}"
    else
        exec "./${script_name}"
    fi
    return 0
}

# ========== Commands =====================================================

compare_wsusoffline_versions
echo ""
return 0
