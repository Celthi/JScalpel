
#!/usr/bin/env bash

set -e
GIT_VERSION=$(git --version | awk '{print $3}')
if [[ "$GIT_VERSION" < "2.24.0" ]]
then
    mkdir -p /tmp/git
    cd /tmp/git
    wget https://mirrors.edge.kernel.org/pub/software/scm/git/git-2.30.0.tar.xz
    tar xf git-2.30.0.tar.xz
    cd git-2.30.0/
    make configure
    ./configure --prefix=/usr/
    make all
    make install
    rm -rf /tmp/git
fi
