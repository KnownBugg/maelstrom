# Copyright 2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit unpacker

MY_PV_MAJOR=$(ver_cut 1)
MY_PV_MINOR=$(ver_cut 2)
MY_PV_PATCH=$(ver_cut 3)
MY_PV_BUILD=$(ver_cut 4)

MY_P=${P}.${MY_PV_BUILD}

UBUNTU_VER="22.04"

AMD_OGL_PREFIX="http://repo.radeon.com/amdgpu/${PV}/ubuntu/pool/proprietary/o/opengl-amdgpu-pro"

DESCRIPTION="AMD's closed source opengl driver, from Radeon Software for Linux"
HOMEPAGE="https://www.amd.com/en/support/linux-drivers"
SRC_URI="
		abi_x86_64? ( ${AMD_OGL_PREFIX}/libegl1-amdgpu-pro_${MY_PV_MAJOR}.${MY_PV_MINOR}-${MY_PV_BUILD}~${UBUNTU_VER}_amd64.deb -> ${P}-libegl1-amd64.deb )
		abi_x86_64? ( ${AMD_OGL_PREFIX}/libgl1-amdgpu-pro-dri_${MY_PV_MAJOR}.${MY_PV_MINOR}-${MY_PV_BUILD}~${UBUNTU_VER}_amd64.deb -> ${P}-libgl1-dri-amd64.deb )
		abi_x86_64? ( ${AMD_OGL_PREFIX}/libgl1-amdgpu-pro-ext_${MY_PV_MAJOR}.${MY_PV_MINOR}-${MY_PV_BUILD}~${UBUNTU_VER}_amd64.deb -> ${P}-libgl1-ext-amd64.deb )
		abi_x86_64? ( ${AMD_OGL_PREFIX}/libgl1-amdgpu-pro-glx_${MY_PV_MAJOR}.${MY_PV_MINOR}-${MY_PV_BUILD}~${UBUNTU_VER}_amd64.deb -> ${P}-libgl1-glx-amd64.deb )
		abi_x86_64? ( ${AMD_OGL_PREFIX}/libgles2-amdgpu-pro_${MY_PV_MAJOR}.${MY_PV_MINOR}-${MY_PV_BUILD}~${UBUNTU_VER}_amd64.deb -> ${P}-libgles2-amd64.deb )
		abi_x86_64? ( ${AMD_OGL_PREFIX}/libglapi1-amdgpu-pro_${MY_PV_MAJOR}.${MY_PV_MINOR}-${MY_PV_BUILD}~${UBUNTU_VER}_amd64.deb -> ${P}-libglapi1-amd64.deb )
"
RESTRICT="bindist mirror"

LICENSE="AMD-GPU-PRO-EULA"
SLOT="0"
KEYWORDS="~amd64"

IUSE="abi_x86_64 video_cards_amdgpu"
REQUIRED_USE="video_cards_amdgpu"

DEPEND=""
RDEPEND="${DEPEND}"
BDEPEND=""

S="${WORKDIR}"

src_unpack() {
	if use abi_x86_64 ; then
		mkdir "${WORKDIR}/amd64" || die
		cd "${WORKDIR}/amd64" || die
		unpack_deb "${DISTDIR}/${P}-libegl1-amd64.deb"
		unpack_deb "${DISTDIR}/${P}-libgl1-dri-amd64.deb"
		unpack_deb "${DISTDIR}/${P}-libgl1-ext-amd64.deb"
		unpack_deb "${DISTDIR}/${P}-libgl1-glx-amd64.deb"
		unpack_deb "${DISTDIR}/${P}-libgles2-amd64.deb"
		unpack_deb "${DISTDIR}/${P}-libglapi1-amd64.deb"
	fi
}

src_prepare() {
	if use abi_x86_64 ; then
		[[ -d "${WORKDIR}/amd64" ]] || die
		cd "${WORKDIR}/amd64" || die

		# Remove currently unused parts
		rm -rd ./etc
		rm -rd ./opt/amdgpu
		rm -rd ./usr/share

		# Prepare directory structure
		# /usr/lib64
		#	amdgpu-pro
		#	dri
		mkdir -p ./usr/lib64/amdgpu-pro || die
		mv -t ./usr/lib64/amdgpu-pro ./opt/amdgpu-pro/lib/x86_64-linux-gnu/* || die
		mv -t ./usr/lib64/amdgpu-pro ./opt/amdgpu-pro/lib/xorg || die
		mv -t ./usr/lib64 ./usr/lib/x86_64-linux-gnu/dri || die

		find "${WORKDIR}" -type d -empty -delete
	fi

	eapply_user
}

src_install() {
	if use abi_x86_64 ; then
		insinto "/usr/lib64"
		doins -r "${WORKDIR}/amd64/usr/lib64/amdgpu-pro"

		exeinto "/usr/lib64/dri"
		doexe "${WORKDIR}/amd64/usr/lib64/dri/amdgpu_dri.so"

		exeinto "/usr/bin"
		doexe "${FILESDIR}/progl"
	fi
}

pkg_postinst() {
	if use abi_x86_64; then
		elog "To run a selected 64bit program using the amdgpu-pro opengl driver use progl script"
		elog "     progl glxgears"
	fi
}
