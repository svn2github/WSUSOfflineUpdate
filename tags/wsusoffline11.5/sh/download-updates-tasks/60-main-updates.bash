# This file will be sourced by the shell bash.
#
# Filename: 60-main-updates.bash
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
#     The task downloads updates for Microsoft Windows and Office,
#     and also dynamic updates for the .Net Frameworks.
#
#     Global variables from other files
#     - The indexed arrays updates_list, architectures_list and
#       languages_list are defined in the file 10-parse-command-line.bash

# ========== Global variables =============================================

if [[ "${prefer_seconly}" == enabled ]]
then
    used_superseded_updates_list="../exclude/ExcludeList-Linux-superseded-seconly.txt"
else
    used_superseded_updates_list="../exclude/ExcludeList-Linux-superseded.txt"
fi

# ========== Functions ====================================================

function get_main_updates ()
{
    local current_update=""
    local current_arch=""
    local current_lang=""

    if (( ${#updates_list[@]} > 0 ))
    then
        for current_update in "${updates_list[@]}"
        do
            case "${current_update}" in
                # Common Windows updates
                win)
                    if [[ "${localized_win_updates}" == "enabled" ]]
                    then
                        for current_lang in "glb" "${languages_list[@]}"
                        do
                            process_main_update "win" "x86" "${current_lang}"
                        done
                    else
                        process_main_update "win" "x86" "glb"
                    fi
                ;;
                # Windows XP, 32-bit
                wxp)
                    for current_lang in "glb" "${languages_list[@]}"
                    do
                        process_main_update "wxp" "x86" "${current_lang}"
                    done
                ;;
                # Windows Server 2003, 32-bit
                w2k3)
                    for current_lang in "glb" "${languages_list[@]}"
                    do
                        # The option -F is not used at this point,
                        # because the search string should be anchored
                        # to the beginning of the line.
                        if grep -q -- "^${current_lang} " <<< "${languages_table_w2k3}"
                        then
                            process_main_update "w2k3" "x86" "${current_lang}"
                        else
                            log_warning_message "Language ${current_lang} is not available for w2k3."
                        fi
                    done
                ;;
                # Windows XP / Server 2003, 64-bit
                w2k3-x64)
                    for current_lang in "glb" "${languages_list[@]}"
                    do
                        if grep -q -- "^${current_lang} " <<< "${languages_table_w2k3_x64}"
                        then
                            process_main_update "w2k3" "x64" "${current_lang}"
                        else
                            log_warning_message "Language ${current_lang} is not available for w2k3-x64."
                        fi
                    done
                ;;
                # 32-bit Windows updates
                w60 | w61 | w62 | w63 | w100)
                    process_main_update "${current_update}" "x86" "glb"
                ;;
                # 64-bit Windows updates
                w60-x64 | w61-x64 | w62-x64 | w63-x64 | w100-x64)
                    process_main_update "${current_update/-x64/}" "x64" "glb"
                ;;
                # 32-bit Office updates (localized), including common "ofc" updates
                ofc | o2k3 | o2k7 | o2k10 | o2k13)
                    for current_lang in "glb" "${languages_list[@]}"
                    do
                        process_main_update "${current_update}" "x86" "${current_lang}"
                    done
                ;;
                # 32-bit and 64-bit Office updates (localized)
                o2k10-x64 | o2k13-x64)
                    for current_lang in "glb" "${languages_list[@]}"
                    do
                        process_main_update "${current_update/-x64/}" "x64" "${current_lang}"
                    done
                ;;
                # Office 2016, 32-bit
                o2k16)
                    process_main_update "o2k16" "x86" "glb"
                ;;
                # Office 2016, 32-bit and 64-bit
                o2k16-x64)
                    process_main_update "o2k16" "x64" "glb"
                ;;
                # Installers and dynamic updates for .Net frameworks,
                # which depend on the architecture
                dotnet)
                    if (( ${#architectures_list[@]} > 0 ))
                    then
                        for current_arch in "${architectures_list[@]}"
                        do
                            process_main_update "dotnet" "${current_arch}" "glb"
                        done
                    else
                        log_warning_message "There are no architectures defined for included downloads. They are derived from Windows updates only."
                    fi
                ;;
                *)
                    fail "${FUNCNAME[0]} - Unknown update name: ${current_update}"
                ;;
            esac
        done
    fi
    return 0
}


function process_main_update ()
{
    local name="$1"
    local arch="$2"
    local lang="$3"
    local -i initial_errors="0"
    initial_errors="$(get_error_count)"

    # Create naming scheme.
    #
    # The variable ${timestamp_pattern} is used to create temporary files
    # like the timestamp files and the static and dynamic download
    # lists. It is also used in messages to identify the download task.
    #
    # The timestamp pattern is usually composed of the first three
    # positional parameters of this function:
    #
    # ${name}-${arch}-${lang}
    #
    # The timestamp pattern for Windows Vista, Windows 7 and .Net
    # Frameworks uses the original language as set on the command-line
    # of the download script, to keep track of localized downloads for
    # Internet Explorer and .Net Framework language packs.
    #
    # 64-bit Office updates for o2k10, o2k13 and o2k16 always
    # include 32-bit updates, and they are downloaded to the same
    # directories. Therefore, if 64-bit updates have been downloaded,
    # it is not necessary to download 32-bit updates again. The timestamp
    # files should still be different, to make sure, that the additional
    # 64-bit downloads are always included.
    #
    # The names for the hashes_file, hashed_dir and download_dir must
    # be synchronized with the Windows script DownloadUpdates.cmd.

    local timestamp_pattern="not-available"
    local hashes_file="not-available"
    local hashed_dir="not-available"
    local download_dir="not-available"
    local timestamp_file="not-available"
    local valid_static_links="not-available"
    local valid_dynamic_links="not-available"
    local valid_links="not-available"
    local -i interval_length="${interval_length_dependent_files}"
    local interval_description="${interval_description_dependent_files}"

    case "${name}" in
        win | wxp | w2k3 | w62 | w63 | w100)
            timestamp_pattern="${name}-${arch}-${lang}"
            if [[ "${arch}" == "x86" ]]
            then
                hashes_file="../client/md/hashes-${name}-${lang}.txt"
                hashed_dir="../client/${name}/${lang}"
                download_dir="../client/${name}/${lang}"
            else
                hashes_file="../client/md/hashes-${name}-${arch}-${lang}.txt"
                hashed_dir="../client/${name}-${arch}/${lang}"
                download_dir="../client/${name}-${arch}/${lang}"
            fi
        ;;
        w60 | w61)
            # The timestamp pattern includes the language list, as passed
            # on the command-line, because the downloads include localized
            # installers for Internet Explorer.
            timestamp_pattern="${name}-${arch}-${language_parameter}"
            if [[ "${arch}" == "x86" ]]
            then
                hashes_file="../client/md/hashes-${name}-${lang}.txt"
                hashed_dir="../client/${name}/${lang}"
                download_dir="../client/${name}/${lang}"
            else
                hashes_file="../client/md/hashes-${name}-${arch}-${lang}.txt"
                hashed_dir="../client/${name}-${arch}/${lang}"
                download_dir="../client/${name}-${arch}/${lang}"
            fi
        ;;
        ofc | o2k3 | o2k7 | o2k10 | o2k13 | o2k16)
            timestamp_pattern="${name}-${arch}-${lang}"
            hashes_file="../client/md/hashes-${name}-${lang}.txt"
            hashed_dir="../client/${name}/${lang}"
            download_dir="../client/${name}/${lang}"
        ;;
        dotnet)
            # The timestamp pattern includes the language list, as passed
            # on the command-line, because the downloads may include
            # additional language packs for languages other than English.
            timestamp_pattern="${name}-${arch}-${language_parameter}"
            hashes_file="../client/md/hashes-${name}-${arch}-${lang}.txt"
            hashed_dir="../client/${name}/${arch}-${lang}"
            download_dir="../client/${name}/${arch}-${lang}"
        ;;
        *)
            fail "${FUNCNAME[0]} - Unknown update name: ${name}"
        ;;
    esac

    # The download results are influenced by the options to include
    # Service Packs and to prefer security-only updates. If these options
    # change, then the affected downloads should be reevaluated. Including
    # the values of these two options in the name of the timestamp file
    # is a simple way to achieve that much.
    #
    # Somehow, the results for w60 are also affected by the option
    # prefer_seconly, although there is no special configuration for
    # Windows Vista.
    #
    # TODO: Maybe this should be done differently, but this would
    # require the script to read and write preferences and to detect
    # changed settings.
    case "${name}" in
        w60 | w61 | w62 | w63 | dotnet)
            timestamp_file="${timestamp_dir}/timestamp-${timestamp_pattern}-${include_service_packs}-${prefer_seconly}.txt"
        ;;
        *)
            timestamp_file="${timestamp_dir}/timestamp-${timestamp_pattern}-${include_service_packs}.txt"
        ;;
    esac
    valid_static_links="${temp_dir}/ValidStaticLinks-${timestamp_pattern}.txt"
    valid_dynamic_links="${temp_dir}/ValidDynamicLinks-${timestamp_pattern}.txt"
    valid_links="${temp_dir}/ValidLinks-${timestamp_pattern}.txt"

    if same_day "${timestamp_file}" "${interval_length}"
    then
        log_info_message "Skipped processing of \"${timestamp_pattern//-/ }\", because it has already been done less than ${interval_description} ago"
    else
        log_info_message "Start processing of \"${timestamp_pattern//-/ }\" ..."

        seconly_safety_guard "${name}"
        verify_integrity_database "${hashed_dir}" "${hashes_file}"
        calculate_static_updates "${name}" "${arch}" "${lang}" "${valid_static_links}"
        calculate_dynamic_updates "${name}" "${arch}" "${lang}" "${valid_dynamic_links}"
        download_static_files "${download_dir}" "${valid_static_links}"
        download_multiple_files "${download_dir}" "${valid_dynamic_links}"
        cleanup_client_directory "${download_dir}" "${valid_static_links}" "${valid_dynamic_links}" "${valid_links}"
        verify_digital_file_signatures "${download_dir}"
        create_integrity_database "${hashed_dir}" "${hashes_file}"
        verify_embedded_checksums "${hashed_dir}" "${hashes_file}"

        if same_error_count "${initial_errors}"
        then
            update_timestamp "${timestamp_file}"
            log_info_message "Done processing of \"${timestamp_pattern//-/ }\""
        else
            log_warning_message "There were $(get_error_difference "${initial_errors}") runtime errors for \"${timestamp_pattern//-/ }\". See the download log for details."
        fi
    fi

    echo ""
    return 0
}


