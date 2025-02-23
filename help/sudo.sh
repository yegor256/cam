#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2021-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT
set -e
set -o pipefail

if "${LOCAL}/help/is-linux.sh" || "${LOCAL}/help/is-macos.sh" ; then
   if [ ! "$(id -u)" = 0 ]; then
     echo "You should run it as root: 'sudo make install'"
     exit 1
   fi

   if [ "$1" == "--as-user" ]; then
     shift
     sudo -u "$SUDO_USER" "$@"
   else
     # If no flag is provided, root is the default option
     "$@"
   fi
 else
   sudo "$@"
 fi
