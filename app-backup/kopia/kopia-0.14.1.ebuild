# Copyright 2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit go-module

DESCRIPTION="Fast and Secure Open-Source Backup"
HOMEPAGE=="https://kopia.io/"
SRC_URI="https://github.com/kopia/kopia/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"
SRC_URI+=" https://download.nizgard.eu/gentoo/${P}-vendor.tar.xz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE="+gui"

DEPEND=""
RDEPEND="${DEPEND}"
BDEPEND=">=dev-lang/go-1.21"


src_compile() {
	KOPIA_BUILD_TAGS="$(usev !gui "nohtmlui")"

	ego build -tags "${KOPIA_BUILD_TAGS}" .
}


src_install() {
	dobin kopia
}
