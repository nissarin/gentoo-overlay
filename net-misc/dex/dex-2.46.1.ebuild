# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit go-module

DESCRIPTION="OpenID Connect (OIDC) identity and OAuth 2.0 provider"
HOMEPAGE="https://dexidp.io"
SRC_URI="https://github.com/dexidp/dex/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"
SRC_URI+=" https://download.jkns.pl/gentoo/${P}-vendor.tar.xz"

LICENSE="Apache-2.0 BSD-2 BSD ISC MIT MPL-2.0 Unicode-DFS-2016"
SLOT="0"
KEYWORDS="~amd64"

DEPEND=""
RDEPEND="${DEPEND}"
BDEPEND=">=dev-lang/go-1.27.0"

# Requires databases, etc.
RESTRICT="test"

src_compile() {
	local go_ldflags=(
		-X main.version=v${PV}
	)

	ego build -ldflags="${go_ldflags[*]}" -o dex ./cmd/dex
}

src_install() {
	dobin dex

	newconfd "${FILESDIR}"/dex.confd dex
	newinitd "${FILESDIR}"/dex.initd dex

	keepdir /etc/dex
	insinto /etc/dex
	newins config.yaml.dist config.yaml.example

	einstalldocs
}
