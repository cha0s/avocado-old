TARGET = SoundService-sfml

include(../Sound.pri)

SOURCES += \
	\
	SfmlSoundService.cpp \
	\
	SfmlSample.cpp SfmlMusic.cpp

HEADERS += \
	\
	SfmlSoundService.h \
	\
	SfmlSample.h SfmlMusic.h

INCLUDEPATH += ../../../deps/SFML/include
LIBS += -L../../../deps/SFML/build/lib
LIBS += -lsfml-audio-s -lsfml-system-s -lopenal -lsndfile
