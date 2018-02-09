# This file will be sourced by the shell bash.
#
# Filename: cleanup-client-directories.bash
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
#     The cleanup function removes old downloads, which are not available
#     anymore. If a trash-handler like gvfs-trash or trash-cli is found,
#     obsolete files will be put into the trash, rather than deleted
#     directly.
#
#     The function uses the concept of download sets, which is the sum
#     of static and dynamic updates: All files in the current download
#     set will be kept.
#
#     In addition, files, which are not in the current download set,
#     but which are still referenced from within the static directory,
#     will also be preserved. These files are considered "valid static
#     files". This was introduced to allow different languages to be
#     downloaded to the same directory in turn.
#
#     The same mechanism also prevents the deletion of some other files,
#     which are still valid, but not in the current download set:
#
#     - Service packs, if the option -includesp is missing
#
#     - 64-bit Office Updates, if only 32-bit updates are selected
#
#     - Installers for Microsoft Security Essentials, if virus definition
#       updates for Windows 8 are selected
#
#     Generally, this situation may occur, whenever different sets of
#     files are downloaded to the same directory.
#
#     If these "valid static files" are not needed anymore, they must
#     be deleted manually once, and then they won't get downloaded again.

# ========== Functions ====================================================

function cleanup_client_directory ()
{
    local download_dir="$1"
    local valid_static_links="$2"
    local valid_dynamic_links="$3"
    local valid_links="$4"
    local -a file_list=()
    local pathname=""
    local filename=""

    # Preconditions
    if [[ "${use_cleanup_function}" == "disabled" ]]
    then
        log_info_message "Cleanup of client directories is disabled in preferences.bash"
        return 0
    fi
    if ! require_directory "${download_dir}"
    then
        log_warning_message "Aborted cleanup of client directory, because the directory ${download_dir} does not exist"
        return 0
    fi

    log_info_message "Cleaning up download directory ${download_dir} ..."

    # For the included downloads, there are no dynamic links, and
    # ${valid_links} is the same as ${valid_static_links}
    #
    # For the main updates, ${valid_links} is the sum of
    # ${valid_static_links} and ${valid_dynamic_links}. This is also
    # called the "download set".
    #
    # Either of the input files may be empty:
    # - Static download links are mostly service packs and other
    #   installers, which may be excluded from the download.
    # - Dynamic update links are not calculated for some download targets.

    if [[ "${valid_dynamic_links}" == "not-available" && "${valid_static_links}" == "${valid_links}" ]]
    then
        log_debug_message "Cleanup only static links"
    else
        log_debug_message "Cleanup both static and dynamic links"
        # Reset output file
        > "${valid_links}"
        if require_non_empty_file "${valid_static_links}"
        then
            cat "${valid_static_links}" >> "${valid_links}"
        fi
        if require_non_empty_file "${valid_dynamic_links}"
        then
            cat "${valid_dynamic_links}" >> "${valid_links}"
        fi
    fi
    if [[ ! -s "${valid_links}" ]]
    then
        log_warning_message "The current download set is empty"
        # If the download set is empty, any existing files should be
        # removed and the empty directory should be deleted. This may
        # happen for some static downloads, if the option -include_sp
        # is not used. Then this is not an error.
        #
        # However, as long as service packs are referenced from the
        # static directory, they will be treated as "valid static files"
        # and not deleted.
    fi

    # Building file list as suggested in
    # http://mywiki.wooledge.org/BashFAQ/004
    shopt -s nullglob
    file_list=("${download_dir}"/*.*)
    shopt -u nullglob

    if (( ${#file_list[@]} > 0 ))
    then
        for pathname in "${file_list[@]}"
        do
            filename="${pathname##*/}"

            # Keep files, which are in the current download set
            if [[ -s "${valid_links}" ]]
            then
                if grep -F -i -q "${filename}" "${valid_links}"
                then
                    continue
                fi
            fi

            # The cleanup function keeps updates, which are not in the
            # current download set, but which are still referenced from
            # the ../static directory. These files are considered "valid
            # static files".
            #
            # It is necessary to keep these files, if different languages
            # are downloaded to the same directory.
            #
            # Valid static files can only be deleted manually.
            if grep -F -i -q -r "${filename}" "../static"
            then
                if [[ "${pathname}" == "../client/ofc/glb/office2010-kb2553065-fullfile-x86-glb.exe" && -f "../client/o2k10/glb/office2010-kb2553065-fullfile-x86-glb.exe" ]]
                then
                    # The file office2010-kb2553065-fullfile-x86-glb.exe
                    # was moved from ../client/ofc/glb to
                    # ../client/o2k10/glb in WSUS Offline Update 11.1. If
                    # it appears twice, it should be deleted from the
                    # former location.
                    log_info_message "The file office2010-kb2553065-fullfile-x86-glb.exe will be deleted from directory ../client/ofc/glb"
                else
                    log_info_message "Kept valid static file ${filename}"
                    continue
                fi
            fi

            # Any remaining files are considered obsolete and will be
            # put into trash or deleted.
            log_info_message "Trashing/deleting obsolete file ${filename} ..."
            trash_file "${pathname}"
        done
    fi

    # Empty download directories should be removed after cleanup. A new
    # file list is created, which includes both files and directories
    # to handle the nested dotnet directories correctly.
    shopt -s nullglob
    file_list=("${download_dir}"/*)
    shopt -u nullglob

    if (( ${#file_list[@]} == 0 ))
    then
        rmdir "${download_dir}"
        log_warning_message "Deleted download directory ${download_dir}, because it was empty"
    else
        log_info_message "Cleaned up download directory"
    fi
    return 0
}
return 0
