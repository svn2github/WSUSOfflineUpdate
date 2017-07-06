# This file will be sourced by the shell bash.
#
# Filename: 40-configure-downloaders.bash
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
#     This file defines command line options for wget and aria2.

# ========== Configuration ================================================

supported_downloaders="${supported_downloaders:-"wget aria2c"}"

# With Wget 1.16 and lower, the complete output is either to the terminal
# window or to a log file.
#
# Since the output to the terminal is volatile, the complete output is
# written to a logfile. Wget then uses a dot display for the progress. The
# granularity can be specified with the option --progress=dot:mega. Users
# can watch the whole output with "tail -f download.log" in another
# terminal window.
#
# But this leaves no output to the terminal window, from which the command
# was started. There is no use to duplicate the whole output with "tee",
# because the verbose output is just too much. On the other hand, the
# no-verbose output is almost useless, if there is any download problem.
#
# A possible workaround would be a filter to further reduce the verbosity,
# as in the script winetricks.
#
# Wget 1.16 introduced a new option --show-progress, but this doesn't
# have any effect, if the output is to a logfile.
#
# In Wget 1.18, the same option --show-progress works slightly different:
# It allows to split the output between the terminal and the logfile. The
# progress bar is always shown in the terminal window, and the rest of
# the output is written to the logfile. Then the output is similar to
# aria2 and curl.
#
# But Wget 1.18 is not available for Debian 8 stable/Jessie, and so the
# options --show-progress and --start-pos=0 are not used for now.


# Persistent connections (HTTP keep-alive) don't work reliably with a
# content delivery network. Both download utilities may occasionally
# receive a server error 502: Bad Gateway, if persistent connections
# are allowed.
#
# The same is true for multiple connections in Aria2, if these are
# used for a fragmented download of the same file. Therefore, the
# option "--max-connection-per-server=5" is not used for now.
#
# Multiple connections for the simultaneous download of different files
# are still allowed; these don't seem to cause problems. In this case,
# Aria2 uses the default of up to five simultaneous connections.


# The download with failsafe options may still fail, but the saving of
# damaged files should be prevented. The download utilities should provide
# more information in this case. For Wget, the option --server-response
# is added, and for Aria2, the log-level is increased.

readonly wget_common_options="--verbose --progress=dot:mega --timestamping --unlink --timeout=60 --no-http-keep-alive" # Add "--show-progress" for Wget 1.18
readonly wget_optimized_options="--tries=10 --waitretry=10"
readonly wget_failsafe_options="--server-response --tries=1 --no-cache" # --no-dns-cache --start-pos=0
readonly wget_spider_option="--spider"

readonly wget_logfile_prefix="--append-output="
readonly wget_download_dir_prefix="--directory-prefix="
readonly wget_inputfile_prefix="--input-file="

readonly wget_connection_test_a="--spider --verbose --tries=1 --timeout=10"
readonly wget_connection_test_b="--spider --debug   --tries=1 --timeout=10"

readonly aria2c_common_options="--conditional-get=true --remote-time=true --allow-overwrite=true --auto-file-renaming=false --max-tries=10 --retry-wait=10 --timeout=60 --enable-http-keep-alive=false"
readonly aria2c_optimized_options="--log-level=notice"
readonly aria2c_failsafe_options="--log-level=info --summary-interval=0 --always-resume=false --max-resume-failure-tries=0 --remove-control-file=true --http-no-cache=true"
readonly aria2c_spider_option="--dry-run=true"

readonly aria2c_logfile_prefix="--log="
readonly aria2c_download_dir_prefix="--dir="
readonly aria2c_inputfile_prefix="--input-file="

readonly aria2c_connection_test_a="--dry-run=true --log-level=notice --max-tries=1 --timeout=10 --force-sequential=true"
readonly aria2c_connection_test_b="--dry-run=true --log-level=info   --max-tries=1 --timeout=10 --force-sequential=true"

# The connection test should only use complete URLs. While web servers
# usually offer a standard document like index.html for incomplete URLs,
# this is not true for the download servers "download.windowsupdate.com"
# and "download.microsoft.com". These servers may respond with "503
# Service Unavailable" or "403 Forbidden", if only the domain name
# is used.

readonly connection_test_urls="http://download.windowsupdate.com/microsoftupdate/v6/wsusscan/wsusscn2.cab"
#readonly connection_test_urls="http://www.wsusoffline.net/ http://download.windowsupdate.com/microsoftupdate/v6/wsusscan/wsusscn2.cab"

# ========== Global variables =============================================

downloader=""

