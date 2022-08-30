# Copyright 2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit go-module


DESCRIPTION="Netdata plugin for collectors written in go"
HOMEPAGE="https://github.com/netdata/go.d.plugin"
SRC_URI="https://github.com/netdata/go.d.plugin/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"
SRC_URI+=" https://download.nizgard.eu/gentoo/${P}-vendor.tar.xz"


LICENSE="GPL-3+ MIT BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"

DEPEND=""
RDEPEND="net-analyzer/netdata"
BDEPEND=">=dev-lang/go-1.17"


MY_PN=go.d.plugin
S="${WORKDIR}/${MY_PN}-${PV}"


src_compile() {
	ego build -ldflags "-w -s -X main.version=${PV}-gentoo" "github.com/netdata/go.d.plugin/cmd/godplugin"
}


src_install() {
	exeinto "/usr/libexec/netdata/plugins.d"
	newexe godplugin go.d.plugin
	insinto "/usr/$(get_libdir)/netdata/conf.d"
	doins -r config/*
}
