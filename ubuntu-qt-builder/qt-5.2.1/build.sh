#!/bin/bash

SOURCEDIR=$(realpath "$(dirname "$0")")
TEMPDIR=${HOME}/build
BUILDDIR=${TEMPDIR}/qt5.2.1-debug-build

ROOTDIR=/usr/local
PREFIX=${QT_BUILD_PREFIX}/qt5.2.1-debug

SOURCE=qt-everywhere-opensource-src-5.2.1.tar.xz
URL=https://download.qt.io/new_archive/qt/5.2/5.2.1/single/${SOURCE}
MD5SUM=0c8d2aa45f38be9c3f7c9325eb059d9d

extract() {
	cd ${TEMPDIR}
	wget -nc ${URL} -O ${SOURCE}
	if ! echo "${MD5SUM}  ${SOURCE}" | md5sum -c - ; then
		exit 1
	fi
	tar xJf ${SOURCE} --skip-old-files
}

prepare() {
	mkdir -p ${BUILDDIR}
}

configure() {
	cd ${BUILDDIR}
	${TEMPDIR}/qt-everywhere-opensource-src-5.2.1/configure -v \
		-opensource -confirm-license \
		-developer-build \
		-optimized-qmake \
		-nomake examples \
		-nomake tests \
		-shared \
		-silent \
		-c++11 \
		-reduce-relocations \
		-no-strip \
		-no-pch \
		-no-rpath \
		-pkg-config \
		-widgets \
		-libudev \
		-linuxfb \
		-kms \
		-directfb \
		-fontconfig \
		-xcursor \
		-xinerama \
		-xinput \
		-xinput2 \
		-xfixes \
		-xrandr \
		-xrender \
		-xshape \
		-xsync \
		-xvideo \
		-dbus \
		-qt-xcb \
		-xcb-xlib \
		-sql-sqlite \
		-system-freetype \
		-system-libjpeg \
		-system-libpng \
		-system-zlib \
		-accessibility \
		-gstreamer 1.0 \
		-alsa \
		-pulseaudio \
		-glib \
		-qreal double \
		-qpa xcb \
		-debug \
		-no-warnings-are-errors
}

build() {
	cd ${BUILDDIR}
	make -j$(nproc)
}

install() {
	cd ${BUILDDIR}
	make install
}

extract
prepare
configure
build

# vim:set ts=2 sw=2 noet ft=sh:
