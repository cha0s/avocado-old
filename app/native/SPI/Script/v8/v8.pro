TARGET = ScriptService-v8

include(../Script.pri)

SOURCES += \
	\
	avocado-v8.cpp ObjectWrap.cpp \
	\
	v8Script.cpp v8ScriptService.cpp \
	\
	v8CoreService.cpp

HEADERS += \
	\
	avocado-v8.h ObjectWrap.h \
	\
	v8Script.h v8ScriptService.h \
	\
	../../Core/CoreService.h v8CoreService.h

LIBS += -L../../../deps/v8
LIBS += -lv8-avocado -lv8_snapshot-avocado
