#!/bin/bash
set -e
set -o pipefail

# Stage	Build	Host	Target	Action
# 1	pc	pc	lfs	Build cross-compiler cc1 using cc-pc on pc.
# 2	pc	lfs	lfs	Build compiler cc-lfs using cc1 on pc.
# 3	lfs	lfs	lfs	Rebuild and test cc-lfs using cc-lfs on lfs.

export LFS=$(pwd)/lfs
export PATH=$LFS/tools/bin:$PATH

export MAKEFLAGS="-j$(nproc)"
export LC_ALL=POSIX
export LFS_TGT=aarch64-tizen-linux-gnu_ilp32
export CONFIG_SITE=$LFS/usr/share/config.site

SOURCE_DIR=$(pwd)/sources
SCRIPT_DIR=$(pwd)
LOGS_DIR=$(pwd)/logs

mkdir -p $SOURCE_DIR
mkdir -p $LOGS_DIR

cd $SOURCE_DIR

export GLOBAL_CFLAGS="-g -O2 -D_FILE_OFFSET_BITS=64 "

#VCS_SERVER_URL=ssh://{user}@review.tizen.org:29418
VCS_SERVER_URL=ssh://review.tizen.org:29418

clean_git() {
	git_dir=$1
	[ -d "$git_dir/.git" ] && \
	git -C $git_dir reset --hard && git -C $git_dir clean -df
}

init_lfs_dirs() {
	mkdir -pv $LFS
}

# 5. Compiling a Cross-Toolchain
build_cross_toolchain() {
	echo "build_cross_toolchain"
	source $SCRIPT_DIR/_1_cross_toolchain.sh
	download_sources
	build_binutils 2>&1 | tee $LOGS_DIR/build_binutils.txt
	build_gcc_step1 2>&1 | tee $LOGS_DIR/build_gcc_step1.txt
	build_linux_headers 2>&1 | tee $LOGS_DIR/build_linux_headers.txt
	build_glibc_step1 2>&1 | tee $LOGS_DIR/build_glibc_step1.txt
	build_gcc_libstdc 2>&1 | tee $LOGS_DIR/build_gcc_libstdc.txt
	build_libxcrypt 2>&1 | tee $LOGS_DIR/build_libxcrypt.txt
}

# 6. Cross Compiling Temporary Tools
build_temporary_tools() {
	echo "build_temporary_tools"
	source $SCRIPT_DIR/_2_1_temporary_tools.sh

	build_m4 2>&1 | tee $LOGS_DIR/build_m4.txt
	build_ncurses 2>&1 | tee $LOGS_DIR/build_ncurses.txt
	build_bash 2>&1 | tee $LOGS_DIR/build_bash.txt
	build_coreutils 2>&1 | tee $LOGS_DIR/build_coreutils.txt
	build_diffutils 2>&1 | tee $LOGS_DIR/build_diffutils.txt
	build_file 2>&1 | tee $LOGS_DIR/build_file.txt
	build_findutils 2>&1 | tee $LOGS_DIR/build_findutils.txt
	build_gawk 2>&1 | tee $LOGS_DIR/build_gawk.txt
	# error build_grep 2>&1 | tee $LOGS_DIR/build_grep.txt
	build_gzip 2>&1 | tee $LOGS_DIR/build_gzip.txt
	build_make 2>&1 | tee $LOGS_DIR/build_make.txt
	build_patch 2>&1 | tee $LOGS_DIR/build_patch.txt
	build_sed 2>&1 | tee $LOGS_DIR/build_sed.txt
	build_tar 2>&1 | tee $LOGS_DIR/build_tar.txt
	build_xz 2>&1 | tee $LOGS_DIR/build_xz.txt
}

build_temporary_tools_toolchain() {
	echo "build_temporary_tools_toolchain"
	source $SCRIPT_DIR/_2_2_temporary_tools_toolchain.sh

	build_binutils_pass2 2>&1 | tee $LOGS_DIR/build_binutils_pass2.txt
	build_gcc_pass2 2>&1 | tee $LOGS_DIR/build_gcc_pass2.txt
}

