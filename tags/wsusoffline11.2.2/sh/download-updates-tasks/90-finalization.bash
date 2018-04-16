# This file will be sourced by the shell bash.
#
# Filename: 90-finalization.bash
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
#     This file does final tasks after running all updates: convert text
#     files to DOS format, show the disk usage of all downloads and the
#     number of runtime errors.

# ========== Functions ====================================================

# unzip is needed by the installation part of WSUS Offline Update,
# to unpack two archives for Windows 7:
#
# ../client/w61/glb/Win7-KB3191566-x86.zip
# ../client/w61-x64/glb/Win7AndW2K8R2-KB3191566-x64.zip

function copy_unzip ()
{
    cp -u "../bin/unzip.exe" "../client/bin/"
}


function remind_build_date ()
{
    local build_date=""

    # The date should be in an international format like 2015-11-26, also
    # known as RFC-3339. GNU date could use the option --rfc-3339=date,
    # but a traditional date string may be more compatible.
    build_date="$(date '+%Y-%m-%d')"

    # Remove existing files first, instead of overwriting, if hard links
    # are used for backups or snapshots of the client directory
    rm -f "../client/builddate.txt"
    rm -f "../client/autorun.inf"
    rm -f "../client/Autorun.inf"

    log_info_message "Reminding build date..."
    printf '%s\r\n' "${build_date}" > "../client/builddate.txt"

    log_info_message "Creating autorun.inf file..."
    {
        printf '%s\r\n' "[autorun]"
        printf '%s\r\n' "open=UpdateInstaller.exe"
        printf '%s\r\n' "icon=UpdateInstaller.exe,0"
        printf '%s\r\n' "action=Run WSUS Offline Update v. ${wou_version} (${build_date})"
    } > "../client/autorun.inf"
    echo ""
    return 0
}


function adjust_update_installer_preferences ()
{
    log_info_message "Adjusting UpdateInstaller.ini file..."
    if [[ -f ../client/UpdateInstaller.ini ]]
    then
        if [[ "${prefer_seconly}" == enabled ]] && grep -F -i -q "seconly=Disabled" ../client/UpdateInstaller.ini
        then
            log_info_message "Option seconly in UpdateInstaller.ini will be changed to Enabled"
            sed -i 's/seconly=Disabled/seconly=Enabled/g' ../client/UpdateInstaller.ini
        elif [[ "${prefer_seconly}" == disabled ]] && grep -F -i -q "seconly=Enabled" ../client/UpdateInstaller.ini
        then
            log_info_message "Option seconly in UpdateInstaller.ini will be changed to Disabled"
            sed -i 's/seconly=Enabled/seconly=Disabled/g' ../client/UpdateInstaller.ini
        else
            log_info_message "Nothing to do"
        fi
    else
        log_warning_message "File ../client/UpdateInstaller.ini was not found"
    fi
    log_info_message "Adjusted UpdateInstaller.ini file"
    echo ""
    return 0
}


function print_disk_usage ()
{
    log_info_message "Disk usage of the client directory:"
    find -L "../client" -maxdepth 1 -type d |
        sort |
        xargs -L1 du -L -h -s |
        tee -a "${logfile}"

    echo ""
    return 0
}


function print_summary ()
{
    log_info_message "Summary"
    if same_error_count "0"
    then
        log_info_message "Download and file verification errors: 0"
    else
        log_warning_message "Download and file verification errors: $(get_error_count)"
    fi
    return 0
}

# ========== Commands =====================================================

copy_unzip
remind_build_date
adjust_update_installer_preferences
print_disk_usage
print_summary

return 0
