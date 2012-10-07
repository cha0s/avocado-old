TARGET = GraphicsService-sdl

include(../Graphics.pri)

SOURCES += \
	\
	SdlGraphicsService.cpp \
	\
	SdlImage.cpp

HEADERS += \
	\
	SdlGraphicsService.h \
	\
	SdlImage.h

win32:LIBS += -lSDLmain -lws2_32 -lwsock32
LIBS += -lSDL -lSDL_gfx -lSDL_image
