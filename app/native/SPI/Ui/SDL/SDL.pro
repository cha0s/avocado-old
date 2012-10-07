TARGET = UiService-sdl

include(../Ui.pri)

SOURCES += \
	\
	SdlUiService.cpp \
	\
	SdlWindow.cpp \
	\
	../../Graphics/SDL/SdlImage.cpp

HEADERS += \
	\
	SdlUiService.h \
	\
	../../Graphics/SDL/Image.h \
	\
	SdlWindow.h \
	\
	../../Graphics/SDL/SdlImage.h
	

win32:LIBS += -lSDLmain -lws2_32 -lwsock32
LIBS += -lSDL -lSDL_gfx -lSDL_image
	