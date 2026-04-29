# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

CRATES=" "
RUST_MIN_VER="1.90.0"

inherit cargo desktop

SKIA_VER="m142-0.89.1"
SKIA_BIN_VER="0.90.0"
SKIA_BIN_FILENAME="skia-binaries-da4579b39b75fa2187c5-x86_64-unknown-linux-gnu-gl-pdf-textlayout-vulkan.tar.gz"

DESCRIPTION="A fast, encrypted, deduplicated backup tool"
HOMEPAGE="https://vykar.borgbase.com/"
SRC_URI="https://github.com/borgbase/vykar/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"
SRC_URI+=" https://download.jkns.pl/gentoo/${P}-crates.tar.xz"
SRC_URI+=" https://github.com/rust-skia/skia-binaries/releases/download/${SKIA_BIN_VER}/${SKIA_BIN_FILENAME}"

LICENSE="GPL-3"
LICENSE+="
	Apache-2.0 Apache-2.0-with-LLVM-exceptions BSD-2 BSD Boost-1.0
	CC0-1.0 CDLA-Permissive-2.0 ISC MIT MPL-2.0 UoI-NCSA Unicode-3.0
	ZLIB
"
SLOT="0"
KEYWORDS="~amd64"
IUSE="gui server"

DEPEND="
	app-arch/zstd:=
	gui? (
		dev-libs/atk:=
		dev-libs/glib:=
		gui-libs/gtk:=
		media-libs/fontconfig:=
		x11-libs/cairo:=
		x11-libs/gdk-pixbuf:=
		x11-libs/pango:=
		x11-misc/xdotool:=
	)
"
RDEPEND="
	${DEPEND}
	dev-libs/libayatana-appindicator
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
	# aws-lc-sys: "The CPU Jitter random number generator must not be compiled
	# with optimizations. See documentation. Use the compiler switch -O0
	# for compiling jitterentropy.c."
	# TODO: find how to filter flags for single crate
	export AWS_LC_SYS_NO_JITTER_ENTROPY=1

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
