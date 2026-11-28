#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2021-2026 Yegor Bugayenko
# SPDX-License-Identifier: MIT
set -e -o pipefail

temp=$1
stdout=$2

{
    mkdir -p "${temp}/help" "${temp}/bin"
    printf '#!/usr/bin/env bash\nexit 1\n' > "${temp}/help/is-macos.sh"
    cp "${temp}/help/is-macos.sh" "${temp}/help/is-linux.sh"
    printf '#!/usr/bin/env bash\nexec "$@"\n' > "${temp}/help/sudo.sh"
    cat > "${temp}/bin/tlmgr" <<'MOCK'
#!/usr/bin/env bash
printf '<%s>' "$@" >> "${TLMGR_LOG}"
printf '\n' >> "${TLMGR_LOG}"
MOCK
    chmod +x "${temp}/help/"*.sh "${temp}/bin/tlmgr"
    installer="${LOCAL}/installs/install-texlive-depends.sh"
    for endings in lf crlf mixed; do
        case "${endings}" in
            lf) printf 'tex alpha\ntex alpha\ntex beta\n' ;;
            crlf) printf 'tex alpha\r\ntex alpha\r\ntex beta\r\n' ;;
            mixed) printf 'tex alpha\ntex alpha\r\ntex beta\r\n' ;;
        esac > "${temp}/DEPENDS.txt"
        log="${temp}/${endings}.log"
        LOCAL="${temp}" PATH="${temp}/bin:${PATH}" TLMGR_LOG="${log}" \
            bash "${installer}"
        grep -Fx '<--verify-repo=none><install><alpha><beta>' "${log}"
        grep -Fx '<--verify-repo=none><update><--no-auto-remove><alpha><beta>' "${log}"
    done
} > "${stdout}" 2>&1
