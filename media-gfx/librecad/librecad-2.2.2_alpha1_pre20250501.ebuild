# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

COMMIT=2f5b68f347ba50fd8d6c4fee437cfedff63848b4
PLOCALES="ar ca cs da de el en en_au es es_ar es_bo es_cl es_co es_cr es_do es_ec es_gt es_hn es_mx es_ni es_pa es_pe es_pr es_py es_sv es_us es_uy es_ve et eu fi fr gl he hi hu id_ID it ja ka ko lv mk nl no pa pl pt_br pt_pt ro_ro ru sk sl sq_al sr sv ta th tr uk zh_cn zh_tw"
inherit desktop edo plocale qmake-utils

DESCRIPTION="Generic 2D CAD program"
HOMEPAGE="https://www.librecad.org/"

if [[ ${PV} == *9999* ]]; then
	EGIT_REPO_URI="https://github.com/LibreCAD/LibreCAD.git"
	inherit git-r3
else
	SRC_URI="https://github.com/LibreCAD/LibreCAD/archive/${COMMIT}.tar.gz -> ${P}-${COMMIT:0:8}.tar.gz"
	S="${WORKDIR}/LibreCAD-${COMMIT}"
	# KEYWORDS="~amd64 ~ppc64 ~riscv ~x86 ~amd64-linux ~x86-linux"
fi

LICENSE="GPL-2"
SLOT="0"
IUSE="doc tools"

RDEPEND="
	dev-cpp/muParser
	dev-libs/boost:=
	dev-qt/qtbase:6[gui,network,widgets]
	dev-qt/qtsvg:6
	media-libs/freetype:2
"
DEPEND="${RDEPEND}
	dev-qt/qtbase:6[xml]
	dev-qt/qttools:6[assistant]
"
BDEPEND="
	dev-qt/qttools:6[linguist]
"

src_prepare() {
	default

	# Stock script doesn't work correctly on gentoo (see bug #847394)
	# and also it compiles all translations regardles of selected locales.
	# To avoid this just comment out locale building and do it manually
	sed -i -e '/LRELEASE/s!^!# !' scripts/postprocess-unix.sh || die

	plocale_find_changes 'librecad/ts' 'librecad_' '.ts'
}

src_configure() {
	eqmake6 -r
}

src_compile() {
	default

	build_locale() {
		local lrelease="$(qt6_get_bindir)/lrelease"
		edo "${lrelease}" "librecad/ts/librecad_${1}.ts" \
			-qm "unix/resources/qm/librecad_${1}.qm"
		edo "${lrelease}" "plugins/ts/plugins_${1}.ts" \
			-qm "unix/resources/qm/plugins_${1}.qm"
	}

	plocale_for_each_locale build_locale
	# We want the en locale to be always present. Otherwise it could
	# be impossible to select the English command set which is quite crucial.
	has en $(plocale_get_locales) || build_locale en
}

src_install() {
	dobin unix/librecad
	use tools && dobin unix/ttf2lff
	insinto /usr/share/${PN}
	doins -r unix/resources/*
	use doc && docinto html && dodoc -r librecad/support/doc/*
	insinto /usr/share/metainfo
	doins unix/appdata/org.librecad.librecad.appdata.xml
	doicon librecad/res/images/${PN}.png
	make_desktop_entry ${PN} LibreCAD ${PN} Graphics
}
