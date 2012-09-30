TEMPLATE = lib
TARGET = ScriptSystem-v8

CONFIG += dll

QMAKE_POST_LINK = cp $(TARGET) ScriptSystem-v8.spi

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
	v8Script.cpp v8ScriptSystem.cpp

HEADERS += \
	\
	../../../avocado-global.h \
	\
	../../../Factory.h \
	\
	../../../FS.h \
	\
	../Script.h ../ScriptSystem.h \
	\
	avocado-v8.h \
	\
	v8Script.h v8ScriptSystem.h

INCLUDEPATH += ../../.. ../../../deps

#LIBS += -lboost_filesystem -lboost_regex -lboost_system

LIBS += -L../../../deps/v8
LIBS += -lv8-avocado -lv8_snapshot-avocado

unix:OUT_DIR = obj/unix

OBJECTS_DIR = $$OUT_DIR

unix:QMAKE_CXXFLAGS += -ansi -Werror
