# Copyright 2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit go-module

DESCRIPTION="BGP implementation in Go"
HOMEPAGE="osrg.github.io/gobgp/"
SRC_URI="https://github.com/osrg/gobgp/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"
SRC_URI+=" https://download.jkns.pl/gentoo/${P}-vendor.tar.xz"


LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"

DEPEND=""
RDEPEND="${DEPEND}"
BDEPEND=">=dev-lang/go-1.24.1"

DOCS="LICENSE README.md"


src_compile() {
	ego build -tags=netgo ./cmd/gobgp
	ego build -tags=netgo ./cmd/gobgpd
}

src_install() {
	einstalldocs

	dobin gobgp
	dobin gobgpd
}
