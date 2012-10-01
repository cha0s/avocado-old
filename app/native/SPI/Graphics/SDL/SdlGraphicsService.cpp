#include "avocado-global.h"

#include "SdlGraphicsService.h"

#include "SdlImage.h"
#include "SdlWindow.h"

namespace avo {

AbstractFactory<SdlGraphicsService> *SdlGraphicsService::factory = new AbstractFactory<SdlGraphicsService>;

SdlGraphicsService::SdlGraphicsService() {

	Image::factoryManager.setInstance(SdlImage::factory);
	Window::factoryManager.setInstance(SdlWindow::factory);
}

SdlGraphicsService::~SdlGraphicsService() {
}

}
