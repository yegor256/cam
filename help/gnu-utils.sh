#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2021-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT
set -e
set -o pipefail


sed() {
    if "$LOCAL/help/is-macos.sh"; then
        # Use grealpath on macOS
        gsed "$@"
    else
        # Use realpath on other systems
        command sed "$@"
    fi
}
export -f sed

realpath() {
    if "$LOCAL/help/is-macos.sh"; then
        # Use grealpath on macOS
        grealpath "$@"
    else
        # Use realpath on other systems
        command realpath "$@"
    fi
}
export -f realpath

date() {
    if "${LOCAL}/help/is-macos.sh"; then
        # Use gdate from coreutils
        gdate "$@"
    else
        # Use date for other operating systems
        command date "$@"
    fi
}
export -f date
