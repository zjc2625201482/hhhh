THEOS_DEVICE_IP = localhost
THEOS_DEVICE_PORT = 2222

ARCHS = arm64 arm64e
TARGET = iphone:clang:latest:14.0

INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = SthenoBoundary

SthenoBoundary_FILES = Tweak.xm
SthenoBoundary_CFLAGS = -fobjc-arc
SthenoBoundary_FRAMEWORKS = UIKit
SthenoBoundary_PRIVATE_FRAMEWORKS = SpringBoard

include $(THEOS)/makefiles/tweak.mk

after-install::
	install.exec "sbreload"
