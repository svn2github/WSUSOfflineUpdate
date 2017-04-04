# This file will be sourced by the shell bash.
#
# Filename: desktop-integration.bash
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
#     This file implements a function to put outdated files into the
#     trash, rather than deleting them directly. With the package
#     trash-cli, this actually works without any graphical desktop
#     environment.
#
#     In Linux, the local trash is the directory
#     $HOME/.local/share/Trash. Removable drives use a directory
#     .Trash-1000 at the root level of the partition. The number "1000"
#     is the user id of the first regular user in Debian. It would be
#     "500" for Fedora.
#
#     gvfs-trash and trash-put may fail, if the file system does not
#     support a trash, for example, because the directory /.Trash-1000
#     could not be created. Then the files are deleted directly with rm.
#
#     The global variable $linux_trash_handler is set in the file
#     20-check-needed-applications.bash.

function trash_file ()
{
    if [[ -f "$1" ]]; then
        if [[ -n "$linux_trash_handler" ]]; then
            "$linux_trash_handler" "$1" || rm -f "$1"
        else
            rm "$1"
        fi
    else
        log_debug_message "${FUNCNAME[0]}: File $1 was not found"
    fi

    return 0
}

return 0
