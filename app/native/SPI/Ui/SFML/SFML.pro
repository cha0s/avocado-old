TARGET = UiService-sfml

include(../Ui.pri)

SOURCES += \
	\
	SfmlUiService.cpp \
	\
	SfmlWindow.cpp ../../Graphics/SFML/SfmlImage.cpp

HEADERS += \
	\
	SfmlUiService.h \
	\
	../../Graphics/Image.h \
	\
	SfmlWindow.h

INCLUDEPATH += ../../../deps/SFML/include
LIBS += -L../../../deps/SFML/build/lib
LIBS += -lsfml-graphics-s -lsfml-window-s -lsfml-system-s -lGL -lXrandr -ljpeg -lGLEW -lrt
