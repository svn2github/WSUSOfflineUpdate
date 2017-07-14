# This file will be sourced by the shell bash.
#
# Filename: timestamps.bash
# Version: 1.0-beta-4
# Release date: 2017-06-23
# Intended compatibility: WSUS Offline Update Version 10.9.2 and newer
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
#     tasks in adjacent runs of the download script. For example, the
#     directory client/win contains common downloads for all Windows
#     versions. Similarly, the directory client/ofc contains common files
#     for all Office versions. If different Windows or Office versions
#     are downloaded in turn, then the downloads for win and ofc should
#     only be processed once.
#
#     The function "same_day checks, if a task has already been done on
#     the same day.
#
#     In its first implementation, it compared the output of the command
#     "date" in the form "2017-05-09", which is known as ISO 8601 (
#     https://xkcd.com/1179/ ). If the file modification date of the
#     timestamp file and the current date were on the same day, then
#     the same_day function returned true and the download task would
#     be skipped.
#
#     The next implementation in version 1.0-beta-2 calculated the time
#     difference in seconds. The same_day function returned true, if the
#     difference between the file modification date and the current date
#     was less than 24 hours.
#
#     In its current implementation, the same_day function uses three
#     different time intervals for different tasks:
#
#     - The four virus definition files change every two hours. It may
#       be useful, to check these files more often, for example every
#       four hours.
#
#     - Configuration files are checked once daily as before. This
#       includes searching for new versions of WSUS Offline Update and
#       the Linux scripts, and updates of the configuration files for
#       WSUS Offline Update and the WSUS catalog files wsusscn2.cab.
#
#       If these configuration files change, then most or all of
#       the remaining updates will be rescheduled by deleting their
#       timestamp files.
#
#     - The remaining updates all depend on the configuration files. If
#       the configuration files don't change, then these updates cannot
#       change either. These are all updates for Windows, Office, .Net
#       frameworks, and Visual C++ runtime libraries.
#
#       The time interval for these dependent updates is set to a safe
#       value of two days.
#
#       Actually, these updates could be postponed forever. They will
#       be rescheduled immediately, if one of the configuration file
#       changes. This would result in an event-driven evaluation of the
#       updates, rather then recalculating everything everyday.
#
#
#     Timestamps are also used to remember the modification date of
#     single files like the WSUS catalog file wsusscn2.cab and several
#     configuration files of WSUS Offline Update. If these files change,
#     then some or all updates need to be recalculated. Using timestamp
#     files for this comparison is more flexible than reading the file
#     modification dates into variables and comparing the variables.

# ========== Configuration ================================================

# The interval length must take into account the time needed to process
# the task: check the consistency of existing downloads, calculate static
# and dynamic download links, fetch all files (if they don't exist yet),
# and calculate new hashes for the download directory. The timestamp
# will be updated after successfully completing the task.
#
# An initial download, for example of the Windows 10 updates,
# may take several hours, dependent on the speed of the Internet
# connection. Therefore, "four hours" are calculated as 3:20 hours,
# "one day" is now 21 hours, and "two days" are 45 hours. Of course,
# these are only guesses, which can be adjusted as needed below:

interval_length_virus_definitions=12000   # 200x60 seconds
interval_length_configuration_files=75600 # 21x60x60 seconds
interval_length_dependent_files=162000    # 45x60x60 seconds

interval_description_virus_definitions="four hours"
interval_description_configuration_files="one day"
interval_description_dependent_files="two days"

# TODO: Some definitions could be better done with associative arrays,
# but this would require bash 4.x and definitely destroy compatibility
# with Mac OS X.

# ========== Functions ====================================================

# function same_day
#
# Parameters
#
# $1 - The pathname of the timestamp file
# $2 - The time interval in seconds. The interval length for configuration
#      files is used as default, if this parameter is missing
#
# Result codes
#
# 0 - The current task has already been processed in the specified
#     time interval
# 1 - The current task has not been processed in the specified time
#     interval, or the timestamp file does not exist yet.

