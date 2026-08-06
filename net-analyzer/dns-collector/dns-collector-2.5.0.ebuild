# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit go-module

DESCRIPTION="The missing piece between DNS servers and your data stack"
HOMEPAGE="https://github.com/dmachard/DNS-collector"
SRC_URI="https://github.com/dmachard/DNS-collector/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"
SRC_URI+=" https://download.jkns.pl/gentoo/${P}-vendor.tar.xz"

LICENSE="
	AGPL-3.0 Apache-2.0 BSD-2-Clause BSD-3-Clause EPL-2.0
	GNU-All-permissive-Copying-License ISC MIT MPL-2.0
"
SLOT="0"
KEYWORDS="~amd64"

DEPEND=""
RDEPEND="${DEPEND}"
BDEPEND=">=dev-lang/go-1.26.5"

MY_PN="DNS-collector"
MY_P="${MY_PN}-${PV}"

S="${WORKDIR}/${MY_P}"

src_compile() {
	local go_ldflags=(
		-X github.com/prometheus/common/version.Version=${PV}
		-X github.com/prometheus/common/version.BuildDate=$(date +"%F_%T_%z")
	)

	CGO_ENABLED=0 ego build -ldflags="${go_ldflags[*]}" -o dnscollector dnscollector.go
}

src_install() {
	dobin dnscollector

	newconfd "${FILESDIR}"/dnscollector.confd dnscollector
	newinitd "${FILESDIR}"/dnscollector.initd dnscollector

	dodoc README.md
	dodoc -r docs
}
