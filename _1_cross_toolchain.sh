# 5. Compiling a Cross-Toolchain

download_sources() {
	[ -d binutils ] || git clone "$VCS_SERVER_URL/platform/upstream/binutils" -b sandbox/dkson95/ilp32 --depth 1
	[ -d gcc ] || git clone "$VCS_SERVER_URL/platform/upstream/gcc" -b sandbox/dkson95/ilp32 --depth 1
	[ -d linux-glibc-devel ] || git clone "$VCS_SERVER_URL/platform/upstream/linux-glibc-devel" -b sandbox/dkson95/ilp32 --depth 1
	[ -d glibc ] || git clone "$VCS_SERVER_URL/platform/upstream/glibc" -b sandbox/dkson95/ilp32 --depth 1
	[ -d libxcrypt ] || git clone "$VCS_SERVER_URL/platform/upstream/libxcrypt" -b tizen_base --depth 1
}

# 1. Binutils
build_binutils() {
	cd binutils
	clean_git $(pwd)

	tar -xf ../gcc/packaging/mpfr-4.1.0.tar.bz2
	tar -xf ../gcc/packaging/gmp-6.2.1.tar.bz2
	rm -rf mpfr gmp
	mv mpfr-4.1.0 mpfr
	mv gmp-6.2.1 gmp

	mkdir -p build
	cd build
	../configure --prefix=$LFS/tools \
		--with-sysroot=$LFS \
		--target=$LFS_TGT \
		--disable-nls \
		--enable-gprofng=no \
		--disable-werror \
		--enable-new-dtags \
		--enable-default-hash-style=gnu

	make $MAKEFLAGS
	make install
	cd ../..
}

# 2. GCC
build_gcc_step1() {
	cd gcc
	clean_git $(pwd)
	tar -xf packaging/mpfr-4.1.0.tar.bz2
	tar -xf packaging/gmp-6.2.1.tar.bz2
	tar -xf packaging/mpc-1.2.1.tar.gz

	rm -rf mpfr gmp mpc
	mv mpfr-4.1.0 mpfr
	mv gmp-6.2.1 gmp
	mv mpc-1.2.1 mpc

	mkdir -p build
	cd build
	CFLAGS="$GLOBAL_CFLAGS" CXXFLAGS="$GLOBAL_CFLAGS" \
	../configure \
		--target=$LFS_TGT \
		--prefix=$LFS/tools \
		--with-glibc-version=2.40 \
		--with-sysroot=$LFS \
		--with-newlib \
		--without-headers \
		--enable-default-pie \
		--enable-default-ssp \
		--disable-nls \
		--disable-shared \
		--disable-multilib \
		--disable-threads \
		--disable-libatomic \
		--disable-libgomp \
		--disable-libquadmath \
		--disable-libssp \
		--disable-libvtv \
		--disable-libstdcxx \
		--enable-languages=c,c++ \
		--enable-multilib \
		--with-arch=armv8-a \
		--disable-sjlj-exceptions \
		--with-multilib-list=ilp32 


	make $MAKEFLAGS
	make install

	cd ..
	cat gcc/limitx.h gcc/glimits.h gcc/limity.h > \
		$(dirname $($LFS_TGT-gcc -print-libgcc-file-name))/include/limits.h
	cd ..
}

