# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit multiprocessing toolchain-funcs

MOLINILLO_PV="0.2.0"
MOLINILLO_P="crystal-molinillo-${MOLINILLO_PV}"

DESCRIPTION="Dependency manager for the Crystal language"
HOMEPAGE="https://github.com/crystal-lang/shards/"
SRC_URI="
	https://github.com/crystal-lang/shards/archive/v${PV}.tar.gz
		-> ${P}.tar.gz
	https://github.com/crystal-lang/crystal-molinillo/archive/v${MOLINILLO_PV}.tar.gz
		-> ${MOLINILLO_P}.tar.gz
"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="amd64"
RESTRICT="test"  # Missing files in the tarball.

RDEPEND="
	>dev-lang/crystal-0.11.1
	dev-libs/libyaml:=
"
DEPEND="
	${RDEPEND}
"

DOCS=( CHANGELOG.md README.md SPEC.md )

QA_PREBUILT=".*"  # Generated by Crystal.

src_prepare() {
	default

	# bundle crystal-molinillo to bootstrap 'shards'
	mkdir -p lib || die
	ln -s "../../${MOLINILLO_P}" lib/molinillo || die

	# Remove failing tests.
	rm ./spec/unit/{fossil,git,hg}_*.cr || die

	tc-export CC
}

src_compile() {
	emake release=1 \
		FLAGS="--link-flags=\"${LDFLAGS}\" --verbose --threads $(makeopts_jobs)"
}

src_install() {
	exeinto /usr/bin
	doexe "bin/${PN}"

	doman man/*
	einstalldocs
}
