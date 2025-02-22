# 6. Cross Compiling Temporary Tools
# Binutils Pass 2
build_binutils_pass2() {
	cd binutils
	sed '6031s/$add_dir//' -i ltmain.sh
	rm -rf build
	mkdir -p build
	cd build
	CFLAGS="$GLOBAL_CFLAGS" CXXFLAGS="$GLOBAL_CFLAGS" \
	../configure \
		--prefix=/usr \
		--build=$(../config.guess) \
		--host=$LFS_TGT \
		--disable-nls \
		--enable-shared \
		--enable-gprofng=no \
		--disable-werror \
		--enable-64-bit-bfd \
		--enable-new-dtags \
		--enable-default-hash-style=gnu

	make $MAKEFLAGS
	make DESTDIR=$LFS install
	rm -v $LFS/usr/lib/lib{bfd,ctf,ctf-nobfd,opcodes,sframe}.{a,la}
	cd ../..
}

# GCC Pass 2
build_gcc_pass2() {
	cd gcc
	sed '/thread_header =/s/@.*@/gthr-posix.h/' \
		-i libgcc/Makefile.in libstdc++-v3/include/Makefile.in

	rm -rf build
	mkdir -p build
	cd build
	CFLAGS="$GLOBAL_CFLAGS" CXXFLAGS="$GLOBAL_CFLAGS" \
	../configure \
		--build=$(../config.guess) \
		--host=$LFS_TGT \
		--target=$LFS_TGT \
		LDFLAGS_FOR_TARGET=-L$PWD/$LFS_TGT/libgcc \
		--prefix=/usr \
		--with-build-sysroot=$LFS \
		--enable-default-pie \
		--enable-default-ssp \
		--disable-nls \
		--disable-multilib \
		--disable-libatomic \
		--disable-libgomp \
		--disable-libquadmath \
		--disable-libsanitizer \
		--disable-libssp \
		--disable-libvtv \
		--enable-languages=c,c++

	make $MAKEFLAGS
	make DESTDIR=$LFS install
	ln -sv gcc $LFS/usr/bin/cc
	cd ../..
}
