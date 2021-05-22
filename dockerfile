RUN set -euxo pipefail \
    && yum update -y\
    && yum group install -y "Development Tools" \
    && yum install -y \
    freetype \
    wget \
    imake \
    glibc-devel.i686 \
    zlib-devel \
    bzip2 \
    ncurses-devel \
    krb5-devel \
    zlib-devel \
    openssl-devel \
    binutils-devel \
    cups-libs \
    yum-utils \
    perl-Data-Dumper \
    perl-DBI \
    perl-DBD-SQLite \
\
    && rm -rf /var/cache/yum/* /var/tmp/yum*

COPY scripts/install-gcc830.sh scripts/hacking-gcc830.py /iserver-dev/scripts/
RUN /iserver-dev/scripts/install-gcc830.sh
RUN set -euxo pipefail \
    && yum update -y\
    && yum install -y \
    ksh \
    mysql-connector-odbc \
    zsh \
    net-tools\
    iproute \
    iproute-doc \
    python3-pip \
    libuuid-devel \
\
    && debuginfo-install -y coreutils \
    && pip3 install cmake \
\
    && curl -sL https://rpm.nodesource.com/setup_14.x | bash - \
    && yum install -y nodejs\
    && curl -fsSL https://get.docker.com/ | sh \ 
    && yum install -y man \
    && rm -rf /var/cache/yum/* /var/tmp/yum*
COPY config/.zshrc /root/
COPY . /iserver-dev/
#install git 2.30.0
RUN /iserver-dev/scripts/install-git230.sh
# This dockerfile is for launching a docker for debugging with vscode
COPY . /iserver-dev/
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" \
    && install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl \
    && rm kubectl \
    && yum install -y http://nexus.internal.microstrategy.com/repository/filerepo/com/postgresql/pgdg-redhat-repo/42.0-11.noarch/pgdg-redhat-repo-42.0-11.noarch.rpm \
    && yum install -y postgresql11 \
    && pip3 install awscli
# you need to copy the ~/.kube/config folder to interact with you host k8s cluster
# helm

RUN export VERIFY_CHECKSUM=false && curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash
