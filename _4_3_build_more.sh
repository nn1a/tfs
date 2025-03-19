build_autoconf() {
	[ -d autoconf ] || git clone "$VCS_SERVER_URL/platform/upstream/autoconf" -b tizen_base --depth 1
	cd autoconf
	clean_git $(pwd)
	./configure --prefix=/usr \
		--host=$LFS_TGT \
		--build=$(./build-aux/config.guess) \
		--docdir=/usr/share/doc/autoconf-2.71

	make $MAKEFLAGS
	make DESTDIR=$LFS install
	cd ..
}

build_automake() {
	[ -d automake ] || git clone "$VCS_SERVER_URL/platform/upstream/automake" -b tizen_base --depth 1
	cd automake
	clean_git $(pwd)
	sh bootstrap
	./configure --prefix=/usr \
		--host=$LFS_TGT \
		--docdir=/usr/share/doc/automake-1.16.5

	make $MAKEFLAGS
	make DESTDIR=$LFS install
	cd ..
}

build_libtool() {
	[ -d libtool ] || git clone "$VCS_SERVER_URL/platform/upstream/libtool" -b tizen_base --depth 1
	cd libtool
	clean_git $(pwd)
	./configure --prefix=/usr \
		--host=$LFS_TGT \
		--build=$(./build-aux/config.guess) \
		--docdir=/usr/share/doc/libtool-2.4.7

	make $MAKEFLAGS
	make DESTDIR=$LFS install
	cd ..
}

build_perl-gettext() {
	[ -d perl-gettext ] || git clone "$VCS_SERVER_URL/platform/upstream/perl-gettext" -b tizen_base --depth 1
	cd perl-gettext
	clean_git $(pwd)

	perl Makefile.PL INSTALLDIRS=vendor
	make $MAKEFLAGS
	make DESTDIR=$LFS install
	cd ..
}

build_help2man() {
	[ -d help2man ] || git clone "$VCS_SERVER_URL/platform/upstream/help2man" -b tizen_base --depth 1
	cd help2man
	clean_git $(pwd)
	autoreconf -fiv
	./configure --prefix=/usr \
		--host=$LFS_TGT

	make clean
	make $MAKEFLAGS
	make DESTDIR=$LFS install
	cd ..
}

build_libxml2() {
	[ -d libxml2 ] || git clone "$VCS_SERVER_URL/platform/upstream/libxml2" -b tizen_base --depth 1
	cd libxml2
	clean_git $(pwd)
	./autogen.sh
	./configure --prefix=/usr \
		--host=$LFS_TGT \
		--build=$(./build-aux/config.guess) \
		--disable-static \
		--docdir=/usr/share/doc/libxml2 \
		--with-html-dir=/usr/share/doc/libxml2/html \
		--with-fexceptions \
		--with-history \
		--without-python \
		--enable-ipv6 \
		--with-sax1 \
		--with-regexps \
		--with-threads \
		--with-reader \
		--with-http

	make $MAKEFLAGS BASE_DIR="/usr/share/doc" DOC_MODULE="libxml2"
	make DESTDIR=$LFS install
	cd ..
}

build_openssl3() {
	[ -d openssl3 ] || git clone "$VCS_SERVER_URL/platform/upstream/openssl3" -b tizen_base --depth 1
	cd openssl3
	clean_git $(pwd)

	./Configure --prefix=/usr \
		--openssldir=/etc/ssl \
		--libdir=lib \
		--cross-compile-prefix=$LFS_TGT- \
		threads shared no-idea no-rc5 no-camellia enable-md2 enable-weak-ssl-ciphers no-afalgeng linux-aarch64 -std=gnu99

	make $MAKEFLAGS build_sw
	make DESTDIR=$LFS install_sw install_ssldirs
	cd ..
}

