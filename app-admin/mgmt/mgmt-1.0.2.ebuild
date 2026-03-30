# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit go-module

DESCRIPTION="Event-driven, parallel config management"
HOMEPAGE="
	https://purpleidea.com/tags/mgmtconfig/
	https://github.com/purpleidea/mgmt
"
SRC_URI="https://github.com/purpleidea/mgmt/archive/refs/tags/${PV}.tar.gz -> ${P}.tar.gz"
SRC_URI+=" https://download.jkns.pl/gentoo/${P}-vendor.tar.xz"
SRC_URI+=" https://download.jkns.pl/gentoo/${P}-deps.tar.xz"

LICENSE="GPL-3"
LICENSE+=" Apache-2.0 BSD-2 BSD ISC LGPL-3 MIT MPL-2.0"
SLOT="0"
KEYWORDS="~amd64"

DEPEND="dev-libs/libxml2"
RDEPEND="${DEPEND}"
BDEPEND=">=dev-lang/go-1.25.7"

RESTRICT="test"
DOCS=( README.md )

src_compile() {
	local go_buildargs=(
		-trimpath
		-tags='noaugeas novirt nodocker'
		-ldflags=github.com/purpleidea/mgmt="-X main.program=mgmt -X main.version=${PV}"
	)

	ego build "${go_buildargs[@]}" -o ${PN} .
}

src_install() {
	einstalldocs

	dobin "${S}/mgmt"
}
