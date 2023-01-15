# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit qmake-utils xdg-utils

DESCRIPTION="Cross-platform comic reader and collection manager"

HOMEPAGE="http://www.yacreader.com"

if [[ ${PV} == 9999 ]];then
		inherit git-r3
		EGIT_REPO_URI="https://github.com/YACReader/${PN}.git"
else
		SRC_URI="https://github.com/YACReader/${PN}/archive/${PV}.tar.gz"
		KEYWORDS="~x86 ~amd64 ~arm"
fi

LICENSE="GPL-3"
SLOT="0"
IUSE="qrencode"

DEPEND="
		>=app-arch/unarr-1.1.0_pre20200131[7z]
		app-text/poppler[qt5]
		dev-qt/qtdeclarative:5
		dev-qt/qtimageformats:5
		dev-qt/qtmultimedia:5
		dev-qt/qtnetwork:5
		dev-qt/qtopengl:5
		dev-qt/qtquickcontrols:5
		dev-qt/qtquickcontrols2:5
		dev-qt/qtsql:5[sqlite]
		qrencode? ( media-gfx/qrencode:= )
		virtual/glu
"
RDEPEND="${DEPEND}"

IDEPEND="dev-util/desktop-file-utils"

src_configure(){
		eqmake5 YACReader.pro CONFIG+=unarr CONFIG+=no_pdf
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
