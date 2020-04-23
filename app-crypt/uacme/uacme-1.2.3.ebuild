# Copyright 2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="Lightweight ACMEv2 client"
HOMEPAGE="https://github.com/ndilieto/uacme"
SRC_URI="https://codeload.github.com/ndilieto/${PN}/tar.gz/v${PV} -> ${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="docs openssl gnutls mbedtls"
REQUIRED_USE="
	^^ ( openssl gnutls mbedtls )
"

DEPEND="
	gnutls? (
		net-libs/gnutls:=
	)
	openssl? (
		>=dev-libs/openssl-1.1.1:=
	)
	mbedtls? (
		net-libs/mbedtls:=
	)
"
RDEPEND="${DEPEND}"
BDEPEND="
	virtual/pkgconfig
	docs? ( app-text/asciidoc )
"


src_configure() {
	local myeconfargs=(
		"--disable-maintainer-mode"
		"--with-ualpn"
		$(use_with gnutls)
		$(use_with openssl)
		$(use_with mbedtls)
		$(use_enable docs)
	)

	econf "${myeconfargs[@]}" 
}


pkg_postinst() {
	elog "Examples of hook scripts can be found in ${EPREFIX}/usr/share/${PN} directory."
}
