# Copyright 2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit flag-o-matic toolchain-funcs

DESCRIPTION="Realtime plotting utility for terminal"
HOMEPAGE="https://github.com/tenox7/ttyplot"
SRC_URI="https://github.com/tenox7/${PN}/archive/refs/tags/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"

DEPEND="sys-libs/ncurses:="
RDEPEND="${DEPEND}"
BDEPEND="virtual/pkgconfig"


src_configure() {
	append-libs $($(tc-getPKG_CONFIG) --libs ncurses)
}


src_compile() {
	# Makefile in 1.4 is broken
	$(tc-getCC) ${CFLAGS} ${LDFLAGS} -o ${PN} ${PN}.c ${LIBS} || die
}


src_install() {
	dobin ttyplot
}
