#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "Usage: ./build_openssl.sh target_architecture!"
    echo "Example: ./build_openssl.sh arm-linux"
    exit
fi
make clean

tool_chain_path=${1%/}

# linux architecture 
item=`ls $tool_chain_path/bin | grep gcc`
IFS=' ' read -ra ADDR <<< "$item"
item="${ADDR[0]}"
ARCH=`echo $item | sed -e 's/-gcc.*//g'`

export INSTALLDIR=$tool_chain_path
export PATH="$INSTALLDIR/bin:$PATH"
export TARGETMACH=$ARCH
export BUILDMACH=i686-pc-linux-gnu

export CROSS=$ARCH
export AR=${CROSS}-ar
export LD=${CROSS}-ld
export AS=${CROSS}-as
export CC=${CROSS}-gcc

./Configure --openssldir=`pwd`/final no-shared os/compiler:$ARCH-
sed -i '/^CFLAG/ s/$/ -fPIC/' Makefile
#sed -i -e 's/^CFLAG= /CFLAG= -g /' Makefile
make RANLIB="${CROSS}-ranlib" 
make install

cd final
sudo cp -r * $tool_chain_path

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
