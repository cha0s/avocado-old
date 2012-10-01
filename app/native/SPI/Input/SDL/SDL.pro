TARGET = InputService-sdl

include(../Input.pri)

SOURCES += \
	\
	SdlInputService.cpp \
	\
	SdlInput.cpp

HEADERS += \
	\
	SdlInputService.h \
	\
	SdlInput.h

win32:LIBS += -lSDLmain -lws2_32 -lwsock32
LIBS += -lSDL -lSDL_gfx -lSDL_image
	