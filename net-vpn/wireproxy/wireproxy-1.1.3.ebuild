# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit go-module

DESCRIPTION="Wireguard client that exposes itself as a socks5 proxy"
HOMEPAGE="https://github.com/windtf/wireproxy"
SRC_URI="https://github.com/windtf/wireproxy/archive/refs/tags/v${PV}.tar.gz -> ${PN}.tar.gz"
SRC_URI+=" https://download.jkns.pl/gentoo/${P}-vendor.tar.xz"

LICENSE="ISC Apache-2.0 BSD GPL-2 MIT"
SLOT="0"
KEYWORDS="~amd64"

DEPEND=""
RDEPEND="${DEPEND}"
BDEPEND=">=dev-lang/go-1.26.0"

DOCS=( UseWithVPN.md README.md )

src_compile() {
	local go_ldflags=(
		-X main.version=${PV}
	)

	export CGO_ENABLED=0
	ego build -trimpath -ldflags "${go_ldflags[*]}" -o wireproxy ./cmd/wireproxy
}

src_install() {
	dobin wireproxy

	keepdir /etc/wireproxy

	newinitd "${FILESDIR}"/wireproxy.initd wireproxy
	newconfd "${FILESDIR}"/wireproxy.confd wireproxy

	insinto /etc/wireproxy
	doins "${FILESDIR}"/wireproxy.conf.example

	EOF
}
