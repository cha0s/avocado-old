TARGET = GraphicsService-sfml

include(../Graphics.pri)

SOURCES += \
	\
	SfmlGraphicsService.cpp \
	\
	SfmlImage.cpp SfmlWindow.cpp

HEADERS += \
	\
	SfmlGraphicsService.h \
	\
	SfmlImage.h SfmlWindow.h

INCLUDEPATH += ../../../deps/SFML/include
LIBS += -L../../../deps/SFML/build/lib
LIBS += -lsfml-graphics-s -lsfml-window-s -lsfml-system-s -lGL -lXrandr -ljpeg -lGLEW -lrt