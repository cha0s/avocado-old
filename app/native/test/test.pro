TARGET = ../avocado-test
TEMPLATE = app

CONFIG -= qt
CONFIG += exceptions precompile_header

QMAKE_LFLAGS += -rdynamic

PRECOMPILED_HEADER = ../avocado-global.h

!debug {
	CONFIG += silent
}

SOURCES += \
	main.cpp \
	\
	../FS.cpp ../FS.test.cpp

HEADERS += \
	\
	../avocado-global.h \
	\
	FS.h

INCLUDEPATH += ../deps gtest/include

LIBS += -Lgtest/avocado
LIBS += -lgtest -lpthread

LIBS += -lboost_filesystem -lboost_regex -lboost_system

unix:OUT_DIR = obj/unix

OBJECTS_DIR = $$OUT_DIR

unix:QMAKE_CXXFLAGS += -ansi -Werror