function calculate_static_updates ()
{
    local name="$1"
    local arch="$2"
    local lang="$3"
    local valid_static_links="$4"
    local current_dir=""
    local current_lang=""
    local -a exclude_lists_static=()

    # Usually, there should be a non-empty file with one of the names:
    #
    # - StaticDownloadLinks-${name}-${lang}.txt
    # - StaticDownloadLinks-${name}-${arch}-${lang}.txt
    #
    # Testing these files beforehand may prevent unnecessary messages,
    # if the created file is empty.

    case "${name}" in
        win)
            # Nominally, this contains 32-bit updates (x86) only,
            # but in the end, it was a mixture of 32-bit and 64-bit
            # downloads. The architecture was removed from the filename
            # in WSUS Offline Update, version 10.4. The localized static
            # download files for win in WSUS Offline Update 9.2.x ESR
            # are all empty.
            require_non_empty_file \
            "../static/StaticDownloadLinks-${name}-${arch}-${lang}.txt" \
            || require_non_empty_file \
            "../static/StaticDownloadLinks-${name}-${lang}.txt" \
            || return 0
        ;;
        wxp | w2k3 | w60 | w61 | w62 | w63 | w100)
            # 32-bit and 64-bit downloads use the same naming scheme
            require_non_empty_file \
            "../static/StaticDownloadLinks-${name}-${arch}-${lang}.txt" \
            || return 0
        ;;
        dotnet)
            # The global static download files for dotnet may be
            # empty after removing the default German and English
            # installers. Localized updates are added again using the
            # original language from the command line.
            require_file \
            "../static/StaticDownloadLinks-${name}-${arch}-${lang}.txt" \
            || return 0
        ;;
        ofc | o2k3 | o2k7)
            # 32-bit downloads only
            require_non_empty_file \
            "../static/StaticDownloadLinks-${name}-${lang}.txt" \
            || return 0
        ;;
        o2k10 | o2k13 | o2k16)
            # 32-bit and 64-bit downloads with different naming
            # schemes. Both are needed, if 64-bit downloads are selected.
            require_non_empty_file \
            "../static/StaticDownloadLinks-${name}-${lang}.txt" \
            || require_non_empty_file \
            "../static/StaticDownloadLinks-${name}-${arch}-${lang}.txt" \
            || return 0
        ;;
    esac

    log_info_message "Determining static update links ..."

    # Reset output files
    > "${temp_dir}/StaticDownloadLinks-${name}-${arch}-${lang}.txt"
    > "${valid_static_links}"
    for current_dir in ../static ../static/custom
    do
        # Global "win" updates (since version 10.4), 32-bit Office updates
        if [[ -s "${current_dir}/StaticDownloadLinks-${name}-${lang}.txt" ]]
        then
            cat_dos "${current_dir}/StaticDownloadLinks-${name}-${lang}.txt" \
                >> "${temp_dir}/StaticDownloadLinks-${name}-${arch}-${lang}.txt"
        fi
        # Global updates for Windows and .NET Frameworks, 64-bit Office
        # updates
        if [[ -s "${current_dir}/StaticDownloadLinks-${name}-${arch}-${lang}.txt" ]]
        then
            cat_dos "${current_dir}/StaticDownloadLinks-${name}-${arch}-${lang}.txt" \
                >> "${temp_dir}/StaticDownloadLinks-${name}-${arch}-${lang}.txt"
        fi
        # Localized updates for Internet Explorer and .NET Frameworks
        #
        # The search patterns are extracted from the Windows script
        # AddCustomLanguageSupport.cmd
        #
        # There are no global installation files for Internet
        # Explorer. Static download links for "dotnet ${arch} glb" are
        # already included in the patterns above. This means, that glb
        # does not need to be added to the language list at this point.
        case "${name}" in
            w60)
                # Localized installers for Internet Explorer 8 and 9
                # on Windows Vista. Only IE 9 is supported in recent
                # versions of WSUS Offline Update.
                for current_lang in "${languages_list[@]}"
                do
                    if [[ -s "${current_dir}/StaticDownloadLinks-ie8-w60-${arch}-${current_lang}.txt" ]]
                    then
                        cat_dos "${current_dir}/StaticDownloadLinks-ie8-w60-${arch}-${current_lang}.txt" \
                            >> "${temp_dir}/StaticDownloadLinks-${name}-${arch}-${lang}.txt"
                    fi
                done
            ;;
            w61)
                # Localized installers for Internet Explorer 9, 10,
                # and 11 on Windows 7. Only IE 11 is supported in recent
                # versions of WSUS Offline Update.
                for current_lang in "${languages_list[@]}"
                do
                    if [[ -s "${current_dir}/StaticDownloadLinks-ie9-w61-${arch}-${current_lang}.txt" ]]
                    then
                        cat_dos "${current_dir}/StaticDownloadLinks-ie9-w61-${arch}-${current_lang}.txt" \
                            >> "${temp_dir}/StaticDownloadLinks-${name}-${arch}-${lang}.txt"
                    fi
                done
            ;;
            dotnet)
                for current_lang in "${languages_list[@]}"
                do
                    if [[ -s "${current_dir}/StaticDownloadLinks-dotnet-${arch}-${current_lang}.txt" ]]
                    then
                        grep_dos -F -i "dotnetfx35langpack_${arch}" \
                            "${current_dir}/StaticDownloadLinks-dotnet-${arch}-${current_lang}.txt" \
                            >> "${temp_dir}/StaticDownloadLinks-${name}-${arch}-${lang}.txt" || true
                    fi
                done
            ;;
        esac
    done
    sort_in_place "${temp_dir}/StaticDownloadLinks-${name}-${arch}-${lang}.txt"

    # Service Packs are already included in the static download links
    # file created above. If the command line option -includesp is not
    # used, then Service Packs must be removed again using the file
    # ExcludeList-SPs.txt as a blacklist.
    exclude_lists_static=( "../exclude/custom/ExcludeListForce-all.txt" )
    if [[ "${include_service_packs}" == "disabled" ]]
    then
        exclude_lists_static+=( "../exclude/ExcludeList-SPs.txt" )
    fi
    # The combined exclude list is the same for all static downloads;
    # therefore, the name is just "ExcludeListStatic.txt".
    apply_exclude_lists \
        "${temp_dir}/StaticDownloadLinks-${name}-${arch}-${lang}.txt" \
        "${valid_static_links}" \
        "${temp_dir}/ExcludeListStatic.txt" \
        "${exclude_lists_static[@]}"

    # Static downloads are mostly installers and service packs. If these
    # files are excluded from the download, then the download list may
    # be empty. This is not an error.
    if ensure_non_empty_file "${valid_static_links}"
    then
        log_info_message "Created file ${valid_static_links##*/}"
    else
        log_warning_message "No static updates found for ${name} ${arch} ${lang}"
    fi
    return 0
}


