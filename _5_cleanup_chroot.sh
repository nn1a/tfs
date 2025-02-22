cleanup_in_chroot() {
    echo "Cleaning up chroot environment..."
    rm -rf /usr/share/{info,man,doc}/*
    find /usr/{lib,libexec} -name \*.la -delete
    rm -rf /tools
}

exit_chroot() {
    echo "Exiting chroot environment..."
    exit
    echo "Unmounting chroot environment..."
    mountpoint -q $LFS/dev/shm && umount $LFS/dev/shm
    umount $LFS/dev/pts
    umount $LFS/{sys,proc,run,dev}
}
