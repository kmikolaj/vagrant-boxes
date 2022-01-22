#!/bin/bash

SCRIPTDIR=$(realpath "$(dirname "$0")")
TEMPDIR=${HOME}/build
VERSION=5.5.1
BUILDDIR=${TEMPDIR}/qt5.5.1-debug-build
SOURCEDIR=${TEMPDIR}/qt-everywhere-opensource-src-5.5.1

PREFIX=${QT_BUILD_PREFIX}/qt-5.5.1-debug-x86_64

SOURCE=qt-everywhere-opensource-src-5.5.1.tar.xz
URL=https://download.qt.io/new_archive/qt/5.5/5.5.1/single/${SOURCE}
MD5SUM=c2a249e8795d45200d997d96860d0353

mkdir -p ${BUILDDIR}

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
	grep -qG "^QMAKE_CXXFLAGS\s*+=" ${SOURCEDIR}/qtbase/mkspecs/common/g++-base.conf || echo "QMAKE_CXXFLAGS          += -std=c++0x -fpermissive -Wno-deprecated-declarations" >> ${SOURCEDIR}/qtbase/mkspecs/common/g++-base.conf

	cd ${TEMPDIR}
	patch -N -p1 < ${SCRIPTDIR}/new-char-types.patch
	patch -N -p1 < ${SCRIPTDIR}/icu60.patch
	mkdir -p ${BUILDDIR}
}

configure() {
	cd ${BUILDDIR}
	${TEMPDIR}/qt-everywhere-opensource-src-5.5.1/configure -v \
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
		-skip qt3d -skip qtactiveqt -skip qtenginio -skip qtandroidextras -skip qtcanvas3d -skip qtconnectivity -skip qtdoc -skip qtgraphicaleffects -skip qtimageformats -skip qtlocation -skip qtmacextras -skip qtmultimedia -skip qtquickcontrols -skip qtscript -skip qtsensors -skip qtserialport -skip qtsvg -skip qttools -skip qttranslations -skip qtwayland -skip qtwebchannel -skip qtwebengine -skip qtwebsockets -skip qtwinextras -skip qtx11extras -skip qtxmlpatterns -skip qtwebkit \
		-c++11 \
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
		-kms \
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
		-dbus-linked \
		-openssl \
		-qt-xcb \
		-qt-pcre \
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
				libssl.so.1.0.0
				libcrypto.so.1.0.0
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

#extract
prepare
configure
build
install

# vim:set ts=2 sw=2 noet ft=sh:
