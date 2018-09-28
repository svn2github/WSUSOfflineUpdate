#!/usr/bin/env bash
#
# Filename: copy-to-target.bash
#
# Copyright (C) 2018 Hartmut Buhrmester <zo3xaiD8-eiK1iawa@t-online.de>
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
#
# Usage
#
# ./copy-to-target.bash <update> <destination-directory> [<option> ...]
#
# This script uses rsync to copy the updates from the ../client directory
# to a destination directory, which must be specified on the command
# line. rsync copies all files by default. A filter file is used, to
# exclude certain directories and files from being copied.
#
# The Linux script copy-to-target.bash uses the existing files
# wsusoffline/exclude/ExcludeListUSB-*.txt to create the initial filter
# file, just like the Windows script CopyToTarget.cmd. This way, the
# files ExcludeListUSB-*.txt define the available options for the <update>
# parameter of the script copy-to-target.bash. Supported updates are:
#
#   all           All Windows and Office updates, 32-bit and 64-bit
#   all-x86       All Windows and Office updates, 32-bit
#   all-win-x64   All Windows updates, 64-bit
#   all-ofc       All Office updates, 32-bit and 64-bit
#   wxp-x86       Windows XP, 32-bit                    (ESR version only)
#   w2k3          Windows Server 2003, 32-bit           (ESR version only)
#   w2k3-x64      Windows XP / Server 2003, 64-bit      (ESR version only)
#   w60           Windows Vista / Server 2008, 32-bit
#   w60-x64       Windows Vista / Server 2008, 64-bit
#   w61           Windows 7, 32-bit
#   w61-x64       Windows 7 / Server 2008 R2, 64-bit
#   w62           Windows 8, 32-bit                     (ESR version only)
#   w62-x64       Windows 8 / Server 2012, 64-bit
#   w63           Windows 8.1, 32-bit
#   w63-x64       Windows 8.1 / Server 2012 R2, 64-bit
#   w100          Windows 10, 32-bit                (current version only)
#   w100-x64      Windows 10 / Server 2016, 64-bit  (current version only)
#
# The corresponding files wsusoffline/exclude/ExcludeListUSB-*.txt are:
#
#   all           ExcludeListUSB-all.txt
#   all-x86       ExcludeListUSB-all-x86.txt
#   all-win-x64   ExcludeListUSB-all-x64.txt
#   all-ofc       ExcludeListUSB-ofc.txt
#   wxp-x86       ExcludeListUSB-wxp-x86.txt   (ESR version only)
#   w2k3          ExcludeListUSB-w2k3-x86.txt  (ESR version only)
#   w2k3-x64      ExcludeListUSB-w2k3-x64.txt  (ESR version only)
#   w60           ExcludeListUSB-w60-x86.txt
#   w60-x64       ExcludeListUSB-w60-x64.txt
#   w61           ExcludeListUSB-w61-x86.txt
#   w61-x64       ExcludeListUSB-w61-x64.txt
#   w62           ExcludeListUSB-w62-x86.txt   (ESR version only)
#   w62-x64       ExcludeListUSB-w62-x64.txt
#   w63           ExcludeListUSB-w63-x86.txt
#   w63-x64       ExcludeListUSB-w63-x64.txt
#   w100          ExcludeListUSB-w100-x86.txt  (current version only)
#   w100-x64      ExcludeListUSB-w100-x64.txt  (current version only)
#
# The script copy-to-target.bash is meant to work with both the current
# and the ESR version of WSUS Offline Update, but some updates are only
# supported by the ESR version and vice versa. This is determined by
# the installed files ExcludeListUSB-*.txt.
#
# The files wsusoffline/exclude/ExcludeListUSB-*.txt are used with
# xcopy.exe on Windows. They had to be edited to work with rsync on
# Linux. Therefore, the Linux script copy-to-target.bash now uses an
# own set of these files in the directory wsusoffline/sh/exclude.
#
# The differences are:
#
# Windows:
# - Back-slashes are separators in pathnames.
# - Filters are case insensitive.
# - xcopy doesn't use shell patterns. This seems to cause some
#   ambiguities: The file wsusoffline/client/bin/IfAdmin.cpp is excluded,
#   if .NET Frameworks are excluded. This is due to the interpretation
#   of the file ExcludeListISO-dotnet.txt by xcopy.exe. The line "cpp\"
#   matches both the directory "cpp" (as expected) and the source file
#   IfAdmin.cpp.
#
# Linux:
# - Forward slashes are separators in pathnames.
# - Filters are case sensitive: both ndp46 and NDP46, ndp472 and NDP472
#   are needed.
# - rsync supports shell patterns like "*", which are added as
#   needed. For example, service packs are excluded with the file
#   wsusoffline/exclude/ExcludeList-SPs.txt. This file contains
#   kb numbers and other unique identifiers, but not the complete
#   filenames. Therefore, the filters had to be enclosed in asterisks like
#   "*KB914961*".
# - File paths are constructed differently with rsync than with mkisofs
#   or xcopy.exe. To exclude the directory client/cpp, the filter should
#   be written as "/cpp", like an absolute path with the source directory
#   as the root of the filesystem.
#
#
# Compared to the Windows script CopyToTarget.cmd, some options
# were renamed to match those of the Linux download script
# download-updates.bash:
#
# - The option "all-x64" was renamed to "all-win-x64", because it only
#   includes Windows updates, but no Office updates.
# - The option "ofc" was renamed to "all-ofc".
#
#
# Finally, some of the private exclude lists were renamed to better
# match the command line parameters of the script copy-to-target.bash:
#
#   ExcludeListUSB-all-x64.txt   -->  ExcludeListUSB-all-win-x64.txt
#   ExcludeListUSB-ofc.txt       -->  ExcludeListUSB-all-ofc.txt
#   ExcludeListUSB-w60-x86.txt   -->  ExcludeListUSB-w60.txt
#   ExcludeListUSB-w61-x86.txt   -->  ExcludeListUSB-w61.txt
#   ExcludeListUSB-w63-x86.txt   -->  ExcludeListUSB-w63.txt
#   ExcludeListUSB-w100-x86.txt  -->  ExcludeListUSB-w100.txt
#
#
# The Linux script copy-to-target.bash handles two options differently
# than the Windows script CopyToTarget.cmd:
#
# - /excludesp is replaced with -includesp.
#
#   This is consistent with both download scripts DownloadUpdates.cmd
#   and download-updates.bash.
#
# - /includedotnet is replaced with -includecpp -includedotnet.
#
#   The option /includedotnet of the Windows script includes both .NET
#   Frameworks and Visual C++ Runtime Libraries. These downloads don't
#   necessarily depend on each other, and previous versions of WSUS
#   Offline Update handled them separately.
#
#
# The built-in Defender of Windows 8 and higher uses the same virus
# definitions as Microsoft Security Essentials, but the installers for
# MSE are not needed. The Linux download script download-updates.bash
# has a separate option -includewddefs8, which will download the
# virus definitions for Microsoft Security Essentials, but omit the
# MSE installers.
#
# The script copy-to-target.bash doesn't have this separate option,
# and -includemsse should be used instead. MSE installers, if present,
# are excluded with the filter files ExcludeListUSB-w62.txt and higher.
#
#
# The Linux script copy-to-target.bash doesn't support the mode "per
# language". This was most useful for Windows XP and Server 2003, because
# they used localized Windows updates. All Windows versions since Vista
# use global/multilingual updates, and all Office updates are always
# lumped together, with most updates in the directory client/ofc/glb. Then
# the distinction by language is not needed anymore.
#
#
# Known differences in the results:
#
# 1. The original file wsusoffline/exclude/ExcludeListISO-w60-x86.txt
#    misses an entry for vcredist2017_x64.exe. This means, that this
#    file is not excluded by the Windows script, if the update "w60"
#    is selected.
#
# 2. The file wsusoffline/client/bin/IfAdmin.cpp is only excluded by the
#    Windows script CopyToTarget.cmd, if the option /includedotnet is NOT
#    used. Then the file wsusoffline/exclude/ExcludeListISO-dotnet.txt
#    is appended to the filter file. With xcopy.exe, the line "cpp\"
#    matches both the directory "cpp" (as expected) and the source file
#    "IfAdmin.cpp".
#
#    But the file IfAdmin.cpp is neither needed for download nor for
#    installation, and it should always be excluded. It is only included
#    in WSUS Offline Update, because the GPL demands, that the source
#    code of all utilities should be made available somewhere.
#
#
# This script uses associative arrays to simplify some things. It was
# successfully tested with:
#
# - Bash version 4.1.5 on Debian 6.0.10 Sqeeze
# - Bash version 4.3.30 on Debian 8.11 Jessie
# - Bash version 4.4.12 on Debian 9.5 Stretch

