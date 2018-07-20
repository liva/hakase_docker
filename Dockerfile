FROM ubuntu:16.04 AS qemu

RUN sed -i'~' -E "s@http://(..\.)?archive\.ubuntu\.com/ubuntu@http://pf.is.s.u-tokyo.ac.jp/~awamoto/apt-mirror/@g" /etc/apt/sources.list
RUN apt update
RUN apt install -y \
          libglib2.0-dev \
	  libfdt-dev \
	  libpixman-1-dev \
	  libncursesw5-dev \
	  zlib1g-dev \
	  flex \
	  bison \
	  wget \
	  build-essential \
	  checkinstall
RUN wget https://download.qemu.org/qemu-2.12.0.tar.bz2
RUN tar xf qemu-2.12.0.tar.bz2
RUN mkdir build-qemu
WORKDIR build-qemu
RUN ../qemu-2.12.0/configure --enable-curses --target-list=x86_64-softmmu --static
RUN make -j$(grep -c ^processor /proc/cpuinfo 2>/dev/null)
RUN checkinstall -y --maintainer="Shinichi Awamoto \<sap.pcmail@gmail.com\>" --pkgname="qemu" --pkgversion="2.9.0"

FROM ubuntu:16.04 AS cpputest

RUN apt update
RUN apt install -y cmake git build-essential
RUN git clone git://github.com/cpputest/cpputest.git
RUN mkdir workspace install
WORKDIR workspace
RUN cmake -DCMAKE_INSTALL_PREFIX=../install -DCOVERAGE=ON ../cpputest
RUN make -j$(grep -c ^processor /proc/cpuinfo 2>/dev/null)
RUN make install

FROM ubuntu:16.04
MAINTAINER Shinichi Awamoto <sap.pcmail@gmail.com>

RUN set -x \
 && cd \
 && apt clean \
 && sed -i'~' -E "s@http://(..\.)?archive\.ubuntu\.com/ubuntu@http://pf.is.s.u-tokyo.ac.jp/~awamoto/apt-mirror/@g" /etc/apt/sources.list \
 && apt update \
 && apt install -y \
	  openssh-client \
	  rsync \
	  wget \
	  libelf-dev \
	  make \
	  g++ \
	  telnet \
	  netcat-openbsd \
 && apt clean \
 && rm -rf /var/lib/apt/lists/* \
 && apt -qy autoremove
WORKDIR /usr/src
# TODO
# COPY --from=qemu /build-qemu/qemu_2.9.0-1_amd64.deb .
RUN wget http://www.pf.is.s.u-tokyo.ac.jp/~awamoto/hakase/qemu_2.9.0-1_amd64.deb \
 && dpkg -i qemu_2.9.0-1_amd64.deb \
 && rm qemu_2.9.0-1_amd64.deb
RUN wget http://www.pf.is.s.u-tokyo.ac.jp/~awamoto/hakase/linux-headers-4.14.34hakase_4.14.34hakase-1_amd64.deb \
 && wget http://www.pf.is.s.u-tokyo.ac.jp/~awamoto/hakase/linux-image-4.14.34hakase_4.14.34hakase-1_amd64.deb \
 && wget http://www.pf.is.s.u-tokyo.ac.jp/~awamoto/hakase/linux-libc-dev_4.14.34hakase-1_amd64.deb \
 && dpkg -i *hakase-1_amd64.deb \
 && rm *hakase-1_amd64.deb
WORKDIR /root
ARG qemu_image_signature="xucqNDjTTtCORC4a"
ADD hakase_qemuimage_${qemu_image_signature}.tar .
RUN mkdir .ssh \
 && chmod 700 .ssh \
 && mv id_rsa* .ssh
COPY --from=cpputest /install /cpputest
COPY qemu .
COPY ssh .
COPY rsync .
COPY monitor .
COPY serial .
RUN set -x \
 && cd \
 && apt update \
 && apt install -y \
	  clang-format \
 && apt clean \
 && rm -rf /var/lib/apt/lists/* \
 && apt -qy autoremove
