ARCHS = arm64 arm64e
# DEBUG = 0

include $(THEOS)/makefiles/common.mk

TOOL_NAME = wepayd

wepayd_INSTALL_PATH = /usr/sbin
wepayd_FILES = $(wildcard fmdb/*.m GCDWebServer/*.m *.m)
wepayd_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tool.mk
