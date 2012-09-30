TARGET = avocado
TEMPLATE = app

CONFIG -= qt
CONFIG += exceptions precompile_header

QMAKE_LFLAGS += -rdynamic

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
	SPI/Script/Script.cpp SPI/Script/ScriptSystem.cpp

HEADERS += \
	\
	avocado-global.h \
	\
	Factory.h \
	\
	FS.h \
	\
	SPI/SpiLoader.h \
	SPI/Script/Script.h SPI/Script/ScriptSystem.h

INCLUDEPATH += deps

LIBS += -lboost_filesystem -lboost_regex -lboost_system

LIBS += -Ldeps/v8
LIBS += -lv8-wb -lv8_snapshot-wb

unix:OUT_DIR = obj/unix

OBJECTS_DIR = $$OUT_DIR

unix:QMAKE_CXXFLAGS += -ansi -Werror
