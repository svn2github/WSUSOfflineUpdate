#!/usr/bin/env bash
#
# Filename: download-updates.bash
# Version: 1.1
# Release date: 2018-02-06
# Intended compatibility: WSUS Offline Update Version 11.1.1 and later
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
#     An analog of the Windows script DownloadUpdates.cmd as a shell
#     script. Use this script to download updates for Microsoft Windows
#     and Office.
#
#     This script is meant to run without user interaction. It will only
#     ask for confirmation, if there is a new version of WSUS Offline
#     Update available, which can be installed. Even this question will
#     default to "no" after 30 seconds. This means, that the script
#     download-updates.bash could be used in cron jobs or similar
#     automated tasks.
#
#     The interactive setup is done by the accompanying script
#     setup-downloads.bash .
#
#     USAGE
#        ./download-updates.bash UPDATE[,UPDATE...] \
#                                LANGUAGE[,LANGUAGE...] \
#                                [OPTIONS]
#
#     UPDATE
#         w60           Windows Server 2008, 32-bit
#         w60-x64       Windows Server 2008, 64-bit
#         w61           Windows 7, 32-bit
#         w61-x64       Windows 7 / Server 2008 R2, 64-bit
#         w62-x64       Windows Server 2012, 64-bit
#         w63           Windows 8.1, 32-bit
#         w63-x64       Windows 8.1 / Server 2012 R2, 64-bit
#         w100          Windows 10, 32-bit
#         w100-x64      Windows 10 / Server 2016, 64-bit
#         o2k10         Office 2010, 32-bit
#         o2k10-x64     Office 2010, 32-bit and 64-bit
#         o2k13         Office 2013, 32-bit
#         o2k13-x64     Office 2013, 32-bit and 64-bit
#         o2k16         Office 2016, 32-bit
#         o2k16-x64     Office 2016, 32-bit and 64-bit
#         all           All Windows and Office updates, 32-bit and 64-bit
#         all-x86       All Windows and Office updates, 32-bit
#         all-x64       All Windows and Office updates, 64-bit
#         all-win       All Windows updates, 32-bit and 64-bit
#         all-win-x86   All Windows updates, 32-bit
#         all-win-x64   All Windows updates, 64-bit
#         all-ofc       All Office updates, 32-bit and 64-bit
#         all-ofc-x86   All Office updates, 32-bit
#
#         Notes: Multiple updates can be joined to a comma-separated
#         list like "w60,w60-x64".
#
#     LANGUAGE
#         deu    German
#         enu    English
#         ara    Arabic
#         chs    Chinese (Simplified)
#         cht    Chinese (Traditional)
#         csy    Czech
#         dan    Danish
#         nld    Dutch
#         fin    Finnish
#         fra    French
#         ell    Greek
#         heb    Hebrew
#         hun    Hungarian
#         ita    Italian
#         jpn    Japanese
#         kor    Korean
#         nor    Norwegian
#         plk    Polish
#         ptg    Portuguese
#         ptb    Portuguese (Brazil)
#         rus    Russian
#         esn    Spanish
#         sve    Swedish
#         trk    Turkish
#
#         Note: Multiple languages can be joined to a comma-separated
#         list like "deu,enu".
#
#     OPTIONS
#        -includesp
#             Include Service Packs
#
#        -includecpp
#             Include Visual C++ runtime libraries
#
#        -includedotnet
#             Include .NET Frameworks: localized installation files
#             and updates
#
#        -includewddefs
#             Virus definition files for Windows Vista and 7. These virus
#             definition files are only compatible with the original
#             Windows Defender, which was included in Windows Vista and 7.
#
#        -includemsse
#             Microsoft Security Essentials: localized installation files
#             and virus definition updates. Microsoft Security Essentials
#             is an optional installation for Windows Vista and 7.
#
#        -includewddefs8
#             Virus definition files for Windows 8 and higher. These
#             are the same virus definition updates as for Microsoft
#             Security Essentials, and they are downloaded to the same
#             directories, but without the localized installers.
#
#             Therefore, "wddefs8" is a subset of "msse", and you should
#             use -includemsse instead for the internal lists "all" and
#             "all-win".

# ========== Formatting ===================================================

# Comments in shell scripts are formatted to a line length of 75
# characters with:
#
# fmt -p "#"
#
# Lists with a hanging indentation can be formatted with the "crown
# margin" option:
#
# fmt -p "#" -c

# ========== Configuration ================================================

