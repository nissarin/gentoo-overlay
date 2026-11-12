# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit go-module

DESCRIPTION="Client for the step-ca"
HOMEPAGE="https://smallstep.com/cli"
SRC_URI="https://github.com/smallstep/cli/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"
SRC_URI+=" https://download.jkns.pl/gentoo/${P}-vendor.tar.xz"

LICENSE="Apache-2.0 BSD-2 BSD ISC MIT MPL-2.0"
SLOT="0"
KEYWORDS="~amd64"

DEPEND=""
RDEPEND="${DEPEND}"
BDEPEND=">=dev-lang/go-1.26.0"

RESTRICT="test"

S="${WORKDIR}/cli-${PV}"


src_compile() {
	local build_date=$(date -u '+%Y-%m-%d %H:%M UTC')
	local go_ldflags=(
		-X main.Version=v${PV}
		-X \"main.BuildTime=${build_date}\"
	)

	CGO_ENABLED=0 ego build -trimpath -ldflags="${go_ldflags[*]}" -o step ./cmd/step
}


src_install() {
	dobin step
}
