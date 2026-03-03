# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

CRATES=" "
RUST_MIN_VER="1.90.0"

inherit cargo

DESCRIPTION="A fast, encrypted, deduplicated backup tool"
HOMEPAGE="https://vykar.borgbase.com/"
SRC_URI="https://github.com/borgbase/vykar/archive/refs/tags/v${PV}.tar.gz"
SRC_URI+=" https://download.jkns.pl/gentoo/${P}-crates.tar.xz"

LICENSE="GPL-3.0"
SLOT="0"
KEYWORDS="~amd64"

DEPEND="
	media-libs/fontconfig:=
	dev-libs/glib:=
	x11-libs/cairo:=
	x11-libs/gdk-pixbuf:=
	x11-libs/pango:=
	dev-libs/atk:=
	gui-libs/gtk:=
	x11-misc/xdotool:=
	app-arch/zstd:=
"
RDEPEND="${DEPEND}"
BDEPEND="
	${DEPEND}
	virtual/pkgconfig
	llvm-core/clang
"

src_configure() {
	export ZSTD_SYS_USE_PKG_CONFIG=1
}

src_install() {
	newbin  "$(cargo_target_dir)/vykar" vykar
	newbin  "$(cargo_target_dir)/vykar-gui" vykar-gui
	newbin  "$(cargo_target_dir)/vykar-server" vykar-server
}
