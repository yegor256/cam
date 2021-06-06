#!/bin/bash

home=$1
summary=$2
temp=$3

total=$(find "${home}" -type file | wc -l)
java=$(find "${home}" -type file -name '*.java' | wc -l)

list="${temp}/non-java-files.txt"
find "${home}" -type file -not -name '*.java' -print > "${list}"
while IFS= read -r f; do
    rm -f "${f}"
done < "${list}"

cat <<EOT > "${summary}"
There are ${total} files total.
${java} of them are \ff{.java} files.
All other files, which are not \ff{.java}, have been deleted:
$(cat ${list} | wc -l) total.
EOT