# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit go-module

DESCRIPTION="DDoS detection & RTBH & XDP mitigation"
HOMEPAGE="https://kapkan.io/"
SRC_URI="https://github.com/fornex/kapkan/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"
SRC_URI+=" https://download.jkns.pl/gentoo/${P}-vendor.tar.xz"

# git rev-parse --short=12 HEAD
GIT_COMMIT="ed89ef770f36"
# git show -s --format=%cI HEAD
GIT_DATE="2026-09-02T10:13:42+03:00"

LICENSE="Apache-2.0 BSD-2 BSD ISC MIT MPL-2.0"
SLOT="0"
KEYWORDS="~amd64"
RESTRICT="test"

DEPEND=""
RDEPEND="${DEPEND}"
BDEPEND=">=dev-lang/go-1.26.6"

S="${WORKDIR}/${P}/engine"

src_prepare() {
	default

	mv "${WORKDIR}/${P}/console" "${WORKDIR}/${P}/engine/internal/api/static"
}

src_compile() {
	local go_ldflags=(
		-X github.com/kapkan-io/kapkan/internal/buildinfo.version=$(date -u "+%Y.%m.%d_%H:%M:%S")
		-X github.com/kapkan-io/kapkan/internal/buildinfo.commit=${GIT_COMMIT}
		-X github.com/kapkan-io/kapkan/internal/buildinfo.date=v${PV}
	)

	export CGO_ENABLED=0
	ego build -trimpath -ldflags "${go_ldflags[*]}" -o kapkan ./cmd/kapkan
}

src_install() {
	dobin kapkan

	newinitd "${FILESDIR}"/kapkan.initd kapkan
	newconfd "${FILESDIR}"/kapkan.confd kapkan

	dodoc -r ../docs

	insinto /etc/kapkan
	newins deploy/config.example.yaml config.yaml.example
}
