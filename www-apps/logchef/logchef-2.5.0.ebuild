# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit go-module

DESCRIPTION="Log analytics for ClickHouse and VictoriaLogs"
HOMEPAGE="https://logchef.app/"
SRC_URI="https://github.com/mr-karan/logchef/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"
SRC_URI+=" https://download.jkns.pl/gentoo/${P}-vendor.tar.xz"
SRC_URI+=" https://download.jkns.pl/gentoo/${P}-assets.tar.xz"

LICENSE="AGPL-3 Apache-2.0 BSD MIT Unlicense"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	acct-user/logchef
	acct-group/logchef
"
BDEPEND="
	acct-user/logchef
	acct-group/logchef
	>=dev-lang/go-1.27.0
"


src_compile() {
	local go_ldflags=(
		-X main.buildString=${PV}
		-X main.versionString=${APP_VERSION}
	)

	CGO_ENABLED=0 ego build -ldflags="${go_ldflags[*]}" -o logchef ./cmd/server
}

src_install() {
	einstalldocs

	dobin logchef

	keepdir /etc/logchef
	insinto /etc/logchef
	newins config.toml config.toml.exaple

	fowners logchef:logchef /etc/logchef/config.toml.exaple
	fperms 0600 /etc/logchef/config.toml.exaple

	newconfd "${FILESDIR}"/logchef.confd logchef
	newinitd "${FILESDIR}"/logchef.initd logchef
}
