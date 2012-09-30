TEMPLATE = lib
TARGET = ScriptService-v8

CONFIG += dll

QMAKE_POST_LINK = cp $(TARGET) ScriptService-v8.spii

PRECOMPILED_HEADER = ../../../avocado-global.h

!debug {
	CONFIG += silent
}

SOURCES += \
	\
	avocado-v8.cpp \
	\
	implementSpi.cpp \
	\
	v8Script.cpp v8ScriptService.cpp

HEADERS += \
	\
	../../../avocado-global.h \
	\
	../../../Factory.h \
	\
	../../../FS.h \
	\
	../Script.h ../ScriptService.h \
	\
	avocado-v8.h \
	\
	v8Script.h v8ScriptService.h

INCLUDEPATH += ../../.. ../../../deps

#LIBS += -lboost_filesystem -lboost_regex -lboost_system

LIBS += -L../../../deps/v8
LIBS += -lv8-avocado -lv8_snapshot-avocado

unix:OUT_DIR = obj/unix

OBJECTS_DIR = $$OUT_DIR

unix:QMAKE_CXXFLAGS += -ansi -Werror
