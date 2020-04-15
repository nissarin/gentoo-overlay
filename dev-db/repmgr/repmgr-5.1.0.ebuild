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

DEPEND="${POSTGRES_DEP}
	net-misc/rsync"
RDEPEND="${DEPEND}"

REQUIRE_USE="${POSTGRES_REQ_USE}"


src_configure() {
	pg_src_configure() {
		PG_CONFIG="${SYSROOT}${EPREFIX}/usr/$(get_libdir)/postgresql-${MULTIBUILD_ID}/bin/pg_config" \
		econf
	}
	postgres-multi_foreach pg_src_configure
}
