# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

CRATES=" "
# due to dependences requiring some unstable features
RUST_MIN_VER="1.95.0"

declare -A GIT_CRATES=(
	[opentelemetry-http]='https://github.com/stalwartlabs/opentelemetry-rust;ae66e97b140f70e477ab710686aafce665cc2f8b;opentelemetry-rust-%commit%/opentelemetry-http'
	[opentelemetry-otlp]='https://github.com/stalwartlabs/opentelemetry-rust;ae66e97b140f70e477ab710686aafce665cc2f8b;opentelemetry-rust-%commit%/opentelemetry-otlp'
	[opentelemetry-proto]='https://github.com/stalwartlabs/opentelemetry-rust;ae66e97b140f70e477ab710686aafce665cc2f8b;opentelemetry-rust-%commit%/opentelemetry-proto'
	[opentelemetry-semantic-conventions]='https://github.com/stalwartlabs/opentelemetry-rust;ae66e97b140f70e477ab710686aafce665cc2f8b;opentelemetry-rust-%commit%/opentelemetry-semantic-conventions'
	[opentelemetry]='https://github.com/stalwartlabs/opentelemetry-rust;ae66e97b140f70e477ab710686aafce665cc2f8b;opentelemetry-rust-%commit%/opentelemetry'
	[opentelemetry_sdk]='https://github.com/stalwartlabs/opentelemetry-rust;ae66e97b140f70e477ab710686aafce665cc2f8b;opentelemetry-rust-%commit%/opentelemetry-sdk'
)

inherit cargo eapi9-ver

DESCRIPTION="All-in-one Mail & Collaboration server"
HOMEPAGE="https://stalw.art/"
SRC_URI="https://github.com/stalwartlabs/stalwart/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"
SRC_URI+=" https://download.jkns.pl/gentoo/${P}-crates.tar.xz"
SRC_URI+=" ${CARGO_CRATE_URIS}"

LICENSE="AGPL-3"
LICENSE+="
	AGPL-3 Apache-2.0 BSD-2 BSD Boost-1.0 CC0-1.0 CDLA-Permissive-2.0
	ISC LGPL-2+ MIT MPL-2.0 Unicode-3.0 ZLIB BZIP2
"

SLOT="0"

# What's pulling in 'dev-libs/icu' ?
DEPEND="
	!!<net-mail/stalwart-cli-1.0.0
	app-arch/bzip2
	app-arch/xz-utils
	dev-db/sqlite:3
	dev-libs/icu
	dev-libs/jemalloc
	dev-libs/openssl
	>=dev-libs/rocksdb-10.4.2:=
	<dev-libs/rocksdb-11:=
	sys-libs/zlib
"
RDEPEND="
	${DEPEND}
	acct-user/stalwart-mail
	acct-group/stalwart-mail"

# clang is required by bindgen
BDEPEND="
	${DEPEND}
	virtual/pkgconfig
	llvm-core/clang
"

KEYWORDS="~amd64"
IUSE="enterprise"
RESTRICT="test"
DOCS="CHANGELOG.md CONTRIBUTING.md LICENSES README.md SECURITY.md UPGRADING"


pkg_pretend() {
	if ver_replacing -lt 0.15.0; then
		eerror "The v0.16.x introduced multiple breaking changes and requires"
		eerror "manual, offline migration from previous version."
		eerror "Upgrade to v0.15.x before continuing."
		die "Currently installed version of Stalwart is too old"
	elif ver_replacing -lt 0.16.0; then
		elog "In order to upgrade from v0.15.x be sure to read upgrade guide"
		elog "available at https://github.com/stalwartlabs/stalwart/blob/main/UPGRADING/v0_16.md"
	fi
}

src_prepare() {
	default

	use enterprise || eapply "${FILESDIR}/${P}-ossify.patch"

	# https://github.com/alexcrichton/bzip2-rs/issues/104
	mkdir "${T}/pkg-config" || die
	cat >>"${T}/pkg-config/bzip2.pc" <<-EOF || die
		Name: bzip2
		Version: 9999
		Description:
		Libs: -lbz2
	EOF

	export PKG_CONFIG_PATH=${T}/pkg-config${PKG_CONFIG_PATH+:${PKG_CONFIG_PATH}}
}

src_configure() {
	local myfeatures=(
		$(usev enterprise)
		mysql
		nats
		postgres
		redis
		rocks
		s3
		sqlite
	)

	export ZSTD_SYS_USE_PKG_CONFIG=1
	export LIBSQLITE3_SYS_USE_PKG_CONFIG=1
	export JEMALLOC_OVERRIDE="${ESYSROOT}/usr/$(get_libdir)/libjemalloc.so"

	# https://github.com/tikv/jemallocator/issues/19
	export CARGO_FEATURE_UNPREFIXED_MALLOC_ON_SUPPORTED_PLATFORMS=1
	export OPENSSL_NO_VENDOR=1
	export PKG_CONFIG_ALLOW_CROSS=1

	export SNAPPY_LIB_DIR="${ESYSROOT}/usr/$(get_libdir)"
	export ROCKSDB_LIB_DIR="${ESYSROOT}/usr/$(get_libdir)"
	export ROCKSDB_INCLUDE_DIR="${ESYSROOT}/usr/include"

	cargo_src_configure --no-default-features
}

src_compile() {
	cargo_src_compile --bin stalwart
}

src_install() {
	cargo_src_install --path crates/main

	newinitd "${FILESDIR}"/stalwart-r2.initd stalwart
	newconfd "${FILESDIR}"/stalwart-r2.confd stalwart

	keepdir /etc/stalwart
	keepdir /var/lib/stalwart
	keepdir /var/lib/stalwart/webui
	keepdir /var/log/stalwart

	einstalldocs
}

pkg_postinst() {
	if use enterprise; then
		elog "Build with enterprise features enabled, package will contain SEL licensed code."
		elog "License text available in ${EROOT}/usr/share/doc/${P}/LICENSES/LicenseRef-SEL.txt"
	fi

	if [ ! -e "${EPREFIX}"/etc/stalwart/config.json ]; then
		elog "In order to bootstrap Stalwart instance execute:"
		elog "chown stalwart-mail:stalwart-mail /etc/stalwart"
		elog "chown stalwart-mail:stalwart-mail /var/log/stalwart"
		elog "chown stalwart-mail:stalwart-mail -R /var/lib/stalwart"
		elog "su stalwart-mail -p -s /bin/sh -c '/usr/bin/stalwart --config /etc/stalwart/config.json'"
	fi
}
