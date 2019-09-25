#!/bin/bash

# extract the kernel command line argument: img=<url>
URL=$(awk 'BEGIN{RS=" ";FS="="} $1=="img"{print $2}' /proc/cmdline)

# setup a new ramfs mount
mkdir -p /mnt/root
mount -t ramfs -o size=32m ramfs /mnt/root
if [ $? -ne 0 ]; then
	echo "Couldn't mount ramfs!"
	exit 1
fi
echo "Mounted ramfs"

# download and extract the image
cd /mnt/root
echo "Image is at $URL, fetching and extracting"
wget -O - $URL | cpio -iv > /dev/null

if [ $? -ne 0 ]; then
	echo "Image download failed!"
	exit 1
fi

echo "Image extracted"

