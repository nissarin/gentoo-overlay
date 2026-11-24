# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# gloo-timers required by patched russh-sftp
CRATES="
	gloo-timers@0.4.1
"
RUST_MIN_VER="1.98.1"

declare -A GIT_CRATES=(
	[russh-sftp]='https://github.com/AspectUnk/russh-sftp;49451b7b89c07149b2a1744f15ba28f983a53ddc;russh-sftp-%commit%'
)

inherit cargo desktop

SKIA_VER="m153-0.101.2"
SKIA_BIN_VER="0.153.3"
SKIA_BIN_FILENAME="skia-binaries-b7f043e0b1e2a850e702-x86_64-unknown-linux-gnu-ganesh-gl-jpegd-jpege-pdf-vulkan.tar.gz"

DESCRIPTION="A fast, encrypted, deduplicated backup tool"
HOMEPAGE="https://vykar.borgbase.com/"
SRC_URI="${CARGO_CRATE_URIS}"
SRC_URI+=" https://github.com/borgbase/vykar/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"
SRC_URI+=" https://download.jkns.pl/gentoo/${P}-crates.tar.xz"
SRC_URI+=" https://github.com/rust-skia/skia-binaries/releases/download/${SKIA_BIN_VER}/${SKIA_BIN_FILENAME}"

LICENSE="GPL-3"
LICENSE+="
	Apache-2.0 BSD-2 BSD Boost-1.0 CDLA-Permissive-2.0 ISC MIT MPL-2.0
	Unicode-3.0 Unlicense ZLIB
"
SLOT="0"
KEYWORDS="~amd64"
IUSE="gui server"

DEPEND="
	app-arch/zstd:=
	gui? (
		media-libs/fontconfig:=
		media-libs/freetype:=
		app-arch/bzip2:=
		media-libs/libpng:=
		dev-libs/expat:=

	)
"
RDEPEND="
	${DEPEND}
"
BDEPEND="
	${DEPEND}
	virtual/pkgconfig
	llvm-core/clang
"

src_prepare() {
	default

	# lifted from dev-python/polars
	local crate
	for crate in "${!GIT_CRATES[@]}"; do
		local override=$(
			grep "^${crate} =" "${ECARGO_HOME}"/config.toml || die
		)
		sed -i -e "s@^${crate} = { git.*\$@${override}@" Cargo.toml || die
	done
}

src_configure() {
	export ZSTD_SYS_USE_PKG_CONFIG=1
	export PACKAGES=(
		vykar-cli
		$(usev gui vykar-gui)
		$(usev server vykar-server)
	)
}

src_compile() {
	# TODO: build it ? package it ?
	export SKIA_BINARIES_URL="file://${DISTDIR}/${SKIA_BIN_FILENAME}"

	cargo_src_compile "${PACKAGES[@]/#/--package=}"
}

src_test() {
	cargo_src_test "${PACKAGES[@]/#/--package=}"
}

src_install() {
	newbin "$(cargo_target_dir)/vykar" vykar
	use server && newbin "$(cargo_target_dir)/vykar-server" vykar-server

	if use gui; then
		newbin "$(cargo_target_dir)/vykar-gui" vykar-gui
		newicon -s scalable "${S}"/docs/public/images/logo-colored-gradient.svg vykar-gui.svg
		domenu "${S}"/crates/vykar-gui/linux/vykar-gui.desktop
	fi
}
