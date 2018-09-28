# This file will be sourced by the shell bash.
#
# Filename: 10-parse-command-line.bash
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


# ========== Global variables =============================================

language_parameter="" # as passed on the command-line

updates_list=()
architectures_list=()
languages_list=()
downloads_list=( "wsus" )

include_service_packs="disabled"

# ========== Functions ====================================================

function parse_command_line ()
{
    log_info_message "Parsing command-line..."
    if (( ${#command_line_parameters[@]} < 2 ))
    then
        wrong_parameter "At least two parameters are required."
    else
        parse_first_parameter_as_list "${command_line_parameters[@]}"
        parse_preliminary_update_list
        parse_second_parameter_as_list "${command_line_parameters[@]}"
        parse_remaining_parameters "${command_line_parameters[@]}"
        print_command_line_summary
    fi
    return 0
}


function wrong_parameter ()
{
    log_error_message "$@"
    show_usage
    exit 1
} 1>&2


function parse_first_parameter_as_list ()
{
    local first_parameter="$1"
    local current_update=""

    # The first parameter may be a comma-separated list, which is split
    # into an indexed array. Internal lists are expanded at this step.
    log_info_message "Parsing first parameter..."
    for current_update in ${first_parameter//,/ }
    do
        case "${current_update}" in
            # Internal lists
            all)
                log_info_message "Expanding internal list: All Windows and Office updates, 32-bit and 64-bit"
                updates_list+=( "${list_all[@]}" )
            ;;
            all-x86)
                log_info_message "Expanding internal list: All Windows and Office updates, 32-bit"
                updates_list+=( "${list_all_x86[@]}" )
            ;;
            all-x64)
                log_info_message "Expanding internal list: All Windows and Office updates, 64-bit"
                updates_list+=( "${list_all_x64[@]}" )
            ;;
            all-win)
                log_info_message "Expanding internal list: All Windows updates, 32-bit and 64-bit"
                updates_list+=( "${list_all_win[@]}" )
            ;;
            all-win-x86)
                log_info_message "Expanding internal list: All Windows updates, 32-bit"
                updates_list+=( "${list_all_win_x86[@]}" )
            ;;
            all-win-x64)
                log_info_message "Expanding internal list: All Windows updates, 64-bit"
                updates_list+=( "${list_all_win_x64[@]}" )
            ;;
            all-ofc)
                log_info_message "Expanding internal list: All Office updates, 32-bit and 64-bit"
                updates_list+=( "${list_all_ofc[@]}" )
            ;;
            all-ofc-x86)
                log_info_message "Expanding internal list: All Office updates, 32-bit"
                updates_list+=( "${list_all_ofc_x86[@]}" )
            ;;
            # Single updates
            #
            # This step lists all known updates from all versions of
            # WSUS Offline Update, but the ${updates_table} determines
            # the valid updates for a particular version.
            wxp | w2k3 | w2k3-x64 | w60 | w60-x64 | w61 | w61-x64 | w62 | w62-x64 | w63 | w63-x64 | w100 | w100-x64 | o2k3 | o2k7 | o2k10 | o2k10-x64 | o2k13 | o2k13-x64 | o2k16 | o2k16-x64)
                # To avoid ambiguities, the search pattern must be
                # anchored to the beginning of the line and also include
                # a trailing space.
                if grep -q -- "^${current_update} " <<< "${updates_table}"
                then
                    log_info_message "Adding \"${current_update}\" to the list of updates..."
                    updates_list+=( "${current_update}" )
                else
                    log_warning_message "Update ${current_update} is not supported by this version of WSUS Offline Update."
                fi
            ;;
            # Unknown or unsupported updates
            *)
                wrong_parameter "Update ${current_update} was not found."
            ;;
        esac
    done
    echo ""
}


# Parse the preliminary list of updates to add common updates for Windows
# and Office (win and ofc), and to build a list of needed architectures.
#
# The architectures list is needed for the optional downloads wddefs,
# msse, wddefs8 and dotnet. They must be downloaded in 32-bit, 64-bit,
# or both. The selected Windows versions determine, which architectures
# are needed.

