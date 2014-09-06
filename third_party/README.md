android third-party
===================

libjpeg-turbo
-------------

Request to use android-ndk-r9d (or above version), since it will require support asm file. I provide Android.mk to support building libjpeg-turbo for armeabi, armeabi-v7a and x86.

Use ./configure to generate jconfig.h manually

Follow simd/Makefile.am to generate jsimdcfg.inc
$ $(NDK_ROOT)/toolchains/x86-4.6/prebuilt/linux-x86/bin/i686-linux-android-gcc -E -I. -I./simd simd/jsimdcfg.inc.h | egrep "^[\;%]|^\ %" | sed 's%_cpp_protection_%%' | sed 's@% define@%define@g' > simd/jsimdcfg.inc

NOTE:
I did not use Android.mk to auto-generate some file, the file is generated manually
and put to repository.
If you encounter link error with some missing symbol (ex: jpeg_create_huffman_index),
  then you may want to merge some code from git://git.linaro.org/people/tomgall/libjpeg-turbo/libjpeg-turbo.git from (http://stackoverflow.com/questions/12260149/libjpeg-turbo-for-android)