function calculate_dynamic_updates ()
{
    local name="$1"
    local arch="$2"
    local lang="$3"
    local valid_dynamic_links="$4"

    case "${name}" in
        win)
            if [[ "${dynamic_win_updates}" == "enabled" ]]
            then
                calculate_dynamic_windows_updates "$@"
            else
                log_info_message "Dynamic updates for win are disabled in this version of WSUS Offline Update."
            fi
        ;;
        wxp | w2k3 | w60 | w61 | w62 | w63 | w100 | dotnet)
            calculate_dynamic_windows_updates "$@"
        ;;
        ofc)
            calculate_dynamic_office_updates "$@"
        ;;
        *)
            log_debug_message "${FUNCNAME[0]}: Dynamic updates are not available for ${name}"
        ;;
    esac
    return 0
}


function calculate_dynamic_windows_updates ()
{
    local name="$1"
    local arch="$2"
    local lang="$3"
    local valid_dynamic_links="$4"
    local -a exclude_lists_windows=()

    require_non_empty_file "../xslt/ExtractDownloadLinks-${name}-${arch}-${lang}.xsl" || return 0
    require_non_empty_file "${used_superseded_updates_list}" || fail "The required file ${used_superseded_updates_list} is missing"
    require_non_empty_file "${cache_dir}/package.xml" || fail "The required file package.xml is missing"

    log_info_message "Determining dynamic update links ..."

    # Reset existing files
    > "${valid_dynamic_links}"

    # Extract dynamic download links
    "${xmlstarlet}" tr "../xslt/ExtractDownloadLinks-${name}-${arch}-${lang}.xsl" \
        "${cache_dir}/package.xml" \
        > "${temp_dir}/DynamicDownloadLinks-${name}-${arch}-${lang}.txt"
    sort_in_place "${temp_dir}/DynamicDownloadLinks-${name}-${arch}-${lang}.txt"

    # Removal of superseded and excluded download links
    #
    # Rather than using one big exclude list file, the calculation of
    # valid dynamic links is now done in two steps:
    #
    # Step 1: Superseded updates are removed by matching two sorted files
    # with complete URLs with "join". This is more efficient than using
    # "grep", which can easily run out of memory at this step.
    #
    # join -v1 does a "left join" and writes lines, which are unique on
    # the left side.
    if [[ -s "${used_superseded_updates_list}" ]]
    then
        join -v1 "${temp_dir}/DynamicDownloadLinks-${name}-${arch}-${lang}.txt" \
            "${used_superseded_updates_list}" \
            > "${temp_dir}/DynamicDownloadLinksPruned-${name}-${arch}-${lang}.txt"
    else
        mv "${temp_dir}/DynamicDownloadLinks-${name}-${arch}-${lang}.txt" \
           "${temp_dir}/DynamicDownloadLinksPruned-${name}-${arch}-${lang}.txt"
    fi

    # Step 2: The remaining dynamic download links are compared to one
    # or more exclude lists, which contain KB numbers only.
    exclude_lists_windows=(
        "../exclude/ExcludeList-${name}-${arch}.txt"
        "../exclude/custom/ExcludeList-${name}-${arch}.txt"
        "../exclude/custom/ExcludeListForce-all.txt"
    )
    if [[ "${prefer_seconly}" == enabled ]]
    then
        exclude_lists_windows+=(
            "../client/exclude/HideList-seconly.txt"
            "../client/exclude/custom/HideList-seconly.txt"
        )
    fi
    if [[ "${include_service_packs}" == disabled ]]
    then
        exclude_lists_windows+=( "../exclude/ExcludeList-SPs.txt" )
    fi

    apply_exclude_lists \
        "${temp_dir}/DynamicDownloadLinksPruned-${name}-${arch}-${lang}.txt" \
        "${valid_dynamic_links}" \
        "${temp_dir}/ExcludeList-${name}-${arch}.txt" \
        "${exclude_lists_windows[@]}"

    # Dynamic updates should always be found, except for "win". But this
    # function should not be called with "win", so an empty output file
    # is unexpected.
    if ensure_non_empty_file "${valid_dynamic_links}"
    then
        log_info_message "Created file ${valid_dynamic_links##*/}"
    else
        log_warning_message "No dynamic updates found for ${name} ${arch} ${lang}"
    fi
    return 0
}


