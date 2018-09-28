# This file will be sourced by the shell bash.
#
# Filename: 50-superseded-updates.bash
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
#     This task calculates superseded updates.

# ========== Functions ====================================================

# The WSUS catalog file package.xml is only extracted from the archive
# wsusscn2.cab, if this file changes. Otherwise, a cached copy of
# package.xml is used.
#
# The file package.xml contains just one long line without any line
# breaks. This is the most compact form of XML files and similar formats
# like JSON. In this form, it can be parsed by applications, but it cannot
# be displayed in a text editor nor searched with grep. For convenience,
# the script also creates a pretty-printed copy of the file with the
# name package-formated.xml.

function unpack_wsus_catalog_file ()
{
    if require_file "${cache_dir}/package.xml"
    then
        log_info_message "Found cached update catalog file package.xml"
    else
        # Remove formated copy of the file
        rm -f "${cache_dir}/package-formated.xml"
        mkdir -p "${cache_dir}"

        if [[ -f "../client/wsus/wsusscn2.cab" ]]
        then
            # cabextract often warns about "possible extra bytes at end of
            # file", if the file wsusscn2.cab is tested or expanded. These
            # warnings can be ignored.
            log_info_message "Extracting Microsoft's update catalog file (ignore any warnings about extra bytes at end of file)..."
            if cabextract -d "${temp_dir}" -F "package.cab" "../client/wsus/wsusscn2.cab"
            then
                if cabextract -d "${cache_dir}" -F "package.xml" "${temp_dir}/package.cab"
                then
                    log_info_message "The file package.xml was extracted successfully."
                    log_info_message "Creating a formated copy of the file package.xml ..."
                    "${xmlstarlet}" format "${cache_dir}/package.xml" > "${cache_dir}/package-formated.xml"
                else
                    rm -f "${timestamp_dir}/timestamp-wsus-all-glb.txt"
                    fail "The file package.xml could not be extracted. The script cannot continue without this file."
                fi
            else
                rm -f "${timestamp_dir}/timestamp-wsus-all-glb.txt"
                fail "The file package.cab could not be extracted. The script cannot continue without this file."
            fi
        else
            rm -f "${timestamp_dir}/timestamp-wsus-all-glb.txt"
            fail "The required file wsusscn2.cab was not found. The script cannot continue without this file."
        fi
    fi
    echo ""
    return 0
}


# The files ExcludeList-Linux-superseded.txt and
# ExcludeList-Linux-superseded-seconly.txt will be deleted, if a new
# version of WSUS Offline Update or the Linux download scripts is
# installed, or if one of the following configurations files has changed:
#
# ../exclude/ExcludeList-superseded-exclude.txt
# ../client/exclude/HideList-seconly.txt
# ../client/wsus/wsusscn2.cab
#
# The function check_superseded_updates then checks, if the exclude
# lists still exist.
#
# Previously, this function did some more checks, but since the files
# ExcludeList-superseded.txt and ExcludeList-superseded-seconly.txt were
# renamed in version 1.5 of the Linux download scripts, these tests are
# not needed anymore.

function check_superseded_updates ()
{
    if [[ -f "../exclude/ExcludeList-Linux-superseded.txt" \
       && -f "../exclude/ExcludeList-Linux-superseded-seconly.txt" ]]
    then
        log_info_message "Found valid list of superseded updates"
    else
        rebuild_superseded_updates
    fi
    return 0
}


# The function rebuild_superseded_updates calculates two alternate lists
# of superseded updates:
#
# ../exclude/ExcludeList-Linux-superseded.txt
# ../exclude/ExcludeList-Linux-superseded-seconly.txt

