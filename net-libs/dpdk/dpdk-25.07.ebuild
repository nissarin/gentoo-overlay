# Copyright 2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{13..14} )

inherit python-single-r1 toolchain-funcs meson

DESCRIPTION="Data Plane Development Kit libraries for implementing user space networking"
HOMEPAGE="https://dpdk.org"
SRC_URI="https://fast.dpdk.org/rel/${P}.tar.xz"

LICENSE="BSD GPL-2"
SLOT="0"
KEYWORDS="~amd64"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

DEPEND="
	$(python_gen_cond_dep '
		dev-python/pyelftools[${PYTHON_USEDEP}]
	')
	app-crypt/intel-ipsec-mb
	dev-libs/elfutils
	dev-libs/isa-l
	dev-libs/jansson
	dev-libs/libbpf
	dev-libs/libbsd
	dev-libs/openssl
	net-libs/libmnl
	net-libs/libpcap
	net-libs/xdp-tools
	sys-apps/dtc
	sys-cluster/rdma-core
	sys-process/numactl
"
RDEPEND="${DEPEND}"
BDEPEND="
	dev-lang/nasm
"


src_configure() {
	python-single-r1_pkg_setup
	local emesonargs=(
		-Dtests=false
		-Denable_driver_sdk=true
	)
	meson_src_configure
}


src_install() {
	meson_src_install
	python_fix_shebang "${ED}"
}