# ========== Shell options ================================================

set -o errexit
set -o nounset
set -o pipefail
shopt -s nocasematch

# ========== Global variables =============================================

source_directory="../client/"
destination_directory=""
link_directory="(unused)"
update=""
selected_excludelist=""
logfile="../log/copy-to-target.log"

declare -A option=(
    ["sp"]="disabled"
    ["cpp"]="disabled"
    ["dotnet"]="disabled"
    ["wddefs"]="disabled"
    ["msse"]="disabled"
)
filter_file=""

# rsync supports different methods to handle symbolic links. For backup
# purposes, the combination "--links --safe-links" works best, because
# it simply copies symbolic links unchanged. To create a working copy of
# the client directory, is seems to be more useful, to resolve symbolic
# links and copy the original files and folders instead.
#
rsync_parameters=( --recursive --copy-links --owner --group --perms
                   --times --verbose --stats --human-readable )

# ========== Functions ====================================================

function show_usage ()
{
    log_info_message "Usage:
./copy-to-target.bash <update> <destination-directory> [<option> ...]

The update can be one of:
    all           All Windows and Office updates, 32-bit and 64-bit
    all-x86       All Windows and Office updates, 32-bit
    all-win-x64   All Windows updates, 64-bit
    all-ofc       All Office updates, 32-bit and 64-bit
    wxp           Windows XP, 32-bit                    (ESR version only)
    w2k3          Windows Server 2003, 32-bit           (ESR version only)
    w2k3-x64      Windows XP / Server 2003, 64-bit      (ESR version only)
    w60           Windows Vista / Server 2008, 32-bit
    w60-x64       Windows Vista / Server 2008, 64-bit
    w61           Windows 7, 32-bit
    w61-x64       Windows 7 / Server 2008 R2, 64-bit
    w62           Windows 8, 32-bit                     (ESR version only)
    w62-x64       Windows 8 / Server 2012, 64-bit
    w63           Windows 8.1, 32-bit
    w63-x64       Windows 8.1 / Server 2012 R2, 64-bit
    w100          Windows 10, 32-bit                (current version only)
    w100-x64      Windows 10 / Server 2016, 64-bit  (current version only)

The destination directory is the directory, to which files are copied
or hard-linked. It should be specified without a trailing slash, because
otherwise rsync may create an additional directory within the destination
directory.

The options are:
    -includesp         Include service packs
    -includecpp        Include Visual C++ Runtime Libraries
    -includedotnet     Include .NET Frameworks
    -includewddefs     Include Windows Defender virus definitions for
                       the built-in Defender of Windows Vista and 7.
    -includemsse       Include Microsoft Security Essentials. The virus
                       definitions are also used for the built-in Defender
                       of Windows 8, 8.1 and 10.
    -cleanup           Tell rsync to delete obsolete files from included
                       directories. This does not delete excluded files
                       or directories.
    -delete-excluded   Tell rsync to delete obsolete files from included
                       directories and also all excluded files and
                       directories. Use this option with caution,
                       e.g. try it with the option -dryrun first.
    -hardlink <dir>    Create hard links instead of copying files. The
                       link directory should be specified with an
                       absolute path, otherwise it will be relative to
                       the destination directory. The link directory
                       and the destination directory must be on the same
                       file system.
    -dryrun            Run rsync without copying or deleting
                       anything. This is useful for testing.
"
    return 0
}