# Configuration variables are placed on the top of the script for easy
# customization. They are considered read-only. Other global variables
# are defined in the next section below.
#
# Note: files and directories with relative paths are defined here,
# but they are created later after setting the working directory.
readonly script_version="1.1"
readonly release_date="2018-02-06"
readonly timestamp_dir="../timestamps"
readonly log_dir="../log"
readonly logfile="${log_dir}/download.log"
readonly cache_dir="../cache"

# Create a temporary directory
if type -P mktemp >/dev/null
then
    temp_dir="$(mktemp -d -p "/tmp" download-updates.XXXXXXXXXX)"
else
    temp_dir="/tmp/download-updates.temp"
    mkdir -p "${temp_dir}"
fi
readonly temp_dir

# ========== Preferences  =================================================

# These are the default values. They should not be edited here. Changes
# should be made to the file preferences.bash.

supported_downloaders="wget aria2c"
proxy_server=""
secure_proxy_server=""
no_proxy_server=""

# Boolean options
#
# Use "enabled" or "disabled" for the following options:
prefer_seconly="disabled"
check_for_self_updates="enabled"
unattended_updates="disabled"
include_win_glb="enabled"
use_file_signature_verification="disabled"
use_integrity_database="enabled"
use_cleanup_function="enabled"
debug="disabled"
exit_on_configuration_problems="enabled"

# ========== Global variables =============================================

# Global variables are used in several places. They are usually
# initialized to a default value and filled in later by the script.

kernel_name=""
kernel_details=""
canonical_name=""
script_name=""
home_directory=""
command_line="$0 $*"
command_line_parameters=( "$@" )

# The version of WSUS Offline Update is read from the script
# DownloadUpdates.cmd.
wou_version=""

# ========== Environment variables ========================================

# Setting LC_ALL to C sets LC_COLLATE, LC_CTYPE and LC_MESSAGES to the
# standard locale C. Messages are printed in American English. It is not
# necessary to set the environment variable LANG, and this may actually
# cause an error. See "man grep" for a description.
#
# LC_ALL and LC_COLLATE influence the sort order of GNU sort and join. To
# stabilize the sort order of some files, a traditional sort order using
# byte values should be used by setting LC_ALL=C.
#
# LC_TIME is needed to get locale independent time strings.
export LC_ALL=C
export LC_TIME=C

# Try to get the height and width of the terminal window. These
# environment variables are usually set in interactive sessions, but
# they are not inherited by scripts.
#
# If the script is running within a terminal emulator window, then tput
# can report its dimensions. This does not work, if the script is started
# with "at", "batch" or "env -i", or if it is running as a cron job. An
# example output with an empty environment is:
#
# $ env -i tput cols
# tput: No value for $TERM and no -T specified
# $ echo $?
# 2
if [[ "${TERM}" != "dumb" ]] && type -P tput  > /dev/null
then
    COLUMNS="$(tput cols)" || true
    LINES="$(tput lines)"  || true
fi

# If the variables could not be set with tput, they will be set to
# default values.
COLUMNS="${COLUMNS:-80}"
LINES="${LINES:-24}"
export COLUMNS
export LINES

# ========== Shell options ================================================

set -o nounset
#set -o errexit  # redundant, if a trap on ERR is defined
set -o errtrace  # needed for a trap on ERR to work in functions
set -o pipefail
shopt -s nocasematch

# ========== Traps ========================================================

function error_handler ()
{
    local result_code=$?
    printf '%s\n' "Failure: unhandled error ${result_code}"
    printf '%s\n' "Backtrace: ${FUNCNAME[*]}"

    local output=""
    local depth=0
    while output="$(caller ${depth})"
    do
        printf '%s\n' "Caller ${depth}: ${output}"
        depth="$(( depth + 1 ))"
    done

    exit "${result_code}"
} 1>&2
trap error_handler ERR

function exception_handler ()
{
    local result_code=$?
    echo "Quitting because of Ctrl-C or similar exception ..."
    exit "${result_code}"
} 1>&2
trap exception_handler SIGHUP SIGINT SIGPIPE SIGTERM

function exit_handler ()
{
    local result_code=$?

    if (( result_code == 0 ))
    then
        if [[ -d "${temp_dir}" ]]
        then
            echo "Cleaning up temporary files ..."
            rm -r "${temp_dir}"
        fi
        echo "Exiting..."
    else
        # Keep temporary files for debugging
        printf '%s\n' "Exiting with error code ${result_code}  (temporary files are kept for debugging)..."
    fi

    echo ""
    exit "${result_code}"
} 1>&2
trap exit_handler EXIT

# ========== Functions ====================================================

function trace_on ()
{
    set -o xtrace
}

function trace_off ()
{
    set +o xtrace
}

function check_uid ()
{
    if (( "${UID}" == 0 ))
    then
        echo "This script should not be run as root."
        exit 1
    fi
}

