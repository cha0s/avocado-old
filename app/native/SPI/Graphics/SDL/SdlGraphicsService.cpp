#include "avocado-global.h"

#include "SdlGraphicsService.h"

#include "SdlImage.h"

namespace avo {

AbstractFactory<SdlGraphicsService> *SdlGraphicsService::factory = new AbstractFactory<SdlGraphicsService>;

SdlGraphicsService::SdlGraphicsService() {

	Image::factoryManager.setInstance(SdlImage::factory);
}

SdlGraphicsService::~SdlGraphicsService() {
}

void SdlGraphicsService::close() {
	GraphicsService::close();
}

}
