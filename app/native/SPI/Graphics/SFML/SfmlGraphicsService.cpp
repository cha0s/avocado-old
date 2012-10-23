#include "avocado-global.h"

#include "SfmlGraphicsService.h"

#include "SfmlFont.h"
#include "SfmlImage.h"
#include "SfmlWindow.h"

namespace avo {

AbstractFactory<SfmlGraphicsService> *SfmlGraphicsService::factory = new AbstractFactory<SfmlGraphicsService>;

SfmlGraphicsService::SfmlGraphicsService() {
	Image::factoryManager.setInstance(SfmlImage::factory);
	Font::factoryManager.setInstance(SfmlFont::factory);
	Window::factoryManager.setInstance(SfmlWindow::factory);
}

SfmlGraphicsService::~SfmlGraphicsService() {
}

void SfmlGraphicsService::close() {
	GraphicsService::close();
}

GraphicsService::SpecialKeyCodes SfmlGraphicsService::specialKeyCodes() {

	SpecialKeyCodes keyMap;

	keyMap.UpArrow = 73;
	keyMap.RightArrow = 72;
	keyMap.DownArrow = 74;
	keyMap.LeftArrow = 71;

	return keyMap;
}

}
