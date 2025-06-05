# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

CRATES="
"
RUST_MIN_VER="1.85.0"

inherit cargo

DESCRIPTION="All-in-one Mail & Collaboration server"
HOMEPAGE="https://stalw.art/"
SRC_URI="https://github.com/stalwartlabs/stalwart/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"
SRC_URI+=" https://download.nizgard.eu/gentoo/${P}-crates.tar.xz"

LICENSE="AGPL-3"
LICENSE+="
    AGPL-3 Apache-2.0 BSD-2 BSD Boost-1.0 CC0-1.0 CDLA-Permissive-2.0
    EPL-2.0 ISC LGPL-2+ MIT MPL-2.0 Unicode-3.0 ZLIB
"

SLOT="0"


# What's pulling in 'dev-libs/icu' ?
DEPEND="
    app-arch/bzip2
    app-arch/xz-utils
    dev-db/sqlite:3
    dev-libs/icu
    dev-libs/jemalloc
    dev-libs/openssl
    sys-libs/zlib
"
RDEPEND="
    ${DEPEND}
    acct-user/stalwart-mail
    acct-group/stalwart-mail"
BDEPEND="
    ${DEPEND}
     virtual/pkgconfig
"

KEYWORDS="~amd64"
DOCS="README.md SECURITY.md UPGRADING.md CONTRIBUTING.md CHANGELOG.md"

src_prepare() {
        default

        # https://github.com/alexcrichton/bzip2-rs/issues/104
        mkdir "${T}/pkg-config" || die
        cat >> "${T}/pkg-config/bzip2.pc" <<-EOF || die
                Name: bzip2
                Version: 9999
                Description:
                Libs: -lbz2
	EOF

        export PKG_CONFIG_PATH=${T}/pkg-config${PKG_CONFIG_PATH+:${PKG_CONFIG_PATH}}
}

src_configure() {
    local server_features=(
        mysql
        postgres
        redis
        rocks
        s3
        sqlite
    )

    readonly SERVER_FEATURES=( --no-default-features ${server_features[@]/#/--features } )

    export ZSTD_SYS_USE_PKG_CONFIG=1
    export LIBSQLITE3_SYS_USE_PKG_CONFIG=1
    export JEMALLOC_OVERRIDE="${ESYSROOT}/usr/$(get_libdir)/libjemalloc.so"

    # https://github.com/tikv/jemallocator/issues/19
    export CARGO_FEATURE_UNPREFIXED_MALLOC_ON_SUPPORTED_PLATFORMS=1
    export OPENSSL_NO_VENDOR=1
    export PKG_CONFIG_ALLOW_CROSS=1
}

src_compile() {
    cargo_src_compile --package stalwart-cli
    cargo_src_compile --package stalwart "${SERVER_FEATURES[@]}"
}

src_install() {
    newbin $(cargo_target_dir)/stalwart-cli stalwart-cli
    newbin $(cargo_target_dir)/stalwart stalwart

    newinitd "${FILESDIR}"/stalwart.initd stalwart
    newconfd "${FILESDIR}"/stalwart.confd stalwart

    insinto /etc/stalwart-
    newins resources/config/config.toml config.toml.example

    einstalldocs
}

pkg_postinst() {
    elog "This package provides following storage backends: sqlite, postgres, mysql, rocks, s3, redis"
}

pkg_config() {
    STALWART_PATH=$(source "${EROOT}"/etc/conf.d/stalwart-mail; echo ${STALWART_PATH:-/var/lib/stalwart})

    if [[ ! -d "${ROOT}${STALWART_PATH}" ]]; then
        einfo "Initializing stalwart-mail in ${ROOT}${STALWART_PATH}"
        ebegin "Continuing in 5 seconds, press Ctrl-C to abort"
        sleep 5
        eend 0

        install -d -m 750 -o stalwart-mail -g stalwart-mail "${ROOT}${STALWART_PATH}"
        su stalwart-mail -s /bin/sh -c "'${ROOT}/usr/bin/stalwart' --init '${ROOT}${STALWART_PATH}'"
    else
        einfo "${ROOT}${STALWART_PATH} already exists."
        einfo "In order to reinitialize remove the directory and try again"
    fi
}
