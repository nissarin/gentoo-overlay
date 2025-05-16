# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit go-module

DESCRIPTION="A Prometheus exporter for Unbound"
HOMEPAGE="https://github.com/letsencrypt/unbound_exporter"
SRC_URI="https://github.com/letsencrypt/unbound_exporter/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"
SRC_URI+=" https://download.nizgard.eu/gentoo/${P}-vendor.tar.xz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"

DEPEND=""
RDEPEND="${DEPEND}
	acct-group/unbound-telemetry
	acct-user/unbound-telemetry
"
BDEPEND=">=dev-lang/go-1.20"

src_compile() {
	ego build
}

src_install() {
	dobin unbound_exporter

	newinitd "${FILESDIR}"/"${PN}".initd ${PN}
	newconfd "${FILESDIR}"/"${PN}".confd ${PN}
}
