#include "avocado-global.h"

#include "SdlInputService.h"

#include "SdlInput.h"

namespace avo {

AbstractFactory<SdlInputService> *SdlInputService::factory = new AbstractFactory<SdlInputService>;

SdlInputService::SdlInputService() {

	Input::factoryManager.setInstance(SdlInput::factory);

	SDL_InitSubSystem(SDL_INIT_JOYSTICK);
}

SdlInputService::~SdlInputService() {
	SDL_QuitSubSystem(SDL_INIT_JOYSTICK);
}

void SdlInputService::close() {
}

}
