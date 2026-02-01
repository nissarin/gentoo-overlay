# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

CRATES=" "
RUST_MIN_VER="1.82.0"

inherit cargo

DESCRIPTION="An RPKI relying party software"
HOMEPAGE="https://nlnetlabs.nl/projects/routing/routinator/"
SRC_URI="https://github.com/NLnetLabs/routinator/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"
SRC_URI+=" https://download.nizgard.eu/gentoo/${P}-crates.tar.xz"

LICENSE="BSD-3.0"
LICENSE+=" Apache-2.0 BSD CDLA-Permissive-2.0 ISC MIT MPL-2.0 Unicode-3.0"
SLOT="0"
KEYWORDS="~amd64"

DEPEND=""
RDEPEND="
	${DEPEND}
	acct-user/routinator
	|| ( net-misc/rsync net-misc/openrsync )
"
BDEPEND=""

DOCS=(
	CONTRIBUTING.md
	LICENSE
	README.md
	SECURITY.md
)

src_prepare() {
	default

	sed -i etc/routinator.conf.example \
		-e '/#rtr-listen/s:#::' \
		-e '/#http-listen/{s:#::; s/\.\.\./["127.0.0.1:8323"]/}' \
		-e '/^repository-dir/s:\.\.\.:/var/lib/routinator/rpki-cache:' \
		-e '/^#working-dir/{s:#::; s:\.\.\.:"/var/lib/routinator":}' || die
}

src_install() {
	einstalldocs

	dosbin target/release/routinator
	doman doc/routinator.1

	insinto /etc
	newins etc/routinator.conf.example routinator.conf

	newinitd "${FILESDIR}/routinator.initd" routinator
	newconfd "${FILESDIR}/routinator.confd" routinator
}
