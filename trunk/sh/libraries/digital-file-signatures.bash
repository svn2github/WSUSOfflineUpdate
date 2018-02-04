# This file will be sourced by the shell bash.
#
# Filename: digital-file-signatures.bash
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
#     This file implements a function, which uses Sysinternals Sigcheck
#     to validate digital file signatures.
#
#     This does not currently work for several reasons:
#
#     1. The Validation of digital signatures requires the installation
#        of the Microsoft root certificates and complete certificate
#        chains. Without these certificates, Sigcheck will only report,
#        if a file is "signed" or "unsigned".
#
#     2. wine uses a built-in library CRYPT32.dll, which does not
#        provide the necessary functionality. It may be replaced with a
#        "native" Windows library with winetricks. But without the needed
#        certificates, every file will show a generic error -2146885628
#        (0x80092004).
#
#     There are also compatibility issues:
#
#     - Sigcheck 2.2 and later require the CPU instruction set SSE2
#       and won't run on old CPUs like the Pentium III.
#
#     - Sigcheck 2.4 and later require Windows Vista.
#
#     Relevant errror codes for Sigcheck can be found in the document
#     "COM Error Codes (Security and Setup)":
#
#     - https://technet.microsoft.com/en-us/sysinternals/dd542646(v=vs.100)
#     - https://msdn.microsoft.com/en-us/windows/desktop/dd542646(v=vs.85)
#
#     CERT_E_EXPIRED
#     0x800B0101
#     A required certificate is not within its validity period when
#     verifying against the current system clock or the timestamp in
#     the signed file.
#
#     CRYPT_E_NOT_FOUND
#     0x80092004
#     Cannot find object or property.
#
#     TODO: In the Debian package wine-development, /usr/bin/wine is
#     renamed to /usr/bin/wine-development. Then both names should
#     be checked.
#
#     TODO: Two zip archives for Windows 7 are not digitally signed. These
#     need an exception.
#
#     TODO: Some updates for the Windows 10, released in April 2017, had
#     expired digital file signatures. This is not really an error. See
#     the discussion in the forum:
#
#     http://forums.wsusoffline.net/viewtopic.php?f=3&t=6540