function same_day ()
{
    local timestamp_file="$1"
    local -i interval_length="${2:-$interval_length_configuration_files}"
    local -i result_code=1  # return "false" by default
    local -i current_date=0
    local -i file_modification_date=0

    if [[ -f "$timestamp_file" ]]; then
        # Get date in seconds since 1970-01-01 UTC
        current_date="$(date '+%s')"
        file_modification_date="$(date -r "$timestamp_file" '+%s')"
        # Add the interval length in seconds
        file_modification_date=$(( file_modification_date + interval_length ))
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
            touch "${timestamp_dir}/timestamp-dotnet-all-enu.txt"
        ;;
        timestamp-dotnet-x86-*.txt)
            # TODO: the variables should be removed from the timestamps
            touch "${timestamp_dir}/timestamp-dotnet-x86-enu-${include_service_packs}-${prefer_seconly}.txt"
        ;;
        timestamp-dotnet-x64-*.txt)
            touch "${timestamp_dir}/timestamp-dotnet-x64-enu-${include_service_packs}-${prefer_seconly}.txt"
        ;;
        timestamp-msse-x86-*.txt)
            touch "${timestamp_dir}/timestamp-wddefs8-x86-glb.txt"
        ;;
        timestamp-msse-x64-*.txt)
            touch "${timestamp_dir}/timestamp-wddefs8-x64-glb.txt"
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


# The function set_timestamp creates a timestamp file as a reference
# for the current file modification date of a particular file. This
# function is called before downloading the WSUS catalog file or the
# various configuration files of WSUS Offline Update.

function set_timestamp ()
{
    local pathname="$1"

    if [[ -f "${pathname}" ]]; then
        touch -r "${pathname}" "${pathname}.timestamp"
    else
        rm -f "${pathname}.timestamp"
    fi
    return 0
}


# The function compare_timestamp is called after downloading the WSUS
# catalog file of one of the configuration files. It compares the current
# file modification date with a previously safed timestamp file. If the
# file is newer after download, most or all downloads and the calculation
# of the superseded updates will be rescheduled.

function compare_timestamp ()
{
    local pathname="$1"
    local filename="${pathname##*/}"

    if [[ -f "${pathname}" ]]; then
        log_info_message "Comparing file modification dates for ${filename} ..."
        # According to the bash manual, the operator -nt is true, if file1
        # is newer than file2, or if file1 exists and file2 does not.
        if [[ "${pathname}" -nt "${pathname}.timestamp" ]]; then
            case "${filename}" in
                wsusscn2.cab)
                    log_info_message "The WSUS catalog file ${filename} was updated. Superseded and dynamic updates will be recalculated."
                    rm -f "${cache_dir}/package.xml"
                    rm -f "${cache_dir}/package-formated.xml"
                    rm -f "../exclude/ExcludeList-superseded.txt"
                    rm -f "../exclude/ExcludeList-superseded-seconly.txt"
                    reevaluate_dynamic_updates
                ;;
                *)
                    log_info_message "The configuration file ${filename} was updated. All updates will be recalculated."
                    rm -f "../exclude/ExcludeList-superseded.txt"
                    rm -f "../exclude/ExcludeList-superseded-seconly.txt"
                    reevaluate_all_updates
                ;;
            esac
        else
            log_info_message "The file ${filename} did not change."
            # TODO: If there are no changes, then the recursive download
            # of some configuration files could also be skipped.
        fi
    fi
    rm -f "${pathname}.timestamp"
    return 0
}


# After downloading new versions of the file wsusscn2.cab, and
# subsequently rebuilding the list of superseded updates, all dynamic
# updates must be recalculated. Static downloads don't need to be
# recalculated.

function reevaluate_dynamic_updates ()
{
    local -a file_list=()
    local pathname=""

    if [[ -d "${timestamp_dir}" ]]; then
        shopt -s nullglob
        file_list=(
            "${timestamp_dir}"/timestamp-w6*.txt
            "${timestamp_dir}"/timestamp-w100-*.txt
            "${timestamp_dir}"/timestamp-dotnet-x86-*.txt
            "${timestamp_dir}"/timestamp-dotnet-x64-*.txt
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


# After installing a new version of WSUS Offline Update, and after updates
# of the configuration files, all downloads should be reevaluated. This
# is done by removing the timestamps for all static and dynamic updates.
#
# This does not include the timestamps for the following tasks, which
# use a different naming scheme:
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

return 0
