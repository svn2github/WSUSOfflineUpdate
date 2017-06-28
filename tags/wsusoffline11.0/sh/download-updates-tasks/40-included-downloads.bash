# This file will be sourced by the shell bash.
#
# Filename: 40-included-downloads.bash
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
#     This task downloads the WSUS catalog file and optional static
#     downloads like the installation files for .NET Frameworks. It
#     must be evaluated before calculating superseded updates and
#     dynamic updates.
#
#     Global variables from other files
#     - runtime_errors is defined in the file download-updates.bash
#     - update_architecture, language_name and included_downloads are
#       defined in the file 10-parse-command-line.bash

# ========== Functions ====================================================

function get_included_downloads ()
{
    local previous_file_date="not-available"
    local current_file_date="not-available"
    local current_download=""

    # Get the file modification date of an existing WSUS catalog file
    if [[ -f "../client/wsus/wsusscn2.cab" ]]; then
        previous_file_date="$(date -R -r ../client/wsus/wsusscn2.cab)"
    fi

    # Get all included downloads
    if (( ${#included_downloads[@]} > 0 )); then
        for current_download in "${included_downloads[@]}"; do
            process_included_download "$current_download"
        done
    fi

    # Get the file modification date after downloading/validating the
    # WSUS catalog file
    if [[ -f "../client/wsus/wsusscn2.cab" ]]; then
        current_file_date="$(date -R -r ../client/wsus/wsusscn2.cab)"
    else
        fail "${FUNCNAME[0]}: The required file wsusscn2.cab was not found."
    fi

    if [[ "$previous_file_date" != "$current_file_date" ]]; then
        log_info_message "The file wsusscn2.cab has been updated. The list of superseded updates needs to be rebuilt."
        log_debug_message "- Previous file modification date: $previous_file_date"
        log_debug_message "- Current file modification date:  $current_file_date"
        rm -f "../exclude/ExcludeList-superseded.txt"
        rm -f "../exclude/ExcludeList-superseded-seconly.txt"
    fi

    return 0
}


function process_included_download ()
{
    local download_name="$1"
    local initial_errors="$runtime_errors"

    # All paths are relative to the home directory of the download script.
    local timestamp_pattern="not-available"
    local hashes_file="not-available"
    local hashed_dir="not-available"
    local download_dir="not-available"
    local timestamp_file="not-available"
    local static_download_links="not-available"

    # The name of the timestamp files is
    # timestamp-${name}-${arch}-${lang}.txt
    #
    # - $arch is "${update_architecture}" or "all" for
    #   architecture-independent downloads
    #
    # - $lang is "${language_name}" or "glb" for global/multilingual
    #   downloads

    case "$download_name" in
        wsus)
            timestamp_pattern="wsus-all-glb"
            hashes_file="../client/md/hashes-wsus.txt"
            hashed_dir="../client/wsus"
            download_dir="../client/wsus"
        ;;
        cpp)
            timestamp_pattern="cpp-all-glb"
            hashes_file="../client/md/hashes-cpp.txt"
            hashed_dir="../client/cpp"
            download_dir="../client/cpp"
        ;;
        dotnet)
            timestamp_pattern="dotnet-all-${language_name}"
            hashes_file="../client/md/hashes-dotnet.txt"
            hashed_dir="../client/dotnet"
            download_dir="../client/dotnet"
        ;;
        msse)
            timestamp_pattern="msse-${update_architecture}-${language_name}"
            hashes_file="../client/md/hashes-msse.txt"
            hashed_dir="../client/msse"
            download_dir="../client/msse/${update_architecture}-glb"
        ;;
        wddefs)
            timestamp_pattern="wddefs-${update_architecture}-glb"
            hashes_file="../client/md/hashes-wddefs.txt"
            hashed_dir="../client/wddefs"
            download_dir="../client/wddefs/${update_architecture}-glb"
        ;;
        wddefs8)
            timestamp_pattern="wddefs8-${update_architecture}-glb"
            hashes_file="../client/md/hashes-msse.txt"
            hashed_dir="../client/msse"
            download_dir="../client/msse/${update_architecture}-glb"
        ;;
        *)
            fail "${FUNCNAME[0]} - Unknown download name: ${download_name}"
        ;;
    esac
    timestamp_file="${timestamp_dir}/timestamp-${timestamp_pattern}.txt"
    static_download_links="${temp_dir}/StaticDownloadLinks-${timestamp_pattern}.txt"

    if same_day "$timestamp_file"; then
        log_info_message "Skipped processing of \"${timestamp_pattern//-/ }\", because it has already been done in the last 24 hours"
    else
        log_info_message "Start processing of \"${timestamp_pattern//-/ }\" ..."

        verify_integrity_database "$hashed_dir" "$hashes_file"
        calculate_static_downloads "$download_name" "$static_download_links"
        download_static_files "$download_dir" "$static_download_links"
        cleanup_client_directory "$download_dir" "$static_download_links" "not-available" "$static_download_links"
        verify_digital_file_signatures "$download_dir"
        create_integrity_database "$hashed_dir" "$hashes_file"

        if (( runtime_errors == initial_errors )); then
            update_timestamp "$timestamp_file"
            log_info_message "Done processing of \"${timestamp_pattern//-/ }\""
        else
            log_warning_message "There were $(( runtime_errors - initial_errors )) runtime errors for \"${timestamp_pattern//-/ }\". See the download log for details."
        fi
    fi

    echo ""
    return 0
}