# Normalize the pathname of the script
#
# Possible values for uname -s are from:
#
# - https://en.wikipedia.org/wiki/Uname
# - https://stackoverflow.com/questions/394230/detect-the-os-from-a-bash-script
#
# FreeBSD seems to use many typical GNU utilities, and a version of
# readlink, which is compatible with GNU readlink:
#
# - https://www.freebsd.org/cgi/man.cgi?query=readlink
#
# BSD readlink in Mac OS X is not a full replacement for GNU readlink:
#
# - https://stackoverflow.com/questions/1055671/how-can-i-get-the-behavior-of-gnus-readlink-f-on-a-mac

function setup_working_directory ()
{
    if type -P uname > /dev/null
    then
        kernel_name="$(uname -s)"
        kernel_details="$(uname -a)"
    else
        echo "Unknown operation system"
        exit 1
    fi

    case "${kernel_name}" in
        Linux | FreeBSD)
            canonical_name="$(readlink -f "$0")"
        ;;
        Darwin | NetBSD | OpenBSD)
            # Use greadlink = GNU readlink, if available; otherwise use
            # BSD readlink, which lacks the option -f
            if type -P greadlink > /dev/null
            then
                canonical_name="$(greadlink -f "$0")"
            else
                canonical_name="$(readlink "$0")"
            fi
        ;;
        *)
            echo "Unknown operating system ${kernel_name}, ${OSTYPE}"
            exit 1
        ;;
    esac

    # Change to the home directory of the script
    script_name="$(basename "${canonical_name}")"
    home_directory="$(dirname "${canonical_name}")"
    cd "${home_directory}" || exit 1

    # Create other directories, which may be relative to the script
    # directory
    mkdir -p "${temp_dir}"
    mkdir -p "${timestamp_dir}"
    mkdir -p "${log_dir}"
    mkdir -p "${cache_dir}"
    return 0
}

function read_preferences ()
{
    if [[ -f ./preferences.bash ]]
    then
        source ./preferences.bash
    fi
    return 0
}

# Run all scripts within a certain directory. Filename
# expansion (globbing) is done as suggested in
# http://mywiki.wooledge.org/BashFAQ/004 . This method is slightly
# elaborate, but it avoids some common problems with globbing:
#
# - The filename expansion is done within an indexed array. This is the
#   same format that the shell itself uses for file lists. It ensures,
#   that filenames with spaces or other problematic characters are
#   handled properly.
#
# - If there is no match, then the globbing pattern will be used as is,
#   but this may cause spurious error messages from external commands. For
#   example, "ls *.txt" returns the error message "The file *.txt was
#   not found", if there is no match at all. Such errors may be prevented
#   by temporarily setting the shell variable nullglob.
#
# - The next problem would be, that "ls *.txt" will show all files in the
#   current directory, if there is no match and the shell option nullglob
#   is set. Then the command would be "ls" without any arguments. This
#   can be prevented by iterating through all elements of the array. If
#   the array is empty, then the command will not be called at all.
#
# - Empty arrays are treated as "unset" by the shell, unlike empty
#   strings. If the shell option "nounset" is set, this would cause
#   another error. Testing the length of the array can prevent such
#   errors. This is actually a known bug:
#
#   bash: nounset treats empty array as unset, contrary to man. page
#   https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=529627

function run_scripts ()
{
    local script_directory="$1"
    local -a file_list=()
    local current_script=""

    if [[ -d ./"${script_directory}" ]]
    then
        shopt -s nullglob
        file_list=(./"${script_directory}"/*.bash)
        shopt -u nullglob

        if (( ${#file_list[@]} > 0 ))
        then
            for current_script in "${file_list[@]}"
            do
                # A new script 10-remove-obsolete-scripts.bash was added
                # to the directory common-tasks in version 1.0-beta-3. It
                # may remove obsolete scripts from previous versions. This
                # requires another check, if the files are still present.
                if [[ -f "${current_script}" ]]
                then
                    source "${current_script}"
                fi
            done
        fi
    else
        printf '%s\n' "The script directory ./${script_directory} was not found"
        exit 1
    fi
    return 0
}

# The last function should be a "main" function. But since all top-level
# code is already called "main" in the indexed array "${FUNCNAME[@]}",
# the main function should be called after the script name.

function download_updates ()
{
    check_uid
    setup_working_directory
    read_preferences
    run_scripts "libraries"
    run_scripts "common-tasks"
    run_scripts "download-updates-tasks"
    return 0
}

# ========== Commands =====================================================

# The only top-level code at this point should be a call of the main
# function.

download_updates "$@"
exit 0
