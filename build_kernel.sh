#!/bin/bash

export ARCH=arm64
mkdir out

BUILD_CROSS_COMPILE=/home/pascua14/gcc-7.4.1/bin/aarch64-linux-gnu-
KERNEL_LLVM_BIN=/home/pascua14/clang/bin
CLANG_TRIPLE=aarch64-linux-gnu-
KERNEL_MAKE_ENV="DTC_EXT=$(pwd)/tools/dtc CONFIG_BUILD_ARM64_DT_OVERLAY=y"

echo "**********************************"
echo "Select variant (Snapdragon only)"
echo "(1) 4G Variant"
echo "(2) 5G Variant"
read -p "Selected variant: " variant

make -j8 -C $(pwd) O=$(pwd)/out $KERNEL_MAKE_ENV ARCH=arm64 \
	CROSS_COMPILE=$BUILD_CROSS_COMPILE \
	CC=$KERNEL_LLVM_BIN/clang \
	AR=$KERNEL_LLVM_BIN/llvm-ar \
	NM=$KERNEL_LLVM_BIN/llvm-nm \
	OBJCOPY=$KERNEL_LLVM_BIN/llvm-objcopy \
	OBJDUMP=$KERNEL_LLVM_BIN/llvm-objdump \
	STRIP=$KERNEL_LLVM_BIN/llvm-strip \
	LD=$KERNEL_LLVM_BIN/ld.lld \
	CLANG_TRIPLE=$CLANG_TRIPLE r8q_defconfig

if [ $variant == "1" ]; then
	echo "
Compiling for 4G variant
"
	MODEL="G780G"

elif [ $variant == "2" ]; then
	echo "
Compiling for 5G variant
"
	MODEL="G781B"

	scripts/configcleaner "
CONFIG_SAMSUNG_NFC
CONFIG_NFC_PN547
CONFIG_NFC_PN547_ESE_SUPPORT
CONFIG_NFC_FEATURE_SN100U
CONFIG_FIVE
"

	echo "
# CONFIG_SAMSUNG_NFC is not set
# CONFIG_NFC_PN547 is not set
# CONFIG_NFC_PN547_ESE_SUPPORT is not set
# CONFIG_NFC_FEATURE_SN100U is not set
# CONFIG_FIVE is not set
" >> out/.config

fi

make -j8 -C $(pwd) O=$(pwd)/out $KERNEL_MAKE_ENV ARCH=arm64 \
	CROSS_COMPILE=$BUILD_CROSS_COMPILE \
	CC=$KERNEL_LLVM_BIN/clang \
	AR=$KERNEL_LLVM_BIN/llvm-ar \
	NM=$KERNEL_LLVM_BIN/llvm-nm \
	OBJCOPY=$KERNEL_LLVM_BIN/llvm-objcopy \
	OBJDUMP=$KERNEL_LLVM_BIN/llvm-objdump \
	STRIP=$KERNEL_LLVM_BIN/llvm-strip \
	LD=$KERNEL_LLVM_BIN/ld.lld \
	CLANG_TRIPLE=$CLANG_TRIPLE

IMAGE="out/arch/arm64/boot/Image.gz-dtb"

if [[ -f "$IMAGE" ]]; then
	rm AnyKernel3/zImage > /dev/null 2>&1
	rm AnyKernel3/*.zip > /dev/null 2>&1
	cp $IMAGE AnyKernel3/zImage
	cd AnyKernel3
	zip -r9 Kernel-$MODEL.zip .
fi
