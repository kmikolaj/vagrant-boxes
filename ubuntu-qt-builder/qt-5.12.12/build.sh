#!/bin/bash

. ${HOME}/common/functions.sh

SCRIPTDIR=$(realpath "$(dirname "$0")")
TEMPDIR=${HOME}/build
VERSION=5.12.12
BUILDDIR=${TEMPDIR}/qt${VERSION}-debug-build
SOURCEDIR=${TEMPDIR}/qt-everywhere-src-${VERSION}

PREFIX=${QT_BUILD_PREFIX}/qt-${VERSION}-debug-x86_64

SOURCE=qt-everywhere-src-${VERSION}.tar.xz
URL=https://download.qt.io/archive/qt/5.12/${VERSION}/single/${SOURCE}
MD5SUM=88e7a1c9952bf5732751c794716c6a55

mkdir -p ${BUILDDIR}
set_gcc_version 7

extract() {
	cd ${TEMPDIR}
	if ! echo "${MD5SUM}  ${SOURCE}" | md5sum -c - ; then
		wget -c ${URL} -O ${SOURCE}
	fi
	if ! echo "${MD5SUM}  ${SOURCE}" | md5sum -c - ; then
		exit 1
	fi
	tar xJf ${SOURCE} --skip-old-files
}

prepare() {
	grep -qG "^QMAKE_CXXFLAGS\s*+=" ${SOURCEDIR}/qtbase/mkspecs/common/g++-base.conf || echo "QMAKE_CXXFLAGS          += -Wno-expansion-to-defined -Wno-shift-overflow -fpermissive -Wno-deprecated-declarations" >> ${SOURCEDIR}/qtbase/mkspecs/common/g++-base.conf

	cd ${TEMPDIR}
	mkdir -p ${BUILDDIR}
}

configure() {
	cd ${BUILDDIR}
	${TEMPDIR}/qt-everywhere-src-${VERSION}/configure -v \
		-opensource -confirm-license \
		-release \
		-force-debug-info \
		-separate-debug-info \
		-qml-debug \
		-nomake examples \
		-nomake tests \
		-prefix ${PREFIX} \
		-extprefix ${PREFIX} \
		-hostprefix ${PREFIX} \
		-shared \
		-silent \
		-c++std c++11 \
		-reduce-relocations \
		-no-strip \
		-no-pch \
		-no-rpath \
		-R ${PREFIX}/lib \
		-pkg-config \
		-no-directfb \
		-widgets \
		-libudev \
		-linuxfb \
		-vulkan \
		-kms \
		-fontconfig \
		-inotify \
		-dbus-linked \
		-qt-xcb \
		-qt-pcre \
		-qt-doubleconversion \
		-xcb-xlib \
		-sql-sqlite \
		-system-freetype \
		-system-libjpeg \
		-system-libpng \
		-system-zlib \
		-accessibility \
		-glib \
		-qreal double \
		-qpa xcb \
		-no-use-gold-linker \
		-no-warnings-are-errors
}

build() {
	cd ${BUILDDIR}
	make -j$(nproc)
}

install() {
	sed -i -e '/^QMAKE_CXXFLAGS\s*+=/d' ${SOURCEDIR}/qtbase/mkspecs/common/g++-base.conf
	cd ${BUILDDIR}
	echo "Installing to ${PREFIX}"
	make -j$(nproc) install

	# copy necessary libraries
	libs=(
		libicudata.so.60.2
		libicui18n.so.60.2
		libicuuc.so.60.2
	)

	local DESTINATION=${PREFIX}/lib
	mkdir -p ${DESTINATION}
	for i in ${!libs[@]}; do
		name0=${libs[$i]}
		name1=${name0%.*}
		name2=${name1%.*}
		name3=${name2%.*}
		find /usr/lib -regextype egrep -regex ".*(${name0}|${name1}|${name2}|${name3})" -exec cp -Pu --preserve=all {} ${DESTINATION} \;
		SOLIB=${DESTINATION}/${name0}
		chmod 755 ${SOLIB}
		# fix rpath (may be unstable)
		patchelf --set-rpath "$PREFIX/lib" ${SOLIB}
	done

	# Drop QMAKE_PRL_BUILD_DIR because reference the build dir
	find "${DESTINATION}" -type f -name '*.prl' -exec sed -i -e '/^QMAKE_PRL_BUILD_DIR/d' {} \;
}

extract
prepare
configure
build
install

# vim:set ts=2 sw=2 noet ft=sh:
