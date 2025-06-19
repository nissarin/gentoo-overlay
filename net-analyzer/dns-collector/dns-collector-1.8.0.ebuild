# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit go-module

DESCRIPTION="The missing piece between DNS servers and your data stack"
HOMEPAGE="https://github.com/dmachard/DNS-collector"
SRC_URI="https://github.com/dmachard/DNS-collector/archive/refs/tags/v1.8.0.tar.gz -> ${P}.tar.gz"
SRC_URI+=" https://nizgard.eu/download/gentoo/${P}-vendor.tar.xz"

# git rev-parse --short HEAD
COMMIT="147340d"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

DEPEND=""
RDEPEND="${DEPEND}"
BDEPEND=">=dev-lang/go-1.23.0"

MY_PN="DNS-collector"
MY_P="${MY_PN}-${PV}"

S="${WORKDIR}/${MY_P}"

src_compile() {
	local go_ldflags=(
		-s
		-w
		-X github.com/prometheus/common/version.Version=${PV}
		-X github.com/prometheus/common/version.Revision=${COMMIT}
		-X github.com/prometheus/common/version.Branch=main
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
