
include $(CLEAR_VARS)
DTOP?=/home/DLT_MIT/MIT6175/mit_6.175_riscv_1/connectal/bluesim
CONNECTALDIR?=/opt/connectal
LOCAL_ARM_MODE := arm
include $(CONNECTALDIR)/scripts/Makefile.connectal.application
LOCAL_SRC_FILES := /home/DLT_MIT/MIT6175/mit_6.175_riscv_1/connectal/main.cpp /home/DLT_MIT/MIT6175/mit_6.175_riscv_1/connectal/Platform.cpp /opt/connectal/cpp/dmaManager.c /opt/connectal/cpp/platformMemory.cpp /opt/connectal/cpp/transportXsim.c $(PORTAL_SRC_FILES)

LOCAL_PATH :=
LOCAL_MODULE := android.exe
LOCAL_MODULE_TAGS := optional
LOCAL_LDLIBS := -llog   
LOCAL_CPPFLAGS := "-march=armv7-a"
LOCAL_CFLAGS := -I$(DTOP)/jni -I$(CONNECTALDIR) -I$(CONNECTALDIR)/cpp -I$(CONNECTALDIR)/lib/cpp   -Werror
LOCAL_CXXFLAGS := -I$(DTOP)/jni -I$(CONNECTALDIR) -I$(CONNECTALDIR)/cpp -I$(CONNECTALDIR)/lib/cpp   -Werror
LOCAL_CFLAGS2 := $(cdefines2)s

include $(BUILD_EXECUTABLE)
