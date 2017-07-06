# This file will be sourced by the shell bash.
#
# Filename: 70-synchronize-with-target.bash
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
#     This task synchronizes the client directory with a target
#     directory. It uses the command rsync to copy only new or modified
#     files. Unused files, which don't exist in the source directory
#     anymore, will be deleted.
#
# Usage
#
#     rsync must be installed from the package repositories of the
#     Linux distribution.
#
#     The target directory must be specified under "Configuration"
#     and this file moved to the directory download-updates-tasks.

# ========== Configuration ================================================

# For rsync, the source directory should end with a slash, but the
# target directory should not. This prevents creating another directory
# at the target.

source_directory="../client/"
target_directory="not-available" # without trailing slash

# ========== Commands =====================================================

# rsync can be used to create rotating backups, where identical files
# are not really copied, but replaced with hard links. An often cited
# reference is:
#
# http://www.mikerubel.org/computers/rsync_snapshots/
#
# But this script is intended to copy the client directory to an external
# drive, similar to the Windows script CopyToTarget.cmd. Therefore,
# rsync doesn't use the option to create hard links.

if [[ -d "${source_directory}" && -d "${target_directory}" ]]; then
    rsync --archive --delete --verbose "${source_directory}" "${target_directory}"
fi
