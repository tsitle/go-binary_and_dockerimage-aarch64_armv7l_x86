# go binary packages for AARCH64, ARMv7l and X86 and Docker Image for creating the packages

This repository provides **go** ([golang](https://golang.org/)) binary packages for

- AARCH64 (aarch64/arm64v8/arm64)
- ARMv7l (armv7l/arm32v7/armhf)
- X86 (i386/i686/ia32/x86)

as well as the Docker Image used for building the binary packages.  

## Using the pre-built binary
Extract the binary package from ``./binary/go<VERSION>.linux-<ARCH>.tar.7z.*`` to ``/usr/local/`` on the **AARCH64 or ARMv7l or X86** machine.

If you don't already have 7-Zip then install it first:

```
$ sudo apt-get install p7zip
```

Now extract the binary package:

```
$ 7zr x -so "binary/go<VERSION>.linux-<ARCH>.tar.7z.001" | sudo tar xf - -C /usr/local/
$ sudo ln -s /usr/local/go/bin/go /usr/local/bin/
$ sudo ln -s /usr/local/go/bin/gofmt /usr/local/bin/
```

Verify that the binary is OK:

```
$ export GOROOT=/usr/local/go
$ go version
```

## Building the binary
### Cross-compiling on a X64/AMD64 host
On the X64/AMD64 host, run:

```
$ cd cross-build
For AARCH64:
	$ ./build_binary.sh arm64
For ARMv7l:
	$ ./build_binary.sh armhf
For X86:
	$ ./build_binary.sh i386
```

This will generate the binary package ``go<VERSION>.linux-<ARCH>.tar.7z.*`` in ``./cross-build/dist/``.

Follow above instructions for using the pre-built binary.  
You'll just need to replace the path `binary/` with `dist/`.

## Compiling a go application
On the **AARCH64 or ARMv7l or X86** machine that you've installed **go** on run the following commands:

```
$ cd $HOME
$ mkdir -p mygoapp/{src,bin,pkg}
$ export GOROOT=/usr/local/go
$ export GOPATH=$HOME/mygoapp
$ export PATH=$PATH:$GOROOT/bin
```

Now you're ready to compile your **go** application under `~/mygoapp/`.

---

The Docker Image is based on:

- [https://gist.github.com/conoro/4fca191fad018b6e47922a21fab499ca](https://gist.github.com/conoro/4fca191fad018b6e47922a21fab499ca)
- [https://github.com/tsitle/dockercompose-binary\_and\_dockerimage-aarch64\_armv7l\_x86\_x64](https://github.com/tsitle/dockercompose-binary_and_dockerimage-aarch64_armv7l_x86_x64)