build_libtool() {
	[ -d libtool ] || git clone "$VCS_SERVER_URL/platform/upstream/libtool" -b tizen_base --depth 1
	cd libtool
	clean_git $(pwd)
	./configure --prefix=/usr \
		--host=$LFS_TGT \
		--build=$(./build-aux/config.guess) \
		--docdir=/usr/share/doc/libtool-2.4.7

	make $MAKEFLAGS
	make DESTDIR=$LFS install
	cd ..
}

build_zstd() {
	[ -d zstd ] || git clone "$VCS_SERVER_URL/platform/upstream/zstd" -b tizen_base --depth 1
	cd zstd
	clean_git $(pwd)
	CC=$LFS_TGT-gcc make $MAKEFLAGS PREFIX=/usr DESTDIR=$LFS
	make DESTDIR=$LFS install
	cd ..
}

build_libarchive() {
	[ -d libarchive ] || git clone "$VCS_SERVER_URL/platform/upstream/libarchive" -b tizen_base --depth 1
	cd libarchive
	clean_git $(pwd)
	autoreconf -fiv
	./configure --prefix=/usr \
		--host=$LFS_TGT \
		--build=$(./build-aux/config.guess) \
		--disable-static \
		--enable-bsdcpio

	make $MAKEFLAGS
	make DESTDIR=$LFS install
	cd ..
}

build_attr() {
	[ -d attr ] || git clone "$VCS_SERVER_URL/platform/upstream/attr" -b tizen_base --depth 1
	cd attr
	clean_git $(pwd)
	./configure --prefix=/usr \
		--host=$LFS_TGT \
		--build=$(./build-aux/config.guess) \
		--disable-static

	make $MAKEFLAGS
	make DESTDIR=$LFS install
	cd ..
}

build_acl() {
	[ -d acl ] || git clone "$VCS_SERVER_URL/platform/upstream/acl" -b tizen_base --depth 1
	cd acl
	clean_git $(pwd)
	./configure --prefix=/usr \
		--host=$LFS_TGT \
		--build=$(./build-aux/config.guess) \
		--disable-static \
		--disable-nls

	make $MAKEFLAGS
	make DESTDIR=$LFS install
	cd ..
}

build_flex() {
	[ -d flex ] || git clone "$VCS_SERVER_URL/platform/upstream/flex" -b tizen_base --depth 1
	cd flex
	clean_git $(pwd)
	./autogen.sh
	./configure --prefix=/usr \
		--host=$LFS_TGT \
		--build=$(./build-aux/config.guess) \
		--disable-static \
		--disable-nls

	make $MAKEFLAGS
	make DESTDIR=$LFS install
	cd ..
}

build_smack() {
	[ -d smack ] || git clone "$VCS_SERVER_URL/platform/upstream/smack" -b tizen_base --depth 1
	cd smack
	clean_git $(pwd)
	./autogen.sh
	./configure --prefix=/usr \
		--host=$LFS_TGT \
		--build=$(./build-aux/config.guess)

	make $MAKEFLAGS
	make DESTDIR=$LFS install
	cd ..
}

build_bc() {
	[ -d bc ] || git clone "$VCS_SERVER_URL/platform/upstream/bc" -b tizen_base --depth 1
	cd bc
	clean_git $(pwd)
	./configure --prefix=/usr \
		--host=$LFS_TGT \
		--enable-readline

	make $MAKEFLAGS
	make DESTDIR=$LFS install
	cd ..
}

build_fdupes() {
	[ -d fdupes ] || git clone "$VCS_SERVER_URL/platform/upstream/fdupes" -b tizen_base --depth 1
	cd fdupes
	clean_git $(pwd)
	./configure --prefix=/usr \
		--host=$LFS_TGT \
		--without-ncurses

	make $MAKEFLAGS
	make DESTDIR=$LFS install
	cd ..
}