common_options=""
optimized_options=""
failsafe_options=""
spider_option=""

logfile_prefix=""
download_dir_prefix=""
inputfile_prefix=""

connection_test_a=""
connection_test_b=""

# ========== Functions ====================================================

function configure_downloaders ()
{
    local binary_name=""

    for binary_name in $supported_downloaders; do
        if type -P "$binary_name" > /dev/null; then
            downloader="$binary_name"
            break
        fi
    done

    case "$downloader" in
        wget)
            log_info_message "Setting download options for GNU Wget..."
            common_options="$wget_common_options"
            optimized_options="$wget_optimized_options"
            failsafe_options="$wget_failsafe_options"
            spider_option="$wget_spider_option"

            logfile_prefix="$wget_logfile_prefix"
            download_dir_prefix="$wget_download_dir_prefix"
            inputfile_prefix="$wget_inputfile_prefix"

            connection_test_a="$wget_connection_test_a"
            connection_test_b="$wget_connection_test_b"
        ;;
        aria2c)
            log_info_message "Setting download options for Aria2..."
            common_options="$aria2c_common_options"
            optimized_options="$aria2c_optimized_options"
            failsafe_options="$aria2c_failsafe_options"
            spider_option="$aria2c_spider_option"

            logfile_prefix="$aria2c_logfile_prefix"
            download_dir_prefix="$aria2c_download_dir_prefix"
            inputfile_prefix="$aria2c_inputfile_prefix"

            connection_test_a="$aria2c_connection_test_a"
            connection_test_b="$aria2c_connection_test_b"
        ;;
        *)
            fail "No supported downloader found"
        ;;
    esac
    return 0
}

# The function is_valid_url tests, if the remote file can be found,
# using either wget --spider or aria2c --dry-run=true. It directly
# returns the result code of the download utility:
#
# 0: no error
# 8: server error 404 in wget
# 3: server error 404 in aria2c

function is_valid_url ()
{
    local download_link="$1"

    "${downloader}" "$spider_option" "$download_link" 1>/dev/null 2>&1
}

# Some input files with static download links contain local filenames
# after a comma. These local filenames are used for downloads, which
# have the same remote filename, but a different path on the server.
#
# - The Visual C++ runtime libraries (cpp) all have similar names.
# - The installers for Microsoft Security Essentials (msse) are localized,
#   but all localized installers share the same remote filename.
#
# In WSUS Offline Update, these files are downloaded to the
# same directories. Then it is necessary to rename them after
# downloading. Before subsequent downloads, the files are renamed again
# to their original remote filenames, to make the timestamping feature
# of wget and aria2 work.

function download_static_files ()
{
    local download_dir="$1"
    local input_file="$2"
    local -i number_of_links=0
    local download_link=""
    local local_filename=""
    local remote_filename=""
    local skip_rest=""
    local initial_errors="${runtime_errors}"

    require_non_empty_file "${input_file}" || return 0
    number_of_links="$(wc -l < "${input_file}")"

    log_info_message "Downloading/validating ${number_of_links} link(s) from input file ${input_file##*/} ..."

    # Setting IFS to a comma and space removes spurious spaces at the
    # end of the line. These may be found in some files created by the
    # Windows script AddCustomLanguageSupport.cmd:
    #
    # ../static/custom/StaticDownloadLinks-dotnet-x64-glb.txt
    # ../static/custom/StaticDownloadLinks-dotnet-x86-glb.txt

    while IFS=', ' read -r download_link local_filename skip_rest
    do
        remote_filename="${download_link##*/}"

        if [[ -n "${local_filename}" && -f "${download_dir}/${local_filename}" ]]; then
            log_info_message "Renaming ${local_filename} to remote filename ${remote_filename}"
            mv "${download_dir}/${local_filename}" \
               "${download_dir}/${remote_filename}"
        fi

        download_single_file "${download_dir}" "${download_link}"

        if [[ -n "${local_filename}" && -f "${download_dir}/${remote_filename}" ]]; then
            log_info_message "Renaming ${remote_filename} to local filename ${local_filename}"
            mv "${download_dir}/${remote_filename}" \
               "${download_dir}/${local_filename}"
        fi
    done < <(cat_dos "${input_file}")

    if (( runtime_errors == initial_errors )); then
        log_info_message "Downloaded/validated ${number_of_links} link(s)"
    else
        log_warning_message "There were $(( runtime_errors - initial_errors )) runtime errors while downloading/validating links from input file ${input_file##*/}. See the download log for details"
    fi
    return 0
}


