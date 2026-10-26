# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit go-module

DESCRIPTION="Fast and easy to use database for logs"
HOMEPAGE="https://victoriametrics.com/products/victorialogs/"
SRC_URI="https://github.com/VictoriaMetrics/VictoriaLogs/archive/refs/tags/v${PV}.tar.gz -> ${PN}.tar.gz"

LICENSE=""
SLOT="0"
KEYWORDS="~amd64"

DEPEND=""
RDEPEND="
	${DEPEND}
	acct-user/victoria-logs
	acct-group/victoria-logs
"
BDEPEND=">=dev-lang/go-1.27.3"

# Requires additional BDEPENDs
RESTRICT="test"

MY_PN=VictoriaLogs

S="${WORKDIR}/${MY_PN}-${PV}"

build_app() {
	local go_build_prefix="github.com/VictoriaMetrics/VictoriaMetrics"
	local go_build_info="${go_pkg_prefix}/lib/buildinfo.Version=${app}-${build_date}-v${PV}-gentoo"
	local go_buildargs=(
		-trimpath
		-buildvcs=false
		-tags='netgo osusergo'
		-ldflags "-extldflags '-static' -X '${go_build_info}'"
	)

	ego build "${go_buildargs[@]}" -o "bin/${app}" "${go_pkg_prefix}/app/${app}"
}

src_compile() {
	export CGO_ENABLED=1

	local build_date=$(date -u +'%Y%m%d-%H%M%S')
	local go_pkg_prefix="github.com/VictoriaMetrics/VictoriaLogs"

	local apps=(
		victoria-logs
		vlagent
		vlogscli
	)

	for app in "${apps[@]}"; do
		build_app
	done
}


src_install() {
	dobin bin/*

	newinitd "${FILESDIR}"/vlagent.initd vlagent
	newconfd "${FILESDIR}"/vlagent.confd vlagent

	newinitd "${FILESDIR}"/victoria-logs.initd victoria-logs
	newconfd "${FILESDIR}"/victoria-logs.confd victoria-logs

	keepdir /etc/victoria-logs
}
