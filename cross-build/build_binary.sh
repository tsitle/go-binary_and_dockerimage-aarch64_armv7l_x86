#!/bin/bash

#
# by TS, Apr 2019
#

VAR_MYNAME="$(basename "$0")"

# ----------------------------------------------------------

function printUsageAndExit() {
	echo "Usage: $VAR_MYNAME TARGET_ARCH" >/dev/stderr
	echo "Examples: $VAR_MYNAME arm64" >/dev/stderr
	echo "          $VAR_MYNAME armhf" >/dev/stderr
	echo "          $VAR_MYNAME i386" >/dev/stderr
	exit 1
}

if [ $# -eq 1 ] && [ "$1" = "-h" -o "$1" = "--help" ]; then
	printUsageAndExit
fi

if [ $# -lt 1 ]; then
	echo -e "Missing argument. Aborting.\n" >/dev/stderr
	printUsageAndExit
fi

OPT_DEBIAN_TRG_DIST="$1"
shift

LVAR_GOLANG_TRG_ARCH=""
case "$OPT_DEBIAN_TRG_DIST" in
	arm64)
		LVAR_GOLANG_TRG_ARCH="arm64"
		;;
	armhf)
		LVAR_GOLANG_TRG_ARCH="arm"
		;;
	i386)
		LVAR_GOLANG_TRG_ARCH="386"
		;;
	*)
		echo -e "$VAR_MYNAME: Error: Unsupported target CPU architecture '$OPT_DEBIAN_TRG_DIST'. Aborting.\n" >/dev/stderr
		printUsageAndExit
		;;
esac

# ----------------------------------------------------------

# Outputs CPU architecture string
#
# @param string $1 debian_rootfs|debian_dist
#
# @return int EXITCODE
function _getCpuArch() {
	case "$(uname -m)" in
		x86_64*)
			echo -n "amd64"
			;;
		i686*)
			if [ "$1" = "qemu" ]; then
				echo -n "i386"
			elif [ "$1" = "s6_overlay" -o "$1" = "alpine_dist" ]; then
				echo -n "x86"
			else
				echo -n "i386"
			fi
			;;
		aarch64*)
			if [ "$1" = "debian_rootfs" ]; then
				echo -n "arm64v8"
			elif [ "$1" = "debian_dist" ]; then
				echo -n "arm64"
			else
				echo "$VAR_MYNAME: Error: invalid arg '$1'" >/dev/stderr
				return 1
			fi
			;;
		armv7*)
			if [ "$1" = "debian_rootfs" ]; then
				echo -n "arm32v7"
			elif [ "$1" = "debian_dist" ]; then
				echo -n "armhf"
			else
				echo "$VAR_MYNAME: Error: invalid arg '$1'" >/dev/stderr
				return 1
			fi
			;;
		*)
			echo "$VAR_MYNAME: Error: Unknown CPU architecture '$(uname -m)'" >/dev/stderr
			return 1
			;;
	esac
	return 0
}

_getCpuArch debian_dist >/dev/null || exit 1

TMP_CPUARCH="$(_getCpuArch debian_dist)"
if [ "$TMP_CPUARCH" != "amd64" ]; then
	echo "$VAR_MYNAME: Error: Unsupported CPU architecture '$TMP_CPUARCH'. Aborting." >/dev/stderr
	echo "$VAR_MYNAME: This script must run on a X64/AMD64 host" >/dev/stderr
	exit 1
fi

# ----------------------------------------------------------

LVAR_DEBIAN_DIST="$(_getCpuArch debian_dist)"
LVAR_DEBIAN_RELEASE="stretch"
LVAR_DEBIAN_VERSION="9.11"

# ----------------------------------------------------------

LVAR_IMAGE_NAME="go-${OPT_DEBIAN_TRG_DIST}-builder-cross-${LVAR_DEBIAN_DIST}"
LVAR_IMAGE_VER="1.13.5"

# ----------------------------------------------------------

cd build-ctx || exit 1

LVAR_SRC_OS_IMAGE="tsle/os-debian-${LVAR_DEBIAN_RELEASE}-${LVAR_DEBIAN_DIST}:${LVAR_DEBIAN_VERSION}"
docker pull $LVAR_SRC_OS_IMAGE || exit 1
echo

echo -e "\n$VAR_MYNAME: Building Docker Image '${LVAR_IMAGE_NAME}:${LVAR_IMAGE_VER}'...\n"
docker build \
		--build-arg CF_SRC_OS_IMAGE="$LVAR_SRC_OS_IMAGE" \
		--build-arg CF_CPUARCH_DEB_TRG_DIST="$OPT_DEBIAN_TRG_DIST" \
		--build-arg CF_GOLANG_VER="$LVAR_IMAGE_VER" \
		--build-arg CF_GOLANG_TRG_ARCH="$LVAR_GOLANG_TRG_ARCH" \
		-t "$LVAR_IMAGE_NAME":"$LVAR_IMAGE_VER" \
		. || exit 1

cd ..

docker run --rm -v "$(pwd)/dist":/dist "$LVAR_IMAGE_NAME":"$LVAR_IMAGE_VER" || exit 1

echo -e "\n$VAR_MYNAME: File has been created in ./dist/"
