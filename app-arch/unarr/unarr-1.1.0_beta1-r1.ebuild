# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

DESCRIPTION="A lightweight decompression library with support for rar, tar and zip archives"
HOMEPAGE="https://github.com/selmf/unarr"
GIT_COMMIT="569ffdb063ce8a76ab069444af175e5953d90c93"
SRC_URI="https://github.com/selmf/unarr/archive/${GIT_COMMIT}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/${PN}-${GIT_COMMIT}"
KEYWORDS="~amd64"
LICENSE="LGPL-3"
SLOT="0"

DEPEND="
	sys-libs/zlib
	app-arch/bzip2
	app-arch/xz-utils
"
RDEPEND="${DEPEND}"
DOCS=( CHANGELOG.md README.md )