function calculate_dynamic_office_updates ()
{
    local name="$1"
    local arch="$2"
    local lang="$3"
    local valid_dynamic_links="$4"
    local language_locale=""
    local line=""
    local -a exclude_lists_office=()

    # The two halves of a bundle record
    local first_half=""
    local second_half=""
    # Fields of a bundle record
    local bundle_update_id=""
    local bundle_category_id=""
    local bundle_language_list=""
    # Fields of an update record
    local update_update_id=""
    local payload_file_id=""
    local update_language=""
    # Ignored parts in read operations
    local skip_rest=""

    # Preconditions
    [[ "${name}" == ofc ]] || return 0
    require_non_empty_file "${used_superseded_updates_list}" || fail "The required file ${used_superseded_updates_list} is missing"
    require_non_empty_file "${cache_dir}/package.xml" || fail "The required file package.xml is missing"

    log_info_message "Determining dynamic update links ..."

    # Convert language names like deu and enu to their locales de and en.
    language_locale="$(language_name_to_locale "${lang}")"

    # Reset existing files
    > "${valid_dynamic_links}"

    "${xmlstarlet}" tr ../xslt/ExtractUpdateCategoriesAndFileIds.xsl \
        "${cache_dir}/package.xml" \
        > "${temp_dir}/UpdateCategoriesAndFileIds.txt"

    # The XSLT transformation reads through the file package.xml and
    # exports the file UpdateCategoriesAndFileIds.txt as a mixture of
    # bundle records and update records.
    #
    # In the resulting file, bundle records have the general structure:
    #
    # - Bundle-UpdateId [,EulaFileId,EulaFileId,...]; CategoryId
    #   [,Language,Language,...]
    #
    # The semicolon is used for bundle records only. Using this separator,
    # a bundle record can be split into two halves:
    #
    # - first half: Bundle-UpdateId [,EulaFileId,EulaFileId,...]
    # - second half: CategoryId [,Language,Language,...]
    #
    # This split is used in the first read operation, to distinguish
    # bundle records and update records: For update records, the second
    # half is empty.
    #
    # EulaFileIds and Languages are both optional.
    #
    # EulaFiles are extracted, because the XSLT transformation doesn't
    # distinguish between Eula files and payload files. But the EulaFiles
    # are not needed and will simply be ignored.
    #
    # All bundle languages are read into the variable
    # ${bundle_language_list}. There is no additional variable
    # ${skip_rest} to receive any remaining fields (which is otherwise
    # common for read).
    #
    # In the Windows script DownloadUpdates.cmd, this corresponds to
    # the line:
    #
    # for /F "tokens=1* delims=," %%k in ("%%j") do
    #
    # which creates two variables only, with the second variable to
    # receive all remaining fields from the input line.
    #
    # Update records have the general structure:
    #
    # - Update-UpdateId, PayloadFileId [,Language,Language,...]
    #
    # There is only one FileId for the payload file and optionally
    # one or more languages in an update record. But, with this read
    # operation, only the first language is actually stored into the
    # variable ${update_language}. All remaining fields are read into
    # the variable ${skip_rest} and will be discarded.
    #
    # In the Windows script DownloadUpdates.cmd, this corresponds to
    # the line:
    #
    # for /F "tokens=1-3 delims=," %%k in ("%%i") do
    #
    # which creates 3 variables for the first 3 tokens, while all
    # remaining tokens will be discarded.

    while IFS=';' read -r first_half second_half skip_rest
    do
        if [[ -z "${second_half}" ]]
        then
            # Parse an update record
            if [[ "${bundle_category_id}" == "477b856e-65c4-4473-b621-a8b230bb70d9" ]]
            then
                IFS=',' read -r update_update_id payload_file_id update_language skip_rest <<< "${first_half}"
                if [[ -n "${payload_file_id}" ]]
                then
                    if [[ "${lang}" == "glb" ]]
                    then
                        # Updates are considered "global", if there is
                        # no language specified at all, or if English
                        # is the only available language.
                        if [[ -z "${bundle_language_list}" && -z "${update_language}" ]]
                        then
                            printf '%s\n' "${payload_file_id},${bundle_update_id}"
                        elif [[ "${bundle_language_list}" == "en" && "${update_language}" == "en" ]]
                        then
                            printf '%s\n' "${payload_file_id},${bundle_update_id}"
                        fi
                    else
                        # For localized updates, the update language and
                        # the locale must match.
                        if [[ "${update_language}" == "${language_locale}" ]]
                        then
                            printf '%s\n' "${payload_file_id},${bundle_update_id}"
                        fi
                    fi
                fi
            fi
        else
            # Parse the two halves of a bundle record
            IFS=',' read -r bundle_update_id skip_rest <<< "${first_half}"
            IFS=',' read -r bundle_category_id bundle_language_list <<< "${second_half}"
        fi
    done < "${temp_dir}/UpdateCategoriesAndFileIds.txt" \
         > "${temp_dir}/OfficeFileAndUpdateIds.txt"

    # Generally, files should be sorted by the first field only, if
    # they are matched with join later. But the FileId has a fixed
    # length, and then the files OfficeFileAndUpdateIds.txt and
    # UpdateCabExeIdsAndLocations.txt can be sorted by the whole line.
    #
    # Similarly, appending a hash "#" to the end of a number field
    # stabilizes the search, if the numbers have different lengths,
    # because the hash comes before all alphanumerical characters in a
    # traditional C sort using native byte values (LC_ALL=C).
    sort_in_place "${temp_dir}/OfficeFileAndUpdateIds.txt"
    cut -d ',' -f 1 "${temp_dir}/OfficeFileAndUpdateIds.txt" > "${temp_dir}/OfficeFileIds.txt"
    remove_duplicates "${temp_dir}/OfficeFileIds.txt"

    "${xmlstarlet}" tr ../xslt/ExtractUpdateCabExeIdsAndLocations.xsl \
        "${cache_dir}/package.xml" \
        > "${temp_dir}/UpdateCabExeIdsAndLocations.txt"
    sort_in_place "${temp_dir}/UpdateCabExeIdsAndLocations.txt"

    # Field order:
    # File 1: OfficeFileIds.txt
    # - Field 1: FileId
    # File 2: UpdateCabExeIdsAndLocations.txt
    # - Field 1: FileId
    # - Field 2: Location (URL)

    # Write Office FileIds and Locations. Since both input files are
    # sorted, the output file will be sorted as well.
    join -t ',' "${temp_dir}/OfficeFileIds.txt" \
        "${temp_dir}/UpdateCabExeIdsAndLocations.txt" \
        > "${temp_dir}/OfficeUpdateCabExeIdsAndLocations.txt"

    # Field order:
    # File 1: OfficeUpdateCabExeIdsAndLocations.txt
    # - Field 1.1: FileId
    # - Field 1.2: Location (URL)
    # File 2: OfficeFileAndUpdateIds.txt
    # - Field 2.1: FileId
    # - Field 2.2: Bundle-UpdateId

    # Extract Office Locations
    cut -d ',' -f 2 "${temp_dir}/OfficeUpdateCabExeIdsAndLocations.txt" \
        > "${temp_dir}/DynamicDownloadLinks-${name}-${lang}.txt"
    sort_in_place "${temp_dir}/DynamicDownloadLinks-${name}-${lang}.txt"

    # Write Bundle-UpdateIds and URLs
    join -t ',' -o 2.2,1.2 "${temp_dir}/OfficeUpdateCabExeIdsAndLocations.txt" \
        "${temp_dir}/OfficeFileAndUpdateIds.txt" \
        > "${temp_dir}/UpdateTableURL-${name}-${lang}.csv"

    # Extract Bundle-UpdateIds and Filenames
    #
    # TODO: this should be done after removing superseded and excluded
    # updates, so that this file is more in sync with the actual downloads
    mkdir -p "../client/ofc"
    while read -r line
    do
        printf '%s\r\n' "${line%%,*},${line##*/}"
    done < "${temp_dir}/UpdateTableURL-${name}-${lang}.csv" \
         > "../client/ofc/UpdateTable-${name}-${lang}.csv"

    # Removal of superseded and excluded download links
    #
    # Step 1: Remove superseded updates by matching complete URLs.
    #
    # join -v1 does a "left join" and returns lines, which are unique
    # on the left side.
    #
    # TODO: The two alternate lists ExcludeList-Linux-superseded.txt
    # and ExcludeList-Linux-superseded-seconly.txt only make a
    # difference for Windows 7, 8 and 8.1 and the corresponding
    # Windows Server versions. For Office updates, the file
    # ExcludeList-Linux-superseded.txt could be used as before.
    if [[ -s "${used_superseded_updates_list}" ]]
    then
        join -v1 "${temp_dir}/DynamicDownloadLinks-${name}-${lang}.txt" \
            "${used_superseded_updates_list}" \
            > "${temp_dir}/DynamicDownloadLinksPruned-${name}-${lang}.txt"
    else
        mv "${temp_dir}/DynamicDownloadLinks-${name}-${lang}.txt" \
           "${temp_dir}/DynamicDownloadLinksPruned-${name}-${lang}.txt"
    fi

    # Step 2: Apply exclude lists with KB numbers only
    exclude_lists_office=(
        "../exclude/ExcludeList-ofc.txt"
        "../exclude/ExcludeList-ofc-${lang}.txt"
        "../exclude/custom/ExcludeList-ofc.txt"
        "../exclude/custom/ExcludeList-ofc-${lang}.txt"
        "../exclude/custom/ExcludeListForce-all.txt"
    )
    if [[ "${include_service_packs}" == disabled ]]
    then
        exclude_lists_office+=( "../exclude/ExcludeList-SPs.txt" )
    fi

    apply_exclude_lists \
        "${temp_dir}/DynamicDownloadLinksPruned-${name}-${lang}.txt" \
        "${valid_dynamic_links}" \
        "${temp_dir}/ExcludeList-ofc-${lang}.txt" \
        "${exclude_lists_office[@]}"

    # Dynamic updates should always be found for "ofc".
    if ensure_non_empty_file "${valid_dynamic_links}"
    then
        log_info_message "Created file ${valid_dynamic_links##*/}"
    else
        log_warning_message "No dynamic updates found for ${name} ${arch} ${lang}"
    fi
    return 0
}

