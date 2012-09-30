#include "avocado-global.h"

#include "SdlCoreService.h"

#include "SDL/SDL.h"

namespace avo {

AbstractFactory<SdlCoreService> *SdlCoreService::factory = new AbstractFactory<SdlCoreService>;

SdlCoreService::SdlCoreService() {
	SDL_Init(SDL_INIT_EVERYTHING);
}

SdlCoreService::~SdlCoreService() {
	close();
}

void SdlCoreService::close() {
	SDL_Quit();
}

}
