# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="FoundationDB - the open source, distributed, transactional key-value store"
HOMEPAGE="https://apple.github.io/foundationdb"

SRC_URI="https://github.com/apple/foundationdb/releases/download/${PV}/fdb-headers-${PV}.tar.gz -> fdb-headers-${PV}.tar.gz
https://github.com/apple/foundationdb/releases/download/${PV}/fdbbackup.x86_64 -> fdbbackup.x86_64-${PV}.bin
https://github.com/apple/foundationdb/releases/download/${PV}/fdbcli.x86_64 -> fdbcli.x86_64-${PV}.bin
https://github.com/apple/foundationdb/releases/download/${PV}/fdbmonitor.x86_64 -> fdbmonitor.x86_64-${PV}.bin
https://github.com/apple/foundationdb/releases/download/${PV}/fdbserver.x86_64 -> fdbserver.x86_64-${PV}.bin
https://github.com/apple/foundationdb/releases/download/${PV}/fdbdecode.x86_64 -> fdbdecode.x86_64-${PV}.bin
https://github.com/apple/foundationdb/releases/download/${PV}/libfdb_c.x86_64.so -> libfdb_c.so.x86_64-${PV}.bin
"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="-* ~amd64"

BDEPEND=""
DEPEND=""
RDEPEND="
	sys-libs/zlib
	app-arch/xz-utils
	acct-user/foundationdb
"

QA_PREBUILT="
	usr/bin/*
	usr/sbin/*
	usr/lib*/libfdb_c.so
"

src_unpack() {
	mkdir -p "${S}"/usr/include/foundationdb || die
	mkdir -p "${S}"/usr/lib/pkgconfig || die

	pushd "${S}"/usr/include/foundationdb > /dev/null
	unpack fdb-headers-${PV}.tar.gz || die
	popd > /dev/null
}

src_prepare() {
	default

	sed -e "s:@LIB_DIR@:/usr/$(get_libdir):" \
		-e "s:@INCLUDE_DIR@:/usr/include/foundationdb:" \
		-e "s:@FDB_VERSION:${PV}:" \
		"${FILESDIR}"/foundationdb-client.pc.in \
		> "${S}"/usr/lib/pkgconfig/foundationdb-client.pc || die

}

src_install() {
	doins -r .
	newlib.so "${DISTDIR}"/libfdb_c.so.x86_64-${PV}.bin libfdb_c.so

	insinto /usr/bin
	newbin "${DISTDIR}"/fdbcli.x86_64-${PV}.bin fdbcli
	newbin "${DISTDIR}"/fdbbackup.x86_64-${PV}.bin fdbbackup
	newbin "${DISTDIR}"/fdbdecode.x86_64-${PV}.bin fdbdecode

	insinto /usr/sbin
	newbin "${DISTDIR}"/fdbserver.x86_64-${PV}.bin fdbserver
	newbin "${DISTDIR}"/fdbmonitor.x86_64-${PV}.bin fdbmonitor

	dosym /usr/bin/fdbbackup /usr/bin/fdbrestore
	dosym /usr/bin/fdbbackup /usr/bin/fdbdr
	dosym /usr/bin/fdbbackup /usr/lib/foundationdb/backup_agent/backup_agent
	dosym /usr/bin/fdbbackup /usr/lib/foundationdb/dr_agent/dr_agent

	newinitd "${FILESDIR}"/foundationdb.initd foundationdb
	newconfd "${FILESDIR}"/foundationdb.confd foundationdb

	insinto /etc/foundationdb
	doins "${FILESDIR}"/foundationdb.conf

	keepdir /var/lib/foundationdb
	keepdir /var/log/foundationdb
}

pkg_postinst() {
	if [ ! -f "/etc/foundationdb/fdb.cluster" ]; then
		elog "Creating initial 'fdb.cluster' in /etc/foundationdb directory"

		local _desc=$(mktemp -u cluster_XXXX)
		local _id=$(mktemp -u XXXXXXXX)

		echo "${_desc}:${_id}@127.0.0.1:4500" > /etc/foundationdb/fdb.cluster

		elog "New database needs to be initialized, for example:"
		elog "fdbcli --exec 'configure new single memory'"
		elog "For additional information check online documentation or run:"
		elog "fdbcli --exec 'help configure'"
	fi
}
