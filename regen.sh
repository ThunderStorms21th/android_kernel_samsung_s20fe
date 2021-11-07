#!/bin/bash

export ARCH=arm64
mkdir out

BUILD_CROSS_COMPILE=/home/pascua14/gcc-7.4.1/bin/aarch64-linux-gnu-
KERNEL_LLVM_BIN=/home/pascua14/clang/bin
CLANG_TRIPLE=aarch64-linux-gnu-
KERNEL_MAKE_ENV="DTC_EXT=$(pwd)/tools/dtc CONFIG_BUILD_ARM64_DT_OVERLAY=y"

scripts/configcleaner "
CONFIG_SAMSUNG_NFC
CONFIG_NFC_PN547
CONFIG_NFC_PN547_ESE_SUPPORT
CONFIG_NFC_FEATURE_SN100U
"

echo "
CONFIG_SAMSUNG_NFC=y
CONFIG_NFC_PN547=y
CONFIG_NFC_PN547_ESE_SUPPORT=y
CONFIG_NFC_FEATURE_SN100U=y
" >> out/.config

#make -j8 -C $(pwd) O=$(pwd)/out $KERNEL_MAKE_ENV ARCH=arm64 \
#CROSS_COMPILE=$BUILD_CROSS_COMPILE CC=$KERNEL_LLVM_BIN/clang CLANG_TRIPLE=$CLANG_TRIPLE oldconfig

make -j8 -C $(pwd) O=$(pwd)/out $KERNEL_MAKE_ENV ARCH=arm64 \
	CC=$KERNEL_LLVM_BIN/clang \
	AR=$KERNEL_LLVM_BIN/llvm-ar \
	NM=$KERNEL_LLVM_BIN/llvm-nm \
	OBJCOPY=$KERNEL_LLVM_BIN/llvm-objcopy \
	OBJDUMP=$KERNEL_LLVM_BIN/llvm-objdump \
	STRIP=$KERNEL_LLVM_BIN/llvm-strip \
	LD=$KERNEL_LLVM_BIN/ld.lld \
	CROSS_COMPILE=$BUILD_CROSS_COMPILE \
	CLANG_TRIPLE=$CLANG_TRIPLE oldconfig

cp out/.config arch/arm64/configs/r8q_defconfig
