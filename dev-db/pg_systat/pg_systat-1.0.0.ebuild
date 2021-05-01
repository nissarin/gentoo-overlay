# Copyright 2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cmake

DESCRIPTION="'systat' for PostgreSQL"
HOMEPAGE="https://pg_systat.gitlab.io/"
SRC_URI="https://pg_systat.gitlab.io/source/${P}.tar.xz"

LICENSE="POSTGRESQL GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"

RDEPEND="dev-db/postgresql:="
DEPEND="
	${RDEPEND}
	dev-libs/libbsd
"

PATCHES=(
	"${FILESDIR}/${P}-sysctl.patch"
)


