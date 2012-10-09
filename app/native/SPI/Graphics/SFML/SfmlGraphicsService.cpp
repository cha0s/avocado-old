#include "avocado-global.h"

#include "SfmlGraphicsService.h"

#include "SfmlImage.h"
#include "SfmlWindow.h"

namespace avo {

AbstractFactory<SfmlGraphicsService> *SfmlGraphicsService::factory = new AbstractFactory<SfmlGraphicsService>;

SfmlGraphicsService::SfmlGraphicsService() {

	Image::factoryManager.setInstance(SfmlImage::factory);
	Window::factoryManager.setInstance(SfmlWindow::factory);
}

SfmlGraphicsService::~SfmlGraphicsService() {
}

void SfmlGraphicsService::close() {
	GraphicsService::close();
}

GraphicsService::SpecialKeyCodes SfmlGraphicsService::specialKeyCodes() {

	SpecialKeyCodes keyMap;

//	keyMap.UpArrow = SFMLK_UP;
//	keyMap.RightArrow = SFMLK_RIGHT;
//	keyMap.DownArrow = SFMLK_DOWN;
//	keyMap.LeftArrow = SFMLK_LEFT;

	return keyMap;
}

}
