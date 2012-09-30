TARGET = ../../avocado
TEMPLATE = app

CONFIG -= qt
CONFIG += exceptions precompile_header

dependencies.target = dependencies
dependencies.commands +=	\
	echo "Building dependencies..."; \
	#
	# V8
	#
	echo "Building v8..."; \
	cd deps; \
	#
	# Checkout the V8 git repository if it hasn't been yet.
	#
	test ! -d v8 \
		&& git clone git://github.com/v8/v8.git v8 \
		&& cd v8 \
		&& patch -p1 < ../v8.patch && make dependencies \
		&& cd ..; \
	cd v8; \
	#
	# Build V8 if necessary, and rename the libraries as we need.
	#
	test ! -f libv8-avocado.a -a ! -f libv8_snapshot-avocado.a \
		&& make -j 4 ia32.release \
		&& mv out/ia32.release/obj.target/tools/gyp/libv8_base.a libv8-avocado.a \
		&& mv out/ia32.release/obj.target/tools/gyp/libv8_snapshot.a libv8_snapshot-avocado.a; \ 
	cd ../..; \
	echo "Done building v8.";
	
spi_implementations.target = spi_implementations
spi_implementations.commands +=	\
	#
	# SPI implementations
	#
	echo "Building SPI implementations..."; \
	./build-spi; \
	echo "Done building SPI implementations.";

QMAKE_EXTRA_TARGETS += dependencies spi_implementations

PRE_TARGETDEPS = spi_implementations

QMAKE_CLEAN += ../../SPI/*
QMAKE_CLEAN += $$system('find SPI -name "*.o" -o -name "*.so*"')

QMAKE_LFLAGS += -rdynamic

PRECOMPILED_HEADER = avocado-global.h

!debug {
	CONFIG += silent
}

SOURCES += \
	\
	main.cpp \
	\
	FS.cpp \
	\
	SPI/Script/Script.cpp SPI/Script/ScriptSystem.cpp

HEADERS += \
	\
	avocado-global.h \
	\
	Factory.h \
	\
	FS.h \
	\
	SPI/SpiLoader.h \
	SPI/Script/Script.h SPI/Script/ScriptSystem.h

INCLUDEPATH += deps

LIBS += -lboost_filesystem -lboost_regex -lboost_system

unix:OUT_DIR = obj/unix

OBJECTS_DIR = $$OUT_DIR

unix:QMAKE_CXXFLAGS += -ansi -Werror
