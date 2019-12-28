#!/bin/bash

./build_binary.sh arm64 || exit 1
./build_binary.sh armhf || exit 1
./build_binary.sh i386 || exit 1