function calculate_static_downloads ()
{
    local download_name="$1"
    local static_download_links="$2"
    local current_dir=""
    local current_arch=""
    local current_lang=""

    log_info_message "Determining static download links ..."

    # Reset output file
    > "$static_download_links"
    for current_dir in ../static ../static/custom; do
        case "$download_name" in
            wsus)
                if [[ -s "${current_dir}/StaticDownloadLinks-wsus.txt" ]]; then
                    cat_dos "${current_dir}/StaticDownloadLinks-wsus.txt" \
                        >> "$static_download_links"
                fi
            ;;
            cpp)
                # Visual C++ runtime libraries always include both 32-bit
                # and 64-bit versions.
                for current_arch in x86 x64; do
                    if [[ -s "${current_dir}/StaticDownloadLinks-cpp-${current_arch}-glb.txt" ]]; then
                        cat_dos "${current_dir}/StaticDownloadLinks-cpp-${current_arch}-glb.txt" \
                            >> "$static_download_links"
                    fi
                done
            ;;
            dotnet)
                # English installers for the .Net Frameworks 3.5, 4.6
                # and 4.6.2. These are the only full installers for the
                # .Net Frameworks, and they are needed for all other
                # languages as well.
                if [[ -s "${current_dir}/StaticDownloadLinks-dotnet.txt" ]]; then
                    cat_dos "${current_dir}/StaticDownloadLinks-dotnet.txt" \
                        >> "$static_download_links"
                fi
                # Localized installers for language packs. The names of
                # these installers are similar to the full installers,
                # but the file size is much smaller.
                #
                # Note, that there are no English static download
                # files like StaticDownloadLinks-dotnet-x86-enu.txt or
                # StaticDownloadLinks-dotnet-x64-enu.txt.
                #
                # The search patterns are extracted from the Windows
                # script AddCustomLanguageSupport.cmd
                for current_lang in glb "${language_name}"; do
                    if [[ -s "${current_dir}/StaticDownloadLinks-dotnet-x86-${current_lang}.txt" ]]; then
                        grep_dos -F -i -e "dotNetFx40LP_Full_" \
                                       -e "NDP452-KB2901907-"  \
                                       -e "NDP46-KB3045557-"   \
                                       -e "NDP461-KB3102436-"  \
                                       -e "NDP462-KB3151800-"  \
                            "${current_dir}/StaticDownloadLinks-dotnet-x86-${current_lang}.txt" \
                            >> "$static_download_links" || true
                    fi
                done
            ;;
            msse)
                for current_lang in glb "${language_name}"; do
                    if [[ -s "${current_dir}/StaticDownloadLinks-msse-${update_architecture}-${current_lang}.txt" ]]; then
                        cat_dos "${current_dir}/StaticDownloadLinks-msse-${update_architecture}-${current_lang}.txt" \
                            >> "$static_download_links"
                    fi
                done
            ;;
            wddefs)
                if [[ -s "${current_dir}/StaticDownloadLink-wddefs-${update_architecture}-glb.txt" ]]; then
                    cat_dos "${current_dir}/StaticDownloadLink-wddefs-${update_architecture}-glb.txt" \
                        >> "$static_download_links"
                fi
            ;;
            wddefs8)
                if [[ -s "${current_dir}/StaticDownloadLinks-msse-${update_architecture}-glb.txt" ]]; then
                    grep_dos -F -i -e "mpam-fe.exe" \
                                   -e "mpam-fex64.exe" \
                                   -e "nis_full.exe" \
                        "${current_dir}/StaticDownloadLinks-msse-${update_architecture}-glb.txt" \
                        >> "$static_download_links" || true
                fi
            ;;
        esac
    done
    sort_in_place "$static_download_links"

    # Since included updates are only statically defined, it is an
    # unexpected error, if the static downloads list is empty.
    if ensure_non_empty_file "$static_download_links"; then
        log_info_message "Created file ${static_download_links##*/}"
    else
        log_warning_message "No downloads found for $download_name"
    fi
    return 0
}

# ========== Commands =====================================================

get_included_downloads
return 0
