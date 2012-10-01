TARGET = TimingService-qt

include(../Timing.pri)

CONFIG += qt

SOURCES += \
	\
	QtTimingService.cpp \
	\
	QtCounter.cpp

HEADERS += \
	\
	QtTimingService.h \
	\
	QtCounter.h
