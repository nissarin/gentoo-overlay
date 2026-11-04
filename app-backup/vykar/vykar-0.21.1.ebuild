# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

CRATES=" "
RUST_MIN_VER="1.98.1"

inherit cargo desktop

SKIA_VER="m153-0.101.2"
SKIA_BIN_VER="0.153.3"
SKIA_BIN_FILENAME="skia-binaries-b7f043e0b1e2a850e702-x86_64-unknown-linux-gnu-ganesh-gl-jpegd-jpege-pdf-vulkan.tar.gz"

DESCRIPTION="A fast, encrypted, deduplicated backup tool"
HOMEPAGE="https://vykar.borgbase.com/"
SRC_URI="https://github.com/borgbase/vykar/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"
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
		newicon -s scalable "${S}"/docs/src/images/logo-colored-gradient.svg vykar-gui.svg
		domenu "${S}"/crates/vykar-gui/linux/vykar-gui.desktop
	fi
}
