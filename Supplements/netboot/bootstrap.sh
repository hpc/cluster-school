#!/bin/bash

TDIR=$(mktemp -d)
IMGDIR=/opt/img/root
TFTPBOOT=/var/lib/tftpboot
KERN_NAME=vmlinuz
INITRD_NAME=initramfs.img

KERNEL=$(rpm --root=/opt/img/root -q kernel | sed -e 's/kernel-//')

echo "Working directory: $TDIR , Kernel version: $KERNEL"

###
# initramfs generation
###
echo "Making initramfs..."

echo -e "\tCopying initramfs template"
chown -R root:root initramfs
cp -a initramfs $TDIR/

cd $TDIR/initramfs

echo -e "\tCreating directory structure"
mkdir -p sbin dev sys proc tmp usr/bin usr/sbin etc lib/modules

echo -e "\tCreating chroot environment"
chroot $TDIR/initramfs /bin/busybox --install -s

echo -e "\tInstalling modules"
for m in $(cat $TDIR/initramfs/modules.txt); do
echo -e "\t\t$m"
find $IMGDIR/lib/modules/$KERNEL -name $m.ko.xz -exec cp -av {} $TDIR/initramfs/lib/modules/ \; > /dev/null
done

echo -e "\tCreating cpio image"
cd $TDIR/initramfs
echo -ne "\t\twrote: "
find . | cpio -oc > $TDIR/$INITRD_NAME 

echo "...Done."

echo "Copying kernel and initramfs to $TFTPBOOT"
cp -av $TDIR/$INITRD_NAME $TFTPBOOT
cp -av $IMGDIR/boot/vmlinuz-$KERNEL $TFTPBOOT/vmlinuz

echo "Cleaning up."
rm -rf $TDIR
