#!/bin/bash

home=$1
summary=$2
temp=$3

list="${temp}/non-java-files.txt"
find "${home}" -type file -not -name '*.java' -print > "${list}"
while IFS= read -r f; do
    echo rm "${f}"
done < "${list}"

cat <<EOT > "${summary}"
There are $(find "${home}" -type file | wc -l) files total.
$(find "${home}" -type file -name '*.java' | wc -l) of them are .java files.
All other files, which are not .java, have been deleted:
$(cat ${list} | wc -l) total.
EOT