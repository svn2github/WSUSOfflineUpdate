# This file will be sourced by the shell bash.
#
# Filename: dos-files.bash
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
#     This file provides simple wrapper functions for cat, cut, grep
#     and tail. They remove any carriage returns from the result. With
#     these wrapper functions, the download script can use the file in
#     the static and exclude directory directly, without changing them
#     to the Linux format first.
#
#     These wrapper functions were introduced as a workaround for old
#     versions of wget: wget downloads all files again, if the file
#     size changes, regardless of the file modification date. Because
#     removing carriage returns changes the file size, timestamping does
#     not work for files in the static and exclude directories, if they
#     are replaced with the "update of static download definitions".
#
#     Wget 1.17 and later use a better method for timestamping, and then
#     all files could be changed on the first run of the script. Then
#     such workarounds are not necessary anymore. However, wget 1.17 is
#     not yet available in Debian 8 stable/Jessie.
#
#     On the other side, the Linux scripts may change the configuration
#     files in the static and exclude directories, because these are
#     not used for the installation. But the configuration files in
#     the client/static and client/exclude directories should not be
#     changed. These files are used since WSUS Offline Update version
#     10.9 to handle security-only updates. Then the wrapper functions
#     to read DOS files are still needed.


function cat_dos ()
{
    # The tool shellcheck calls this a useless cat, but it is actually
    # needed, if several files are used as input. A simple input
    # redirection will not handle this case.
    cat "$@" | tr -d '\r'
}

function cut_dos ()
{
    cut "$@" | tr -d '\r'
}

function grep_dos ()
{
    grep "$@" | tr -d '\r'
}

function tail_dos ()
{
    tail "$@" | tr -d '\r'
}

# Filter functions read from standard input and write to standard
# output. They are typically used in pipes.
#
# The function todos_line_endings is used to convert the output of
# hashdeep to DOS line endings on the fly.

function todos_line_endings ()
{
    local line=""

    # IFS is set to an empty string, to read a complete line including
    # leading and trailing spaces.
    while IFS="" read -r line
    do
        printf '%s\r\n' "${line}"
    done

    return 0
}

function filter_cr ()
{
    tr -d '\r'
}

function unquote ()
{
    tr -d '"'
}

return 0
