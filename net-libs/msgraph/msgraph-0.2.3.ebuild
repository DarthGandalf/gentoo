# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit gnome.org meson

DESCRIPTION="GLib-based library for accessing online serive APIs using MS Graph protocol."
HOMEPAGE="https://gitlab.gnome.org/GNOME/msgraph"

LICENSE="LGPL-2+"
SLOT="0/1"
KEYWORDS="~amd64 ~arm ~arm64 ~loong ~ppc64 ~riscv ~sparc ~x86"

IUSE="debug gtk-doc +introspection man"

RDEPEND="
	>=dev-libs/glib-2.28.0:2
	dev-libs/json-glib
	net-libs/rest
	>=net-libs/libsoup-3.0:3.0
	net-libs/gnome-online-accounts
	>=net-libs/uhttpmock-0.11.0
	introspection? ( >=dev-libs/gobject-introspection-0.6.2:= )
"

DEPEND="${RDEPEND}
	>=dev-util/gdbus-codegen-2.30.0
	>=sys-devel/gettext-0.19.8
	virtual/pkgconfig
	dev-libs/gobject-introspection-common
"
BDEPEND="gtk-doc? ( dev-util/gtk-doc )"

src_configure() {
	local emesonargs=(
		$(meson_use gtk-doc gtk_doc)
		$(meson_use introspection)
	)
	meson_src_configure
}
