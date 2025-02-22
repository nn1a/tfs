# 6. Cross Compiling Temporary Tools

build_m4() {
	echo "build_m4"
	[ -d m4 ] || git clone "$VCS_SERVER_URL/platform/upstream/m4" -b tizen_base --depth 1
	cd m4
	clean_git $(pwd)

	sed -i 's/SUBDIRS = lib src doc man po tests/SUBDIRS = lib src po tests/g' Makefile.in
	sed -i 's/SUBDIRS = . examples lib src doc checks po tests/SUBDIRS = . examples lib src checks po tests/g' Makefile.am

	autoreconf -fiv
	CFLAGS="$GLOBAL_CFLAGS" CXXFLAGS="$GLOBAL_CFLAGS" \
	./configure --prefix=/usr \
		--host=$LFS_TGT \
		--build=$(build-aux/config.guess) \
		gl_cv_func_isnanl_works=yes \
	    gl_cv_func_printf_directive_n=yes \
	    ac_cv_sys_stack_overflow_works=yes \
	    ac_cv_sys_xsi_stack_overflow_heuristic=yes

	make $MAKEFLAGS
	make DESTDIR=$LFS install
	cd ..
}

build_ncurses() {
	echo "build_ncurses"
	[ -d ncurses ] || git clone "$VCS_SERVER_URL/platform/upstream/ncurses" -b tizen_base --depth 1
	cd ncurses
	clean_git $(pwd)
	mkdir -p build
	pushd build
	CFLAGS="$GLOBAL_CFLAGS" CXXFLAGS="$GLOBAL_CFLAGS" \
	../configure AWK=gawk
	make -C include
	make -C progs tic
	popd
	CFLAGS="$GLOBAL_CFLAGS -Wno-error=implicit-function-declaration" CXXFLAGS="$GLOBAL_CFLAGS" \
	./configure --prefix=/usr \
		--host=$LFS_TGT \
		--build=$(./config.guess) \
		--mandir=/usr/share/man \
		--with-manpage-format=normal \
		--with-shared \
		--without-normal \
		--with-cxx-shared \
		--without-debug \
		--without-ada \
		--disable-stripping \
		--enable-widec \
		--with-termlib \
		AWK=gawk

	make $MAKEFLAGS
	make DESTDIR=$LFS TIC_PATH=$(pwd)/build/progs/tic install
	[ -f $LFS/usr/lib/libncurses.so ] || ln -sv libncursesw.so $LFS/usr/lib/libncurses.so
	[ -f $LFS/usr/lib/libtinfo.so ] || ln -sv libtinfow.so $LFS/usr/lib/libtinfo.so
	sed -e 's/^#if.*XOPEN.*$/#if 1/' \
		-i $LFS/usr/include/curses.h
	cd ..
}

build_bash() {
	echo "build_bash"
	[ -d bash ] || git clone "$VCS_SERVER_URL/product/upstream/bash" -b tizen_base --depth 1
	cd bash
	clean_git $(pwd)

	CFLAGS="$GLOBAL_CFLAGS -Wno-error=implicit-function-declaration -Wno-error=implicit-int " CXXFLAGS="$GLOBAL_CFLAGS" \
		./configure --prefix=/usr \
		--build=$(sh support/config.guess) \
		--host=$LFS_TGT \
		--enable-largefile \
		--without-bash-malloc \
		--disable-nls \
		--enable-alias \
		--enable-readline  \
		--enable-history

	# parallel build is make error, so use -j1
	make -j1 "CPPFLAGS=-D_GNU_SOURCE -DDEFAULT_PATH_VALUE='\"/usr/local/bin:/usr/bin\"' -DRECYCLES_PIDS"
	make DESTDIR=$LFS install
	[ -f $LFS/usr/bin/sh ] || ln -sv bash $LFS/usr/bin/sh
	cd ..
}

