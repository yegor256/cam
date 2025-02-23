#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2021-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT
set -e
set -o pipefail

temp=$1
stdout=$2

# To make sure it is installed
multimetric --help >/dev/null

{
    java="${temp}/Foo long 'weird' name (--).java"
    cat > "${java}" <<EOT
    import java.io.File;
    import java.io.IOException;
    class Foo extends Boo implements Bar {
        // This is static
        private static int X = 1;
        private java.io.File z;

        Foo(File zz) throws IOException {
            this.z = zz;
            zz.delete();
        }
        private final boolean boom() { return true; }
    }
EOT
    "${LOCAL}/metrics/multimetric.sh" "${java}" "${temp}/stdout"
    cat "${TARGET}/temp/multimetric.json"
    cat "${temp}/stdout"
    grep "HSD 6.000 " "${temp}/stdout"
    grep "HSE 1133.217 " "${temp}/stdout"
    grep "HSV 188.869 " "${temp}/stdout"
    grep "MIdx 100.000 " "${temp}/stdout"
    grep "FOut 0.000 " "${temp}/stdout"
} > "${stdout}" 2>&1
echo "👍🏻 Correctly counted a few metrics"