# 7. Entering Chroot and Building Additional Temporary Tools
build_chroot() {
	echo "build_chroot"
    source $SCRIPT_DIR/_4_1_inchroot_create_directories.sh
	# TODO
	return
	# root privilege required
	chroot_out_change_owner

	chroot_out_make_dirs

	# qeumu linux user mode
	chroot_enter
	chroot_in_create_dirs
	chroot_in_create_files
}

build_chroot_tools() {
	echo "build_chroot_tools"
	source $SCRIPT_DIR/_4_2_inchroot_temporary_tools.sh
	build_gettext 2>&1 | tee $LOGS_DIR/build_gettext.txt
	build_bison 2>&1 | tee $LOGS_DIR/build_bison.txt
	build_perl 2>&1 | tee $LOGS_DIR/build_perl.txt
	build_zlib 2>&1 | tee $LOGS_DIR/build_zlib.txt
	build_libffi 2>&1 | tee $LOGS_DIR/build_libffi.txt
	build_util_linux 2>&1 | tee $LOGS_DIR/build_util_linux.txt
	build_python3 2>&1 | tee $LOGS_DIR/build_python3.txt
	# error build_texinfo 2>&1 | tee $LOGS_DIR/build_texinfo.txt
}

build_clean() {
	echo "build_clean"
	return 
	# TODO
	source $SCRIPT_DIR/_5_cleanup_chroot.sh
	cleanup_in_chroot
	exit_chroot
}

build_backup() {
	echo "build_backup"
	return
	# TODO
	# Backup
	cd $LFS
	tar -cJpf $HOME/lfs-temp-tools-arm64_32.tar.xz .
}
build_more() {
	echo "build_more"
	source $SCRIPT_DIR/_4_3_build_more.sh
	build_autoconf 2>&1 | tee $LOGS_DIR/build_autoconf.txt
	build_automake 2>&1 | tee $LOGS_DIR/build_automake.txt
	build_libtool 2>&1 | tee $LOGS_DIR/build_libtool.txt
	build_perl-gettext 2>&1 | tee $LOGS_DIR/build_perl-gettext.txt
	build_help2man 2>&1 | tee $LOGS_DIR/build_help2man.txt
	build_libxml2 2>&1 | tee $LOGS_DIR/build_libxml2.txt
	build_openssl3 2>&1 | tee $LOGS_DIR/build_openssl3.txt
	build_libtool 2>&1 | tee $LOGS_DIR/build_libtool.txt
	build_zstd 2>&1 | tee $LOGS_DIR/build_zstd.txt
	build_libarchive 2>&1 | tee $LOGS_DIR/build_libarchive.txt
	build_attr 2>&1 | tee $LOGS_DIR/build_attr.txt
	build_acl 2>&1 | tee $LOGS_DIR/build_acl.txt
	build_flex 2>&1 | tee $LOGS_DIR/build_flex.txt
	build_smack 2>&1 | tee $LOGS_DIR/build_smack.txt
	build_bc 2>&1 | tee $LOGS_DIR/build_bc.txt
	build_fdupes 2>&1 | tee $LOGS_DIR/build_fdupes.txt
	build_libcap 2>&1 | tee $LOGS_DIR/build_libcap.txt
}

main() {
	init_lfs_dirs
	build_cross_toolchain
	build_temporary_tools
	build_temporary_tools_toolchain
	build_chroot
	build_chroot_tools
	build_more

	build_clean

}

# check packages are installed
#host_packages="bash binutils bison coreutils findutils gawk gcc grep gzip m4 perl make patch texinfo help2man xz-utils tar sed python3 autopoint autoconf automake libtool gettext po4a"
#echo "sudo apt install -y $pkg"

main "$@"
