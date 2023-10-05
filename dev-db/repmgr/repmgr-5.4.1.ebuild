# Copyright 2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

POSTGRES_COMPAT=( {10..15} )
POSTGRES_USEDEP="server"

inherit postgres-multi

DESCRIPTION="PostgreSQL Replication Manager"
HOMEPAGE="http://www.repmgr.org/"
SRC_URI="http://www.repmgr.org/download/${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"


BDEPEND="${POSTGRES_DEP}
	sys-devel/flex
"
DEPEND="${POSTGRES_DEP}"
RDEPEND="${POSTGRES_DEP}
	net-misc/rsync
	virtual/ssh
"


src_configure() {
	postgres-multi_foreach econf
}


src_compile() {
	postgres-multi_foreach emake
}


src_install() {
	postgres-multi_foreach emake DESTDIR="${D}" install

	dodoc repmgr.conf.sample CREDITS HISTORY COPYRIGHT *.md
	docompress -x /usr/share/doc/${PF}/repmgr.conf.sample

	newinitd "${FILESDIR}"/repmgrd.init repmgrd
}


pkg_postinst() {
	elog "Complete documentation is available at https://repmgr.org/docs/current/"
	elog "Sample configuration file can be found at "
	elog "${ROOT}/usr/share/doc/${PF}/repmgr.conf.sample"
}
