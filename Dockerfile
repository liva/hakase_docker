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
