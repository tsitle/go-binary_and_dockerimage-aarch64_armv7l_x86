
ARG CF_GOLANG_VER

FROM go-builder-cross-prestage-amd64:${CF_GOLANG_VER}

ARG CF_GOLANG_TRG_ARCH
ARG CF_GOLANG_VER
ARG CF_DEBIAN_TRG_DIST

WORKDIR /root

RUN \
	export GOPATH=/root/tmpgo/go \
	&& export GOROOT=/usr/local/go \
	&& echo "CF_GOLANG_VER='$CF_GOLANG_VER'" \
	&& echo "CF_GOLANG_TRG_ARCH='$CF_GOLANG_TRG_ARCH'" \
	&& echo "CF_DEBIAN_TRG_DIST='$CF_DEBIAN_TRG_DIST'" \
	&& cd gobuild/ \
	&& cd go \
	&& git checkout go${CF_GOLANG_VER} \
	&& cd src \
	&& export GOARCH=${CF_GOLANG_TRG_ARCH} \
	&& export GOROOT_BOOTSTRAP=/usr/local/go \
	&& export GOOS=linux \
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
	&& echo "Creating 7-Zip'ed tarball of cross-built ${CF_DEBIAN_TRG_DIST} package..." \
	&& tar cf - "go" | 7zr a -si -v45m "go${CF_GOLANG_VER}.linux-${CF_DEBIAN_TRG_DIST}.tar.7z" \
	&& for TMPFN in *.tar.7z*; do md5sum $TMPFN > $TMPFN.md5; done

ENV CF_GOLANG_VER $CF_GOLANG_VER
ENV CF_DEBIAN_TRG_DIST $CF_DEBIAN_TRG_DIST

# Copy out the generated binary
VOLUME /dist
CMD cp go${CF_GOLANG_VER}.linux-*.tar.7z* gobuild/go${CF_GOLANG_VER}.linux-*.tar.7z* /dist
