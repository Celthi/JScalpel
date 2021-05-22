#!/usr/bin/env bash

set -e

GCC_VERSION=$(gcc --version | grep ^gcc | awk '{print $3}')
if [[ "$GCC_VERSION" < "8.3.0" ]]
then
    echo "installing GCC 8.3.0..."
    mkdir -p /tmp/gcc
    cd /tmp/gcc
    if [ ! -f gcc-8.3.0.tar.xz ]
    then
        wget https://ftp.gnu.org/gnu/gcc/gcc-8.3.0/gcc-8.3.0.tar.xz
    fi

    if [ ! -d gcc-8.3.0 ]
    then
        tar -xf gcc-8.3.0.tar.xz
    fi
    cd gcc-8.3.0
    ./contrib/download_prerequisites


    mkdir build
    cd build
    ../configure --prefix=/usr --disable-libmpx --with-system-zlib --enable-multilib --with-multilib-list=m32,m64 --with-default-libstdcxx-abi=gcc4-compatible   --disable-gnu-unique-object --enable-linker-build-id --enable-languages=c,c++  && make -j 4
    make install  
    rm -rf /tmp/gcc
fi
