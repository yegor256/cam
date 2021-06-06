#!/bin/bash

home=$1
summary=$2
temp=$3

list="${temp}/package-info-files.txt"
find "${home}" -type file -name 'package-info.java' -print > "${list}"
while IFS= read -r f; do
    rm -f "${f}"
done < "${list}"

cat <<EOT > "${summary}"
There were $(cat ${list} | wc -l) files named as \ff{package-info.java},
all of them were deleted.
EOT