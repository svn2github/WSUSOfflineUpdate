#!/usr/bin/env bash
#
# Filename: fix-file-permissions.bash
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
#
# Description
#
#     If the new Linux scripts are distributed with the WSUS Offline
#     Update archive, then they don't need any special installation. But
#     zip archives, which are created on Windows, won't preserve Linux
#     file permissions. Therefore, these scripts may not be executable
#     initially.
#
#     This script is meant to correct the missing file permissions.
#
# Usage
#
#     Since this script will also be affected by this problem, you should
#     change to the installation directory sh and run the script as:
#
#     bash fix-file-permissions.bash
#
#     This is only needed once after the first installation. The
#     self-update scripts should take care of adjusting file permissions
#     in the future.

# ========== Functions ====================================================

function fix_file_permissions ()
{
    # Resolving the installation path with GNU readlink is very reliable,
    # but it may only work in Linux and FreeBSD. Remove the option -f for
    # BSD readlink on Mac OS X. If there are problems with resolving the
    # installation path, change directly into the installation directory
    # of this script and run it script from there.
    cd "$(dirname "$(readlink -f "$0")")" || exit 1

    # Ensure, that Linux scripts are executable (excluding libraries,
    # tasks and the preferences file, since these files are sourced)
    chmod +x \
        ./download-updates.bash \
        ./fix-file-permissions.bash \
        ./get-all-updates.bash \
        ./update-generator.bash \
        ./comparison-linux-windows/compare-integrity-database.bash \
        ./comparison-linux-windows/compare-update-tables.bash
}

# ========== Commands =====================================================

fix_file_permissions

exit 0
