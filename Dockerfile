FROM ghcr.io/linuxserver/baseimage-alpine-python:3.11

# set version label
ARG BUILD_DATE
ARG VERSION
LABEL build_version="emmanuelvargas version with headphone bandcamp based on Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="emmanuelvargas"
# hard set UTC in case the user does not define it
ENV TZ="Etc/UTC"

# copy patches folder
COPY patches/ /tmp/patches/

RUN \
 echo "**** install build packages ****" && \
 apk add --no-cache --virtual=build-dependencies \
	g++ \
	gcc \
	make && \
 echo "**** install runtime packages ****" && \
 apk add --no-cache \
	ffmpeg \
	flac \
	mc && \
 echo "**** install python3 ****" && \
 apk add --no-cache python3 && \
 pip3 install deezer-py deemix && \
 echo "**** compile shntool *** *" && \
 mkdir -p \
	/tmp/shntool && \
 tar xf /tmp/patches/shntool-3.0.10.tar.gz -C \
	/tmp/shntool --strip-components=1 && \
 cp /tmp/patches/config.* /tmp/shntool && \
 cd /tmp/shntool && \
 ./configure \
	--infodir=/usr/share/info \
	--localstatedir=/var \
	--mandir=/usr/share/man \
	--prefix=/usr \
	--sysconfdir=/etc && \
 make && \
 make install && \
 echo "**** install app ****" && \
 git clone --depth 1 https://github.com/emmanuelvargas/headphones.git /app/headphones && \
 echo "**** cleanup ****" && \
 apk del --purge \
	build-dependencies && \
 rm -rf \
	/tmp/* \
	/usr/lib/*.la

# add local files
COPY root/ /

# ports and volumes
EXPOSE 8181
VOLUME /config
