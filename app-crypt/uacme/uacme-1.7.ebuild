# Copyright 2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

MY_P="${PN}-upstream-${PV}"

DESCRIPTION="Lightweight ACMEv2 client"
HOMEPAGE="https://github.com/ndilieto/uacme"
SRC_URI="https://github.com/ndilieto/${PN}/archive/refs/tags/upstream/${PV}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="doc openssl gnutls mbedtls"
REQUIRED_USE="
	^^ ( openssl gnutls mbedtls )
"

DEPEND="
	net-misc/curl[ssl]
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
	doc? ( app-text/asciidoc )
"

S="${WORKDIR}/${MY_P}"


src_configure() {
	local myeconfargs=(
		"--disable-maintainer-mode"
		"--with-ualpn"
		$(use_with gnutls)
		$(use_with openssl)
		$(use_with mbedtls)
		$(use_enable doc docs)
	)

	econf "${myeconfargs[@]}" 
}


src_install() {
	emake DESTDIR="${D}" install
	use doc || doman uacme.1 ualpn.1
}


pkg_postinst() {
	elog "Examples of hook scripts can be found in ${EPREFIX}/usr/share/${PN} directory."
}
