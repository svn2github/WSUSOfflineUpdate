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

    # Obsolete files in version 1.8
    #
    # The script available-tasks/70-synchronize-with-target.bash
    # is obsolete with version 1.8, because a more elaborate script
    # copy-to-target.bash was introduced.
    #
    # The new file documentation/changelog.txt has the same information
    # as the version-history.txt, but in reverse order.
    #
    # The file NEWS.txt replaces the former release_notes_[version].txt,
    # but it is not really necessary, to delete the old files now.
    rm -f ./available-tasks/70-synchronize-with-target.bash
    rm -f ./documentation/version-history.txt

    # Obsolete files in version 1.9
    #
    # The script update-generator.bash uses a new script to create the
    # selection dialogs with the external utility "dialog".
    #
    # The existing script 10-show-selection-dialogs.bash is used as a
    # fallback and simply renamed to 20-show-selection-dialogs.bash.
    #
    rm -f ./update-generator-tasks/10-show-selection-dialogs.bash

    return 0
}

# The files ExcludeList-superseded.txt and
# ExcludeList-superseded-seconly.txt are
# renamed to ExcludeList-Linux-superseded.txt and
# ExcludeList-Linux-superseded-seconly.txt in version 1.5 of the Linux
# download scripts. Existing files may be kept and renamed, if they are
# sorted in C-style, and if they use Linux line endings.
#
# If the exclude lists were created on Windows, they are kept as is at
# this point. They may still be removed later, if a new version of WSUS
# Offline Update or the WSUS catalog file is available.

function rename_exclude_lists ()
{
    if [[ -f "../exclude/ExcludeList-superseded.txt" ]]
    then
        # Testing the expected sort order. GNU sort uses a C-style sort,
        # if the environment variable LC_ALL=C is set.
        if sort --check=quiet "../exclude/ExcludeList-superseded.txt"
        then
            # Testing the line endings. A carriage return can be passed
            # to grep with the "ANSI-C quoting" of the bash.
            if ! grep -F -q $'\r' "../exclude/ExcludeList-superseded.txt"
            then
                if [[ ! -f "../exclude/ExcludeList-Linux-superseded.txt" ]]
                then
                    # Any refactoring, e.g. renaming existing files,
                    # should be done first, but the script should not
                    # create any output yet. Logging should start with
                    # the script 20-start-logging.bash, which inserts
                    # a divider line into the log and prints a header
                    # with the script name. Any previous output will
                    # look out of place.
                    #
                    #echo "Renaming ExcludeList-superseded.txt to ExcludeList-Linux-superseded.txt"
                    mv "../exclude/ExcludeList-superseded.txt" \
                       "../exclude/ExcludeList-Linux-superseded.txt"
                else
                    #echo "Could not rename ExcludeList-superseded.txt"
                    rm "../exclude/ExcludeList-superseded.txt"
                fi
            fi
        fi
    fi

    if [[ -f "../exclude/ExcludeList-superseded-seconly.txt" ]]
    then
        if sort --check=quiet "../exclude/ExcludeList-superseded-seconly.txt"
        then
            if ! grep -F -q $'\r' "../exclude/ExcludeList-superseded-seconly.txt"
            then
                if [[ ! -f "../exclude/ExcludeList-Linux-superseded-seconly.txt" ]]
                then
                    #echo "Renaming ExcludeList-superseded-seconly.txt to ExcludeList-Linux-superseded-seconly.txt"
                    mv "../exclude/ExcludeList-superseded-seconly.txt" \
                       "../exclude/ExcludeList-Linux-superseded-seconly.txt"
                else
                    #echo "Could not rename ExcludeList-superseded-seconly.txt"
                    rm "../exclude/ExcludeList-superseded-seconly.txt"
                fi
            fi
        fi
    fi
    return 0
}

# ========== Commands =====================================================

remove_obsolete_scripts
rename_exclude_lists
return 0
