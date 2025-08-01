# Copyright 2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

DESCRIPTION="A high-performance DDoS detector/sensor"
HOMEPAGE="https://fastnetmon.com/"
SRC_URI="https://github.com/pavel-odintsov/fastnetmon/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"

DEPEND="
	dev-libs/boost
	dev-libs/libbpf
	dev-libs/log4cpp
	dev-libs/mongo-c-driver
	net-libs/grpc
	net-libs/libpcap
	sys-libs/ncurses
	virtual/libelf
"
RDEPEND="${DEPEND}"

# >=capnproto-1.0.1+ fixes build failures with recent compilers
BDEPEND="
	>=dev-libs/capnproto-1.0.1
"

CMAKE_USE_DIR="${S}/src"

PATCHES=(
	"${FILESDIR}/fastnetmon-1.2.8-Boost-migration.patch"
	"${FILESDIR}/fastnetmon-1.2.8-Implemented-move-constructor-in-dynamic_binary_buffe.patch"
)

src_configure() {
	local mycmakeargs=(
		-DLINK_WITH_ABSL=TRUE
	)
	cmake_src_configure
}


src_install() {
	cmake_src_install

	dodoc README.md SECURITY.md THANKS.md
}
