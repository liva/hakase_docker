FROM ubuntu:16.04
MAINTAINER Shinichi Awamoto <sap.pcmail@gmail.com>

RUN set -x \
 && cd \
 && apt clean \
 && sed -i'~' -E "s@http://(..\.)?archive\.ubuntu\.com/ubuntu@http://pf.is.s.u-tokyo.ac.jp/~awamoto/apt-mirror/@g" /etc/apt/sources.list \
 && apt update \
 && apt install -y \
	  wget \
	  git \
	  lbzip2 \
	  libelf-dev \
	  make \
	  g++ \
	  telnet \
	  netcat-openbsd \
 && apt clean \
 && rm -rf /var/lib/apt/lists/* \
 && apt -qy autoremove
WORKDIR /usr/src
RUN wget http://www.pf.is.s.u-tokyo.ac.jp/~awamoto/hakase/qemu_2.9.0-1_amd64.deb \
 && dpkg -i qemu_2.9.0-1_amd64.deb \
 && rm qemu_2.9.0-1_amd64.deb
RUN wget http://www.pf.is.s.u-tokyo.ac.jp/~awamoto/hakase/linux-headers-4.14.34hakase_4.14.34hakase-1_amd64.deb \
 && wget http://www.pf.is.s.u-tokyo.ac.jp/~awamoto/hakase/linux-image-4.14.34hakase_4.14.34hakase-1_amd64.deb \
 && wget http://www.pf.is.s.u-tokyo.ac.jp/~awamoto/hakase/linux-libc-dev_4.14.34hakase-1_amd64.deb \
 && dpkg -i *hakase-1_amd64.deb \
 && rm *hakase-1_amd64.deb
WORKDIR /root
RUN QEMUIMAGE=hakase_qemuimage_AtLJVzxuTE0Wd3gyRb0gSffva5mJ3NVP.tar.bz2 \
 && wget http://www.pf.is.s.u-tokyo.ac.jp/~awamoto/hakase/${QEMUIMAGE} \
 && tar xf ${QEMUIMAGE} \
 && rm ${QEMUIMAGE}
RUN mkdir .ssh \
 && chmod 700 .ssh \
 && mv id_rsa* .ssh
COPY qemu .
COPY ssh .
COPY rsync .
