# Makefile for libjpeg-turbo

ifneq ($(TARGET_SIMULATOR),true)
##################################################
# NOTE(ytshen):
#
# Use ./configure to generate jconfig.h manually
#
# Follow simd/Makefile to generate jsimdcfg.inc
#
# $ $(NDK_ROOT)/toolchains/x86-4.6/prebuilt/linux-x86/bin/i686-linux-android-gcc -E -I. -I./simd simd/jsimdcfg.inc.h | egrep "^[\;%]|^\ %" | sed 's%_cpp_protection_%%' | sed 's@% define@%define@g' > simd/jsimdcfg.inc
#
# Request to use android-ndk-r9d (or above version), since it will require support
# asm file
#
#
# If you encounter link error with some missing symbol (ex: jpeg_create_huffman_index),
#   then you may want to merge some code from
# 	  git://git.linaro.org/people/tomgall/libjpeg-turbo/libjpeg-turbo.git from (http://stackoverflow.com/questions/12260149/libjpeg-turbo-for-android)
##################################################

##################################################
###                simd                        ###
##################################################
LOCAL_PATH := $(my-dir)
include $(CLEAR_VARS)

ifeq ($(ARCH_ARM_HAVE_NEON),true)
	LOCAL_CFLAGS += -D__ARM_HAVE_NEON
endif

# From autoconf-generated Makefile
EXTRA_DIST = simd/nasm_lt.sh simd/jcclrmmx.asm simd/jcclrss2.asm simd/jdclrmmx.asm simd/jdclrss2.asm \
	simd/jdmrgmmx.asm simd/jdmrgss2.asm simd/jcclrss2-64.asm simd/jdclrss2-64.asm \
	simd/jdmrgss2-64.asm simd/CMakeLists.txt
 
ifeq ($(TARGET_ARCH),arm)
libsimd_SOURCES_DIST = simd/jsimd_arm_neon.S \
                       simd/jsimd_arm.c 

AM_CFLAGS := -march=armv7-a -mfpu=neon
AM_CCASFLAGS := -march=armv7-a -mfpu=neon
endif

ifeq ($(TARGET_ARCH),x86)
EGREP=egrep
jsimdcfg.inc: simd/jsimdcfg.inc.h jpeglib.h jconfig.h jmorecfg.h
	$(CPP) -I$(LOCAL_PATH) -I$(LOCAL_PATH)/simd $(LOCAL_PATH)/simd/jsimdcfg.inc.h | $(EGREP) "^[\;%]|^\ %" | sed 's%_cpp_protection_%%' | sed 's@% define@%define@g' > $@

libsimd_SOURCES_DIST = simd/jsimd_i386.c \
	simd/jsimd.h simd/jsimdcfg.inc.h \
	simd/jsimdext.inc simd/jcolsamp.inc simd/jdct.inc \
	simd/jsimdcpu.asm \
	simd/jccolmmx.asm simd/jdcolmmx.asm simd/jcgrammx.asm \
	simd/jcsammmx.asm simd/jdsammmx.asm simd/jdmermmx.asm \
	simd/jcqntmmx.asm simd/jfmmxfst.asm simd/jfmmxint.asm \
	simd/jimmxred.asm simd/jimmxint.asm simd/jimmxfst.asm \
	simd/jcqnt3dn.asm simd/jf3dnflt.asm simd/ji3dnflt.asm \
	simd/jcqntsse.asm simd/jfsseflt.asm simd/jisseflt.asm \
	simd/jccolss2.asm simd/jdcolss2.asm simd/jcgrass2.asm \
	simd/jcsamss2.asm simd/jdsamss2.asm simd/jdmerss2.asm \
	simd/jcqnts2i.asm simd/jfss2fst.asm simd/jfss2int.asm \
	simd/jiss2red.asm simd/jiss2int.asm simd/jiss2fst.asm \
	simd/jcqnts2f.asm simd/jiss2flt.asm
LOCAL_ASMFLAGS := -P$(LOCAL_PATH)/simd/jsimdcfg.inc -DELF
endif

LOCAL_C_INCLUDES := $(LOCAL_PATH)/simd \
                    $(LOCAL_PATH)/android
 
######################################################
###           libjpeg-turbo.so                       ##
######################################################
 
# From autoconf-generated Makefile
libjpeg_SOURCES_DIST =  jcapimin.c jcapistd.c jccoefct.c jccolor.c \
        jcdctmgr.c jchuff.c jcinit.c jcmainct.c jcmarker.c jcmaster.c \
        jcomapi.c jcparam.c jcphuff.c jcprepct.c jcsample.c jctrans.c \
        jdapimin.c jdapistd.c jdatadst.c jdatasrc.c jdcoefct.c jdcolor.c \
        jddctmgr.c jdhuff.c jdinput.c jdmainct.c jdmarker.c jdmaster.c \
        jdmerge.c jdphuff.c jdpostct.c jdsample.c jdtrans.c jerror.c \
        jfdctflt.c jfdctfst.c jfdctint.c jidctflt.c jidctfst.c jidctint.c \
        jidctred.c jquant1.c jquant2.c jutils.c jmemmgr.c jmemnobs.c \
	jaricom.c jcarith.c jdarith.c \
	turbojpeg.c transupp.c jdatadst-tj.c jdatasrc-tj.c \
	turbojpeg-mapfile

LOCAL_SRC_FILES:= $(libjpeg_SOURCES_DIST)
 
LOCAL_C_INCLUDES := $(LOCAL_PATH) 
 
LOCAL_CFLAGS := -DAVOID_TABLES  -O3 -fstrict-aliasing -fprefetch-loop-arrays  -DANDROID \
        -DANDROID_TILE_BASED_DECODE -DENABLE_ANDROID_NULL_CONVERT

LOCAL_MODULE_PATH := $(TARGET_OUT_OPTIONAL_STATIC_LIBRARY)
 
LOCAL_MODULE_TAGS := debug
 
LOCAL_MODULE := libjpeg-turbo

LOCAL_SRC_FILES +=  $(libsimd_SOURCES_DIST)
include $(BUILD_STATIC_LIBRARY)
include $(CLEAR_VARS)

endif  # TARGET_SIMULATOR != true
