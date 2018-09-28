# This file will be sourced by the shell bash.
#
# Filename: messages.bash
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
#     Most message functions display some text in the terminal window and
#     write the same information to the log file. Colors and bold text
#     are used to highlight the log levels Info, Warning, Error and Debug.
#
#     Terminal colors are set with tput, which is safer than hard-coding
#     the escape sequences. But tput uses the environment variable
#     ${TERM}, to determine, if terminal colors can be used:
#
#     - It does work, if ${TERM} is set to xterm-256color or
#       rxvt-256color.
#     - It does not work with ${TERM} set to xterm, xterm-color, rxvt
#       or rxvt-color. Then only bold text will be used.
#     - If ${TERM} is set to "dumb", then no text formating will be
#       used. bash uses this value, if it is running as a cron job.
#
#     The correct terminal type should be set in the preferences of
#     the terminal emulator application. If this is not possible, you
#     could also define this environment variable in a settings file
#     like ~/.bashrc with:
#
#     export TERM=xterm-256color
#     export TERM=rxvt-256color
#
#     This script does not set ${TERM} itself, but it sets the environment
#     variables ${LINES} and ${COLUMNS}.

# ========== Environment variables ========================================

# Try to get the height and width of the terminal window and export them
# as ${LINES} and ${COLUMNS}. These environment variables are usually
# set in interactive sessions, but they are not inherited by scripts.
#
# If the script is running within a terminal emulator window, then tput
# can report its dimensions. This does not work, if the script is started
# with "at", "batch", "env -i", or if it is running as a cron job. An
# example output with an empty environment is:
#
# $ env -i tput cols
# tput: No value for $TERM and no -T specified
# $ echo $?
# 2
#
# Terminal colors can also be set with tput, rather than hard-coding the
# escape sequences. A colored output should only be used, if the output
# is directly written to a terminal window.
#
# The test -t of POSIX shells ensures, that both file descriptors 1 and
# 2 (standard output and error output) are attached to a terminal. It
# detects, if the script is running as a cron job or batch job, or if
# the output is redirected to a file or piped to another command.
#
if [[ -t 1 ]] && [[ -t 2 ]]
then
    COLUMNS="$(tput cols)" || true
    LINES="$(tput lines)"  || true

    # Text formatting and foreground colors
    #
    bold="$(tput bold)"             || true
    darkred="$(tput setaf 1)"       || true
    darkgreen="$(tput setaf 2)"     || true
    darkyellow="$(tput setaf 3)"    || true
    darkblue="$(tput setaf 4)"      || true
    brightred="$(tput setaf 9)"     || true
    brightgreen="$(tput setaf 10)"  || true
    brightyellow="$(tput setaf 11)" || true
    brightblue="$(tput setaf 12)"   || true
    reset_all="$(tput sgr0)"        || true
fi

# If the height and width could not be set with tput, they will be set
# to default values.
#
COLUMNS="${COLUMNS:-80}"
LINES="${LINES:-24}"
export COLUMNS
export LINES

# If colors cannot be used, then the text formatting variables are set
# to empty strings.
#
bold="${bold:-}"
darkred="${darkred:-}"
darkgreen="${darkgreen:-}"
darkyellow="${darkyellow:-}"
darkblue="${darkblue:-}"
brightred="${brightred:-}"
brightgreen="${brightgreen:-}"
brightyellow="${brightyellow:-}"
brightblue="${brightblue:-}"
reset_all="${reset_all:-}"

# ========== Global variables =============================================

# The global variables logfile and debug should always be set by the
# scripts, which source this library. For example, ${logfile} is set
# to "../log/download.log" by the scripts download-updates.bash and
# update-generator.bash.
#
# To make this file more self-contained and supply reasonably defaults
# for other scripts, ${logfile} is set to "messages.log", and ${debug}
# is set to "disabled" with standard parameters.
#
logfile="${logfile:-messages.log}"
debug="${debug:-disabled}"

# ========== Functions ====================================================

# If long lines are displayed in a terminal window, then the terminal
# emulator often breaks lines within words, which makes the text hard
# to read. This can be prevented by wrapping the text to the length of
# the terminal window with fold --spaces.
#
# TODO: Terminal colors influence the line width. Lines with colors are
# shorter than those without.
#
# printf '%s\n' should be used instead of echo, except for simple messages
# without escape characters or variables.
#
function show_message ()
{
    printf '%s\n' "$*" | fold -s -w "${COLUMNS}"
    return 0
}

function log_message ()
{
    printf '%s\n' "$*" | fold -s -w "${COLUMNS}"
    printf '%s\n' "$(date "+%F %T") - $*" >> "${logfile}"
    return 0
}

# By default, terminal emulators use bold text for bright colors. This
# can be disabled in XTerm and KDE Konsole, but not in most other terminal
# emulators. To ensure the wanted style, "bold" should be set anyway.
#
function log_info_message ()
{
    printf '%s\n' "${bold}${brightgreen}Info:${reset_all} $*" | fold -s -w "${COLUMNS}"
    printf '%s\n' "$(date "+%F %T") - Info: $*" >> "${logfile}"
    return 0
}

# Warnings are not errors, but unusual conditions, which should be
# examined.
function log_warning_message ()
{
    printf '%s\n' "${bold}${brightyellow}Warning:${reset_all} $*" | fold -s -w "${COLUMNS}"
    printf '%s\n' "$(date "+%F %T") - Warning: $*" >> "${logfile}"
    return 0
} 1>&2

# Errors are runtime errors from wget or aria2, which may be
# recovered. Temporary download errors happen all the time. Some downloads
# like the virus definition files may fail even after ten tries. Such
# errors are reported and written to the log file, but then the script
# should continue anyway.
function log_error_message ()
{
    printf '%s\n' "${bold}${brightred}Error:${reset_all} $*" | fold -s -w "${COLUMNS}"
    printf '%s\n' "$(date "+%F %T") - Error: $*" >> "${logfile}"
    return 0
} 1>&2

# Failures are programming errors of the type "This should never happen".
function fail ()
{
    printf '%s\n' "${bold}${brightred}Failure:${reset_all} $*" | fold -s -w "${COLUMNS}"
    printf '%s\n' "$(date "+%F %T") - Failure: $*" >> "${logfile}"
    show_backtrace
    echo "The script will now exit"
    exit 1
} 1>&2

# Enabling the option debug provides more output for some functions,
# but this is only meant for development.
function log_debug_message ()
{
    if [[ "${debug}" == "enabled" ]]
    then
        printf '%s\n' "${bold}${brightblue}Debug:${reset_all} $*" | fold -s -w "${COLUMNS}"
        printf '%s\n' "$(date "+%F %T") - Debug: $*" >> "${logfile}"
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
    while output="$(caller ${depth})"
    do
        printf '%s\n' "Caller ${depth}: ${output}"
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
    if [[ -n "${help_text}" ]]
    then
        show_message "${help_text}"
    fi

    while true
    do
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

# Example code
# log_info_message "Information"
# log_warning_message "Warning"
# log_error_message "Error"
# debug=enabled log_debug_message "Debug"
# fail "Failure"

return 0
