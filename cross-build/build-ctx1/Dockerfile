FROM scratch

ARG CF_DEBIAN_VERSION
ARG CF_CPUARCH_DEB_ROOTFS

# add Debian root-fs
ADD cache/debian_stretch/rootfs-debian_stretch_${CF_DEBIAN_VERSION}-${CF_CPUARCH_DEB_ROOTFS}.tar.xz /

ARG CF_GOLANG_VER

ENV DEBIAN_FRONTEND=noninteractive

RUN \
	apt-get update \
	&& apt-get install -y \
			git wget gcc p7zip \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/*

WORKDIR /root

RUN \
	echo "Downloading tarball of original AMD64 package..." \
	&& wget -q https://storage.googleapis.com/golang/go${CF_GOLANG_VER}.linux-amd64.tar.gz \
	&& echo "Extracting tarball of original AMD64 package..." \
	&& tar xzf go${CF_GOLANG_VER}.linux-amd64.tar.gz \
	&& rm go${CF_GOLANG_VER}.linux-amd64.tar.gz \
	#
	&& echo "Creating 7-Zip'ed tarball of original AMD64 package..." \
	&& tar cf - "go" | 7zr a -si -v45m "go${CF_GOLANG_VER}.linux-amd64.tar.7z" \
	&& for TMPFN in *.tar.7z*; do md5sum $TMPFN > $TMPFN.md5; done \
	#
	&& mv go /usr/local/ \
	&& export GOROOT=/usr/local/go \
	&& mkdir -p tmpgo/go/src \
	&& mkdir tmpgo/go/bin \
	&& mkdir tmpgo/go/pkg \
	&& export GOPATH=/root/tmpgo/go \
	&& ln -s /usr/local/go/bin/go /usr/local/bin/ \
	&& go version

RUN \
	mkdir gobuild \
	&& cd gobuild/ \
	&& git clone https://go.googlesource.com/go

#
ENV DEBIAN_FRONTEND=dialog
