# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

CRATES=" "

inherit cargo

DESCRIPTION="Single Sign-On Identity & Access Management via OpenID Connect, OAuth 2, and PAM"
HOMEPAGE="https://sebadob.github.io/rauthy/"
SRC_URI="https://github.com/sebadob/rauthy/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"
SRC_URI+=" https://download.jkns.pl/gentoo/${P}-crates.tar.xz"
SRC_URI+=" https://download.jkns.pl/gentoo/${P}-assets.tar.xz"

LICENSE="
	0BSD Apache-2.0 BSD CC0-1.0 CDLA-Permissive-2.0 ISC MIT MPL-2.0
	Unicode-3.0 ZLIB
"
SLOT="0"
KEYWORDS="~amd64"

DEPEND=""
RDEPEND="
	${DEPEND}
	acct-user/rauthy
	acct-group/rauthy
"
BDEPEND=""

# Broken in current version
RESTRICT="test"


src_install() {
	newbin "$(cargo_target_dir)/rauthy" rauthy

	keepdir /etc/rauthy

	newinitd "${FILESDIR}"/rauthy.initd rauthy
	newconfd "${FILESDIR}"/rauthy.confd rauthy

	einstalldocs
}

pkg_postinst() {
	if [ ! -e "${EPREFIX}"/etc/rauthy/config.toml ]; then
		elog "You can bootstrap rauthy using following command:"
		elog "su rauthy -p -s /bin/sh -c 'rauthy generate-config --output-file /etc/rauthy/config.toml'"
		elog "Any 'secret' (and only those) can be put in seperate file,"
		elog "e.g. /etc/rauthy/secrets.toml."
	fi
}
