# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit go-module

DESCRIPTION="Archival and Restoration for databases in the Cloud"
HOMEPAGE="wal-g.readthedocs.io"
SRC_URI="https://github.com/wal-g/wal-g/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"
SRC_URI+=" https://download.nizgard.eu/gentoo/${P}-vendor.tar.xz"

GIT_COMMIT="f81943e6"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"
IUSE="brotli sodium lzo"

DEPEND="
	brotli? ( app-arch/brotli )
	sodium? ( dev-libs/libsodium )
	lzo? ( dev-libs/lzo )
"
RDEPEND="${DEPEND}"
BDEPEND=">=dev-lang/go-1.25"

# requires git, docker, etc.
RESTRICT="test"

src_compile() {
	export GOEXPERIMENT=jsonv2

	local go_tags="$(usev brotli) $(usex sodium libsodium '') $(usev lzo)"

	for db in etcd fdb gp mongo mysql pg redis sqlserver; do
		local go_ldflags=(
			-X github.com/wal-g/wal-g/cmd/${db}.buildDate=$(date -u "+%Y.%m.%d_%H:%M:%S")
			-X github.com/wal-g/wal-g/cmd/${db}.gitRevision=${GIT_COMMIT}
			-X github.com/wal-g/wal-g/cmd/${db}.walgVersion=v${PV}
		)

		ego build -tags="${go_tags}" -ldflags "${go_ldflags[*]}" -o wal-g-${db} ./main/${db}
	done
}

src_install() {
	for db in etcd fdb gp mongo mysql pg redis sqlserver; do
		dobin wal-g-${db}
	done

	dodoc docs/*.md
}
