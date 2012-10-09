#include "avocado-global.h"

#include "SfmlGraphicsService.h"

#include "SfmlImage.h"

namespace avo {

AbstractFactory<SfmlGraphicsService> *SfmlGraphicsService::factory = new AbstractFactory<SfmlGraphicsService>;

SfmlGraphicsService::SfmlGraphicsService() {

	Image::factoryManager.setInstance(SfmlImage::factory);
}

SfmlGraphicsService::~SfmlGraphicsService() {
}

void SfmlGraphicsService::close() {
	GraphicsService::close();
}

}
