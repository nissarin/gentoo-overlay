# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit go-module fcaps

DESCRIPTION="A private certificate authority & ACME server"
HOMEPAGE=""https://smallstep.com/certificates
SRC_URI="https://github.com/smallstep/certificates/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"
SRC_URI+=" https://download.jkns.pl/gentoo/${P}-vendor.tar.xz"

LICENSE="Apache-2.0 BSD-2 BSD MIT MPL-2.0"
SLOT="0"
KEYWORDS="~amd64"

DEPEND="sys-apps/pcsc-lite"
RDEPEND="
    ${DEPEND}
    acct-user/step-ca
    acct-group/step-ca
    app-crypt/step-cli
"
BDEPEND=">=dev-lang/go-1.25.0"

# Needs additional packages
RESTRICT="test"

FILECAPS=( cap_net_bind_service+ep usr/bin/step-ca )

S="${WORKDIR}/certificates-${PV}"


src_compile() {
    local build_date=$(date -u '+%Y-%m-%d %H:%M UTC')
    local go_ldflags=(
        -X main.Version=v${PV}
        -X \"main.BuildTime=${build_date}\"
    )

    CGO_ENABLED=1 ego build -trimpath -ldflags="${go_ldflags[*]}" -o step-ca ./cmd/step-ca
}


src_install() {
    dobin step-ca

    keepdir /var/log/step-ca

    newconfd "${FILESDIR}"/step-ca.confd step-ca
    newinitd "${FILESDIR}"/step-ca.initd step-ca

    einstalldocs
}


pkg_postinst() {
    if [[ -z "${REPLACING_VERSIONS}" ]] ; then
        elog "You might want to run:"
        elog "\"emerge --config =${CATEGORY}/${PF}\""
        elog "if this is a new install."
    fi
}

pkg_config() {
    export STEPPATH="/var/lib/step-ca"

    if [[ -d "${EROOT}${STEPPATH}/config" ]]; then
        ewarn "${EROOT}${STEPPATH}/config already exists,"
        ewarn "aborting to avoid damaging any existing configuration."
    else
        einfo "Press enter to interactively create a new configuration file for step-ca"
        einfo "To abort, press Control-C"
        read

        install -o step-ca -g step-ca -m 600 <(step crypto rand --format alphanumeric 40) \
            ${STEPPATH}/password
        install -o step-ca -g step-ca -m 600 <(step crypto rand --format alphanumeric 40) \
            ${STEPPATH}/provisioner_password
        su step-ca -p -s /bin/sh -c "/usr/bin/step ca init                 \
            --password-file=${STEPPATH}/password                           \
            --provisioner-password-file=${STEPPATH}/provisioner_password
        "
    fi
}
