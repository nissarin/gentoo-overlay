# Copyright 2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{13..14} )

inherit cmake python-single-r1 toolchain-funcs ninja-utils

DESCRIPTION="A high performance, packet-processing stack that can run on commodity CPUs"
HOMEPAGE="https://fd.io/"
SRC_URI="https://github.com/FDio/vpp/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"

VPP_VERSION="v25.06-0-g1573e751c"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"
IUSE="rdma dpdk xdp lcp"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

DEPEND="
	$(python_gen_cond_dep '
		dev-python/pyelftools[${PYTHON_USEDEP}]
		dev-python/ply[${PYTHON_USEDEP}]
	')
	>=app-crypt/intel-ipsec-mb-2.0[static-libs]
	>=dev-libs/openssl-3.5.0
	dev-lang/python
	net-libs/libpcap
	sys-libs/libunwind
	lcp? ( dev-libs/libnl )
	dpdk? ( >=net-libs/dpdk-25.07 )
	xdp? (
		>=net-libs/xdp-tools-1.5.5[static-libs]
		dev-libs/libbpf[static-libs]
	)
	rdma? ( >=sys-cluster/rdma-core-58.0[static-libs] )
"
RDEPEND="
	acct-user/vpp
	acct-group/vpp
	${DEPEND}
"
BDEPEND="
	${NINJA_DEPEND}
	llvm-core/clang
"

CMAKE_BUILD_TYPE=release
CMAKE_USE_DIR="${S}/src"

src_configure(){
	if ! tc-is-clang; then
		local -x CC=${CHOST}-clang
		local -x XX=${CHOST}-clang++
	fi

	echo "${VPP_VERSION}" > "${S}/src/scripts/.version"

	local excluded_plugins=(
		$(usev !dpdk)
		$(usev !rdma)
		$(usev !xdp af_xdp)
		$(usev !lcp linux-cp)
	)

	local mycmakeargs=(
		-DVPP_EXCLUDED_PLUGINS="$(IFS=","; echo "${excluded_plugins[*]}")"
		$(usev dpdk "-DVPP_USE_SYSTEM_DPDK=y")
		-DVPP_BUILD_NATIVE_ONLY=y
		-DVPP_BUILD_VCL_TESTS=n
		-DVPP_BUILD_PYTHON_API=n
		-DCMAKE_INSTALL_SYSCONFDIR="${EPREFIX}/etc"
		-DPython3_FIND_STRATEGY=LOCATION
	)
	cmake_src_configure
}

src_install() {
	cmake_src_install

	# QA Notice: The following deprecated .egg or .egg-info files were found.
	rm -rf "${D}/$(python_get_sitedir)"/*.egg-info

	insinto /etc/sysctl.d

	dodir "/etc/vpp"
	keepdir "/etc/vpp"

	dodir "/var/lib/vpp"
	keepdir "/var/lib/vpp"

	dodir "/var/log/vpp"
	keepdir "/var/log/vpp"

	newinitd "${FILESDIR}"/vpp.initd vpp
	newinitd "${FILESDIR}"/vpp_prometheus_export.initd vpp_exporter

	newconfd "${FILESDIR}"/vpp.confd vpp
	newconfd "${FILESDIR}"/vpp_prometheus_export.confd vpp_prometheus_export

	python_optimize
	python_fix_shebang "${ED}"/usr/bin
}
