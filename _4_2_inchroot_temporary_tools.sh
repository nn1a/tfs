# 7. Entering Chroot and Building Additional Temporary Tools
build_gettext() {
	[ -d gettext ] || git clone "$VCS_SERVER_URL/platform/upstream/gettext" -b tizen_base --depth 1
	cd gettext
	clean_git $(pwd)
	./configure \
		--prefix=/usr \
		--host=$LFS_TGT \
		--build=$(./build-aux/config.guess) \
		--disable-static \
		--enable-shared

	make $MAKEFLAGS
	make DESTDIR=$LFS install
	cp -v gettext-tools/src/{msgfmt,msgmerge,xgettext} $LFS/usr/bin
	cd ..
}

build_bison() {
	[ -d bison ] || git clone "$VCS_SERVER_URL/platform/upstream/bison" -b tizen_base --depth 1
	cd bison
	clean_git $(pwd)
	./configure --prefix=/usr \
		--host=$LFS_TGT \
		--build=$(./build-aux/config.guess) \
		--docdir=/usr/share/doc/bison-3.8.2

	make $MAKEFLAGS
	make DESTDIR=$LFS install
	cd ..
}

build_perl() {
	[ -d perl ] || git clone "$VCS_SERVER_URL/platform/upstream/perl" -b tizen_base --depth 1
	[ -f perl-cross-1.6.1.tar.gz ] ||
		curl -L -O https://github.com/arsv/perl-cross/releases/download/1.6.1/perl-cross-1.6.1.tar.gz
	cd perl
	clean_git $(pwd)

	[ -f configure ] || tar --strip-components=1 -xf ../perl-cross-1.6.1.tar.gz
	./configure \
		--prefix=/usr \
		--target=$LFS_TGT \
		-Dprefix=/usr \
		-Dvendorprefix=/usr \
		-Duseshrplib \
		-Dprivlib=/usr/lib/perl5/5.38/core_perl \
		-Darchlib=/usr/lib/perl5/5.38/core_perl \
		-Dsitelib=/usr/lib/perl5/5.38/site_perl \
		-Dsitearch=/usr/lib/perl5/5.38/site_perl \
		-Dvendorlib=/usr/lib/perl5/5.38/vendor_perl \
		-Dvendorarch=/usr/lib/perl5/5.38/vendor_perl \
		-Dman1dir=/usr/share/man/man1 \
		-Dman3dir=/usr/share/man/man3 \
		-Accflags='-DPERL_USE_SAFE_PUTENV'

	make $MAKEFLAGS
	make DESTDIR=$LFS install
	cd ..
}

build_zlib() {
	[ -d zlib ] || git clone "$VCS_SERVER_URL/platform/upstream/zlib" -b tizen_base --depth 1
	cd zlib
	clean_git $(pwd)
	CROSS_PREFIX=$LFS_TGT- \
		./configure --prefix=/usr \
		--shared

	make $MAKEFLAGS
	make DESTDIR=$LFS install
	cd ..
}

build_libffi() {
	[ -d libffi ] || git clone "$VCS_SERVER_URL/platform/upstream/libffi" -b tizen_base --depth 1
	cd libffi
	clean_git $(pwd)
	./autogen.sh
	./configure --prefix=/usr \
		--host=$LFS_TGT \
		--build=$(sh ./config.guess) \
		--disable-static \
		--enable-shared \
		--enable-portable-binary

	make $MAKEFLAGS
	make DESTDIR=$LFS install
	cd ..
}

build_util_linux() {
	[ -d util-linux ] || git clone "$VCS_SERVER_URL/platform/upstream/util-linux" -b tizen_base --depth 1
	cd util-linux
	clean_git $(pwd)
	GTKDOCIZE="echo" autoreconf -fi

	CFLAGS="$GLOBAL_CFLAGS -Wno-error=implicit-function-declaration -DHAVE_MOUNT_SETATTR" \
		./configure \
		--host=$LFS_TGT \
		--prefix=/usr \
		--libdir=/usr/lib \
		--runstatedir=/run \
		--disable-raw \
		--enable-mesg \
		--enable-partx \
		--disable-kill \
		--enable-write \
		--enable-line \
		--enable-new-mount \
		--enable-login-utils \
		--enable-mountpoint \
		--enable-fdformat \
		--disable-use-tty-group \
		--disable-static \
		--disable-silent-rules \
		--disable-rpath \
		--disable-makeinstall-chown \
		--disable-hwclock-gplv3 \
		--without-python

	make $MAKEFLAGS
	make DESTDIR=$LFS install
	cd ..
}

build_python3() {
	[ -d python3 ] || git clone "$VCS_SERVER_URL/platform/upstream/python3" -b tizen_base --depth 1

	cd python3
	clean_git $(pwd)
	# build x86_64 python3
	mkdir _host_build
	cd _host_build
	host_python=$(pwd)/host_tools
	../configure \
		--prefix=$host_python \
		--build=$(./config.guess) \
		--enable-shared \
		--without-ensurepip

	make $MAKEFLAGS
	make install
	cd ..

	# clean_git $(pwd)
	# build aarch64 python3
	backup_ld_library_path=$LD_LIBRARY_PATH
	export LD_LIBRARY_PATH=$host_python/lib

	./configure --prefix=/usr \
		--host=$LFS_TGT \
		--build=$(./config.guess) \
		--with-build-python=$host_python/bin/python3 \
		--enable-shared \
		--without-ensurepip \
		--disable-ipv6 \
		ac_cv_file__dev_ptmx=no \
		ac_cv_file__dev_ptc=no

	make $MAKEFLAGS
	make DESTDIR=$LFS install

	export LD_LIBRARY_PATH=$backup_ld_library_path
	cd ..
}

build_cross_help2man() {
	[ -d help2man ] || git clone "$VCS_SERVER_URL/platform/upstream/help2man" -b tizen_base --depth 1
	cd help2man
	clean_git $(pwd)
	autoreconf -fiv
	./configure --prefix=$LFS/tools

	make $MAKEFLAGS
	make install
	cd ..
}
build_texinfo() {
	[ -d texinfo ] || git clone "$VCS_SERVER_URL/platform/upstream/texinfo" -b tizen_base --depth 1
	cd texinfo
	# clean_git $(pwd)
	AUTOPOINT=true autoreconf -fi

	./configure \
		--prefix=/usr \
		--host=$LFS_TGT \
		--build=$(build-aux/config.guess) \
		--disable-perl-xs \
		--enable-nls \
		--disable-man \
		texinfo_cv_sys_iconv_converts_euc_cn=no

	make $MAKEFLAGS
	exit 1
	make DESTDIR=$LFS install
	cd ..
}
