# This file will be sourced by the shell bash.
#
# Filename: 10-parse-command-line.bash
# Version: 1.0-beta-5
# Release date: 2017-08-25
# Intended compatibility: WSUS Offline Update Version 11.0.1 and newer
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


# ========== Global variables =============================================

update_name=""
update_description=""
update_architecture=""
language_list=""
include_service_packs="disabled"
declare -ag included_downloads=("wsus")

# ========== Functions ====================================================

function wrong_parameter ()
{
    log_error_message "$@"
    show_usage
    exit 1
} 1>&2


function validate_first_parameter ()
{
    local update_record=""

    # To avoid ambiguities, the search pattern must be anchored to the
    # beginning of the line and also include a trailing space.
    if update_record="$(grep -- "^$1 " <<< "$updates_table")"; then
        read -r update_name update_architecture update_description <<< "$update_record"
    else
        wrong_parameter "Update $1 was not found."
    fi

    log_info_message "Found update: ${update_name}, $update_description"
    return 0
}


function validate_second_parameter ()
{
    local current_language=""
    local language_record=""
    local language_name=""
    local language_locale=""
    local language_description=""

    # The second parameter can be parsed as a comma-separated list of
    # language names.
    for current_language in ${2//,/ }; do
        if language_record="$(grep -- "^$current_language " <<< "$languages_table")"; then
            read -r language_name language_locale language_description <<< "$language_record"
            log_info_message "Found language: ${language_name}, ${language_locale}, ${language_description}"
        else
            wrong_parameter "The language $current_language was not found."
        fi
    done

    # After validating all parts of the comma-separated list, the global
    # variable $language_list is set to the second positional parameter.
    language_list="$2"
    # TODO: the language list could also be defined as an indexed array,
    # which seems to be the preferred format for the shell, but so far,
    # the original comma-separated list is still needed to create the
    # timestamp files.
    return 0
}


function validate_remaining_parameters ()
{
    local valid_options=""
    local option_record=""
    local option_name=""
    local option_description=""

    case "$update_name" in
        w60 | w60-x64 | w61 | w61-x64)
            valid_options="$options_table_windows_vista"
        ;;
        w62-x64 | w63 | w63-x64 | w100 | w100-x64)
            valid_options="$options_table_windows_8"
        ;;
        o2k7 | o2k10 | o2k10-x64 | o2k13 | o2k13-x64 | o2k16 | o2k16-x64)
            valid_options="$options_table_office"
        ;;
        *)
            fail "Update $update_name was not found."
        ;;
    esac

    shift 2
    while (( $# > 0 )); do
        if option_record="$(grep -- "^$1 " <<< "$valid_options")"; then
            read -r option_name option_description <<< "$option_record"
            case "${option_name}" in
                -includesp)
                    include_service_packs="enabled"
                ;;
                -includecpp | -includedotnet | -includewddefs | -includemsse | -includewddefs8)
                    # Delete the prefix -include and add the download
                    # name to the list of included downloads
                    included_downloads+=("${option_name/-include/}")
                ;;
                *)
                    fail "Unknown option ${option_name}"
                ;;
            esac
        else
            log_warning_message "Option $1 is not applicable for $update_name"
        fi
        shift
    done

    log_info_message "Found included downloads: ${included_downloads[*]}"
    return 0
}


function parse_command_line ()
{
    log_info_message "Parse command-line..."
    if (( ${#command_line_parameters[@]} < 2 )); then
        wrong_parameter "At least two parameters are required."
    else
        validate_first_parameter "${command_line_parameters[@]}"
        validate_second_parameter "${command_line_parameters[@]}"
        validate_remaining_parameters "${command_line_parameters[@]}"
    fi
    return 0
}

# ========== Commands =====================================================

parse_command_line
echo ""
return 0
