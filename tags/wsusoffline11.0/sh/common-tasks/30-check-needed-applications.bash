# This file will be sourced by the shell bash.
#
# Filename: 30-check-needed-applications.bash
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
#     This script checks for needed and recommended applications, but
#     not for optional applications.
#
#     Needed applications: cabextract, hashdeep, wget, xmlstarlet
#
#     Recommended applications: gvfs-trash or trash-put
#
#     Optional applications: aria2, rsync, wine

# ========== Global variables =============================================

xmlstarlet=""
linux_trash_handler=""

# ========== Functions ====================================================

# Needed applications: cabextract, hashdeep, wget, xmlstarlet
#
# XMLStarlet
#
# The application XMLStarlet may be installed as /usr/bin/xml or
# /usr/bin/xmlstarlet, dependent on the distribution.
#
# The original documentation at http://xmlstar.sourceforge.net/docs.php
# refers to the binary as "xml". Simply compiling the unmodified upstream
# source code will get the binary "xml". The application name and the
# package name of this project are still set to XMLStarlet and xmlstarlet,
# respectively.
#
# Major distributions, like Debian and Red Hat (RPMForge, RepoForge),
# and subsequently Ubuntu and CentOS, now modify the source code to get
# the binary "xmlstarlet".
#
# In Debian, the binary name was "xmlstarlet" or "xml", depending on
# the architecture, but that was solved in 2006:
#
# Debian Bug report logs - #312932
# wrong binary name (xmlstarlet instead of xml) on i386
# https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=312932
#
# Remaining inconsistencies in the documentation were solved in 2011
# (but not ported back to Debian 7 Wheezy):
#
# Debian Bug report logs - #621755
# xml vs xmlstarlet inconsistencies in documentation
# https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=621755
#
# RepoForge, the successor of RPMForge, uses the name "xmlstarlet"
# for the binary as well. See the package contents at:
#
# http://pkgs.repoforge.org/xmlstarlet/
#
# So, while major Linux distributions use the binary name "xmlstarlet",
# I'm not sure about more archaic distributions, which like to use the
# unmodified upstream source, or the BSDs. Therefore, it may still be
# needed to check both binary names.
#
# Still, there is only one package to install: xmlstarlet. It was a
# mistake of the old Linux script, to request the installation of two
# packages (one of which never existed).

function check_needed_applications ()
{
    local binary_name=""
    local missing_binaries=0

    log_info_message "Checking needed applications..."

    for binary_name in xmlstarlet xml; do
        if type -P "$binary_name" > /dev/null; then
            xmlstarlet="$binary_name"
            break
        fi
    done

    if [[ -z "$xmlstarlet" ]]; then
        log_info_message "Please install the package xmlstarlet"
        missing_binaries="$(( missing_binaries + 1 ))"
    fi

    for binary_name in cabextract wget; do
        if ! type -P "$binary_name" > /dev/null; then
            log_info_message "Please install the package $binary_name"
            missing_binaries="$(( missing_binaries + 1 ))"
        fi
    done

    if ! type -P hashdeep > /dev/null; then
        log_info_message "Please install the command hashdeep,
- from package md5deep for Debian 7 Wheezy
- from package md5deep for Debian 8 Jessie
- from package hashdeep for Debian 8 Jessie-Backports
  Generally, install the package hashdeep, if available
  Otherwise, install the package md5deep, which used to provide the command hashdeep"
        missing_binaries="$(( missing_binaries + 1 ))"
        echo ""
    fi

    if (( missing_binaries == 1 )); then
        log_error_message "$missing_binaries needed command is missing"
        exit 1
    elif (( missing_binaries > 1 )); then
        log_error_message "$missing_binaries needed commands are missing"
        exit 1
    fi
}

# Recommended applications: gvfs-trash or trash-put
#
# It is safer to put outdated files into the trash than to delete them
# directly. Suitable trash handlers are:
#
# - gvfs-trash from package gvfs-bin, for GNOME 3 and other GTK-based
#   desktops environments
# - trash-put from package trash-cli, as a command-line interface to the
#   trash, which is desktop-independent. This should also work without
#   any graphical user interface.

function check_recommended_applications ()
{
    local binary_name=""

    log_info_message "Checking recommended applications..."

    for binary_name in gvfs-trash trash-put; do
        if type -P "$binary_name" > /dev/null; then
            linux_trash_handler="$binary_name"
            break
        fi
    done

    if [[ -z "$linux_trash_handler" ]]; then
        log_info_message "Please install a trash handler, to move files into the trash:
- gvfs-trash from package gvfs-bin for GNOME and LXDE
- trash-put from package trash-cli for other desktop environments and window managers"
    else
        log_info_message "Found Linux trash handler: $linux_trash_handler"
    fi
}

# Optional applications: Aria2, wine, rsync
#
# These applications are not tested by the script, but can be installed
# for some additional functionality.
#
# aria2 can be used as an alternate download utility. Note, that the
# application and package are usually called "aria2", but the binary is
# installed as "/usr/bin/aria2c".
#
# Timestamping works better with Aria2 than with old versions of
# Wget. Wget downloads the file again, whenever the files size changes,
# regardless of the modification date. This is still true for Wget 1.16
# as of Debian 8 stable/Jessie.
#
# Wget 1.17 and higher uses a much improved method for timestamping by
# sending a conditional header If-Modified-Since, just like aria2. Wget
# 1.18 is available in Debian 9 testing/Stretch.
#
# wine is needed to run Sysinternals Sigcheck.exe, but verifying file
# signatures doesn't really work without the necessary root certificates.
#
# rsync is used by the optional task 70-synchronize-with-target.bash,
# to copy the client directory to an external drive.

# ========== Commands =====================================================

check_needed_applications
check_recommended_applications
echo ""
return 0
