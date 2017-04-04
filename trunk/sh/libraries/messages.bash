# This file will be sourced by the shell bash.
#
# Filename: messages.bash
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
#     Most message functions are written to display some text in the
#     terminal, and to write the same information to the log file.


# Testing global variables used in this file
: "${COLUMNS:?variable is not set}"
: "${logfile:?variable is not set}"
: "${debug:?variable is not set}"

# printf '%s\n' should be used instead of echo, except for simple messages
# without escape characters or variables. fold --spaces prevents line
# breaks within words.
function show_message ()
{
    printf '%s\n' "$*" | fold -s -w "$COLUMNS"
    return 0
}

function log_message ()
{
    printf '%s\n' "$*" | fold -s -w "$COLUMNS"
    printf '%s\n' "$(date "+%F %T") - $*" >> "$logfile"
    return 0
}

function log_info_message ()
{
    log_message "Info: $*"
    return 0
}

# Warnings are not errors, but unusual conditions, which should be
# examined.
function log_warning_message ()
{
    log_message "Warning: $*"
    return 0
} 1>&2

# Errors are runtime errors from wget or aria2, which may be
# recovered. Temporary download errors happen all the time. Some downloads
# like the virus definition files may fail even after ten tries. Such
# errors are reported and written to the log file, but then the script
# should continue anyway.
function log_error_message ()
{
    log_message "Error: $*"
    return 0
} 1>&2

# Failures are programming errors of the type "This should never happen".
function fail ()
{
    log_message "Failure: $*"
    show_backtrace
    exit 1
} 1>&2

# Enabling the option debug provides more output for some functions,
# but this is only meant for development.
function log_debug_message ()
{
    if [[ "$debug" == "enabled" ]]; then
        log_message "Debug: $*"
    fi
    return 0
} 1>&2

function show_backtrace ()
{
    local output=""
    local depth=0

    # The indexed array FUNCNAME has the calling chain of all functions,
    # with the top level code called "main". This is why there is no
    # function "main" in the script.
    printf '%s\n' "Backtrace: ${FUNCNAME[*]}"

    # The bash internal command "caller" is meant for the bash debugger,
    # but it can be used without one.
    while output="$(caller $depth)"; do
        printf '%s\n' "Caller $depth: $output"
        depth="$(( depth + 1 ))"
    done

    return 0
} 1>&2

# function ask_question ()
#
# Print a question ($1) and an optional help_text ($2), then show the
# prompt [Y/n]. If only return is pressed, "Y" will be the default answer.
#
# For a discussion see
# https://stackoverflow.com/questions/226703/how-do-i-prompt-for-input-in-a-linux-shell-script/22893526
#
# The second parameter with the help_text is optional; a standard value
# is supplied to prevent error messages, if the shell option -u is used.
function ask_question ()
{
    local question="$1"
    local help_text="${2:-}"
    local answer=""

    show_message "${question}"
    if [[ -n "${help_text}" ]]; then
        show_message "${help_text}"
    fi

    while true; do
        read -r -p "[Y/n]: " answer
        # Assume "Yes", if only return is pressed
        case "${answer:-Y}" in
            [Yy]*)
                return 0
            ;;
            [Nn]*)
                return 1
            ;;
            *)
                echo "Please enter \"Yes\" or \"no\" or simply hit return to select the default answer."
            ;;
        esac
    done
    return 0
}

return 0
