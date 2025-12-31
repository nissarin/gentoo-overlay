# Copyright 1999-2023 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit qmake-utils xdg-utils

DESCRIPTION="Cross-platform comic reader and collection manager"

HOMEPAGE="http://www.yacreader.com"

SRC_URI="https://github.com/YACReader/yacreader/archive/refs/tags/${PV}.tar.gz -> ${P}.tar.gz"
KEYWORDS="~amd64"

LICENSE="GPL-3"
SLOT="0"
IUSE="qrencode pdf"

DEPEND="
		>=app-arch/unarr-1.1.0
		dev-qt/qt5compat:6
		dev-qt/qtbase:6[network,widgets,opengl,sqlite]
		dev-qt/qtdeclarative:6
		dev-qt/qtimageformats:6
		dev-qt/qtmultimedia:6
		dev-qt/qtsvg:6
		pdf? ( app-text/poppler[qt6] )
		qrencode? ( media-gfx/qrencode:= )
		virtual/glu
"
RDEPEND="${DEPEND}"
BDEPEND=""

IDEPEND="dev-util/desktop-file-utils"

src_prepare() {
	default
	sed -i "s@\$\$DATADIR/doc/yacreader@\$\$DATADIR/doc/yacreader-${PV}@" "${S}/YACReader/YACReader.pro"
}

src_configure(){
	eqmake6 YACReader.pro CONFIG+=unarr CONFIG+=$(usex pdf poppler no_pdf) CONFIG+=server_bundled
}

src_install(){
		INSTALL_ROOT="${D}" default
}

pkg_postinst() {
		xdg_desktop_database_update
}

pkg_postrm() {
		xdg_desktop_database_update
}
