# Copyright 2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

POSTGRES_COMPAT=( 9.{4..6} {10..12} )
POSTGRES_USEDEP="server"

inherit postgres-multi

DESCRIPTION="PostgreSQL Replication Manager"
HOMEPAGE="http://www.repmgr.org/"
SRC_URI="http://www.repmgr.org/download/${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="${POSTGRES_DEP}"

RDEPEND="${POSTGRES_DEP}
		net-misc/rsync
		virtual/ssh
"

REQUIRE_USE="${POSTGRES_REQ_USE}"


src_configure() {
	postgres-multi_foreach econf
}


pkg_postinst() {
	ebegin "Refreshing PostgreSQL symlinks"
	postgresql-config update
	eend $?

	elog "This package does not provide documentation, please visit web page"
	elog "https://repmgr.org/docs/$(ver_cut 1-2) for further information."
}
