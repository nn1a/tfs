

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