TEMPLATE = lib

CONFIG += dll

QMAKE_POST_LINK = cp $(TARGET) $${TARGET}.spii

PRECOMPILED_HEADER = ../../../avocado-global.h

!debug {
	CONFIG += silent
}

SOURCES += implementSpi.cpp

HEADERS += ../../../avocado-global.h

INCLUDEPATH += ../../.. ../../../deps

unix:OUT_DIR = obj/unix

OBJECTS_DIR = $$OUT_DIR

unix:QMAKE_CXXFLAGS += -ansi -Werror