function rebuild_superseded_updates ()
{
    local -a excludelist_overrides=()
    local -a excludelist_overrides_seconly=()

    # Preconditions
    require_file "${cache_dir}/package.xml" || fail "The required file package.xml is missing"

    # Delete existing files, just to be sure
    rm -f "../exclude/ExcludeList-Linux-superseded.txt"
    rm -f "../exclude/ExcludeList-Linux-superseded-seconly.txt"

    # Create a new file ExcludeList-Linux-superseded.txt from package.xml and
    # ExcludeList-superseded-exclude.txt
    log_info_message "Determining superseded updates (please be patient, this will take a while)..."

    # *** First step: Calculate superseded revision ids ***
    #
    # Superseded bundle records can be recognized by an element of type
    # "SupersededBy" with one or more "RevisionIds". Some of these
    # RevisionIds may not be valid, though. For example, the bundle
    # records for some Windows 7 updates include the element:
    #
    #  <SupersededBy>
    #    <Revision Id="13941260"/>
    #    <Revision Id="16506826"/>
    #  </SupersededBy>
    #
    # but both RevisionIds don't seem to exist. The page
    # "https://support.microsoft.com/en-us/kb/2604114" for the update
    # files doesn't indicate, that these updates are outdated. Therefore,
    # it is necessary to extract all existing bundle RevisionIds and
    # compare this list to the supposed superseding RevisionIds.

    log_info_message "Extracting file 1..."
    # Extract all existing bundle RevisionIds
    ${xmlstarlet} transform \
        ../xslt/extract-existing-bundle-revision-ids.xsl \
        "${cache_dir}/package.xml" \
        > "${temp_dir}/existing-bundle-revision-ids.txt"
    sort_in_place "${temp_dir}/existing-bundle-revision-ids.txt"

    log_info_message "Extracting file 2..."
    # Extract all superseding RevisionIds and the superseded RevisionIds
    # of the bundle records, to which they belong
    ${xmlstarlet} transform \
        ../xslt/extract-superseding-and-superseded-revision-ids.xsl \
        "${cache_dir}/package.xml" \
        > "${temp_dir}/superseding-and-superseded-revision-ids.txt"
    sort_in_place "${temp_dir}/superseding-and-superseded-revision-ids.txt"

    log_info_message "Joining files 1 and 2 to file 3..."
    # Get valid superseded RevisionIds by verifying, that the superseding
    # RevisionIds actually exist.

    # Field order:
    # File 1: existing-bundle-revision-ids.txt
    # - Field 1: existing bundle RevisionIds
    # File 2: superseding-and-superseded-revision-ids.txt
    # - Field 1: superseding RevisionIds
    # - Field 2: superseded RevisionIds (not verified)

    # Write verified, superseded RevisionIds
    join -t ',' -o 2.2 \
        "${temp_dir}/existing-bundle-revision-ids.txt" \
        "${temp_dir}/superseding-and-superseded-revision-ids.txt" \
        > "${temp_dir}/ValidSupersededRevisionIds.txt"
    sort_in_place "${temp_dir}/ValidSupersededRevisionIds.txt"

    # *** Second step: Calculate superseded file ids ***

    log_info_message "Extracting file 4..."
    # Extract three connected fields from the same Update records:
    # - the Bundle RevisionId from the field "BundledBy"
    # - the RevisionId of the Update record itself
    # - the File-Id of the Payload File
    ${xmlstarlet} transform \
        ../xslt/extract-update-revision-and-file-ids.xsl \
        "${cache_dir}/package.xml" \
        > "${temp_dir}/BundledUpdateRevisionAndFileIds.txt"
    sort_in_place "${temp_dir}/BundledUpdateRevisionAndFileIds.txt"

    log_info_message "Joining files 3 and 4 to file 5..."
    # Get superseded File-Ids of the PayloadFiles. Since the superseded
    # Bundle RevisionIds are verified, this join will also verify the
    # FileIds. This means: if there are Bundle RevisionIds in the second
    # file, which don't really exist, they won't be matched by this join.

    # Revised field order:
    # File 1: ValidSupersededRevisionIds.txt
    # - Field 1: superseded Bundle RevisionId (verified)
    # File 2: BundledUpdateRevisionAndFileIds.txt
    # - Field 1: Bundle RevisionId
    # - Field 2: Update RevisionId (not really needed, but useful for
    #            debugging)
    # - Field 3: FileId

    # Write FileIds only
    join -t ',' -o 2.3 \
        "${temp_dir}/ValidSupersededRevisionIds.txt" \
        "${temp_dir}/BundledUpdateRevisionAndFileIds.txt" \
        > "${temp_dir}/SupersededFileIds.txt"
    sort_in_place "${temp_dir}/SupersededFileIds.txt"

    # *** Third step: Calculate superseded file locations (URLs) ***

    log_info_message "Extracting file 6..."
    ${xmlstarlet} transform \
        ../xslt/extract-update-cab-exe-ids-and-locations.xsl \
        "${cache_dir}/package.xml" \
        > "${temp_dir}/UpdateCabExeIdsAndLocations.txt"
    sort_in_place "${temp_dir}/UpdateCabExeIdsAndLocations.txt"

    log_info_message "Joining files 5 and 6 to file 7..."
    # Field order:
    # File 1: SupersededFileIds.txt
    # - Field 1: FileId
    # File 2: UpdateCabExeIdsAndLocations.txt
    # - Field 1: FileId
    # - Field 2: Location (URL)

    # Write superseded File Locations
    join -t ',' -o 2.2 \
        "${temp_dir}/SupersededFileIds.txt" \
        "${temp_dir}/UpdateCabExeIdsAndLocations.txt" \
        > "${temp_dir}/ExcludeListLocations-superseded-all.txt"
    sort_in_place "${temp_dir}/ExcludeListLocations-superseded-all.txt"

    # *** Apply ExcludeList-superseded-exclude.txt ***
    #
    # The file ExcludeList-superseded-exclude.txt contains KB
    # numbers of updates, which are marked as superseded by
    # Microsoft, but which should be downloaded and installed
    # nonetheless. Therefore, theses KB numbers are removed from the
    # file ExcludeListLocations-superseded-all.txt again.
    #
    # The file ExcludeList-superseded-seconly.txt was introduced in WSUS
    # Offline Update 10.9. It is created by applying additional exclude
    # lists with security-only updates.
    #
    # The Linux scripts use the name
    # ExcludeList-Linux-superseded-seconly.txt instead since version 1.5.
    excludelist_overrides=(
        ../exclude/ExcludeList-superseded-exclude.txt
        ../exclude/custom/ExcludeList-superseded-exclude.txt
    )

    shopt -s nullglob
    excludelist_overrides_seconly=(
        ../exclude/ExcludeList-superseded-exclude.txt
        ../exclude/custom/ExcludeList-superseded-exclude.txt
        ../exclude/ExcludeList-superseded-exclude-seconly.txt
        ../client/static/StaticUpdateIds-w61*-seconly.txt
        ../client/static/StaticUpdateIds-w62*-seconly.txt
        ../client/static/StaticUpdateIds-w63*-seconly.txt
        ../client/static/custom/StaticUpdateIds-w61*-seconly.txt
        ../client/static/custom/StaticUpdateIds-w62*-seconly.txt
        ../client/static/custom/StaticUpdateIds-w63*-seconly.txt
    )
    shopt -u nullglob

    apply_exclude_lists \
        "${temp_dir}/ExcludeListLocations-superseded-all.txt" \
        "../exclude/ExcludeList-Linux-superseded.txt" \
        "${temp_dir}/ExcludeList-superseded-exclude.txt" \
        "${excludelist_overrides[@]}"
    sort_in_place "../exclude/ExcludeList-Linux-superseded.txt"

    apply_exclude_lists \
        "${temp_dir}/ExcludeListLocations-superseded-all.txt" \
        "../exclude/ExcludeList-Linux-superseded-seconly.txt" \
        "${temp_dir}/ExcludeList-superseded-exclude-seconly.txt" \
        "${excludelist_overrides_seconly[@]}"
    sort_in_place "../exclude/ExcludeList-Linux-superseded-seconly.txt"

    # After recalculating superseded updates, all dynamic updates must
    # be recalculated as well.
    reevaluate_dynamic_updates

    if ensure_non_empty_file "../exclude/ExcludeList-Linux-superseded.txt"
    then
        log_info_message "Created file ExcludeList-Linux-superseded.txt"
    else
        fail "File ExcludeList-Linux-superseded.txt was not created"
    fi
    return 0
}

# ========== Commands =====================================================

unpack_wsus_catalog_file
check_superseded_updates
echo ""
return 0
