# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

MY_PV="${PV}+240606fc80"

DESCRIPTION="A fast and lightweight TR-069 Auto Configuration Server"
HOMEPAGE="https://genieacs.com/"
SRC_URI="https://github.com/genieacs/genieacs/releases/download/v${PV}/genieacs-${MY_PV}.tgz -> ${P}.tgz"
SRC_URI+=" https://download.nizgard.eu/gentoo/${P}-node_modules.tar.xz"

LICENSE="AGPL-3"
SLOT="0"
KEYWORDS="~amd64"

DEPEND="
	net-libs/nodejs
	dev-db/mongodb
"
RDEPEND="
	${DEPEND}
	acct-user/genieacs
"
BDEPEND=""

S="${WORKDIR}/package"

src_compile() {
	:
}

src_install() {
	local npm_module_dir="/usr/$(get_libdir)/node_modules/${PN}"

	insinto "${npm_module_dir}"
	doins -r *

	# Services are renamed to simplify initd files
	for srv in cwmp ext fs nbi ui; do
		fperms +x "${npm_module_dir}"/bin/genieacs-"${srv}"
		dosym "${npm_module_dir}"/bin/genieacs-"${srv}" /usr/bin/genieacs."${srv}"
	done

	newconfd "${FILESDIR}"/genieacs.confd genieacs

	newinitd "${FILESDIR}"/genieacs.initd genieacs.cwmp

	dosym /etc/init.d/genieacs.cwmp /etc/init.d/genieacs.fs
	dosym /etc/init.d/genieacs.cwmp /etc/init.d/genieacs.nbi
	dosym /etc/init.d/genieacs.cwmp /etc/init.d/genieacs.ui
}
