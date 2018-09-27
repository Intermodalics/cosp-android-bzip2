LOCAL_PATH := $(call my-dir)
PROJECT_ROOT:= $(call my-dir)

include $(CLEAR_VARS)
LOCAL_MODULE    := bzip2
LOCAL_SRC_FILES := $(LOCAL_PATH)/blocksort.c $(LOCAL_PATH)/huffman.c $(LOCAL_PATH)/crctable.c $(LOCAL_PATH)/randtable.c $(LOCAL_PATH)/compress.c $(LOCAL_PATH)/decompress.c $(LOCAL_PATH)/bzlib.c $(LOCAL_PATH)/bzip2.c $(LOCAL_PATH)/bzip2recover.c
LOCAL_C_INCLUDES += $(LOCAL_PATH)/bzlib_private.h $(LOCAL_PATH)/bzlib.h
LOCAL_CFLAGS  += -Wall -Winline -O2 -g -fPIC -D_FILE_OFFSET_BITS=64
LOCAL_LDLIBS += -landroid -lm -llog -lz
LOCAL_EXPORT_C_INCLUDES := $(LOCAL_C_INCLUDES)
LOCAL_DISABLE_FATAL_LINKER_WARNINGS=true
include $(BUILD_STATIC_LIBRARY)
