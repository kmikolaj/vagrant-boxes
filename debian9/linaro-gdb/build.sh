#!/bin/bash

SOURCEDIR=$(realpath "$(dirname "$0")")
TEMPDIR=${HOME}/build
BUILDDIR=${TEMPDIR}/gdb-linaro-build
INSTALLDIR=${TEMPDIR}/gdb-linaro-install

SOURCE=gdb-linaro-7.8-2014.09.tar.xz
URL=http://releases.linaro.org/archive/14.09/components/toolchain/gdb-linaro/${SOURCE}
MD5SUM=954e47e397de0b635ecdb5bb5d0f145f

extract() {
	cd ${TEMPDIR}
	wget -nc ${URL} -O ${SOURCE}
	if ! echo "${MD5SUM}	${SOURCE}" | md5sum -c - ; then
		exit 1
	fi
	tar xJf ${SOURCE} --skip-old-files
}

prepare() {
	cd ${ROOTDIR}
	#sed -i "/ac_cpp=/s/\$CPPFLAGS/\$CPPFLAGS -O2/" libiberty/configure
	mkdir -p ${BUILDDIR}
}

configure() {
	cd ${BUILDDIR}
	${TEMPDIR}/gdb-linaro-7.8-2014.09/configure -v \
		--target=arm-linux-gnueabihf \
		--prefix=/usr \
		--datarootdir=/usr/share/gcc-linaro-arm-linux-gnueabihf-gdb \
		--enable-multilib \
		--enable-interwork \
		--without-system-readline \
		--with-guile=guile-2.0 \
		--with-python=python2.7 \
		--disable-nls
}

build() {
	cd ${BUILDDIR}
	make -j$(nproc)
}

install() {
	cd ${BUILDDIR}
	make DESTDIR=${INSTALLDIR} install
}

extract
prepare
configure
build
install

# vim:set ts=2 sw=2 noet ft=sh:
