# This file will be sourced by the shell bash.
#
# Filename: 10-show-selection-dialogs-with-dialog.bash
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
# Description
#
#     This file displays the selection dialogs for the updates, languages
#     and optional downloads. It uses the external command "dialog"
#     to format the dialogs. All three dialogs allow multiple selections.
#
#     If dialog is not installed, then this script will simply return
#     and the next file will be sourced. That file will use the internal
#     command "select" of the bash as a fallback.

# ========== Configuration ================================================

# This is the configuration for the current version of WSUS Offline
# Update, 11.4 and later

updates_dialog=(
    w60           "Windows Server 2008, 32-bit"                         off
    w60-x64       "Windows Server 2008, 64-bit"                         off
    w61           "Windows 7, 32-bit"                                   off
    w61-x64       "Windows 7 / Server 2008 R2, 64-bit"                  off
    w62-x64       "Windows Server 2012, 64-bit"                         off
    w63           "Windows 8.1, 32-bit"                                 off
    w63-x64       "Windows 8.1 / Server 2012 R2, 64-bit"                off
    w100          "Windows 10, 32-bit"                                  off
    w100-x64      "Windows 10 / Server 2016, 64-bit"                    off
    o2k10         "Office 2010, 32-bit"                                 off
    o2k10-x64     "Office 2010, 32-bit and 64-bit"                      off
    o2k13         "Office 2013, 32-bit"                                 off
    o2k13-x64     "Office 2013, 32-bit and 64-bit"                      off
    o2k16         "Office 2016, 32-bit"                                 off
    o2k16-x64     "Office 2016, 32-bit and 64-bit"                      off
    all           "All Windows and Office updates, 32-bit and 64-bit"   off
    all-x86       "All Windows and Office updates, 32-bit"              off
    all-x64       "All Windows and Office updates, 64-bit"              off
    all-win       "All Windows updates, 32-bit and 64-bit"              off
    all-win-x86   "All Windows updates, 32-bit"                         off
    all-win-x64   "All Windows updates, 64-bit"                         off
    all-ofc       "All Office updates, 32-bit and 64-bit"               off
    all-ofc-x86   "All Office updates, 32-bit"                          off
)

languages_dialog=(
    deu   "German"                  on
    enu   "English"                 on
    ara   "Arabic"                  off
    chs   "Chinese (Simplified)"    off
    cht   "Chinese (Traditional)"   off
    csy   "Czech"                   off
    dan   "Danish"                  off
    nld   "Dutch"                   off
    fin   "Finnish"                 off
    fra   "French"                  off
    ell   "Greek"                   off
    heb   "Hebrew"                  off
    hun   "Hungarian"               off
    ita   "Italian"                 off
    jpn   "Japanese"                off
    kor   "Korean"                  off
    nor   "Norwegian"               off
    plk   "Polish"                  off
    ptg   "Portuguese"              off
    ptb   "Portuguese (Brazil)"     off
    rus   "Russian"                 off
    esn   "Spanish"                 off
    sve   "Swedish"                 off
    trk   "Turkish"                 off
)

options_dialog=(
    sp        "Service Packs"                                        on
    cpp       "Visual C++ Runtime Libraries"                         off
    dotnet    ".NET Frameworks"                                      off
    wddefs    "Windows Defender updates for Windows Vista and 7"     off
    msse      "Microsoft Security Essentials"                        off
    wddefs8   "Windows Defender updates for Windows 8, 8.1 and 10"   off
)

# ========== Functions ====================================================

# Test the result code of dialog
#
#   0 = OK-Button
#   1 = Cancel-Button
# 255 = Escape-Key

function check_dialog_result_code ()
{
    case $? in
        0)
            #echo "OK button pressed"
            :
        ;;
        1)
            echo "Cancel button pressed"
            exit 1
        ;;
        255)
            echo "Escape key pressed"
            exit 255
        ;;
        *)
            echo "Unknown result code"
            exit 1
        ;;
    esac
    return 0
}


function show_selection_dialogs_with_dialog ()
{
    local update_list=""
    local update_list_csv=""
    local language_list=""
    local language_list_csv=""
    local options=""
    local next_option=""
    local -a command_line=()

    # The language dialog does not have any options preselected. It must
    # be repeated until a non-empty list of updates is returned.
    #
    while [[ -z "${update_list}" ]]
    do
        # If the shell option errexit or a trap on ERR is used, then
        # the result code of each command must be directly checked. This
        # usually means, that it must be inserted in an if-then-else-fi
        # construct.
        #
        # For some reason, the negation with "!" does not seem to work
        # in this case.
        #
        if update_list="$(dialog --stdout --title "Update selection" --checklist "Please select your updates:" 0 0 0 "${updates_dialog[@]}" )"
        then
            :
        else
            check_dialog_result_code
        fi
    done

    while [[ -z "${language_list}" ]]
    do
        if language_list="$(dialog --stdout --title "Language selection" --checklist "Please select your languages:" 0 0 0 "${languages_dialog[@]}" )"
        then
            :
        else
            check_dialog_result_code
        fi
    done

    if options="$(dialog --stdout --title "Optional downloads" --checklist "Please select the downloads to include:" 0 0 0 "${options_dialog[@]}" )"
    then
        :
    else
        check_dialog_result_code
    fi

    # Change word lists to comma-separated lists
    #
    update_list_csv="${update_list// /,}"
    language_list_csv="${language_list// /,}"

    # Assemble command line for the download script
    #
    command_line=( ./download-updates.bash "${update_list_csv}" "${language_list_csv}" )

    if [[ -n "${options}" ]]
    then
        for next_option in ${options}
        do
            command_line+=( "-include${next_option}" )
        done
    fi

    # Print summary and confirm download command
    #
    if dialog --title "Summary" --yesno "Your selections are:\n
\n
* Updates: ${update_list}\n
* Languages: ${language_list}\n
* Included downloads: ${options}\n
\n
The command to download the updates is:\n
\n
${command_line[*]}\n
\n
Do you wish to execute it now?" 0 0
    then
        :
    else
        check_dialog_result_code
    fi

    echo "Executing: ${command_line[*]}"
    exec "${command_line[@]}"
}

# ========== Commands =====================================================

if type -P dialog
then
    show_selection_dialogs_with_dialog
else
    log_warning_message "Please install the package dialog, to display nicely formated dialogs in the terminal window."
fi

# If dialog is installed, then it will be used to create the selection
# dialogs for updates, languages and optional downloads. As the last step,
# the execution is passed to the download script.
#
# Selecting the cancel button or typing escape will exit the script.
#
# If dialog is not installed, then this script will simply return, and
# the next script will be sourced. This will use the internal command
# "select" of the bash as a fallback.

return 0