function download_single_file ()
{
    local download_dir="$1"
    local download_link="$2"
    local filename="${download_link##*/}"
    local pathname="${download_dir}/${filename}"

    case "$filename" in
        # Virus definition files
        mpam-fe.exe | mpam-fex64.exe | mpas-fe.exe | mpas-feX64.exe)
            create_backup_copy "${pathname}"
            download_single_file_failsafe "$@"
            restore_backup_copy "${pathname}" # If necessary
        ;;
        # WSUS catalog file
        wsusscn2.cab)
            set_timestamp "${pathname}"
            create_backup_copy "${pathname}"
            download_single_file_failsafe "$@"
            verify_cabinet_file "${pathname}" # May delete the file, if the test fails
            restore_backup_copy "${pathname}" # If necessary
            compare_timestamp "${pathname}"
            if ! require_file "${pathname}"; then
                log_error_message "The download or the integrity test of the WSUS catalog file wsusscn2.cab failed. Without this file, the script cannot continue."
                exit 1
            fi
        ;;
        # WSUS Offline Update configuration files
        ExcludeList-superseded-exclude.txt | HideList-seconly.txt | StaticDownloadFiles-modified.txt | ExcludeDownloadFiles-modified.txt | StaticUpdateFiles-modified.txt)
            set_timestamp "${pathname}"
            download_single_file_optimized "$@"
            compare_timestamp "${pathname}"
        ;;
        # All other downloads
        *)
            download_single_file_optimized "$@"
        ;;
    esac
    return 0
}


# The function download_single_file_optimized is optimized for files,
# which don't change on the server.

function download_single_file_optimized ()
{
    local download_dir="$1"
    local download_link="$2"
    local filename="${download_link##*/}"
    mkdir -p "$download_dir"

    if "${downloader}" ${common_options} ${optimized_options} \
        "${logfile_prefix}${logfile}" \
        "${download_dir_prefix}${download_dir}" \
        "${download_link}"
    then
        log_debug_message "Download/validation of ${filename} succeeded"
    else
        log_error_message "Download/validation of ${filename} failed"
        runtime_errors="$(( runtime_errors + 1 ))"
    fi

    return 0
}


# The function download_single_file_failsafe is optimized for a reliable
# download of the files wsusscn2.cab and the four virus definition files.
#
# The virus definition files change every two hours, and there may be up
# to three different versions of the same file in the content delivery
# network, all with the same URL. Simply resuming a download will often
# result in a broken download. It is better to restart every download
# from scratch. This must be done manually for both downloaders.
#
# Only Wget 1.18 with the option --start-pos=0 can restart a download
# from scratch itself.
#
# Aria2 stops a download, if it gets conflicting information about the
# file length, but it doesn't restart the download.

function download_single_file_failsafe ()
{
    local download_dir="$1"
    local download_link="$2"
    local filename="${download_link##*/}"
    local result_code=1
    local try_count=1
    local max_tries=10
    local wait_time=10
    mkdir -p "$download_dir"

    until (( result_code == 0 )) || (( try_count > max_tries )); do

        log_info_message "Downloading/validating ${filename}, try $try_count ..."
        if "${downloader}" ${common_options} ${failsafe_options} \
            "${logfile_prefix}${logfile}" \
            "${download_dir_prefix}${download_dir}" \
            "${download_link}"
        then
            result_code=0
            log_debug_message "Download/validation of ${filename} succeeded"
        else
            result_code="$?"
            log_error_message "Download/validation of ${filename} failed with result code $result_code"

            if (( try_count < max_tries )); then
                log_info_message "Restarting download in $(( try_count * wait_time )) seconds ..."
                sleep "$(( try_count * wait_time ))"
            else
                log_info_message "Maximum number of tries reached. Giving up."
                runtime_errors="$(( runtime_errors + 1 ))"
                # If the download failed after 10 attempts, then the
                # downloaded file (if any) is most probably damaged and
                # should be deleted.
                rm -f "${download_dir}/${filename}"
            fi
        fi

        try_count=$(( try_count + 1 ))
    done

    return 0
}


# The function download_multiple_files uses a text file with URLs as
# input. This function is used for dynamic updates and for the recursive
# update of static download definitions.

