# This file will be sourced by the shell bash.
#
# Filename: 10-show-selection-dialogs.bash
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
#     The file creates the selection dialogs for the update, language
#     and download options. It uses the built-in command "select" of the
#     bash. This is easy to use, but it doesn't allow multiple selections.
#
#     The menus are provided by the file updates-and-languages.bash. They
#     are used by this file and by the file 10-parse-command-line.bash
#     for the download script.

# ========== Global variables =============================================

update_name=""
declare -ag download_command=("./download-updates.bash")

# ========== Functions ====================================================

function show_selection_dialogs ()
{
    [[ "$debug" == "disabled" ]] && clear
    select_update

    [[ "$debug" == "disabled" ]] && clear
    select_language

    [[ "$debug" == "disabled" ]] && clear
    case "$update_name" in
        w60 | w60-x64 | w61 | w61-x64)
            select_options "${options_menu_windows_vista[@]}"
        ;;
        w62-x64 | w63 | w63-x64 | w100 | w100-x64)
            select_options "${options_menu_windows_8[@]}"
        ;;
        o2k7 | o2k10 | o2k10-x64 | o2k13 | o2k13-x64 | o2k16 | o2k16-x64)
            select_options "${options_menu_office[@]}"
        ;;
        *)
            fail "Update $update_name was not found."
        ;;
    esac

    [[ "$debug" == "disabled" ]] && clear
    confirm_download_command "${download_command[@]}"
    return 0
}


function select_update ()
{
    local menu_selection=""
    local update_description=""

    echo "Update selection"
    echo "----------------"
    PS3="Please select your update: "
    select menu_selection in "${updates_menu[@]}"; do
        if [[ -n "${menu_selection}" ]]; then
            break
        else
            echo "Please try again!"
        fi
    done
    PS3=""

    read -r update_name update_description <<< "${menu_selection}"
    download_command+=("$update_name")

    log_debug_message "Update name:  $update_name"
    log_debug_message "Description:  $update_description"
    log_debug_message "Command:      ${download_command[*]}"
    return 0
}


function select_language ()
{
    local menu_selection=""
    local language_name=""
    local language_description=""

    echo "Language selection"
    echo "------------------"
    PS3="Please select your language: "
    select menu_selection in "${languages_menu[@]}"; do
        if [[ -n "${menu_selection}" ]]; then
            break
        else
            echo "Please try again!"
        fi
    done
    PS3=""

    read -r language_name language_description <<< "${menu_selection}"
    download_command+=("$language_name")

    log_debug_message "Language name: $language_name"
    log_debug_message "Description:   $language_description"
    log_debug_message "Command line:  ${download_command[*]}"
    return 0
}


# Each positional parameter for the function consists of an option name
# and its description.
function select_options ()
{
    local option_name=""
    local option_description=""

    echo "Optional downloads"
    echo "------------------"
    while (( $# > 0 )); do
        read -r option_name option_description <<< "$1"

        if ask_question "Include ${option_description}?"; then
            download_command+=("${option_name}")
        fi

        shift
    done
    return 0
}


function confirm_download_command ()
{
    echo "Summary"
    echo "-------"
    echo "The interactive setup is complete. The command to download the updates is:"
    show_message "${download_command[*]}"
    echo ""

    if ask_question "Do you wish to execute is now?"; then
        exec "${download_command[@]}"
    fi
    return 0
}

# ========== Commands =====================================================

show_selection_dialogs
return 0
