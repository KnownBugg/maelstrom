# Copyright 2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_SETUPTOOLS=rdepend
PYTHON_COMPAT=( python3_{10..11} )

inherit distutils-r1

DESCRIPTION="Run docker-compose files without root with podman"
HOMEPAGE="https://pypi.org/project/podman-compose https://github.com/containers/podman-compose"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"

DEPEND=""
RDEPEND="
	${DEPEND}
	dev-python/pyyaml[${PYTHON_USEDEP}]
	dev-python/python-dotenv[${PYTHON_USEDEP}]
"
BDEPEND=""

