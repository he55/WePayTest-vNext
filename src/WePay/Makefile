ARCHS = arm64 arm64e
# DEBUG = 0

INSTALL_TARGET_PROCESSES = WeChat

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = WePay

WePay_FILES = Tweak.x
WePay_FILES = $(wildcard Classes/*.m fmdb/*.m)
WePay_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
