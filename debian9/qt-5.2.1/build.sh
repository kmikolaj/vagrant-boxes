#!/bin/bash

SOURCEDIR=$(realpath "$(dirname "$0")")
TEMPDIR=${HOME}/build
BUILDDIR=${TEMPDIR}/qt5-debug-build

ROOTDIR=/usr/local
PREFIX=/usr/local
INSTALLDIR=${PREFIX}/Qt5.2_tegra2-dbg
SYSROOT=${ROOTDIR}/colibri-t20
BINCROSS=${ROOTDIR}/gcc-linaro-arm-linux-gnueabihf/bin/arm-linux-gnueabihf

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
	cd ${ROOTDIR}
	patch -N -p1 < ${SOURCEDIR}/sysroot-gles-fix.patch

	cd ${TEMPDIR}
	patch -N -p1 < ${SOURCEDIR}/linux-tegra2-qmake-conf.patch
	mkdir -p ${BUILDDIR}
}

configure() {
	cd ${BUILDDIR}
	${TEMPDIR}/qt-everywhere-opensource-src-5.2.1/configure -v \
		-opensource -confirm-license \
		-developer-build \
		-nomake examples \
		-nomake tests \
		-prefix ${PREFIX} \
		-bindir ${INSTALLDIR}/bin \
		-headerdir ${INSTALLDIR}/include \
		-libdir ${INSTALLDIR}/lib \
		-archdatadir ${INSTALLDIR} \
		-datadir ${INSTALLDIR} \
		-sysconfdir ${INSTALLDIR}/etc/xdg \
		-examplesdir ${INSTALLDIR}/examples \
		-testsdir ${INSTALLDIR}/tests \
		-hostprefix ${SYSROOT}${PREFIX}/Qt5.2_tegra2-dbg-tools \
		-device tegra2 \
		-device-option CROSS_COMPILE=${BINCROSS}- \
		-sysroot ${SYSROOT} \
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
		-glib \
		-no-sse2 \
		-no-sse3 \
		-no-ssse3 \
		-no-sse4.1 \
		-no-sse4.2 \
		-no-avx \
		-no-avx2 \
		-no-neon \
		-no-mips_dsp \
		-no-mips_dspr2 \
		-qreal float \
		-qpa xcb \
		-opengl es2 -no-eglfs \
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