function check_requirements ()
{
    if ! type -P rsync >/dev/null
    then
        printf '%s\n' "Please install the package rsync"
        exit 1
    fi

    return 0
}


function setup_working_directory ()
{
    local kernel_name=""
    local canonical_name=""
    #local script_name=""
    local home_directory=""

    if type -P uname >/dev/null
    then
        kernel_name="$(uname -s)"
    else
        printf '%s\n' "Unknown operation system"
        exit 1
    fi

    case "${kernel_name}" in
        Linux | FreeBSD)
            canonical_name="$(readlink -f "$0")"
        ;;
        Darwin | NetBSD | OpenBSD)
            # Use greadlink = GNU readlink, if available; otherwise use
            # BSD readlink, which lacks the option -f
            if type -P greadlink >/dev/null
            then
                canonical_name="$(greadlink -f "$0")"
            else
                canonical_name="$(readlink "$0")"
            fi
        ;;
        *)
            printf '%s\n' "Unknown operating system ${kernel_name}"
            exit 1
        ;;
    esac

    # Change to the home directory of the script
    #script_name="$(basename "${canonical_name}")"
    home_directory="$(dirname "${canonical_name}")"
    cd "${home_directory}" || exit 1

    return 0
}


function import_libraries ()
{
    source ./libraries/dos-files.bash
    source ./libraries/messages.bash

    return 0
}


function parse_command_line ()
{
    local next_parameter=""
    local option_name=""

    log_info_message "Starting script copy-to-target.bash ..."
    log_info_message "Command line: ${0} $*"

    if (( $# < 2 ))
    then
        log_error_message "At least two parameters are required."
        show_usage
        exit 1
    else
        log_info_message "Parsing command line..."

        # Parse first parameter
        update="${1}"
        case "${update}" in
            #
            # These are all known parameters. Some will only be available
            # in the current version or in the ESR version of WSUS
            # Offline Update.
            #
            all | all-x86 | all-win-x64 | all-ofc \
            | wxp | w2k3 | w2k3-x64 \
            | w60 | w60-x64 | w61 | w61-x64 | w62 | w62-x64 \
            | w63 | w63-x64 | w100 | w100-x64)
                #
                # Note, that the script uses its own copies of the
                # exclude lists, because the filters had to be edited
                # to be compatible with rsync.
                #
                # These files are also renamed to match the command
                # line parameters.
                #
                if [[ -f "./exclude/ExcludeListUSB-${update}.txt" ]]
                then
                    log_info_message "Found update ${update}"
                    selected_excludelist="ExcludeListUSB-${update}.txt"
                else
                    log_error_message "The update ${update} is not supported in this version of WSUS Offline Update."
                    exit 1
                fi
            ;;
            *)
                log_error_message "Update ${update} is not recognized"
                show_usage
                exit 1
            ;;
        esac

        # Parse second parameter
        destination_directory="${2}"

        # Parse remaining parameters
        shift 2
        while (( $# > 0 ))
        do
            next_parameter="${1}"
            case "${next_parameter}" in
                -includesp)
                    log_info_message "Found option -includesp"
                    option[sp]="enabled"
                ;;
                -includecpp | -includedotnet | -includemsse)
                    if [[ "${update}" == "all-ofc" ]]
                    then
                        log_warning_message "Option ${next_parameter} is ignored for update all-ofc"
                    else
                        log_info_message "Found option ${next_parameter}"
                        # Strip the prefix "-include"
                        option_name="${next_parameter/#-include/}"
                        option["${option_name}"]="enabled"
                    fi
                ;;
                -includewddefs)
                    case "${update}" in
                        all-ofc)
                            log_warning_message "Option -includewddefs is ignored for update all-ofc"
                        ;;
                        w62 | w62-x64 | w63 | w63-x64 | w100 | w100-x64)
                            log_warning_message "Option -includewddefs is ignored for Windows 8 and higher. Use -includemsse instead."
                        ;;
                        *)
                            log_info_message "Found option -includewddefs"
                            option["wddefs"]="enabled"
                        ;;
                    esac
                ;;
                -cleanup)
                    log_info_message "Found option -cleanup"
                    #
                    # The rsync option --delete removes obsolete files
                    # from the included directories. It does not remove
                    # excluded files or directories. If this is needed,
                    # then the option --delete-excluded must also be used.
                    #
                    rsync_parameters+=( --delete )
                ;;
                -delete-excluded)
                    #
                    # Delete all excluded files and folder. This should
                    # be used with caution: If, for example, the update
                    # is "w60", then all other Windows versions will
                    # be deleted.
                    #
                    # This option may be needed to solve some problems:
                    # If service packs are included with -includesp,
                    # they won't be deleted again by simply omitting this
                    # option. Service packs are explicitly excluded with
                    # the file wsusoffline/exclude/ExcludeList-SPs.txt,
                    # and such files are not deleted with the rsync
                    # option --delete; it needs the second option
                    # --delete-excluded as well.
                    #
                    # The results should be tested first with the
                    # dryrun option.
                    #
                    log_info_message "Found option -delete-excluded"
                    rsync_parameters+=( --delete --delete-excluded )
                ;;
                -hardlink)
                    log_info_message "Found option -hardlink"
                    #
                    # The link directory should be specified with an
                    # absolute path. If the link directory is a relative
                    # path, it will be relative to the destination
                    # directory.
                    #
                    shift 1
                    if (( $# > 0 ))
                    then
                        link_directory="${1}"
                    else
                        log_error_message "The link directory was not specified"
                        exit 1
                    fi
                    rsync_parameters+=( "--link-dest=${link_directory}" )
                ;;
                -dryrun)
                    log_info_message "Found option -dryrun"
                    rsync_parameters+=( --dry-run )
                ;;
                *)
                    log_error_message "Parameter ${next_parameter} is not recognized"
                    show_usage
                    exit 1
                ;;
            esac
            shift 1
        done
    fi
    echo ""
    return 0
}


