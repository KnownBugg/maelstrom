# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Linux tool for controlling Sony PlayStation 5 DualSense controller."
HOMEPAGE="https://github.com/nowrep/dualsensectl"

SRC_URI="https://github.com/nowrep/dualsensectl/archive/refs/tags/v${PV}.tar.gz -> dualsensectl-v${PV}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"

QA_PRESTRIPPED="
	/usr/bin/dualsensectl
"

RDEPEND="
	virtual/udev
	sys-apps/dbus
	dev-libs/hidapi
"
