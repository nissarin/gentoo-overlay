# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit go-module

DESCRIPTION="Fast, cost-effective and scalable monitoring solution and time series database"
HOMEPAGE="https://victoriametrics.com/"
SRC_URI="https://github.com/VictoriaMetrics/VictoriaMetrics/archive/refs/tags/v${PV}-cluster.tar.gz -> ${P}.tar.gz"
SRC_URI+=" https://download.nizgard.eu/gentoo/${P}-vendor.tar.xz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"

DEPEND=""
RDEPEND="
	${DEPEND}
	acct-user/victoria-metrics
	acct-group/victoria-metrics"
BDEPEND=">=dev-lang/go-1.25.1"

# Requires git, etc. present at build time
RESTRICT="test"

MY_PN=VictoriaMetrics

S="${WORKDIR}/${MY_PN}-${PV}-cluster"


build_app() {
	local go_build_info="${go_pkg_prefix}/lib/buildinfo.Version=${app}-${build_date}-v${PV}-gentoo"
	local go_buildargs=(
		-trimpath
		-buildvcs=false
		-tags='netgo osusergo'
		-ldflags "-extldflags '-static' -X '${go_build_info}'"
	)

	ego build "${go_buildargs[@]}" -o "${T}/apps/${app}" "${go_pkg_prefix}/app/${app}"
}

src_compile() {
	export CGO_ENABLED=1

	local build_date=$(date -u +'%Y%m%d-%H%M%S')
	local go_pkg_prefix="github.com/VictoriaMetrics/VictoriaMetrics"

	local apps=(
		vminsert
		vmselect
		vmstorage
		vmagent
		vmalert
		vmauth
		vmbackup
		vmctl
		vmrestore
	)

	for app in "${apps[@]}"; do
		build_app
	done
}

src_install() {
	dobin "${T}"/apps/*

	newinitd "${FILESDIR}"/vminsert.initd vminsert
	newconfd "${FILESDIR}"/vminsert.confd vminsert

	newinitd "${FILESDIR}"/vmselect.initd vmselect
	newconfd "${FILESDIR}"/vmselect.confd vmselect

	newinitd "${FILESDIR}"/vmstorage.initd vmstorage
	newconfd "${FILESDIR}"/vmstorage.confd vmstorage

	newinitd "${FILESDIR}"/vmalert.initd vmalert
	newconfd "${FILESDIR}"/vmalert.confd vmalert

	newinitd "${FILESDIR}"/vmauth.initd vmauth
	newconfd "${FILESDIR}"/vmauth.confd vmauth

	newinitd "${FILESDIR}"/vmagent.initd vmagent
	newconfd "${FILESDIR}"/vmagent.confd vmagent
}