build_coreutils() {
	echo "build_coreutils"
	[ -d coreutils ] || git clone "$VCS_SERVER_URL/product/upstream/coreutils" -b tizen_base --depth 1
	cd coreutils
	clean_git $(pwd)

	# tar xf packaging/mktemp-1.5.tar.gz
	# cp build-aux/config.sub mktemp-1.5
	# cp build-aux/config.guess mktemp-1.5
	# pushd mktemp-1.5
	# ./configure --prefix=/usr \
	# 	--host=$LFS_TGT \
	# 	--build=$(build-aux/config.guess)
	# make
	# popd
	
	sed 's/SUBDIRS = lib src doc man po tests/SUBDIRS = lib src po tests/g' -i Makefile.in
	sed 's/SUBDIRS = lib src doc man po tests/SUBDIRS = lib src po tests/g' -i Makefile.am

	sed 's/--output=\$t\/\$@ \$t\/\$/--output=\$t\/\$@ \$/' -i man/Makefile.in
	sed 's/--output=\$t\/\$@ \$t\/\$/--output=\$t\/\$@ \$/' -i man/Makefile.am

	sed -i 's/@itemx/@item/g' doc/coreutils.texi
	CFLAGS="$GLOBAL_CFLAGS -mabi=ilp32 -Wno-error=implicit-function-declaration -Wno-error=calloc-transposed-args " CXXFLAGS="$GLOBAL_CFLAGS" \
		./configure --prefix=/usr \
		--host=$LFS_TGT \
		--build=$(build-aux/config.guess) \
		ac_cv_func_strcoll_works=yes \
        ac_cv_func_working_mktime=yes \
	
	make $MAKEFLAGS
	make DESTDIR=$LFS install
	mv -v $LFS/usr/bin/chroot $LFS/usr/sbin
#	mkdir -pv $LFS/usr/share/man/man8
#	mv -v $LFS/usr/share/man/man1/chroot.1 $LFS/usr/share/man/man8/chroot.8
#	sed -i 's/"1"/"8"/' $LFS/usr/share/man/man8/chroot.8
	cd ..
}

build_diffutils() {
	echo "build_diffutils"
	# [ -d diffutils ] || git clone "$VCS_SERVER_URL/platform/upstream/diffutils" -b tizen_base --depth 1
	# clean_git $(pwd)
	# cd diffutils
	if [ ! -d diffutils-3.11 ]; then
		curl -o diffutils-3.11.tar.xz https://ftp.gnu.org/gnu/diffutils/diffutils-3.11.tar.xz
		tar -xf diffutils-3.11.tar.xz
	fi
	cd diffutils-3.11
	CFLAGS="$GLOBAL_CFLAGS" CXXFLAGS="$GLOBAL_CFLAGS" \
	./configure --prefix=/usr \
		--host=$LFS_TGT \
		--build=$(./build-aux/config.guess) \
		--disable-nls

	make $MAKEFLAGS
	make DESTDIR=$LFS install
	cd ..
}

