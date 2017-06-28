# This file will be sourced by the shell bash.
#
# Filename: timestamps.bash
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
#     Timestamps are used to prevent a repeated evaluation of the same
#     tasks in adjacent runs of the download script. It uses a simple
#     "same day" rule: a task will be skipped, if it has already been
#     done in the last 24 hours.
#
#     TODO: This could be made more flexible by using three different
#     time intervals.
#
#     The virus definition files, could be checked more often. They
#     change every two hours and may be checked every four hours.
#
#     The input files of WSUS Offline update should be checked once daily
#     (every 24 hours). These are online checks for:
#     - new versions of WSUS Offline Update
#     - new versions of the Linux scripts
#     - changed configuration files, formerly known as the update of
#       static download definitions (SDD)
#     - new versions of the Microsoft WSUS catalog file wsusscn2.cab
#
#     If these input files don't change, then the other downloads won't
#     change either. Most downloads could be postponed for some days,
#     or possibly forever. This would lead to an event-driven evaluation
#     of most downloads. A safe value for testing would be two days.
#
#     This is currently in planning, but not implemented yet.


# ========== Configuration ================================================

# TODO: Use a variable interval for recalculating updates

time_interval_virus_definitions=14400   # 4x60x60 seconds
time_interval_input_files=86400         # 24x60x60 seconds
time_interval_dependent_files=172800    # 2x24x60x60 seconds

interval_description_virus_definitions="four hours"
interval_description_input_files="24 hours"
interval_description_dependent_files="two days"

# ========== Functions ====================================================

# function same_day
#
# Parameters
#
# $1 - The pathname of the timestamp file
# $2 - The time interval in seconds. A default value of 86400 seconds =
#      24 hours is used, if this parameter is missing.
#
# Result codes
#
# 0 - The current task has already been processed in the specified
#     interval (the last 24 hours).
# 1 - The current task has not been processed in the specified interval
#     (the last 24 hours), or the timestamp file does not exist yet.
function same_day ()
{
    local timestamp_file="$1"
    local -i time_interval="${2:-86400}" # use 24 hours as default
    local -i result_code=1  # return "false" by default
    local -i current_date=0
    local -i file_modification_date=0

    if [[ -f "$timestamp_file" ]]; then
        # Get date in seconds since 1970-01-01 UTC
        current_date="$(date '+%s')"
        file_modification_date="$(date -r "$timestamp_file" '+%s')"
        # Add the time interval in seconds
        file_modification_date=$(( file_modification_date + time_interval ))
        if (( file_modification_date > current_date )); then
            result_code=0
        fi
    fi
    return "${result_code}"
}

# In some cases, updating the timestamp for one download should also
# update the timestamp of another, included download:
#
# - Downloads for .Net Framework always include the English installers,
#   because these are the only "full" installers. Installers for other
#   languages are only language packs. Therefore, the timestamp for
#   dotnet-x86-deu should also update the timestamp for dotnet-x86-enu.
# - wddefs8 is msse without the localized installers. Any download for
#   msse should also update the timestamp for wddefs8.
# - Office 32-bit downloads are included in Office 64-bit downloads.
function update_timestamp ()
{
    local timestamp_file="$1"

    touch "${timestamp_file}"
    case "${timestamp_file##*/}" in
        timestamp-dotnet-all-*.txt)
            touch "${timestamp_dir}"/timestamp-dotnet-all-enu.txt
        ;;
        timestamp-dotnet-x86-*.txt)
            touch "${timestamp_dir}/timestamp-dotnet-x86-enu-${include_service_packs}-${prefer_seconly}.txt"
        ;;
        timestamp-dotnet-x64-*.txt)
            touch "${timestamp_dir}/timestamp-dotnet-x64-enu-${include_service_packs}-${prefer_seconly}.txt"
        ;;
        timestamp-msse-x86-*.txt)
            touch "${timestamp_dir}"/timestamp-wddefs8-x86-glb.txt
        ;;
        timestamp-msse-x64-*.txt)
            touch "${timestamp_dir}"/timestamp-wddefs8-x64-glb.txt
        ;;
        timestamp-o2k10-x64-*.txt | timestamp-o2k13-x64-*.txt | timestamp-o2k16-x64-*.txt)
            touch "${timestamp_file/x64/x86}"
        ;;
        *)
            :
        ;;
    esac
    return 0
}


# After installing a new version of WSUS Offline Update, and after updates
# of the configuration files, all downloads should be reevaluated. This is
# done by removing the timestamps for all static and dynamic updates. This
# does not include the timestamps for the following tasks:
#
# - check wsusoffline version
# - check sh version
# - update configuration files
function reevaluate_all_updates ()
{
    local -a file_list=()
    local pathname=""

    if [[ -d "${timestamp_dir}" ]]; then
        shopt -s nullglob
        file_list=("${timestamp_dir}"/timestamp-*.txt)
        shopt -u nullglob

        if (( ${#file_list[@]} > 0 )); then
            for pathname in "${file_list[@]}"; do
                rm "$pathname"
            done
        fi
    fi
    return 0
}

# After downloading new versions of the files wsusscn2.cab and
# ExcludeList-superseded-exclude.txt, and subsequently rebuilding the list
# of superseded updates, all dynamic updates must be recalculated. Static
# downloads don't need to be recalculated.
function reevaluate_dynamic_updates ()
{
    local -a file_list=()
    local pathname=""

    if [[ -d "${timestamp_dir}" ]]; then
        shopt -s nullglob
        file_list=(
            "${timestamp_dir}"/timestamp-w6*.txt
            "${timestamp_dir}"/timestamp-w100-*.txt
            "${timestamp_dir}"/timestamp-dotnet-*-glb.txt
            "${timestamp_dir}"/timestamp-ofc-*.txt
        )
        shopt -u nullglob

        if (( ${#file_list[@]} > 0 )); then
            for pathname in "${file_list[@]}"; do
                rm "$pathname"
            done
        fi
    fi
    return 0
}

return 0