# Safety guard for security only updates for Windows 7, 8, 8.1 and the
# corresponding server versions.
#
# The download and installation of security only updates depends on the
# correct configuration of the files:
#
# - wsusoffline/client/exclude/HideList-seconly.txt
# - wsusoffline/client/static/StaticUpdateIds-w61-seconly.txt
# - wsusoffline/client/static/StaticUpdateIds-w62-seconly.txt
# - wsusoffline/client/static/StaticUpdateIds-w63-seconly.txt
#
# These files must be updated after the official patch day, which
# is the second Tuesday each month. This is done by the maintainer
# of WSUS Offline Update, and new configuration files are downloaded
# automatically.
#
# In the meantime, the safety guard compares the file modification date
# of the configuration files to the date of the official patch day,
# which is the second Tuesday each month.
#
# If the configuration files have not yet been updated after the official
# patch day, the download will be stopped, to prevent unwanted side
# effects.

function seconly_safety_guard ()
{
    local name="$1"

    # Preconditions
    if [[ "${prefer_seconly}" != "enabled" ]]
    then
        log_debug_message "Option prefer_seconly is not enabled"
        return 0
    fi
    case "${name}" in
        w61 | w62 | w63)
            log_debug_message "Recognized Windows 7, 8, 8.1"
        ;;
        *)
            log_debug_message "Not an affected Windows version"
            return 0
        ;;
    esac

    # A crude attempt to get the official patch day, which is the second
    # Tuesday each month. The comparison with "Tuesday" requires,
    # that LC_TIME is set to "C", to get locale independent date
    # strings. This is done by the calling scripts update-generator.bash
    # and download-updates.bash, since they are responsible for setting
    # up the environment.

    local this_month=""
    this_month="$(date '+%Y-%m')"      # for example 2017-08

    local i=""
    local current_date=""              # ISO format: 2017-08-08
    local day_of_week=""               # weekday names: Monday, Tuesday...
    local second_tuesday=""            # for example 2017-08-08
    local -i second_tuesday_seconds=0  # seconds since 1970-01-01
    for i in 08 09 10 11 12 13 14
    do
        current_date="${this_month}-${i}"
        day_of_week="$(date -d "${current_date}" '+%A')"
        if [[ "${day_of_week}" == "Tuesday" ]]
        then
            second_tuesday="${current_date}"
            second_tuesday_seconds="$(date -d "${current_date}" '+%s')"
        fi
    done

    # The safety guard should run each month, starting at the official
    # patch day, and then until the end of the month.

    local -i this_day_seconds=0
    this_day_seconds="$(date '+%s')"
    if (( this_day_seconds < second_tuesday_seconds ))
    then
        return 0
    fi

    log_info_message "Running safety guard for security only update rollups"

    # Create a list of configuration files for the correct handling of
    # security only update rollups. This list only includes the default
    # files of WSUS Offline Update, not user-created files in the custom
    # subdirectories.
    #
    # Appending an asterisk will remove the files from the list, if they
    # cannot be found anymore.

    local -a configuration_files=()
    shopt -s nullglob
    configuration_files=(
        ../client/exclude/HideList-seconly.txt*
        ../client/static/StaticUpdateIds-w61-seconly.txt*
        ../client/static/StaticUpdateIds-w62-seconly.txt*
        ../client/static/StaticUpdateIds-w63-seconly.txt*
    )
    shopt -u nullglob

    # The configuration files are usually updated after the official patch
    # day. The script displays a warning, if the modification date of
    # a configuration file is before the official patch day of the month.

    local current_file=""
    local modification_date=""            # ISO format for display
    local -i modification_date_seconds=0  # seconds since 1970-01-01
    local -i misconfiguration=0
    for current_file in "${configuration_files[@]}"
    do
        modification_date="$(date -r "${current_file}" --iso-8601)"
        modification_date_seconds="$(date -r "${current_file}" '+%s')"
        if (( modification_date_seconds < second_tuesday_seconds ))
        then
            log_warning_message "The configuration file ${current_file} was last modified on ${modification_date}, which is before the official patch day ${second_tuesday} of this month."
            misconfiguration=1
        fi
    done

    if (( misconfiguration == 1 ))
    then
        log_warning_message "\
The correct handling of security only update rollups for both download
and installation depends on the configuration files:

