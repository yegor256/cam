#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2021-2026 Yegor Bugayenko
# SPDX-License-Identifier: MIT
set -e -o pipefail

stdout=$2

{
    javac -version
    mvn --version
    gradle --version
    java -jar "${JPEEK}" --help
} > "${stdout}" 2>&1
echo "👍🏻 jPeek dependencies are installed"

{
    repo="yegor256/jaxec"
    echo -e "name\n${repo}" > "${TARGET}/repositories.csv"
    rm -rf "${TARGET}/github"
    mkdir -p "${TARGET}/github/${repo}"
    cp -r "${LOCAL}/fixtures/jaxec"/* "${TARGET}/github/${repo}"
    msg=$("${LOCAL}/steps/jpeek-repo.sh" "${repo}" 1 1)
    test "$(echo "${msg}" | grep -c "0 classes, sum is 0")" = 0
    echo "${msg}" | grep "Analyzed ${repo} through jPeek"
    echo "${msg}" | grep ", 2 classes"
    mfile=${TARGET}/measurements/${repo}/src/main/java/com/yegor256/Jaxec.java.m.NHD
    test -e "${mfile}"
    value=$(cat "${mfile}")
    test ! "${value}" = '0'
    test ! "${value}" = 'NaN'
    test -e "${TARGET}/measurements/${repo}/src/main/java/com/yegor256/Jaxec.java.m.NHD-cvc"
    test ! -e "${TARGET}/measurements/${repo}/src/main/java/com/yegor256/Jaxec.java.m.NHD-cvc-cvc"
    test "$(grep -Ec 'Success.*Maven' "${TARGET}/temp/jpeek_success.log")" = '1'
} > "${stdout}" 2>&1
echo "👍🏻 A simple repo analyzed with jpeek correctly"

{
    repo="foo/bar"
    rm -rf "${TARGET}/github"
    mkdir -p "${TARGET}/temp/jpeek-logs/${repo}"
    msg=$("${LOCAL}/steps/jpeek-repo.sh" "${repo}" 1 1)
    echo "${msg}" | grep "Repo ${repo} already analyzed by jPeek"
} > "${stdout}" 2>&1
echo "👍🏻 A duplicate analysis didn't happen"

{
    repo="foo/gradle"
    project=${TARGET}/github/${repo}
    mkdir -p "${project}/src/main/java/com/example"
    echo "rootProject.name = 'gradle-fixture'" > "${project}/settings.gradle"
    cat > "${project}/src/main/java/com/example/Foo.java" <<EOT
package com.example;
public final class Foo {
    private int value;
    public int increment() {
        return ++this.value;
    }
}
EOT
    cat > "${project}/build.gradle" <<EOT
apply plugin: 'java'
java {
    sourceCompatibility = JavaVersion.VERSION_17
    targetCompatibility = JavaVersion.VERSION_17
}
EOT
    msg=$("${LOCAL}/steps/jpeek-repo.sh" "${repo}" 1 1)
    echo "${msg}" | grep "Compiled ${repo} using Gradle"
    echo "${msg}" | grep "Analyzed ${repo} through jPeek"
    echo "${msg}" | grep ", 1 classes"
    test -e "${project}/build/classes/java/main/com/example/Foo.class"
    test -s "${TARGET}/measurements/${repo}/src/main/java/com/example/Foo.java.m.NHD"
    test "$(grep -Ec "Success ${repo} Gradle$" "${TARGET}/temp/jpeek_success.log")" = '1'
} > "${stdout}" 2>&1
echo "👍🏻 A Gradle repo compiled and analyzed with jpeek correctly"
