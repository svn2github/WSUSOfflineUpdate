# This file will be sourced by the shell bash.
#
# Filename: 20-get-sysinternals-helpers.bash
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
#     This task downloads and installs the Sysinternals utilities Sigcheck
#     and Autologon.
#
#     Sigcheck may be used under wine to check the digital file
#     signatures, but this requires the necessary root certificates and
#     all certificate chains to be installed. This doesn't work so far.
#
#     Autologon is used during the installation of the updates.
#
#     The Windows script DownloadUpdates.cmd uses a third utility Streams,
#     which removes alternate data streams on NTFS volumes, but this is
#     not needed for Linux.


# ========== Global variables =============================================

# The variable sigcheck_bin must be global, because it is used in the
# file digital-file-signatures.bash
sigcheck_bin="sigcheck.exe"

# ========== Functions ====================================================

function get_sysinternals_helpers ()
{
    # It is recommended to use two steps to define a local variable and
    # to assign a value with a command substitution, because otherwise,
    # the built-in command "local" would mask the return code of the
    # command substitution.
    local autologon_link=""
    autologon_link="$(grep_dos -F -i autologon.zip ../static/StaticDownloadLinks-sysinternals.txt)" || true
    # Use a secure connection, because we can.
    local autologon_link="${autologon_link/http:/https:}"
    local autologon_archive="${autologon_link##*/}"
    local autologon_bin="Autologon.exe"

    local sigcheck_link=""
    sigcheck_link="$(grep_dos -F -i sigcheck.zip ../static/StaticDownloadLinks-sysinternals.txt)" || true
    local sigcheck_link="${sigcheck_link/http:/https:}"
    local sigcheck_archive="${sigcheck_link##*/}"

    local -i initial_errors="0"
    initial_errors="$(get_error_count)"

    log_info_message "Searching Sysinternals helper applications Autologon and Sigcheck..."

    # Get Sysinternals Autologon
    if [[ -f "../client/bin/${autologon_bin}" ]]
    then
        log_info_message "Found ../client/bin/${autologon_bin}"
    else
        log_info_message "Downloading and installing Sysinternals Autologon.exe ..."
        download_single_file "../client/bin" "${autologon_link}"
        if same_error_count "${initial_errors}"
        then
            log_info_message "Extracting Sysinternals Autologon.exe ..."
            if unzip "../client/bin/${autologon_archive}" "${autologon_bin}" -d "../client/bin"
            then
                log_info_message "Trashing/deleting archive ${autologon_archive} ..."
                trash_file "../client/bin/${autologon_archive}"
                log_info_message "Installed Sysinternals Autologon.exe"
            else
                log_error_message "Extracting Autologon.exe failed"
            fi
        else
            log_error_message "Download of Autologon.exe failed"
        fi
        echo ""
    fi
    #echo ""

    # Get Sysinternals Sigcheck
    initial_errors="$(get_error_count)"
    if [[ -f "../bin/${sigcheck_bin}" ]]
    then
        log_info_message "Found ../bin/${sigcheck_bin}"
    else
        log_info_message "Downloading and installing Sysinternals sigcheck.exe ..."
        download_single_file "../bin" "${sigcheck_link}"
        if same_error_count "${initial_errors}"
        then
            log_info_message "Extracting Sysinternals sigcheck.exe ..."
            if unzip "../bin/${sigcheck_archive}" "${sigcheck_bin}" -d "../bin"
            then
                log_info_message "Trashing/deleting archive ${sigcheck_archive} ..."
                trash_file "../bin/${sigcheck_archive}"
                log_info_message "Installed Sysinternals sigcheck.exe"
            else
                log_error_message "Extracting sigcheck.exe failed"
            fi
        else
            log_error_message "Download of sigcheck.exe failed"
        fi
    fi
    echo ""
    return 0
}

# ========== Commands =====================================================

get_sysinternals_helpers
return 0