build_libcap() {
	[ -d libcap ] || git clone "$VCS_SERVER_URL/platform/upstream/libcap" -b tizen_base --depth 1
	cd libcap
	clean_git $(pwd)
	CROSS_COMPILE=$LFS_TGT- make $MAKEFLAGS prefix=/usr DESTDIR=$LFS all
	CROSS_COMPILE=$LFS_TGT- make $MAKEFLAGS CC=$LFS_TGT-gcc prefix=/usr DESTDIR=$LFS install RAISE_SETFCAP=no
	cd ..
}

build_sqlite() {
	[ -d sqlite ] || git clone "$VCS_SERVER_URL/platform/upstream/sqlite" -b tizen_base --depth 1
	cd sqlite
	clean_git $(pwd)
	autoreconf -fi
	./configure --prefix=/usr \
		--host=$LFS_TGT \
		--build=$(./config.guess) \
		-disable-dependency-tracking \
		--enable-shared=yes \
		--enable-static=no \
		--enable-threadsafe \
		--enable-fts5

	make $MAKEFLAGS
	make DESTDIR=$LFS install
	cd ..
}

build_nspr() {
	[ -d nspr ] || git clone "$VCS_SERVER_URL/platform/upstream/nspr" -b tizen_base --depth 1
	cd nspr
	clean_git $(pwd)

	local modified="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
	local BUILD_STRING="$(date -u -d "${modified}" "+%F %T")"
	local BUILD_TIME="$(date -u -d "${modified}" "+%s000000")"

	cp $SCRIPT_DIR/extra/_linux.cfg pr/include/md/_linux.cfg

	CROSS_COMPILE=1 \
		./configure \
		--prefix=/usr \
		--host=$LFS_TGT \
		--disable-debug \
		--enable-optimize \
		--includedir=/usr/include/nspr4

	sed -i 's#$(CC)#$(HOST_CC)#g' config/Makefile
	make CROSS_COMPILE=1 HOST_CC=gcc SH_DATE="$BUILD_STRING" SH_NOW="$BUILD_TIME" $MAKEFLAGS
	make DESTDIR=$LFS install
	cd ..
}

