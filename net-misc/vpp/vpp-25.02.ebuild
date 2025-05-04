# Copyright 2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..13} )

inherit cmake python-single-r1 toolchain-funcs

MY_PV=$(ver_cut 1-2)

DESCRIPTION="A high performance, packet-processing stack that can run on commodity CPUs"
HOMEPAGE="https://fd.io/"
SRC_URI="https://github.com/FDio/vpp/archive/refs/tags/v${MY_PV}.tar.gz -> ${PN}-${MY_PV}.tar.gz"
S="${WORKDIR}"/${PN}-${MY_PV}

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

DEPEND="
	$(python_gen_cond_dep '
		dev-python/pyelftools[${PYTHON_USEDEP}]
		dev-python/ply[${PYTHON_USEDEP}]
	')
	>=app-crypt/intel-ipsec-mb-2.0[static-libs]
	dev-lang/python
	dev-libs/libbpf
	dev-libs/libnl
	>=dev-libs/openssl-3.4.0
	net-libs/dpdk
	net-libs/libpcap
	net-libs/xdp-tools
	sys-libs/libunwind
	>=sys-cluster/rdma-core-55.0[static-libs]
"
RDEPEND="
	acct-user/vpp
	acct-group/vpp
	${DEPEND}
"
BDEPEND="
	dev-lang/nasm
"

PATCHES=(
)

CMAKE_BUILD_TYPE=release
CMAKE_USE_DIR="${S}/src"

src_prepare() {
	PATCHES+=(
		# current stable/2502 commits
		"${FILESDIR}"/0001-vrrp-force-sleeps-between-timer-events.patch
		"${FILESDIR}"/0002-acl-fix-an-off-by-one-error-in-fa_acl_match_ip6_addr.patch
	)

	# compilation fails with gcc
	sed -e 's/-Werror//' -i src/CMakeLists.txt || die

	cmake_src_prepare
}


src_configure(){
	echo "${PV}" > "${S}/src/scripts/.version"

	local mycmakeargs=(
		-DVPP_USE_SYSTEM_DPDK=y
		-DVPP_BUILD_NATIVE_ONLY=y
		-DPython3_FIND_STRATEGY=LOCATION
	)
	cmake_src_configure
}


src_install() {
	cmake_src_install

	insinto /etc/sysctl.d
	doins "${FILESDIR}"/80-vpp.conf

	newdoc "${ED}"/usr/etc/vpp/startup.conf startup.conf.dist

	dodir "/etc/vpp"
	keepdir "/etc/vpp"

	dodir "/var/lib/vpp"
	keepdir "/var/lib/vpp"

	dodir "/var/log/vpp"
	keepdir "/var/log/vpp"

	newinitd "${FILESDIR}"/vpp.initd vpp

	python_optimize
	python_fix_shebang "${ED}"/usr/bin
}
