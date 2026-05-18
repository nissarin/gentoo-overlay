# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit autotools toolchain-funcs

COMMIT="cd619f58a90ecfc93d89e30735040febe8f87576"

DESCRIPTION="A network tool to gather IP traffic information"
HOMEPAGE="http://www.pmacct.net/"

SRC_URI="https://github.com/pmacct/pmacct/archive/${COMMIT}.tar.gz -> ${P}.tar.gz"

KEYWORDS="~amd64 ~x86"
LICENSE="GPL-2"
SLOT="0"

IUSE="ebpf avro geoip jansson kafka mysql ndpi nflog postgres rabbitmq sqlite zmq"

REQUIRED_USE="
	kafka? ( jansson )
	rabbitmq? ( jansson )
"

# avro is currenly "broken" becase of invalid pkg-config file
RDEPEND="
	avro? (
		dev-libs/avro-c
		dev-libs/libserdes
	)
	dev-libs/libcdada
	ebpf? ( dev-libs/libbpf )
	geoip? ( dev-libs/libmaxminddb )
	jansson? ( dev-libs/jansson:= )
	kafka? ( dev-libs/librdkafka )
	ndpi? ( >=net-libs/nDPI-3.6:= )
	net-libs/libpcap
	nflog? ( net-libs/libnetfilter_log )
	mysql? (
		dev-db/mysql-connector-c:0=
		sys-process/numactl
	)
	postgres? ( dev-db/postgresql:* )
	rabbitmq? ( net-libs/rabbitmq-c )
	sqlite? ( =dev-db/sqlite-3* )
	zmq? ( net-libs/zeromq:= )"
DEPEND="${RDEPEND}"
BDEPEND="virtual/pkgconfig"

PATCHES=(
	"${FILESDIR}/${PN}-1.7.9-build-system.patch"
	"${FILESDIR}/${P}.patch"
)

DOCS=(
	AUTHORS CONFIG-KEYS FAQS QUICKSTART README.md UPGRADE
	docs examples sql
)

S="${WORKDIR}/${PN}-${COMMIT}"

src_prepare() {
	default
	eautoreconf
}

src_configure() {
	# tc-export CC AR RANLIB

	local myeconfargs=(
		$(use_enable mysql)
		$(use_enable postgres pgsql)
		$(use_enable sqlite sqlite3)
		$(use_enable rabbitmq)
		$(use_enable zmq)
		$(use_enable kafka)
		$(use_enable geoip geoipv2)
		$(use_enable jansson)
		$(use_enable avro)
		$(use_enable avro serdes)
		$(use_enable ndpi)
		--disable-unyte-udp-notif
		--disable-grpc-collector
		$(use_enable ebpf)
		$(use_enable nflog)

		--without-external-deps
	)

	econf "${myeconfargs[@]}"
}

src_install() {
	einstalldocs

	dosbin src/nfacctd
	dosbin src/pmacctd
	dosbin src/pmbgpd
	dosbin src/pmbmpd
	dosbin src/pmtelemetryd
	dosbin src/sfacctd
	use nflog && dosbin src/uacctd

	keepdir "/etc/pmacctd"

	newinitd "${FILESDIR}"/pmacctd.initd pmacctd
	newconfd "${FILESDIR}"/pmacctd.confd pmacctd
}

pkg_postinst() {
	elog "The /etc/init.d/pmacctd script supports all tools installed by this"
	elog "package and also running multiple instances. This can be achieved by"
	elog "creating necessary symlinks in /etc/init.d directory, e.g."
	elog "ln -s pmacctd <daemon>.<instance>"
}
