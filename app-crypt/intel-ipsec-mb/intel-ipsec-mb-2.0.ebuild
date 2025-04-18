# Copyright 2021-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

DESCRIPTION="Multi-Buffer Crypto for IPSec from Intel"
HOMEPAGE="https://github.com/intel/intel-ipsec-mb"

SRC_URI="https://github.com/intel/intel-ipsec-mb/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"
KEYWORDS="~amd64"

LICENSE="BSD"
SLOT="0"
IUSE="static-libs"
RESTRICT="test"

BDEPEND="
	>=dev-lang/nasm-2.14
"

src_configure(){
	local mycmakeargs=(
		-DBUILD_SHARED_LIBS=$(usex static-libs NO YES)
		-DSAFE_OPTIONS=OFF
		-DLIB_INSTALL_DIR=${EPREFIX}/usr/$(get_libdir)
		-DMAN_INSTALL_DIR=${EPREFIX}/usr/share/man
	)
	cmake_src_configure
}
