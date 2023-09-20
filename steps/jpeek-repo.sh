#!/bin/bash
# The MIT License (MIT)
#
# Copyright (c) 2021-2022 Yegor Bugayenko
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included
# in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
set -e
set -o pipefail

repo=$1
pos=$2
total=$3

start=$(date +%s)

project="${TARGET}/github/${repo}"

logs="${TARGET}/temp/jpeek-logs/${repo}"
mkdir -p "${logs}"

build() {
    if [ -e "${project}/gradlew" ]; then
        echo "Building ${repo} (${pos}/${total}) with Gradlew..."
        if ! "${project}/gradlew" classes -q -p "${project}" > "${logs}/gradlew.log" 2>&1; then
            echo "Failed to compile ${repo} using Gradlew, in $(echo "$(date +%s) - ${start}" | bc)s"
            exit
        fi
        echo "Сompiled ${repo} using Gradlew"
    elif [ -e "${project}/build.gradle" ]; then
        echo "Building ${repo} (${pos}/${total}) with Gradle..."
        echo "apply plugin: 'java'" >> "${d}/build.gradle"
        if ! gradle classes -q -p "${project}" > "${logs}/gradle.log" 2>&1; then
            echo "Failed to compile ${repo} using Gradle, in $(echo "$(date +%s) - ${start}" | bc)s"
            exit
        fi
        echo "Сompiled ${repo} using Gradle"
    elif [ -e "${project}/pom.xml" ]; then
        echo "Building ${repo} (${pos}/${total}) with Maven..."
        if ! mvn compiler:compile -quiet -DskipTests -f "${project}" -U > "${logs}/maven.log" 2>&1; then
            echo "Failed to compile ${repo} using Maven, in $(echo "$(date +%s) - ${start}" | bc)s"
            exit
        fi
        echo "Сompiled ${repo} using Maven, in $(echo "$(date +%s) - ${start}" | bc)s"
    else
        echo "Could not build classes in ${repo} (${pos}/${total}) (neither Maven nor Gradle project)"
        exit
    fi
}

jpeek() {
    java -jar ${JPEEK} --overwrite --include-ctors --include-static-methods \
        --include-private-methods --sources "${project}" \
        --target "${dir}" > "${logs}/jpeek-main.log" 2>&1
    java -jar ${JPEEK} --overwrite --sources "${project}" \
        --target "${dir}cvc" > "${logs}/jpeek-cvc.log" 2>&1
}

declare -i re=0
until build; do
    re=re+1
    echo "Retry #${re} for ${repo} (${pos}/${total})..."
done

measurements="$(echo "${project}" | sed "s|${TARGET}/github|${TARGET}/jpeek|")"

dir="${TARGET}/temp/jpeek"

start=$(date +%s)

if ! jpeek; then
    echo "Failed to calculate jpeek metrics in ${repo} (${pos}/${total}) due to jpeek.jar error"
    exit
fi

accept=".*[^index|matrix|skeleton].xml"
lastm=""

for jpeek in "${dir}" "${dir}cvc"; do
    for report in $(find "${jpeek}" -type f -maxdepth 1); do
        metric="$(basename "${report}" | sed "s|.xml||")"
        suffix=$(echo "${jpeek}" | sed "s|${dir}||")
        descsuffix=""
        if [ "${suffix}" != "" ]; then
            suffix="(${suffix})"
            descsuffix="In this case, the constructors are excluded from the metric formulas."
        fi
        if echo ${report} | grep -q ${accept}; then
            packages="$(xmlstarlet sel -t -v 'count(/metric/app/package/@id)' "${report}")"
            name="$(xmlstarlet sel -t -v "/metric/title" "${report}")"
            description="$(xmlstarlet sel -t -v "/metric/description" "${report}" | tr "\n" " " | sed "s|\s+| |g") ${descsuffix}"
            for ((i=1; i <= ${packages}; i++)); do
                package="$(echo "$(xmlstarlet sel -t -v "/metric/app/package[${i}]/@id" "${report}")" | sed "s|\.|/|g")"
                classes="$(xmlstarlet sel -t -v "count(/metric/app/package[${i}]/class/@id)" "${report}")"
                for ((j=1; j <= ${classes}; j++)); do
                    class="$(xmlstarlet sel -t -v "/metric/app/package[${i}]/class[${j}]/@id" "${report}")"
                    value="$(xmlstarlet sel -t -v "/metric/app/package[${i}]/class[${j}]/@value" "${report}")"
                    mfile="$(find "${project}" -path "*${package}/${class}.java" | sed "s|/github|/jpeek|")"
                    if [ ! -z "${mfile}" ]; then
                        mkdir -p "$(dirname ${mfile})"
                        echo "${name}${suffix} ${value} ${name}" >> "${mfile}"
                        lastm="${mfile}"
                    fi
                done
            done
        fi
    done
done
echo "${repo} analyzed through jPeek (${pos}/${total}) in $(echo "$(date +%s) - ${start}" | bc)s"
