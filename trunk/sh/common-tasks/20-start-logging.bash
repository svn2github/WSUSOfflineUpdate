# This file will be sourced by the shell bash.
#
# Filename: 20-start-logging.bash
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
#     Start logging and write some information about the system and
#     environment, which may be useful for debugging.

# ========== Functions ====================================================

# The formatted string for the WSUS Offline Update version is extracted
# from the file DownloadUpdates.cmd.
function set_wou_version ()
{
    if  wou_version="$(grep_dos -F -- "set WSUSOFFLINE_VERSION=" ../cmd/DownloadUpdates.cmd)"; then
        wou_version="${wou_version/set WSUSOFFLINE_VERSION=/}"
    else
        wou_version="not-available"
    fi
    return 0
}

function create_logfile ()
{
    if [[ -f "$logfile" ]]; then
        {
            echo ""
            echo "--------------------------------------------------------------------------------"
            echo ""
        } >> "$logfile"
    else
        touch "$logfile"
    fi
    return 0
}

function print_info_block ()
{
    local linux_details=""

    echo ""
    log_info_message "Starting $script_name $script_version ($release_date)"
    log_info_message "Running on WSUS Offline Update version $wou_version"
    if [[ -f ../client/builddate.txt ]]; then
        log_info_message "Repository last updated on $(cat_dos ../client/builddate.txt)"
    fi

    # The command lsb_release is installed on Debian with the package
    # lsb-release. Although the Linux Standard Base is not supported
    # anymore by Debian, lsb_release is still useful by itself, to get
    # information about the Linux distribution.
    if type -P lsb_release > /dev/null; then
        linux_details="$(lsb_release --all 2> /dev/null)"
    else
        linux_details="not-available"
    fi

    # The logfile includes an info block about the Kernel, Linux
    # distribution and environment. This is only for reference and not
    # displayed in the terminal window.
    {
        printf '%s\n' "Local time:     $(date -R)"     # RFC 2822 format
        printf '%s\n' "OS type:        ${OSTYPE}"      # as identified by bash and exported as an environment variable
        printf '%s\n' "Kernel name:    ${kernel_name}" # as identified by uname
        printf '%s\n' "Kernel details: ${kernel_details}"
        echo ""
        printf '%s\n' "Linux distribution" "${linux_details}"
        echo ""
        printf '%s\n' "Environment" "LC_ALL=${LC_ALL:-}" \
                      "LC_COLLATE=${LC_COLLATE:-}" "LC_CTYPE=${LC_CTYPE:-}" \
                      "LC_MESSAGES=${LC_MESSAGES:-}" "LANG=${LANG:-}"
        echo ""
        printf '%s\n' "Command line:      ${command_line}"
        printf '%s\n' "Canonical name:    ${canonical_name}"
        printf '%s\n' "Script name:       ${script_name}"
        printf '%s\n' "Home directory:    ${home_directory}"
        printf '%s\n' "Working directory: $(pwd)"
        printf '%s\n' "prefer_seconly:    ${prefer_seconly}"
    } >> "${logfile}"
    return 0
}

# ========== Commands =====================================================

set_wou_version
create_logfile
print_info_block
echo ""
return 0
