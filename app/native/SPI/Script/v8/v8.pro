TARGET = ScriptService-v8

include(../Script.pri)

SOURCES += \
	\
	avocado-v8.cpp \
	\
	v8Script.cpp v8ScriptService.cpp

HEADERS += \
	\
	avocado-v8.h \
	\
	v8Script.h v8ScriptService.h

LIBS += -L../../../deps/v8
LIBS += -lv8-avocado -lv8_snapshot-avocado
