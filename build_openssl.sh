#!/bin/bash

if [ "$#" -ne 2 ]; then
    echo "Usage: ./build_openssl.sh tool_chain_path install_path!"
    echo "Example: ./build_openssl.sh /usr/local/arm-linux /Desktop/eric/logger/build/moxa-ia240/openssl"
    exit
fi
set -x
make clean

tool_chain_path=${1%/}

# linux architecture 
item=`ls $tool_chain_path/bin | grep gcc`
IFS=' ' read -ra ADDR <<< "$item"
item="${ADDR[0]}"
ARCH=`echo $item | sed -e 's/-gcc.*//g'`

export INSTALLDIR=$tool_chain_path
export PATH="$PATH:$INSTALLDIR/bin"
export TARGETMACH=$ARCH
export BUILDMACH=i686-pc-linux-gnu
export CROSS=$ARCH

if [ "$CROSS" == "" ]; then
	export AR=ar
	export LD=ld
	export AS=as
	export CC=gcc
	./Configure linux-x86_64 --prefix=$2 --openssldir=`pwd`/final/openssl no-shared
else
	export CROSS=$ARCH
	export AR=${CROSS}-ar
	export LD=${CROSS}-ld
	export AS=${CROSS}-as
	export CC=${CROSS}-gcc
	./Configure --openssldir=$2 -I$tool_chain_path/include no-shared os/compiler:$ARCH-
fi

sed -i '/^CFLAG/ s/$/ -fPIC/' Makefile
#sed -i -e 's/^CFLAG= /CFLAG= -g /' Makefile
make RANLIB="${CROSS}-ranlib" 
make install_sw

#cd final
#sudo cp -r * $tool_chain_path

#cd final/lib
#$AR -x libcrypto.a
#$CC -shared *.o -o libcrypto.so
#rm *.o
#$AR -x libssl.a
#$CC -shared *.o -o libssl.so
#rm *.so
#rm *.o

#cd ..
#sudo cp -r * $tool_chain_path
