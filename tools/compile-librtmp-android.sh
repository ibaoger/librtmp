#! /bin/sh

RTMP_ARCH=$1
if [ -z "$RTMP_ARCH" ]; then
    echo "You must specific an architecture 'armv5, armv7a, x86, mips, ...'."
    echo ""
    exit 1
fi

# replace this path to your android NDK standalone toolchain ptah.
RTMP_TOOLCHAIN_PATH=/Users/shishuo/Documents/app/Android-NDK-Toolchain
RTMP_BUILD_ROOT=`pwd`
RTMP_BIN_ROOT=$RTMP_BUILD_ROOT/bin
RTMP_ARCH_DIR=
cd ..

compile_armv7a() {
	export CC=$RTMP_TOOLCHAIN_PATH/arm/bin/arm-linux-androideabi-gcc
	export LD=$RTMP_TOOLCHAIN_PATH/arm/bin/arm-linux-androideabi-ld
	export AR=$RTMP_TOOLCHAIN_PATH/arm/bin/arm-linux-androideabi-ar
	export ARCH_CFLAGS=-march=armv7-a -mfpu=vfpv3-d16 -mfloat-abi=softfp -mthumb
	make clean
	make all
}

compile_armv5() {
	export CC=$RTMP_TOOLCHAIN_PATH/arm/bin/arm-linux-androideabi-gcc
	export LD=$RTMP_TOOLCHAIN_PATH/arm/bin/arm-linux-androideabi-ld
	export AR=$RTMP_TOOLCHAIN_PATH/arm/bin/arm-linux-androideabi-ar
	export ARCH_CFLAGS=-march=armv5te -msoft-float
	make clean
	make all
}

compile_arm64() {
	export CC=$RTMP_TOOLCHAIN_PATH/arm64/bin/aarch64-linux-android-gcc
	export LD=$RTMP_TOOLCHAIN_PATH/arm64/bin/aarch64-linux-android-ld
	export AR=$RTMP_TOOLCHAIN_PATH/arm64/bin/aarch64-linux-android-ar
	export ARCH_CFLAGS=-march=armv8-a
	make clean
	make all
}

compile_x86() {
	export CC=$RTMP_TOOLCHAIN_PATH/x86/bin/i686-linux-android-gcc
	export LD=$RTMP_TOOLCHAIN_PATH/x86/bin/i686-linux-android-ld
	export AR=$RTMP_TOOLCHAIN_PATH/x86/bin/i686-linux-android-ar
	export ARCH_CFLAGS=-mtune=intel -m32 -mmmx -msse2 -msse3 -mssse3
	make clean
	make all
}

compile_x86_64() {
	export CC=$RTMP_TOOLCHAIN_PATH/x86_64/bin/x86_64-linux-android-gcc
	export LD=$RTMP_TOOLCHAIN_PATH/x86_64/bin/x86_64-linux-android-ld
	export AR=$RTMP_TOOLCHAIN_PATH/x86_64/bin/x86_64-linux-android-ar
	export ARCH_CFLAGS=-mtune=intel -m64 -mmmx -msse2 -msse3 -mssse3 -msse4.1 -msse4.2 -mpopcnt
	make clean
	make all
}

compile_mips() {
	export CC=$RTMP_TOOLCHAIN_PATH/mips/bin/mipsel-linux-android-gcc
	export LD=$RTMP_TOOLCHAIN_PATH/mips/bin/mipsel-linux-android-ld
	export AR=$RTMP_TOOLCHAIN_PATH/mips/bin/mipsel-linux-android-ar
	export ARCH_CFLAGS=-march=mips32 -mfp32 -mhard-float
	make clean
	make all
}

compile_mips64() {
	export CC=$RTMP_TOOLCHAIN_PATH/mips64/bin/mips64el-linux-android-gcc
	export LD=$RTMP_TOOLCHAIN_PATH/mips64/bin/mips64el-linux-android-ld
	export AR=$RTMP_TOOLCHAIN_PATH/mips64/bin/mips64el-linux-android-ar
	export ARCH_CFLAGS=-march=mips64r6
	make clean
	make all
}

release_librtmp() {
	if [ "$RTMP_ARCH" = "armv7a" ]; then
		RTMP_ARCH_DIR=armeabi-v7a
	elif [ "$RTMP_ARCH" = "armv5" ]; then
		RTMP_ARCH_DIR=armeabi
	elif [ "$RTMP_ARCH" = "arm64" ]; then
		RTMP_ARCH_DIR=arm64-v8a
	else
		RTMP_ARCH_DIR=$RTMP_ARCH
	fi
	mkdir -p        $RTMP_BIN_ROOT/$RTMP_ARCH_DIR/lib
	cp -f librtmp.a $RTMP_BIN_ROOT/$RTMP_ARCH_DIR/lib
	mkdir -p        $RTMP_BIN_ROOT/$RTMP_ARCH_DIR/include/librtmp
	cp -f amf.h     $RTMP_BIN_ROOT/$RTMP_ARCH_DIR/include/librtmp
	cp -f http.h    $RTMP_BIN_ROOT/$RTMP_ARCH_DIR/include/librtmp
	cp -f log.h     $RTMP_BIN_ROOT/$RTMP_ARCH_DIR/include/librtmp
	cp -f rtmp.h    $RTMP_BIN_ROOT/$RTMP_ARCH_DIR/include/librtmp
}

if [ "$RTMP_ARCH" = "armv7a" ]; then
	compile_armv7a
	release_librtmp

elif [ "$RTMP_ARCH" = "armv5" ]; then
	compile_armv5
	release_librtmp

elif [ "$RTMP_ARCH" = "arm64" ]; then
	compile_arm64
	release_librtmp

elif [ "$RTMP_ARCH" = "x86" ]; then
	compile_x86
	release_librtmp

elif [ "$RTMP_ARCH" = "x86_64" ]; then
	compile_x86_64
	release_librtmp

elif [ "$RTMP_ARCH" = "mips" ]; then
	compile_mips
	release_librtmp

elif [ "$RTMP_ARCH" = "mips64" ]; then
	compile_mips64
	release_librtmp

elif [ "$RTMP_ARCH" = "all" ]; then
	cd tools
	sh compile-librtmp-android.sh armv7a
	sh compile-librtmp-android.sh armv5
	sh compile-librtmp-android.sh arm64
	sh compile-librtmp-android.sh x86
	sh compile-librtmp-android.sh x86_64
	sh compile-librtmp-android.sh mips
	sh compile-librtmp-android.sh mips64

else
    echo "unknown architecture $RTMP_ARCH";
    exit 1
fi