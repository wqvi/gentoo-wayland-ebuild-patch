# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

LUA_COMPAT=( lua5-{1..3} )
WX_GTK_VER="3.2-gtk3"

inherit cmake lua-single wxwidgets xdg

MY_PV="${PV/beta/b}"
DESCRIPTION="Modern editor for Doom-engine based games and source ports"
HOMEPAGE="https://slade.mancubus.net/"
SRC_URI="https://github.com/sirjuddington/${PN^^}/archive/${MY_PV}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/${PN^^}-${MY_PV}"
LICENSE="GPL-2 MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE="fluidsynth timidity webkit"
REQUIRED_USE="${LUA_REQUIRED_USE}"

# <libfmt-11 https://github.com/sirjuddington/SLADE/issues/1746
DEPEND="
	${LUA_DEPS}
	app-arch/bzip2:=
	<dev-libs/libfmt-11:=
	>=media-libs/dumb-2:=
	media-libs/freeimage[jpeg,png,tiff]
	media-libs/glew:0=
	media-libs/libsfml:=
	media-sound/mpg123
	net-misc/curl
	sys-libs/zlib
	x11-libs/wxGTK:${WX_GTK_VER}[curl(+),opengl,webkit?,X]
	fluidsynth? ( media-sound/fluidsynth:= )
"

RDEPEND="
	${DEPEND}
	timidity? ( media-sound/timidity++ )
"

BDEPEND="
	app-arch/p7zip
	virtual/pkgconfig
"

PATCHES=(
	"${FILESDIR}"/${PN}-3.2.0_beta2-fluidsynth-driver.patch
	"${FILESDIR}"/${PN}-3.2.2-wayland.patch
	"${FILESDIR}"/${PN}-3.2.6-fix-sol.patch
)

src_prepare() {
	cmake_src_prepare

	# Delete bundled libraries just in case.
	rm -r thirdparty/dumb/ thirdparty/fmt/ || die

}

src_configure() {
	local luav=$(lua_get_version)

	local mycmakeargs=(
		-DLua_FIND_VERSION_MAJOR=$(ver_cut 1 "${luav}")
		-DLua_FIND_VERSION_MINOR=$(ver_cut 2 "${luav}")
		-DLua_FIND_VERSION_COUNT=2
		-DLua_FIND_VERSION_EXACT=ON
		-DNO_COTIRE=ON
		-DNO_FLUIDSYNTH=$(usex fluidsynth OFF ON)
		-DNO_WEBVIEW=$(usex webkit OFF ON)
		-DUSE_SFML_RENDERWINDOW=ON
		-DUSE_SYSTEM_DUMB=ON
		-DUSE_SYSTEM_FMT=ON
		-DWX_GTK3=ON
	)

	setup-wxwidgets
	cmake_src_configure
}
