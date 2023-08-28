# Copyright 2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop

DESCRIPTION="Perforce Helix Core - Version Everything Without Limits"
HOMEPAGE="https://www.perforce.com/products/helix-core"
LICENSE="perforce"

SLOT="0"
KEYWORDS="~amd64"
RESTRICT="bindist mirror"

DEPEND=""
RDEPEND="${DEPEND}"
BDEPEND=""

IUSE="abi_x86_64 +p4 +p4broker +p4d +p4p +p4v"

SRC_PREFIX="https://cdist2.perforce.com/perforce/r${PV}/bin.linux26x86_64"

SRC_HELIX_CORE="${SRC_PREFIX}/helix-core-server.tgz"
SRC_P4V="${SRC_PREFIX}/p4v.tgz"

SRC_URI="
	abi_x86_64? ( p4? ( $SRC_HELIX_CORE ) p4broker? ( $SRC_HELIX_CORE ) p4d? ( $SRC_HELIX_CORE ) p4p? ( $SRC_HELIX_CORE ) )
	abi_x86_64? ( p4v? ( $SRC_P4V ) )
"

#PN_INSTALL="${PN}"
PN_INSTALL="perforce-helix-core"

QA_PRESTRIPPED="
	/opt/${PN_INSTALL}/bin/p4p
	/opt/${PN_INSTALL}/bin/p4
	/opt/${PN_INSTALL}/bin/p4broker
	/opt/${PN_INSTALL}/bin/p4d
	/opt/${PN_INSTALL}/lib/P4VResources/p4_parallel
	/opt/${PN_INSTALL}/lib/P4VResources/DVCS/p4d
	/opt/${PN_INSTALL}/lib/libQt5WebEngineCore.so.5
"

QA_SONAME="
	/opt/${PN_INSTALL}/lib/plugins/imageformats/libqpdf.so
"

S="${WORKDIR}"

src_prepare() {
	if use abi_x86_64 ; then
		HELIX_CORE_ROOT="${WORKDIR}/${PN_INSTALL}"
		HELIX_CORE_BIN="${HELIX_CORE_ROOT}/bin"

		mkdir "${HELIX_CORE_ROOT}" || die
		mkdir "${HELIX_CORE_BIN}" || die

		if use p4v ; then
			P4V=$(find "${WORKDIR}" -maxdepth 1 -type d -name "p4v-*")
			[[ -d "${P4V}" ]] || die
			[[ -d "${P4V}/bin" ]] || die
			[[ -d "${P4V}/lib" ]] || die

			mv "${P4V}/bin" "${HELIX_CORE_ROOT}" || die
			mv "${P4V}/lib" "${HELIX_CORE_ROOT}" || die
		fi

		if use p4 ; then
			mv "${WORKDIR}/p4" "${HELIX_CORE_BIN}" || die
		fi

		if use p4broker ; then
			mv "${WORKDIR}/p4broker" "${HELIX_CORE_BIN}" || die
		fi

		if use p4d ; then
			mv "${WORKDIR}/p4d" "${HELIX_CORE_BIN}" || die
		fi

		if use p4p ; then
			mv "${WORKDIR}/p4p" "${HELIX_CORE_BIN}" || die
		fi

		find "${HELIX_CORE_ROOT}" -type d -empty -delete
	fi

	eapply_user
}

src_install() {
	if use abi_x86_64 ; then
		HELIX_CORE_ROOT="${WORKDIR}/${PN_INSTALL}"
		[[ -d "${HELIX_CORE_ROOT}" ]] || die

		insinto "/opt"
		doins -r "${HELIX_CORE_ROOT}"

		INSTALLED_ROOT="/opt/${PN_INSTALL}"

		if use p4v ; then
			fperms +x ${INSTALLED_ROOT}/bin/p4admin{,.bin}
			fperms +x ${INSTALLED_ROOT}/bin/p4merge{,.bin}
			fperms +x ${INSTALLED_ROOT}/bin/p4v{,.bin}
			fperms +x ${INSTALLED_ROOT}/bin/p4vc
			fperms +x ${INSTALLED_ROOT}/bin/QtWebEngineProcess

			dosym "${INSTALLED_ROOT}/bin/p4admin" "/usr/bin/p4admin"
			dosym "${INSTALLED_ROOT}/bin/p4merge" "/usr/bin/p4merge"
			dosym "${INSTALLED_ROOT}/bin/p4v" "/usr/bin/p4v"
			dosym "${INSTALLED_ROOT}/bin/p4vc" "/usr/bin/p4vc"

			doicon -s 64 "${PN_INSTALL}/lib/P4VResources/icons/p4admin.svg"
			doicon -s 64 "${PN_INSTALL}/lib/P4VResources/icons/p4merge.svg"
			doicon -s 64 "${PN_INSTALL}/lib/P4VResources/icons/p4v.svg"

			domenu "${FILESDIR}/p4v.desktop"
		fi

		if use p4 ; then
			fperms +x ${INSTALLED_ROOT}/bin/p4
			dosym "${INSTALLED_ROOT}/bin/p4" "/usr/bin/p4"
		fi

		if use p4broker ; then
			fperms +x ${INSTALLED_ROOT}/bin/p4broker
			dosym "${INSTALLED_ROOT}/bin/p4broker" "/usr/bin/p4broker"
		fi

		if use p4d ; then
			fperms +x ${INSTALLED_ROOT}/bin/p4d
			dosym "${INSTALLED_ROOT}/bin/p4d" "/usr/bin/p4d"
		fi

		if use p4p ; then
			fperms +x ${INSTALLED_ROOT}/bin/p4p
			dosym "${INSTALLED_ROOT}/bin/p4p" "/usr/bin/p4p"
		fi
	fi
}