# 3. Linux
build_linux_headers() {
	cd linux-glibc-devel
	clean_git $(pwd)
	build_arch="arm64"
	mkdir -p $LFS/usr/include
cat >version.h <<-BOGUS
#ifdef __KERNEL__
#error "======================================================="
#error "You should not include /usr/include/{linux,asm}/ header"
#error "files directly for the compilation of kernel modules."
#error ""
#error "glibc now uses kernel header files from a well-defined"
#error "working kernel version (as recommended by Linus Torvalds)"
#error "These files are glibc internal and may not match the"
#error "currently running kernel. They should only be"
#error "included via other system header files - user space"
#error "programs should not directly include <linux/*.h> or"
#error "<asm/*.h> as well."
#error ""
#error "Since Linux 2.6, the kernel module build process has been"
#error "updated such that users building modules should not typically"
#error "need to specify additional include directories at all."
#error ""
#error "To build kernel modules, ensure you have the build environment "
#error "available either via the kernel-devel and kernel-<flavor>-devel "
#error "packages or a properly configured kernel source tree."
#error ""
#error "Then, modules can be built using:"
#error "make -C <path> M=$PWD"
#error ""
#error "For the currently running kernel there will be a symbolic "
#error "link pointing to the build environment located at "
#error "/lib/modules/$(uname -r)/build for use as <path>."
#error ""
#error "If you are seeing this message, your environment is "
#error "not configured properly. "
#error ""
#error "Please adjust the Makefile accordingly."
#error "======================================================="
#else
BOGUS
# Get LINUX_VERSION_CODE and KERNEL_VERSION directly from kernel
cat ${build_arch}/usr/include/linux/version.h >>version.h
cat >>version.h <<-BOGUS
	#endif
BOGUS
	cat version.h

	cp -a $build_arch/usr $LFS
	cp -a version.h $LFS/usr/include/linux/
	cp -a $LFS/usr/include/asm/ $LFS/usr/include/asm-${build_arch}
	# Temporarily exclude i2c header files, which are provided by i2c-tools instead
	rm -fv $LFS/usr/include/linux/i2c-dev.h
	# resolve file conflict with glibc for now
	rm -fv $LFS/usr/include/scsi/scsi*

	cd ..
}

# 4. Glibc
build_glibc_step1() {
	cd glibc
	clean_git $(pwd)
	mkdir -p build
	cd build
	echo "rootsbindir=/usr/sbin" >configparms
	# --disable-werror -> error in ILP32, MACRO is 64bit offset, but it is used in 32bit
	CFLAGS="$GLOBAL_CFLAGS -U_LARGEFILE_SOURCE -U_LARGEFILE64_SOURCE -U_FILE_OFFSET_BITS " CXXFLAGS="$GLOBAL_CFLAGS -U_LARGEFILE_SOURCE -U_LARGEFILE64_SOURCE -U_FILE_OFFSET_BITS" \
		../configure \
		--prefix=/usr \
		--host=$LFS_TGT \
		--target=$LFS_TGT \
		--build=$(../scripts/config.guess) \
		--enable-kernel=3.0.0 \
		--with-headers=$LFS/usr/include \
		--disable-nscd \
		--with-abi=ilp32 \
		--disable-werror \
		libc_cv_slibdir=/usr/lib

	make $MAKEFLAGS
	make DESTDIR=$LFS install

	# sed '/RTLDLIST=/s@/usr@@g' -i $LFS/usr/bin/ldd

	echo 'int main(){}' | $LFS_TGT-gcc -xc -
	readelf -l a.out | grep ld-linux
	rm -v a.out
	cd ../..
}

# Libstdc++
build_gcc_libstdc() {
	cd gcc
	clean_git $(pwd)
	tar -xf packaging/mpfr-4.1.0.tar.bz2
	tar -xf packaging/gmp-6.2.1.tar.bz2
	tar -xf packaging/mpc-1.2.1.tar.gz

	rm -rf mpfr gmp mpc
	mv mpfr-4.1.0 mpfr
	mv gmp-6.2.1 gmp
	mv mpc-1.2.1 mpc

	mkdir -p build-libstdc++
	cd build-libstdc++
	CFLAGS="$GLOBAL_CFLAGS" CXXFLAGS="$GLOBAL_CFLAGS" \
	../libstdc++-v3/configure \
		--host=$LFS_TGT \
		--build=$(../config.guess) \
		--prefix=/usr \
		--disable-multilib \
		--disable-nls \
		--disable-libstdcxx-pch \
		--with-gxx-include-dir=/tools/$LFS_TGT/include/c++/14.2.0 \
		--with-mabi=ilp32

	make $MAKEFLAGS
	make DESTDIR=$LFS install
	rm -v $LFS/usr/lib/lib{stdc++{,exp,fs},supc++}.la || true
	cd ../..
}

build_libxcrypt () {
	cd libxcrypt
	clean_git $(pwd)
	autoreconf -fiv -Wall,error
	CFLAGS="$GLOBAL_CFLAGS" CXXFLAGS="$GLOBAL_CFLAGS" \
	./configure \
		--host=$LFS_TGT \
		--build=$(m4-autogen/config.guess) \
		--prefix=/usr \
		--enable-hashes=strong,glibc \
		--enable-obsolete-api=no     \
		--disable-static             \
		--disable-failure-tokens

	make $MAKEFLAGS
	make DESTDIR=$LFS install

	cd ..
}