function print_summary ()
{
    log_info_message "Summary after parsing command-line"
    log_info_message "- Destination directory: ${destination_directory}"
    log_info_message "- Link directory: ${link_directory}"
    log_info_message "- Update: ${update}"
    log_info_message "- Selected exclude list: ${selected_excludelist}"
    log_info_message "- Options: $(declare -p option)"

    echo ""
    return 0
}


function create_filter_file ()
{
    local line=""
    local option_name=""

    log_info_message "Creating filter file for rsync..."
    if type -P mktemp >/dev/null
    then
        filter_file="$(mktemp -p "/tmp" copy-to-target.XXXXXXXXXX)"
    else
        filter_file="/tmp/copy-to-target.temp"
        touch "${filter_file}"
    fi

    # Copy the selected file ./exclude/ExcludeListUSB-*.txt
    #
    log_info_message "Copying ${selected_excludelist} ..."
    cat_dos "./exclude/${selected_excludelist}" >> "${filter_file}"

    # Service packs
    #
    if [[ "${option[sp]}" == "enabled" ]]
    then
        log_info_message "Service Packs are included"
    else
        log_info_message "Service Packs are excluded"
        if [[ -f "../exclude/ExcludeList-SPs.txt" ]]
        then
            log_info_message "Appending ExcludeList-SPs.txt ..."
            while read -r line
            do
                #
                # Add shell pattern around the lines for rsync, because
                # only the kb numbers are listed.
                #
                printf '%s\n' "*${line}*" >> "${filter_file}"
            done < <(cat_dos "../exclude/ExcludeList-SPs.txt")
        else
            log_error_message "File ../exclude/ExcludeList-SPs.txt was not found."
            exit 1
        fi
    fi

    # Included downloads
    #
    for option_name in cpp dotnet wddefs msse
    do
        if [[ "${option[${option_name}]}" == "enabled" ]]
        then
            log_info_message "Directory ${option_name} is included"
        else
            log_info_message "Excluding directory ${option_name} ..."
            #
            # Excluded directories are specified with the source directory
            # as the root of the path, e.g. "/cpp", "/dotnet", "/msse",
            # "/wddefs". There should be no shell pattern before or
            # after the directory name.
            #
            printf '%s\n' "/${option_name}" >> "${filter_file}"
        fi
    done

    # Add filter to the command-line options
    #
    rsync_parameters+=( "--exclude-from=${filter_file}" )

    echo ""
    return 0
}


function call_rsync ()
{
    log_info_message "Calling rsync..."
    mkdir -p "${destination_directory}"
    rsync "${rsync_parameters[@]}" "${source_directory}" "${destination_directory}"

    # TODO: enable log file for rsync?
    return 0
}


function remove_filter_file ()
{
    rm -f "${filter_file}"
}


# The main function is called after the script name.
#
function copy_to_target ()
{
    check_requirements
    setup_working_directory
    import_libraries
    parse_command_line "$@"
    print_summary
    create_filter_file
    call_rsync
    remove_filter_file

    return 0
}

# ========== Commands =====================================================

copy_to_target "$@"
exit 0
