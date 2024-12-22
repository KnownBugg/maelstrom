# Copyright 2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop xdg-utils

DESCRIPTION="A stand-alone graphics debugging tool"
HOMEPAGE="https://renderdoc.org https://github.com/baldurk/renderdoc"

SRC_URI="https://renderdoc.org/stable/${PV}/renderdoc_${PV}.tar.gz -> renderdoc.tgz"
S="${WORKDIR}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE="abi_x86_64"
RESTRICT="bindist mirror"

PN_INSTALL="renderdoc-bin"

QA_PRESTRIPPED="
	/opt/${PN_INSTALL}/bin/renderdoccmd
	/opt/${PN_INSTALL}/bin/qrenderdoc
	/opt/${PN_INSTALL}/lib/librenderdoc.so
	/usr/share/renderdoc/plugins/amd/isa/spvgen.so
	/usr/share/renderdoc/plugins/amd/isa/VirtualContext
	/usr/share/renderdoc/plugins/spirv/glslang
	/usr/share/renderdoc/plugins/spirv/spirv-as
	/usr/share/renderdoc/plugins/spirv/spirv-dis
	/usr/share/renderdoc/plugins/spirv/spirv-cross
	/usr/share/renderdoc/plugins/spirv/glslangValidator
"

RDEPEND="
	dev-libs/libffi
"
DEPEND="${RDEPEND}"

src_prepare() {
	if use abi_x86_64 ; then
		READY_ROOT="${WORKDIR}/${PN_INSTALL}"
		mkdir "${READY_ROOT}" || die
		[[ -d "${READY_ROOT}" ]] || die

		SOURCE_ROOT="${WORKDIR}/renderdoc_${PV}"
		[[ -d "${SOURCE_ROOT}" ]] || die

		mv "${SOURCE_ROOT}/bin" "${READY_ROOT}" || die
		mv "${SOURCE_ROOT}/lib" "${READY_ROOT}" || die
		mv "${SOURCE_ROOT}/LICENSE.md" "${READY_ROOT}" || die
		mv "${SOURCE_ROOT}/README" "${READY_ROOT}" || die

		mkdir "${READY_ROOT}/share"
		[[ -d "${READY_ROOT}/share" ]] || die
		mv "${SOURCE_ROOT}/share/renderdoc" "${READY_ROOT}/share/" || die

	fi

	eapply_user
}

src_install() {
	if use abi_x86_64 ; then
		READY_ROOT="${WORKDIR}/${PN_INSTALL}"
		[[ -d "${READY_ROOT}" ]] || die

		SOURCE_ROOT="${WORKDIR}/renderdoc_${PV}"
		[[ -d "${SOURCE_ROOT}" ]] || die

		# Main application
		insinto "/opt"
		doins -r "${READY_ROOT}"

		INSTALLED_ROOT="/opt/${PN_INSTALL}"
		fperms +x ${INSTALLED_ROOT}/bin/qrenderdoc
		dosym "${INSTALLED_ROOT}/bin/qrenderdoc" "/usr/bin/qrenderdoc"

		insinto "/usr/share"
		doins -r "${SOURCE_ROOT}/share/mime"

		# Vulkan layer
		VULKAN_LAYER_FILE="${SOURCE_ROOT}/etc/vulkan/implicit_layer.d/renderdoc_capture.json"
		sed -i "s|/io/dist/lib/librenderdoc.so|${INSTALLED_ROOT}/lib/librenderdoc.so|g" "${VULKAN_LAYER_FILE}"

		# /io/dist/lib/librenderdoc.so
		# ${INSTALLED_ROOT}/lib/librenderdoc.so

		insinto "/etc/vulkan/implicit_layer.d/"
		doins "${VULKAN_LAYER_FILE}"

		# Includes
		doheader "${SOURCE_ROOT}/include/renderdoc_app.h"

		# Icon and the .desktop file
		doicon "${SOURCE_ROOT}/share/icons/hicolor/scalable/mimetypes/application-x-renderdoc-capture.svg"
		domenu "${SOURCE_ROOT}/share/applications/renderdoc.desktop"
	fi
}

pkg_postinst() {
	xdg_desktop_database_update
	xdg_mimeinfo_database_update
}

pkg_postrm() {
	xdg_desktop_database_update
	xdg_mimeinfo_database_update
}
