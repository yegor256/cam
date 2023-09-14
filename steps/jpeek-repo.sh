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

project=$1
pos=$2
total=$3

JPEEK_MAIN="java -jar ${JPEEK} --overwrite --include-ctors --include-static-methods --include-private-methods"
JPEEK_CVC="java -jar ${JPEEK} --overwrite"

echo "Building project: ${project}"
if [ -e "${project}/gradlew" ]; then
    echo "Using gradlew"
    ${project}/gradlew classes -p "${project}" || break
elif [ -e "${project}/build.gradle" ]; then
    echo "Using build.gradle"
    echo "apply plugin: 'java'" >> "${d}/build.gradle"
    gradle classes -p "${project}" || break
elif [ -e "${project}/pom.xml" ]; then
    echo "Using mvn install"
    mvn compiler:compile -quiet -Dmaven.test.skip=true -f "${project}" -U || break
else
    echo "Could not build classes (not maven nor gradle project)..."
    continue
fi
measurements="$(echo "${project}" | sed "s|${TARGET}/github|${TARGET}/jpeek|")"
dir="${TARGET}/temp/jpeek"
echo "Old-fashioned..."
${JPEEK_MAIN} --sources "${project}" --target "${dir}"
echo "Ctors vs cohesion..."
${JPEEK_CVC} --sources "${project}" --target "${dir}cvc"
accept=".*[^index|matrix|skeleton].xml"
lastm=""
for jpeek in "${dir}" "${dir}cvc"; do
    echo "${jpeek}"
    for report in $(find "${jpeek}" -type f -maxdepth 1); do
        metric="$(basename "${report}" | sed "s|.xml||")"
        suffix=$(echo "${jpeek}" | sed "s|${dir}||")
        descsuffix=""
        if [ "${suffix}" != "" ];
        then
            suffix="(${suffix})"
            descsuffix="In this case, the constructors are excluded from the metric formulas."
        fi
        if echo ${report} | grep -q ${accept} ; then
            # echo "Found ${report}";
            packages="$(xmlstarlet sel -t -v 'count(/metric/app/package/@id)' "${report}")"
            # echo "There are ${packages} packages";
            name="$(xmlstarlet sel -t -v "/metric/title" "${report}")"
            description="$(xmlstarlet sel -t -v "/metric/description" "${report}" | tr "\n" " " | sed "s|\s+| |g") ${descsuffix}"
            for ((i=1; i <= ${packages}; i++))
            do
                package="$(echo "$(xmlstarlet sel -t -v "/metric/app/package[${i}]/@id" "${report}")" | sed "s|\.|/|g")"
                classes="$(xmlstarlet sel -t -v "count(/metric/app/package[${i}]/class/@id)" "${report}")"
                for ((j=1; j <= ${classes}; j++))
                do
                    class="$(xmlstarlet sel -t -v "/metric/app/package[${i}]/class[${j}]/@id" "${report}")"
                    value="$(xmlstarlet sel -t -v "/metric/app/package[${i}]/class[${j}]/@value" "${report}")"
                    mfile="$(find "${project}" -path "*${package}/${class}.java" | sed "s|/github|/jpeek|")"
                    if [ "${mfile}" != "" ]
                    then
                        # echo "${package}/${class}: ${value}"
                        mkdir -p "$(dirname ${mfile})"
                        echo "${name}${suffix} ${value} ${name}" >> "${mfile}"
                        lastm="${mfile}"
                    else
                        echo "${package}/${class}: can't find corresponding file"
                    fi
                done
            done
        fi
    done
done
echo "${project} analyzed through jPeek (${pos}/${total})"
