#-------------------------------------------------
#
# Project created by QtCreator 2010-11-18T08:15:47
#
#-------------------------------------------------

TARGET = avocado
TEMPLATE = app

CONFIG -= qt
CONFIG += exceptions precompile_header

PRECOMPILED_HEADER = avocado-global.h

!debug {
	CONFIG += silent
}

SOURCES += \
	\
	main.cpp \
	\
	FS.cpp \
	\
	SPI/Script/Script.cpp SPI/Script/ScriptSystem.cpp \
	SPI/Script/v8/avocado-v8.cpp SPI/Script/v8/v8Script.cpp SPI/Script/v8/v8ScriptSystem.cpp

HEADERS += \
	\
	avocado-global.h \
	\
	Factory.h \
	\
	FS.h \
	\
	SPI/Script/Script.h SPI/Script/ScriptSystem.h \
	SPI/Script/v8/avocado-v8.h SPI/Script/v8/v8Script.h SPI/Script/v8/v8ScriptSystem.h

LIBS += -lboost_filesystem -lboost_regex -lboost_system

LIBS += -Ldeps/v8
LIBS += -lv8-wb -lv8_snapshot-wb

unix:OUT_DIR = obj/unix

OBJECTS_DIR = $$OUT_DIR

unix:QMAKE_CXXFLAGS += -ansi -Werror
