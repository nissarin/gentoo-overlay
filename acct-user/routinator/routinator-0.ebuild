# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit acct-user

DESCRIPTION="User for net-misc/routinator"
ACCT_USER_ID=-1
ACCT_USER_GROUPS=( "${PN}" )
ACCT_USER_HOME="/var/lib/${PN}"

acct-user_add_deps