function parse_preliminary_update_list ()
{
    local current_update=""
    local update_record=""
    local update_name=""
    local update_description=""
    local need_x86="disabled"
    local need_x64="disabled"
    local need_win="disabled"
    local need_ofc="disabled"

    log_info_message "Parsing preliminary list of updates..."
    for current_update in "${updates_list[@]}"
    do
        # Print the update name and description for reference. The update
        # name was already validated at the previous step.
        #
        # To avoid ambiguities, the search pattern must be anchored to
        # the beginning of the line and also include a trailing space.
        if update_record="$(grep -- "^${current_update} " <<< "${updates_table}")"
        then
            read -r update_name update_description <<< "${update_record}"
            log_info_message "Found update: ${update_name}, ${update_description}"
        else
            wrong_parameter "Update ${current_update} was not found."
        fi

        # Determine the common updates to add:
        # - win for all Windows updates
        # - ofc for all Office updates
        case "${current_update}" in
            wxp | w2k3 | w2k3-x64 | w60 | w60-x64 | w61 | w61-x64 | w62 | w62-x64 | w63 | w63-x64 | w100 | w100-x64)
                need_win="enabled"
            ;;
            o2k3 | o2k7 | o2k10 | o2k10-x64 | o2k13 | o2k13-x64 | o2k16 | o2k16-x64)
                need_ofc="enabled"
            ;;
            *)
                fail "Unknown update ${current_update}"
            ;;
        esac

        # Determine the needed architectures for optional updates like
        # .NET Frameworks, Windows Defender virus definitions, and
        # Microsoft Security Essentials. This depends on the Windows
        # updates only.
        case "${current_update}" in
            wxp | w2k3 | w60 | w61 | w62 | w63 | w100)
                # Optional downloads will be downloaded in 32-bit versions
                need_x86="enabled"
            ;;
            w2k3-x64 | w60-x64 | w61-x64 | w62-x64 | w63-x64 | w100-x64)
                # Optional downloads will be downloaded in 64-bit versions
                need_x64="enabled"
            ;;
            o2k3 | o2k7 | o2k10 | o2k10-x64 | o2k13 | o2k13-x64 | o2k16 | o2k16-x64)
                :
            ;;
            *)
                fail "Unknown update ${current_update}"
            ;;
        esac
    done
    echo ""

    # Add common updates to the list of updates
    log_info_message "Adding common updates for all Windows and Office versions..."
    if [[ "${need_win}" == "enabled" ]]
    then
        # In current versions of WSUS Offline Update, the download target
        # "win" only contains two installers for Silverlight. Such
        # browser extensions are rarely used anymore, and they can be
        # disabled in the preferences file.
        if [[ "${include_win_glb}" == "enabled" ]]
        then
            log_info_message "Adding \"win\" to the list of updates..."
            updates_list+=( "win" )
        else
            log_info_message "Processing of \"win glb\" is disabled by preferences settings."
        fi
    fi
    if [[ "${need_ofc}" == "enabled" ]]
    then
        log_info_message "Adding \"ofc\" to the list of updates..."
        updates_list+=( "ofc" )
    fi
    echo ""

    # Create a list of needed architectures
    log_info_message "Building a list of needed architectures for the included downloads. This depends on Windows updates only..."
    if [[ "${need_x86}" == "enabled" ]]
    then
        log_info_message "Adding \"x86\" to the list of architectures..."
        architectures_list+=( "x86" )
    fi
    if [[ "${need_x64}" == "enabled" ]]
    then
        log_info_message "Adding \"x64\" to the list of architectures..."
        architectures_list+=( "x64" )
    fi
    echo ""
    return 0
}


# The languages_table lists 24 languages. Windows Server 2003 only
# supports a few of them. But, if several updates can be specified on the
# command-line, this can not be validated here. The check for supported
# languages is done in the file 60-main-updates.bash instead.

function parse_second_parameter_as_list ()
{
    language_parameter="$2" # globally defined, because it is used for the
                            # timestamp files
    local current_language=""
    local language_record=""
    local language_name=""
    local language_locale=""
    local language_description=""

    # The second parameter can be parsed as a comma-separated list of
    # language names.
    log_info_message "Parsing second parameter..."
    for current_language in ${language_parameter//,/ }
    do
        if language_record="$(grep -- "^${current_language} " <<< "${languages_table}")"
        then
            read -r language_name language_locale language_description <<< "${language_record}"
            log_info_message "Found language: ${language_name}, ${language_locale}, ${language_description}"
            languages_list+=( "${current_language}" )
        else
            wrong_parameter "The language ${current_language} was not found."
        fi
    done
    echo ""
    return 0
}


function parse_remaining_parameters ()
{
    local option_record=""
    local option_name=""
    local option_description=""

    log_info_message "Parsing remaining parameters..."
    shift 2
    while (( $# > 0 ))
    do
        if option_record="$(grep -- "^$1 " <<< "${options_table_all}")"
        then
            read -r option_name option_description <<< "${option_record}"
            case "${option_name}" in
                -includesp)
                    include_service_packs="enabled"
                ;;
                -includecpp | -includewddefs | -includemsse | -includewddefs8)
                    # Delete the prefix -include and add the download
                    # name to the list of included downloads
                    log_info_message "Found included download ${option_name/-include/}"
                    downloads_list+=( "${option_name/-include/}" )
                ;;
                -includedotnet)
                    log_info_message "Found included download dotnet"
                    downloads_list+=( "dotnet" ) # statically defined installers
                    updates_list+=( "dotnet" )   # dynamically calculated updates
                ;;
                *)
                    fail "Unknown option ${option_name}"
                ;;
            esac
        else
            log_warning_message "Option $1 is not recognized."
        fi
        shift
    done

    echo ""
    return 0
}


function print_command_line_summary ()
{
    local architectures_list_serialized="-"

    # The list of architectures may be empty, if only Office update
    # are selected. Bash up to version 4.3 will treat empty arrays as
    # "unset", even if the array variables were properly declared and
    # initialized. This is fixed in bash version 4.4.
    if (( ${#architectures_list[@]} > 0 ))
    then
        architectures_list_serialized="${architectures_list[*]}"
    fi
    # This test is not necessary for the other lists, because they should
    # never be empty. One update and language must be specified on the
    # command line, and the list of included updates is initialized with
    # "wsus".

    log_info_message "Final lists after processing command-line arguments. dotnet, if selected, appears twice to handle both installers and dynamic updates.
- Updates:       ${updates_list[*]}
- Architectures: ${architectures_list_serialized} (depends on Windows updates only)
- Languages:     ${languages_list[*]}
- Downloads:     ${downloads_list[*]}
"
    return 0
}

# ========== Commands =====================================================

parse_command_line
return 0
