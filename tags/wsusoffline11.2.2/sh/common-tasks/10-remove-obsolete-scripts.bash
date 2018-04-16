# This file will be sourced by the shell bash.
#
# Filename: 10-remove-obsolete-scripts.bash
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
#     During the development of the new Linux scripts, tasks and
#     libraries sometimes need to be replaced or renumbered. Then
#     the first task would be to delete obsolete files of previous
#     versions. Therefore, this new task is inserted as the first file
#     in the directory common-tasks.

# ========== Functions ====================================================

function remove_obsolete_scripts ()
{
    # Remove the obsolete script DownloadUpdates.sh and related files.
    #
    # The new Linux scripts are included in the main WSUS Offline Update
    # archive in changeset 866 http://trac.wsusoffline.net/changeset/866 ,
    # but then the old scripts in the same directory need to be removed.
    rm -f ./commonparts.inc
    rm -f ./CreateISOImage.sh
    rm -f ./DownloadUpdates.sh
    rm -f ./RemoveGermanAndEnglishLanguageSupport.sh

    # Remove obsolete scripts from version 1.0-beta-2
    #
    # The directory common-tasks was refactored in version 1.0-beta-3:
    # A new script 10-remove-obsolete-scripts.bash (this one) was added,
    # and the script 40-check-for-self-updates.bash was split into two
    # smaller scripts. The other scripts were renumbered. Thus, all
    # scripts from version 1.0-beta-2 in this directory, if present,
    # need to be removed.
    rm -f ./common-tasks/10-start-logging.bash
    rm -f ./common-tasks/20-check-needed-applications.bash
    rm -f ./common-tasks/30-configure-downloaders.bash
    rm -f ./common-tasks/40-check-for-self-updates.bash

    # Remove old documentation files from version 1.0-beta-3
    #
    # These files were renamed in version 1.0-beta-4 to
    # Installation_Guide.txt and Installationsanleitung.txt.
    rm -f ./documentation/Quick_installation_guide.txt
    rm -f ./documentation/Kurzinstallationsanleitung.txt
}

# ========== Commands =====================================================

remove_obsolete_scripts
return 0
