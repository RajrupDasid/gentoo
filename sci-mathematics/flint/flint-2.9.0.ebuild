# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# ninja doesn't like "-lcblas" so using make.
CMAKE_MAKEFILE_GENERATOR="emake"
PYTHON_COMPAT=( python3_{8..11} )
inherit cmake python-any-r1

DESCRIPTION="Fast Library for Number Theory"
HOMEPAGE="http://www.flintlib.org/"

# flintlib.org tarballs have been broken in the past, Bill Hart suggests
# we get them from Github (which he has control over).
SRC_URI="https://github.com/wbhart/flint2/archive/refs/tags/v${PV}.tar.gz
	-> ${P}.tar.gz"

LICENSE="LGPL-2.1+"

# Based off the soname, e.g. /usr/lib64/libflint.so -> libflint.so.15
SLOT="0/17"

KEYWORDS="amd64 ~arm ~arm64 ~ppc ~ppc64 ~riscv x86"
IUSE="doc ntl test"

RESTRICT="!test? ( test )"

BDEPEND="doc? (
	dev-python/sphinx
	app-text/texlive-core
	dev-texlive/texlive-latex
	dev-texlive/texlive-latexextra
	dev-tex/latexmk
	)
	${PYTHON_DEPS}"
DEPEND="dev-libs/gmp:=
	dev-libs/mpfr:=
	ntl? ( dev-libs/ntl:= )
	virtual/cblas"
RDEPEND="${DEPEND}"

S="${WORKDIR}/flint2-${PV}"

src_prepare() {
	# https://github.com/wbhart/flint2/issues/1140
	rm test/t-sdiv_qrnnd.c || die
	cmake_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-DWITH_NTL="$(usex ntl)"
		-DBUILD_TESTING="$(usex test)"
		-DBUILD_DOCS="$(usex doc)"
		-DCBLAS_INCLUDE_DIRS="${EPREFIX}/usr/include"
		-DCBLAS_LIBRARIES="-lcblas"
	)

	cmake_src_configure

	if use doc ; then
		HTML_DOCS="${BUILD_DIR}/html/*"
		DOCS=(
			"${S}"/README
			"${S}"/AUTHORS
			"${S}"/NEWS
			"${BUILD_DIR}"/latex/Flint.pdf
		)
	fi
}

src_compile() {
	cmake_src_compile

	if use doc ; then
		cmake_build html
		cmake_build pdf
	fi
}
