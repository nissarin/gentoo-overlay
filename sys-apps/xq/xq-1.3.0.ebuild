# Copyright 2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit go-module

DESCRIPTION="Command-line XML and HTML beautifier and content extractor"
HOMEPAGE="https://github.com/sibprogrammer/xq"
SRC_URI="https://github.com/sibprogrammer/xq/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"
SRC_URI+=" https://download.nizgard.eu/gentoo/${P}-vendor.tar.xz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

DEPEND=""
RDEPEND="${DEPEND}"
BDEPEND=">=dev-lang/go-1.23"


src_prepare() {
	default
	mv docs/xq.man docs/xq.1
}


src_compile() {
	ego build
}


src_install() {
	dobin xq
	doman docs/xq.1
}
