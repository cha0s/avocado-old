#include "avocado-global.h"

#include "SdlGraphicsService.h"

#include "SdlImage.h"
#include "SdlWindow.h"

namespace avo {

AbstractFactory<SdlGraphicsService> *SdlGraphicsService::factory = new AbstractFactory<SdlGraphicsService>;

SdlGraphicsService::SdlGraphicsService() {

	Image::factoryManager.setInstance(SdlImage::factory);
	Window::factoryManager.setInstance(SdlWindow::factory);

	SDL_InitSubSystem(SDL_INIT_VIDEO);
}

SdlGraphicsService::~SdlGraphicsService() {
}

void SdlGraphicsService::close() {
	SDL_QuitSubSystem(SDL_INIT_VIDEO);
}

}