function verify_digital_file_signatures ()
{
    local download_dir="$1"
    local sigcheck_output=""
    local windows_path=""
    local linux_path=""
    local file_validation=""
    local skip_rest=""
    local initial_errors="${runtime_errors}"

    # Check preconditions
    if [[ "${use_file_signature_verification}" == "disabled" ]]
    then
        log_info_message "Verification of digital file signatures is disabled in preferences"
        return 0
    fi
    if ! type -P wine > /dev/null
    then
        log_warning_message "Verification of digital file signatures requires wine"
        return 0
    fi
    if [[ ! -f ../bin/"${sigcheck_bin}" ]]
    then
        log_warning_message "Verification of digital file signatures requires Sysinternals Sigcheck"
        return 0
    fi
    if [[ -z "${DISPLAY:-}" ]]
    then
        log_warning_message "The environment variable DISPLAY is not set, either because no X server is running or environment variables are not passed to the script. As a command line application, Sigcheck should still work as expected. wine error messages may be neglected."
    fi
    if ! require_directory "${download_dir}"
    then
        log_error_message "The specified directory ${download_dir} does not exist."
        return 0
    fi

    # Begin processing
    log_info_message "Verifying digital file signatures for directory ${download_dir} ..."
    # Recent versions of Sigcheck use the option -nobanner instead of -q,
    # but there is way to check the file version in Linux. The online
    # documentation for Sigcheck seems to be wrong, since it doesn't
    # mention the new option -nobanner.
    #
    # http://forum.sysinternals.com/sigcheck-online-docu-is-wrong_topic32310.html
    # https://technet.microsoft.com/en-us/sysinternals/bb897441
    #
    # In Windows, the "banner" is written to standard output and can be
    # easily suppressed, but this may not work with wine.
    if [[ "${download_dir}" == "../client/dotnet" ]]
    then
        #local sigcheck_options=( "/accepteula" "-q" "-c" )             # for Sigcheck 2.0 - 2.4
        local sigcheck_options=(  "/accepteula" "-q" "-c" "-nobanner" ) # for Sigcheck 2.5 and higher
    else
        #local sigcheck_options=( "/accepteula" "-q" "-c" "-s" )
        local sigcheck_options=(  "/accepteula" "-q" "-c" "-s" "-nobanner" )
    fi
    sigcheck_output="$(wine "../bin/${sigcheck_bin}" "${sigcheck_options[@]}" "${download_dir}" 2> /dev/null | tail -n +2 | unquote)" || true
    log_debug_message "Sigcheck output:"
    log_debug_message "${sigcheck_output}"

    while IFS=',' read -r windows_path file_validation skip_rest
    do
        if [[ -z "${windows_path}" || -z "${file_validation}" ]]
        then
            fail "Error parsing Sigcheck output"
        fi
        # Using winepath to convert pathnames is better than hard-coding
        # the translation, but it generates unnecessarily long pathnames,
        # including symbolic links in ~/.wine/dosdevices/z:/
        linux_path="$(winepath --unix "${windows_path}")"
        log_debug_message "Windows path: ${windows_path}"
        log_debug_message "Linux path:   ${linux_path}"
        log_debug_message "Filename:     ${linux_path##*/}"
        log_debug_message "Validation:   ${file_validation}"

        case "${file_validation}" in
            Signed)
                # The file has a digital signature. With the default
                # configuration of wine, Sigcheck can not validate any
                # signatures, since root certificates are not available
                # and a library CRYPT32.dll needs to be replaced. Signed
                # files with wrong digital signatures are still reported
                # as "Signed" on Linux. The only distinction would be
                # between "Signed" and "Unsigned".
                :
            ;;
            Unsigned)
                # Usually, all files by Microsoft should be signed, but
                # this was forgotten for the last version of rootsupd.exe.
                if [[ "${linux_path##*/}" == "rootsupd.exe" ]]
                then
                    log_info_message "Kept unsigned file rootsupd.exe"
                else
                    trash_file "${linux_path}"
                    runtime_errors="$(( runtime_errors + 1 ))"
                    log_warning_message "Trashed/deleted unsigned file ${linux_path##*/}"
                fi
            ;;
            "Not a cryptographic message or the cryptographic message is not formatted correctly." | \
            "The digital signature of the object did not verify.")
                # The file is signed, but damaged.
                trash_file "${linux_path}"
                runtime_errors="$(( runtime_errors + 1 ))"
                log_warning_message "Trashed/deleted damaged file ${linux_path##*/}"
            ;;
            Error*)
                # Error -2146762495 (0x800b0101) means, that the
                # certificate has expired.
                #
                # Error -2146885628 (0x80092004) is a general error. It
                # probably means, that the certificate could not be
                # traced back to a root certificate. This may happen
                # with ALL signed files, if Sigcheck is running under
                # wine on Linux. It depends on the configuration of wine:
                # if the library crypt32.dll is replaced with winetricks,
                # Sigcheck tries to validate the signatures, but fails
                # on all signed files with this error code.
                #
                # In both cases, the file may be still valid and should
                # not be deleted.
                log_warning_message "Received \"${file_validation}\" for file ${linux_path##*/}"
            ;;
            *)
                # Empty files are "Unsigned", but very small files, with
                # a file length of only 2 bytes, may give the result
                # "Invalid parameter.". This message may be localized
                # as "Ungueltiger Parameter" in German. Of course,
                # the filename does not correspond to any known parameter.
                log_warning_message "Unknown result \"${file_validation}\" for file ${linux_path##*/}"
            ;;
        esac
    done <<< "${sigcheck_output}"

    if (( runtime_errors == initial_errors ))
    then
        log_info_message "Verified digital file signatures"
    else
        log_error_message "Verification of digital file signatures detected $(( runtime_errors - initial_errors )) errors"
    fi
    return 0
}

return 0
