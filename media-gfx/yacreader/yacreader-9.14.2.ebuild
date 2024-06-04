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
		app-text/poppler[qt5]
		dev-qt/qtdeclarative:5
		dev-qt/qtimageformats:5
		dev-qt/qtmultimedia:5
		dev-qt/qtnetwork:5
		dev-qt/qtopengl:5
		dev-qt/qtquickcontrols:5
		dev-qt/qtquickcontrols2:5
		dev-qt/qtsql:5[sqlite]
		pdf? ( app-text/poppler )
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
	eqmake5 YACReader.pro CONFIG+=unarr CONFIG+=$(usex pdf poppler no_pdf)
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
