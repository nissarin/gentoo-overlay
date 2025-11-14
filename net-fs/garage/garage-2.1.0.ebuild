# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
CRATES=" "
RUST_MIN_VER="1.81.0"

inherit cargo

DESCRIPTION="Garage is an S3-compatible distributed object storage"
HOMEPAGE="https://garagehq.deuxfleurs.fr/"
SRC_URI="https://git.deuxfleurs.fr/Deuxfleurs/garage/archive/v${PV}.tar.gz -> ${P}.tar.gz"
SRC_URI+=" https://download.nizgard.eu/gentoo/${P}-crates.tar.xz"

LICENSE="AGPL-3"
LICENSE+=" Apache-2.0 BSD-2 BSD Boost-1.0 ISC MIT MPL-2.0 Unicode-3.0 ZLIB"

SLOT="0"
KEYWORDS="~amd64"

DEPEND="
	>=dev-libs/libsodium-1.0.11:=
	app-arch/zstd:=
	dev-db/sqlite:3
	sys-libs/zlib
"
RDEPEND="
	${DEPEND}
	acct-user/garage
	acct-group/garage
"
BDEPEND="
	${DEPEND}
	virtual/pkgconfig
"

S="${WORKDIR}/${PN}"

src_configure() {
	# is this needed ?
	export PKG_CONFIG_ALLOW_CROSS=1

	local myfeatures=(
		system-libs
		metrics
		syslog
		lmdb
		sqlite
	)

	cargo_src_configure --no-default-features
}

src_install() {
	dobin "$(cargo_target_dir)"/garage

	newinitd "${FILESDIR}"/garage.initd garage
	newconfd "${FILESDIR}"/garage.confd garage
}

pkg_preinst() {
	install -m 0640 -o garage -g garage -D /dev/null "${ED}"/etc/garage.toml || die

	if [ -f "${EROOT}"/etc/garage.toml ]; then
		cp "${EROOT}"/etc/garage.toml "${ED}"/etc/garage.toml || die
	else
		elog "Generating new configuration file."

		cat <<-EOF > "${ED}"/etc/garage.toml
			replication_factor = 1

			metadata_dir = "/var/lib/garage/metadata"
			metadata_snapshots_dir = "/var/lib/garage/snapshots"
			data_dir = "/var/lib/garage/data"

			rpc_secret = "$(tr -dc 'a-f0-9' </dev/urandom | head -c 64)"
			rpc_bind_addr = "[::]:3901"
			rpc_public_addr = "127.0.0.1:3901"

			[admin]
			api_bind_addr = "[::]:3093"
			admin_token = "$(tr -dc 'a-f0-9' </dev/urandom | head -c 64)"
			metrics_token = "$(tr -dc 'a-f0-9' </dev/urandom | head -c 64)"

			[s3_api]
			api_bind_addr = "[::]:3900"
			s3_region = "garage"
			root_domain = ".s3.garage.localhost"

			[s3_web]
			bind_addr = "[::]:3902"
			root_domain = ".web.garage.localhost"

			[k2v_api]
			api_bind_addr = "[::]:3904"
		EOF
	fi
}