- wsusoffline/client/exclude/HideList-seconly.txt
- wsusoffline/client/static/StaticUpdateIds-w61-seconly.txt
- wsusoffline/client/static/StaticUpdateIds-w62-seconly.txt
- wsusoffline/client/static/StaticUpdateIds-w63-seconly.txt

These files should be updated after the official patch day, which is the
second Tuesday each month. This is done by the maintainer of WSUS Offline
Update, but it may take some days. New versions of the configuration
files are downloaded automatically.

If these files have not been updated yet, the download and installation
of security only updates should be postponed, to prevent unwanted side
effects.

If necessary, you could also update the configuration files yourself. See
the discussion in the forum for details:

- http://forums.wsusoffline.net/viewtopic.php?f=4&t=6897&start=10#p23708

If you have manually updated and verified the configuration files, you
can set the variable exit_on_configuration_problems to disabled in the
preferences file.
"
        if [[ "${exit_on_configuration_problems}" == "enabled" ]]
        then
            log_error_message "The script will exit now, to prevent unwanted side effects with the download and installation of security only updates for Windows 7, 8, and 8.1. Setting the variable exit_on_configuration_problems to disabled in the preferences file will let the script continue, regardless of possible configuration problems."
            exit 0
        else
            log_warning_message "There are configuration problems with the download of security only updates for Windows 7, 8, and 8.1. Proceed with caution to prevent unwanted side effects."
        fi
    else
        log_info_message "No problems found"
    fi

    return 0
}

# ========== Commands =====================================================

get_main_updates
return 0
