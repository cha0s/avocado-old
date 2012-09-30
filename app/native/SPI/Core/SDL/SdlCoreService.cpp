#include "avocado-global.h"

#include "SdlCoreService.h"

#include "SDL/SDL.h"

namespace avo {

AbstractFactory<SdlCoreService> *SdlCoreService::factory = new AbstractFactory<SdlCoreService>;

SdlCoreService::SdlCoreService() {

	SDL_putenv(const_cast<char *>("SDL_VIDEO_CENTERED=center"));

	const char *currentDriver = SDL_getenv(const_cast<char *>("SDL_VIDEODRIVER"));
	if (currentDriver) {
		std::string *driver = new std::string("AVOCADO_SDL_VIDEODRIVER=");
		*driver += currentDriver;
		SDL_putenv(const_cast<char *>(driver->c_str()));
	}
	SDL_putenv(const_cast<char *>("AVOCADO_SDL_VIDEORESTORE=1"));
	SDL_putenv(const_cast<char *>("SDL_VIDEODRIVER=dummy"));

	SDL_Init(SDL_INIT_EVERYTHING);
}

SdlCoreService::~SdlCoreService() {
	close();
}

void SdlCoreService::close() {
	SDL_Quit();
}

}
