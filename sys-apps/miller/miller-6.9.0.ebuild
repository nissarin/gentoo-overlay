# Copyright 2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit go-module

DESCRIPTION="Miller is a command-line tool for querying, shaping, and reformatting data files in various formats."
HOMEPAGE="https://miller.readthedocs.io"
SRC_URI="https://github.com/johnkerl/miller/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"
SRC_URI+=" https://download.nizgard.eu/gentoo/${P}-vendor.tar.xz"

LICENSE="BSD-2"
SLOT="0"
KEYWORDS="~x86 ~amd64"

DEPEND=""
RDEPEND="${DEPEND}"
BDEPEND=">=dev-lang/go-1.18"


src_configure() {
	# not used
	:
}


src_compile() {
	ego build ./cmd/mlr
}


src_install() {
	dobin mlr
	doman man/mlr.1
}