build_file() {
	echo "build_file"
	[ -d file ] || git clone "$VCS_SERVER_URL/platform/upstream/file" -b tizen_base --depth 1
	cd file
	clean_git $(pwd)

	rm -f Magdir/*,v Magdir/*~
	rm -f ltcf-c.sh ltconfig ltmain.sh
	autoreconf -fiv

	mkdir -p build
	pushd build
	../configure --disable-bzlib \
		--disable-libseccomp \
		--disable-xzlib \
		--disable-zlib \
		--build=$(./config.guess)
	make
	popd
	CFLAGS="$GLOBAL_CFLAGS" CXXFLAGS="$GLOBAL_CFLAGS" \
	./configure \
		--prefix=/usr \
		--host=$LFS_TGT \
		--build=$(./config.guess) \
		--disable-silent-rules \
		--disable-static \
		--enable-fsect-man5

	sed -i 's|^hardcode_libdir_flag_spec=.*|hardcode_libdir_flag_spec=""|g' libtool
	sed -i 's|^runpath_var=LD_RUN_PATH|runpath_var=DIE_RPATH_DIE|g' libtool

	make FILE_COMPILE=$(pwd)/build/src/file
	make DESTDIR=$LFS install
	rm -v $LFS/usr/lib/libmagic.la
	cd ..
}

build_findutils() {
	echo "build_findutils"
	[ -d findutils ] || git clone "$VCS_SERVER_URL/product/upstream/findutils" -b tizen_base --depth 1
	cd findutils
	clean_git $(pwd)

	CFLAGS="$GLOBAL_CFLAGS" CXXFLAGS="$GLOBAL_CFLAGS" \
	./configure --prefix=/usr \
		--localstatedir=/var/lib/locate \
		--host=$LFS_TGT \
		--build=$(build-aux/config.guess) \
		ac_cv_func_strcoll_works=yes \
        ac_cv_func_working_mktime=yes \
	
	sed -i 's/char \*program_name;//g' find/find.c
	sed -i 's/^int starting_desc;//g' find/find.c
	sed -i 's/^const char \*program_name;//g' locate/code.c

	make $MAKEFLAGS
	make DESTDIR=$LFS install
	cd ..
}

build_gawk() {
	echo "build_gawk"
	[ -d gawk ] || git clone "$VCS_SERVER_URL/product/upstream/gawk" -b tizen_base --depth 1
	cd gawk
	clean_git $(pwd)
	sed -i 's/extras//' Makefile.in
	sed -i 's/AM_C_PROTOTYPES//' configure.ac
	sed -i 's/AUTOMAKE_OPTIONS = ansi2knr dist-bzip2/AUTOMAKE_OPTIONS = dist-bzip2/g' Makefile.am

	sed -i 's/static ptr_t xmalloc PARAMS ((size_t n));//g' dfa.c
	sed -i 's/#include "hard-locale.h"/static ptr_t xmalloc PARAMS ((size_t n));\n#include "hard-locale.h"/g' dfa.c
	sed -i 's/static ptr_t xmalloc PARAMS ((size_t n));//g' hard-locale.h
	sed -i 's/^extern void dfasyntax PARAMS ((reg_syntax_t, int, unsigned char));/extern void dfasyntax (reg_syntax_t, int, unsigned char);/g' dfa.h

	autoreconf -fiv
	CFLAGS="$GLOBAL_CFLAGS" CXXFLAGS="$GLOBAL_CFLAGS" \
	./configure --prefix=/usr \
		--host=$LFS_TGT \
		--build=$(./config.guess) \
		--disable-man \
        --disable-nls

	# parallel build is make error, so use -j1
	make -j1
	make DESTDIR=$LFS install
	cd ..
}

build_grep() {
	echo "build_grep"
	[ -d grep ] || git clone "$VCS_SERVER_URL/product/upstream/grep" -b tizen_base --depth 1
	cd grep
	clean_git $(pwd)

	sed -i 's/^AM_C_PROTOTYPES//g' configure.ac
	sed -i 's/^AM_C_PROTOTYPES//g' configure.ac.in
	sed -i 's/^AM_GNU_GETTEXT$/AM_GNU_GETTEXT([external])/g' configure.ac
	sed -i 's/^AM_GNU_GETTEXT$/AM_GNU_GETTEXT([external])/g' configure.ac.in
	sed -i 's/^AM_CONFIG_HEADER$/AM_CONFIG_HEADERS/g' configure.ac
	sed -i 's/^AM_CONFIG_HEADER$/AM_CONFIG_HEADERS/g' configure.ac.in
	sed -i 's/^AC_HEADER_STDC$/AC_CHECK_HEADERS([stdlib.h string.h])/g' configure.ac
	sed -i 's/^AC_HEADER_STDC$/AC_CHECK_HEADERS([stdlib.h string.h])/g' configure.ac.in

	sed -i 's/AC_OUTPUT(Makefile lib\/Makefile lib\/posix\/Makefile src\/Makefile tests\/Makefile po\/Makefile.in intl\/Makefile doc\/Makefile m4\/Makefile vms\/Makefile bootstrap\/Makefile, \[sed -e "\/POTFILES =\/r po\/POTFILES" po\/Makefile.in > po\/Makefile; echo timestamp > stamp-h\])/AC_OUTPUT(Makefile lib\/Makefile lib\/posix\/Makefile src\/Makefile tests\/Makefile po\/Makefile.in intl\/Makefile doc\/Makefile m4\/Makefile vms\/Makefile bootstrap\/Makefile, \[echo timestamp > stamp-h\])/g' configure.ac
	sed -i 's/AC_OUTPUT(Makefile lib\/Makefile lib\/posix\/Makefile src\/Makefile tests\/Makefile po\/Makefile.in intl\/Makefile doc\/Makefile m4\/Makefile vms\/Makefile bootstrap\/Makefile, \[sed -e "\/POTFILES =\/r po\/POTFILES" po\/Makefile.in > po\/Makefile; echo timestamp > stamp-h\])/AC_OUTPUT(Makefile lib\/Makefile lib\/posix\/Makefile src\/Makefile tests\/Makefile po\/Makefile.in intl\/Makefile doc\/Makefile m4\/Makefile vms\/Makefile bootstrap\/Makefile, \[echo timestamp > stamp-h\])/g' configure.ac.in

	sed -i 's/AUTOMAKE_OPTIONS = ..\/src\/ansi2knr/AUTOMAKE_OPTIONS = /g' lib/Makefile.am
	sed -i 's/AUTOMAKE_OPTIONS = ansi2knr/AUTOMAKE_OPTIONS = /g' src/Makefile.am

 	cp /usr/share/gettext/config.rpath .
	autoreconf -fiv
	
	CFLAGS="$GLOBAL_CFLAGS" CXXFLAGS="$GLOBAL_CFLAGS" \
	./configure --prefix=/usr \
		--host=$LFS_TGT \
		--build=$(./config.guess)
	make $MAKEFLAGS
	make DESTDIR=$LFS install
	cd ..
}

build_gzip() {
	echo "build_gzip"
	[ -d gzip ] || git clone "$VCS_SERVER_URL/product/upstream/gzip" -b tizen_base --depth 1
	cd gzip
	clean_git $(pwd)
	CFLAGS="$GLOBAL_CFLAGS" CXXFLAGS="$GLOBAL_CFLAGS" \
	./configure --prefix=/usr --host=$LFS_TGT
	make $MAKEFLAGS
	make DESTDIR=$LFS install
	cd ..
}

build_make() {
	echo "build_make"
	[ -d make ] || git clone "$VCS_SERVER_URL/platform/upstream/make" -b tizen_base --depth 1
	cd make
	clean_git $(pwd)
	CFLAGS="$GLOBAL_CFLAGS" CXXFLAGS="$GLOBAL_CFLAGS" \
	./configure --prefix=/usr \
		--without-guile \
		--host=$LFS_TGT \
		--build=$(build-aux/config.guess)
	make $MAKEFLAGS
	make DESTDIR=$LFS install
	cd ..
}

build_patch() {
	echo "build_patch"
	[ -d patch ] || git clone "$VCS_SERVER_URL/platform/upstream/patch" -b tizen_base --depth 1
	cd patch
	clean_git $(pwd)
	autoreconf -fiv
	CFLAGS="$GLOBAL_CFLAGS" CXXFLAGS="$GLOBAL_CFLAGS" \
	./configure --prefix=/usr \
		--host=$LFS_TGT \
		--build=$(build-aux/config.guess)
	make $MAKEFLAGS
	make DESTDIR=$LFS install
	cd ..
}

build_sed() {
	echo "build_sed"
	[ -d sed ] || git clone "$VCS_SERVER_URL/product/upstream/sed" -b tizen_base --depth 1
	cd sed
	clean_git $(pwd)
	CFLAGS="$GLOBAL_CFLAGS -Wno-error=implicit-function-declaration -Wno-error=builtin-declaration-mismatch" CXXFLAGS="$GLOBAL_CFLAGS" \
	./configure --prefix=/usr \
		--host=$LFS_TGT \
		--build=$(./build-aux/config.guess) \
		--disable-nls
	sed -i 's/SUBDIRS = intl lib po sed doc testsuite/SUBDIRS = intl lib po sed testsuite/g' Makefile
	make $MAKEFLAGS
	make DESTDIR=$LFS install
	cd ..
}

build_tar() {
	echo "build_tar"
	[ -d tar ] || git clone "$VCS_SERVER_URL/product/upstream/tar" -b tizen_base --depth 1
	cd tar
	clean_git $(pwd)
	CFLAGS="$GLOBAL_CFLAGS" CXXFLAGS="$GLOBAL_CFLAGS" \
	./configure --prefix=/usr \
		--host=$LFS_TGT \
		--build=$(build-aux/config.guess) \
		ac_cv_func_strcoll_works=yes \
        ac_cv_func_working_mktime=yes \

	make $MAKEFLAGS
	make DESTDIR=$LFS install
	cd ..
}

build_xz() {
	echo "build_xz"
	CFLAGS="$GLOBAL_CFLAGS" CXXFLAGS="$GLOBAL_CFLAGS" \
	[ -d xz ] || git clone "$VCS_SERVER_URL/platform/upstream/xz" -b tizen_base --depth 1
	cd xz
	clean_git $(pwd)
	CFLAGS="$GLOBAL_CFLAGS" CXXFLAGS="$GLOBAL_CFLAGS" \
	./configure --prefix=/usr \
		--host=$LFS_TGT \
		--build=$(build-aux/config.guess) \
		--disable-static \
		--docdir=/usr/share/doc/xz-5.6.4
	make $MAKEFLAGS
	make DESTDIR=$LFS install
	rm -v $LFS/usr/lib/liblzma.la
	cd ..
}
