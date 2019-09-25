#!/bin/sh

if [ $1 == "bound" ]; then
	echo "Setting IP..."
	ip addr add $ip/$subnet dev $interface
	echo "Setting DNS"
	for i in $dns; do 
		echo "nameserver $i" >> /etc/resolv.conf
	done
fi
