#include "avocado-global.h"

#include "SfmlUiService.h"

#include "SfmlWindow.h"

namespace avo {

AbstractFactory<SfmlUiService> *SfmlUiService::factory = new AbstractFactory<SfmlUiService>;

SfmlUiService::SfmlUiService() {

	Window::factoryManager.setInstance(SfmlWindow::factory);

}

SfmlUiService::~SfmlUiService() {
}

void SfmlUiService::close() {
	UiService::close();
}

SfmlUiService::SpecialKeyCodes SfmlUiService::specialKeyCodes() {

	SpecialKeyCodes keyMap;

//	keyMap.UpArrow = SFMLK_UP;
//	keyMap.RightArrow = SFMLK_RIGHT;
//	keyMap.DownArrow = SFMLK_DOWN;
//	keyMap.LeftArrow = SFMLK_LEFT;

	return keyMap;
}

}
