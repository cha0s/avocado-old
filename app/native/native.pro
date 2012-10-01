TARGET = ../../avocado
TEMPLATE = app

CONFIG -= qt
CONFIG += exceptions precompile_header

gtest.commands += \
	#
	# Google Test
	#
	echo "Building Google Test..."; \
	cd test/gtest; \
	#
	# Build it if it hasn't been.
	#
	test ! -d avocado \
		&& mkdir avocado \
		&& cd avocado \
		&& cmake .. \
		&& make \
		&& cd ..; \
	cd ..; \
	echo "Done building Google Test."; \
	echo "Building tests..."; \
	#
	# Build tests
	#
	qmake; \
	make -j4 && \
	cd .. && \
	echo "Done building tests..." && \
	echo "Running tests..." && \
	#
	# Run tests
	#
	./avocado-test;
	
dependencies.commands += \
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
	
spiis.commands += \
	#
	# SPIIs
	#
	echo "Building SPIIs..."; \
	./build-spi; \
	echo "Done building SPIIs.";

everything.depends = dependencies spiis all

QMAKE_EXTRA_TARGETS += dependencies spiis everything gtest

QMAKE_CLEAN += ../../SPII/*.spii
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
	SPI/Script/Script.cpp SPI/Script/ScriptService.cpp \
	SPI/Core/CoreService.cpp \
	SPI/Graphics/GraphicsService.cpp SPI/Graphics/Image.cpp SPI/Graphics/Window.cpp \
	SPI/Timing/TimingService.cpp SPI/Timing/Counter.cpp

HEADERS += \
	\
	avocado-global.h \
	\
	Factory.h \
	\
	FS.h \
	\
	SPI/SpiiLoader.h \
	SPI/Script/Script.h SPI/Script/ScriptService.h \
	SPI/Core/CoreService.h \
	SPI/Graphics/GraphicsService.h SPI/Graphics/Image.h SPI/Graphics/Window.h \
	SPI/Timing/TimingService.h SPI/Timing/Counter.h

INCLUDEPATH += deps

LIBS += -lboost_filesystem -lboost_regex -lboost_system

unix:OUT_DIR = obj/unix

OBJECTS_DIR = $$OUT_DIR

unix:QMAKE_CXXFLAGS += -ansi -Werror
