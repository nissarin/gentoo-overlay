# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit go-module

DESCRIPTION="Prometheus exporter for bird routing daemon "
HOMEPAGE="https://github.com/czerwonk/bird_exporter"
SRC_URI="https://github.com/czerwonk/bird_exporter/archive/refs/tags/v${PV}.tar.gz"
SRC_URI+=" https://download.nizgard.eu/gentoo/${P}-vendor.tar.xz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

DEPEND=""
RDEPEND="${DEPEND}"
BDEPEND=">=dev-lang/go-1.24.3"

src_compile() {
	export CGO_ENABLED=0

	ego build .
}

src_install() {
	dobin bird_exporter

	newinitd "${FILESDIR}"/bird_exporter.initd bird_exporter
	newconfd "${FILESDIR}"/bird_exporter.confd bird_exporter
}
