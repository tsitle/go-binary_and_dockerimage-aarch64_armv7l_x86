ARG CF_DEBIAN_RELEASE
ARG CF_DEBIAN_VERSION
ARG CF_CPUARCH_DEB_DIST

FROM tsle/os-debian-${CF_DEBIAN_RELEASE}-${CF_CPUARCH_DEB_DIST}:${CF_DEBIAN_VERSION}

#
ARG CF_GOLANG_TRG_ARCH
ARG CF_GOLANG_VER
ARG CF_CPUARCH_DEB_TRG_DIST

ENV DEBIAN_FRONTEND=noninteractive

RUN \
	apt-get update \
	&& apt-get --assume-yes upgrade \
	&& apt-get --assume-yes dist-upgrade \
	&& apt-get -y --no-install-recommends install \
			git \
			build-essential \
			p7zip \
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

ENV DEBIAN_FRONTEND=dialog

# ----------------------------------------------------------

RUN \
	echo "CF_GOLANG_VER='$CF_GOLANG_VER'"; \
	echo "CF_GOLANG_TRG_ARCH='$CF_GOLANG_TRG_ARCH'"; \
	echo "CF_CPUARCH_DEB_TRG_DIST='$CF_CPUARCH_DEB_TRG_DIST'"; \
	#
	export GOPATH=/root/tmpgo/go \
	&& export GOROOT=/usr/local/go \
	&& export GOARCH=${CF_GOLANG_TRG_ARCH} \
	&& export GOROOT_BOOTSTRAP=/usr/local/go \
	&& export GOOS=linux \
	#
	&& cd gobuild/ \
	&& cd go \
	&& git checkout go${CF_GOLANG_VER} \
	&& cd src \
	&& echo "Running ./make.bash..." \
	&& ./make.bash >/dev/null \
	&& cd ../../go \
	&& rm -r .git .gitignore .gitattributes \
	&& cd bin \
	&& test -d linux_${CF_GOLANG_TRG_ARCH} \
	&& rm go gofmt \
	&& ln -s linux_${CF_GOLANG_TRG_ARCH}/go . \
	&& ln -s linux_${CF_GOLANG_TRG_ARCH}/gofmt . \
	&& cd ../.. \
	&& echo "Creating 7-Zip'ed tarball of cross-built ${CF_CPUARCH_DEB_TRG_DIST} package..." \
	&& tar cf - "go" | 7zr a -si -v45m "go${CF_GOLANG_VER}.linux-${CF_CPUARCH_DEB_TRG_DIST}.tar.7z" \
	&& for TMPFN in *.tar.7z*; do md5sum $TMPFN > $TMPFN.md5; done

ENV CF_GOLANG_VER $CF_GOLANG_VER
ENV CF_CPUARCH_DEB_TRG_DIST $CF_CPUARCH_DEB_TRG_DIST

# Copy out the generated binary
VOLUME /dist
CMD cp go${CF_GOLANG_VER}.linux-*.tar.7z* gobuild/go${CF_GOLANG_VER}.linux-*.tar.7z* /dist