build_nss() {
	[ -d nss ] || git clone "$VCS_SERVER_URL/platform/upstream/nss" -b tizen_base --depth 1
	cd nss
	clean_git $(pwd)

	make -j1 -C coreconf/nsinstall program \
		CROSS_COMPILE=1 \
		NATIVE_CC="gcc" \
		NATIVE_FLAGS="-DLINUX -Dlinux" \
		NATIVE_LDFLAGS="-L/usr/lib" \
		NS_USE_GCC=1 \
		BUILD_OPT=1 \
		FREEBL_NO_DEPEND=1 \
		NSPR_INCLUDE_DIR="${LFS}/usr/include/nspr4" \
		NSPR_LIB_DIR="${LFS}/usr/lib" \
		OPT_FLAGS="  -fno-strict-aliasing -Wl,-z,relro,-z,now" \
		DSO_LDOPTS_HARDEN="-Wl,-z,relro,-z,now" \
		LIBDIR=/usr/lib \
		NSS_USE_SYSTEM_SQLITE=1 \
		NSS_ENABLE_ECC=1 \
		NSS_DISABLE_GTESTS=1 \
		OS_TEST=aarch64

	rm -rf ../dist

	make -j1 all latest \
		CC="$LFS_TGT-gcc --sysroot $LFS" \
		CROSS_COMPILE=1 \
		USE_64=0 \
		NATIVE_CC="gcc" \
		NATIVE_FLAGS="-DLINUX -Dlinux" \
		NATIVE_LDFLAGS="-L/usr/lib" \
		NS_USE_GCC=1 \
		BUILD_OPT=1 \
		FREEBL_NO_DEPEND=1 \
		NSPR_INCLUDE_DIR="${LFS}/usr/include/nspr4" \
		NSPR_LIB_DIR="${LFS}/usr/lib" \
		OPT_FLAGS=" -DPR_BYTES_PER_LONG=4 -mabi=ilp32 -DNS_PTR_LE_32 -Wno-error=overflow -Wno-error=shift-count-overflow -fno-strict-aliasing -Wl,-z,relro,-z,now" \
		DSO_LDOPTS_HARDEN="-Wl,-z,relro,-z,now" \
		LIBDIR=/usr/lib \
		NSS_USE_SYSTEM_SQLITE=1 \
		NSS_ENABLE_ECC=1 \
		NSS_DISABLE_GTESTS=1 \
		OS_TEST=aarch64

	mkdir -p $LFS/usr/lib
	mkdir -p $LFS/usr/libexec/nss
	mkdir -p $LFS/usr/include/nss3
	mkdir -p $LFS/usr/bin
	mkdir -p $LFS/usr/sbin
	mkdir -p $LFS/etc/pki/nssdb
	pushd ../dist/Linux*
	# copy headers
	cp -rL ../public/nss/*.h $LFS/usr/include/nss3
	# copy dynamic libs
	cp -L lib/libnss3.so \
		lib/libnssdbm3.so \
		lib/libnssutil3.so \
		lib/libnssckbi.so \
		lib/libnsssysinit.so \
		lib/libsmime3.so \
		lib/libsoftokn3.so \
		lib/libssl3.so \
		$LFS/usr/lib
	cp -L lib/libfreebl3.so \
		$LFS/usr/lib
	# copy static libs
	cp -L lib/libcrmf.a \
		lib/libnssb.a \
		lib/libnssckfw.a \
		$LFS/usr/lib
	# copy tools
	cp -L bin/certutil \
		bin/cmsutil \
		bin/crlutil \
		bin/modutil \
		bin/pk12util \
		bin/signtool \
		bin/signver \
		bin/ssltap \
		$LFS/usr/bin
	# copy unsupported tools
	cp -L bin/atob \
		bin/btoa \
		bin/derdump \
		bin/ocspclnt \
		bin/pp \
		bin/selfserv \
		bin/shlibsign \
		bin/strsclnt \
		bin/symkeyutil \
		bin/tstclnt \
		bin/vfyserv \
		bin/vfychain \
		$LFS/usr/libexec/nss
	popd
	# prepare pkgconfig file
	mkdir -p $LFS/usr/lib/pkgconfig/
	sed "s:%LIBDIR%:/usr/lib:g
s:%VERSION%:3.98:g
s:%NSPR_VERSION%:4.35:g" \
		packaging/nss.pc.in >$LFS/usr/lib/pkgconfig/nss.pc

	NSS_VMAJOR=$(cat lib/nss/nss.h | grep "#define.*NSS_VMAJOR" | awk '{print $3}')
	NSS_VMINOR=$(cat lib/nss/nss.h | grep "#define.*NSS_VMINOR" | awk '{print $3}')
	NSS_VPATCH=$(cat lib/nss/nss.h | grep "#define.*NSS_VPATCH" | awk '{print $3}')
	cat packaging/nss-config.in | sed -e "s,@libdir@,%{_libdir},g" \
		-e "s,@prefix@,/usr,g" \
		-e "s,@exec_prefix@,/usr,g" \
		-e "s,@includedir@,/usr/include/nss3,g" \
		-e "s,@MOD_MAJOR_VERSION@,$NSS_VMAJOR,g" \
		-e "s,@MOD_MINOR_VERSION@,$NSS_VMINOR,g" \
		-e "s,@MOD_PATCH_VERSION@,$NSS_VPATCH,g" \
		>$LFS/usr/bin/nss-config
	chmod 755 $LFS/usr/bin/nss-config
	# setup-nsssysinfo.sh
	install -m 744 packaging/setup-nsssysinit.sh $LFS/usr/sbin/
	# copy empty NSS database
	install -m 644 packaging/cert9.db $LFS/etc/pki/nssdb
	install -m 644 packaging/key4.db $LFS/etc/pki/nssdb
	install -m 644 packaging/pkcs11.txt $LFS/etc/pki/nssdb

	rm -rf ../dist
	cd ..
}
