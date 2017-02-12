FROM linuxserver/transmission:50
MAINTAINER OpenGG

# set version label
ARG BUILD_DATE
ARG VERSION
LABEL build_version="transmission-skip-hash-check version:- ${VERSION} Build-date:- ${BUILD_DATE}"

# install packages
RUN \
 apk add --no-cache \
  ca-certificates \
  curl-dev \
  libressl-dev \
  g++ \
  gcc \
  libc-dev \
  make \
  cmake \
  python \
  intltool \
  xz \
  file \
  patch && \
 mkdir /transmission-build && \
 cd /transmission-build && \
 curl https://cloud.github.com/downloads/libevent/libevent/libevent-2.0.18-stable.tar.gz -O && \
 tar xzf libevent-2.0.18-stable.tar.gz && \
 cd libevent-2.0.18-stable && \
 mkdir build && \
 cd build && \
 CFLAGS="-Os -march=native" ../configure && \
 make && \
 make install && \
 cd /transmission-build && \
 curl https://raw.githubusercontent.com/transmission/transmission-releases/master/transmission-2.92.tar.xz -O && \
 tar -Jxf transmission-2.92.tar.xz && \
 cd transmission-2.92 && \
 curl https://raw.githubusercontent.com/OpenGG/transmission-2.92_skiphashcheck/master/libtransmission/rpcimpl.c \
  -o libtransmission/rpcimpl.c && \
 curl https://raw.githubusercontent.com/OpenGG/transmission-2.92_skiphashcheck/master/libtransmission/verify.c \
  -o libtransmission/verify.c && \
 mkdir build && \
 cd build && \
 CFLAGS="-Os -march=native" ../configure && \
 cmake .. && \
 make && \
 apk del \
  ca-certificates \
  curl-dev \
  libressl-dev \
  g++ \
  gcc \
  libc-dev \
  make \
  cmake \
  python \
  intltool \
  xz \
  file \
  coreutils \
  patch && \
 cp /transmission-build/transmission-2.92/build/daemon/transmission-daemon /usr/bin/ && \
 rm -rf /transmission-build

# ports and volumes
EXPOSE 9091 51413
VOLUME /config /downloads /watch
