TARGET = CoreService-sdl

include(../Core.pri)

SOURCES += \
	\
	SdlCoreService.cpp

HEADERS += \
	\
	SdlCoreService.h

win32:LIBS += -lSDLmain -lws2_32 -lwsock32
LIBS += -lSDL