function download_multiple_files ()
{
    local download_dir="$1"
    local input_file="$2"
    local -i number_of_links=0

    require_non_empty_file "$input_file" || return 0
    number_of_links="$(wc -l < "${input_file}")"
    # The download directory should only be created after testing
    # the input file. This is needed to prevent the creation of empty
    # directories.
    mkdir -p "$download_dir"

    log_info_message "Downloading/validating ${number_of_links} link(s) from input file ${input_file##*/} ..."

    if "${downloader}" ${common_options} ${optimized_options} \
        "${logfile_prefix}${logfile}" \
        "${download_dir_prefix}${download_dir}" \
        "${inputfile_prefix}$input_file"
    then
        log_info_message "Downloaded/validated ${number_of_links} link(s)"
    else
        log_error_message "Some downloads from input file ${input_file##*/} failed -- see the download log for details"
        runtime_errors="$(( runtime_errors + 1 ))"
    fi

    return 0
}


# function download_and_verify
#
# Download an archive and the accompanying hashes file, and use the
# hashes file to verify the archive. This is used for the self update
# of WSUS Offline Update and the Linux scripts.

function download_and_verify ()
{
    local download_dir="$1"
    local archive_link="$2"
    local hashes_link="$3"
    local archive_filename="${archive_link##*/}"
    local hashes_filename="${hashes_link##*/}"
    local -i initial_errors="${runtime_errors}"

    log_info_message "Downloading archive and accompanying hashes file..."
    download_single_file "${download_dir}" "${archive_link}"
    (( runtime_errors == initial_errors )) || exit 1
    download_single_file "${download_dir}" "${hashes_link}"
    (( runtime_errors == initial_errors )) || exit 1

    log_info_message "Searching downloaded files..."
    if [[ -f "${download_dir}/${archive_filename}" ]]; then
        log_info_message "Found archive:     ${download_dir}/${archive_filename}"
    else
        log_error_message "Archive ${archive_filename} was not found"
        exit 1
    fi
    if [[ -f "${download_dir}/${hashes_filename}" ]]; then
        log_info_message "Found hashes file: ${download_dir}/${hashes_filename}"
    else
        log_error_message "Hashes file ${hashes_filename} was not found"
        exit 1
    fi

    # Validate the archive using hashdeep in audit mode (-a). The bare
    # mode (-b) removes any leading directory information. This enables
    # us to check files without changing directories with pushd/popd.
    log_info_message "Verifying the integrity of the archive ${archive_filename} ..."
    if hashdeep -a -b -v -v -k "${download_dir}/${hashes_filename}" "${download_dir}/${archive_filename}"; then
        log_info_message "Validated archive ${archive_filename}"
    else
        log_error_message "Validation failed"
        exit 1
    fi
    return 0
}


# Do a two step connection test.
#
# DSL modems and routers are sometimes slow to connect. It may take
# several seconds to establish an Internet connection, and this may
# already cause some downloads to fail. Therefore, the connection should
# be established and tested, before starting the real downloads.

function test_internet_connection ()
{
    log_info_message "Wake up sleeping DSL modems and routers..."

    # The first test sometimes fails with the error message "ping: unknown
    # host www.wsusoffline.net". Then the Internet router was too slow to
    # connect to its Internet Service Provider, but subsequent connection
    # tests should succeed.
    (ping -c 4 -q download.windowsupdate.com 2>&1 | tee -a "${logfile}") || true
    echo ""
    sleep 4

    log_info_message "Testing the Internet connection..."
    if "${downloader}" ${connection_test_a} \
        "${logfile_prefix}${logfile}" \
        ${connection_test_urls}
    then
        log_info_message "Connection test succeeded"
    else
        log_info_message "Retrying with increased verbosity in 10 seconds..."
        sleep 10
        if "${downloader}" ${connection_test_b} \
            "${logfile_prefix}${logfile}" \
            ${connection_test_urls}
        then
            log_info_message "Connection test succeeded"
        else
            log_error_message "The Internet connection could not be established. See download log for details."
            exit 1
        fi
    fi
    return 0
}


# Proxy servers should not be set on the command line. The complete
# command line of all running applications may be revealed with tools
# like htop and ps, even by other users.
#
# Exporting proxy servers as environment variables is safer, as these
# commands appear nowhere. The environment is changed only for the
# running script.

function export_proxy_servers ()
{
    if [[ -n "$proxy_server" ]]; then
        log_info_message "Setting http_proxy to $proxy_server"
        export http_proxy="$proxy_server"
    fi
    if [[ -n "$secure_proxy_server" ]]; then
        log_info_message "Setting https_proxy to $secure_proxy_server"
        export https_proxy="$secure_proxy_server"
    fi
    if [[ -n "$no_proxy_server" ]]; then
        log_info_message "Setting no_proxy to $no_proxy_server"
        export no_proxy="$no_proxy_server"
    fi
}

# ========== Commands =====================================================

configure_downloaders
export_proxy_servers
test_internet_connection
echo ""
return 0
