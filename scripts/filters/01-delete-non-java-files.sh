#!/bin/bash

home=$1
summary=$2
temp=$3

list="${temp}/non-java-files.txt"
find "${home}" -type file -not -name '*.java' > "${list}"
for f in $(cat "${list}"); do
    rm "${f}"
done

cat <<EOT > "${summary}"
There are $(find "${home}" -type file) files total.
$(find "${home}" -type file -name '*.java') of them are .java files.
All other files, which are .java, have been deleted:
$(wc -l ${list}) total.
EOT