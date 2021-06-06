#!/bin/bash

home=$1
summary=$2
temp=$3

total=$(find "${home}" -type file | wc -l)

list="${temp}/test-files.txt"
find "${home}" -type file -name '*Test.java' -o -name '*ITCase.java' -print > "${list}"
while IFS= read -r f; do
    rm -f "${f}"
done < "${list}"

cat <<EOT > "${summary}"
There were ${total} files total.
$(cat ${list} | wc -l) of them were test files
with \ff{Test} or \ff{ITCase} suffixes
and that's why were deleted.
EOT