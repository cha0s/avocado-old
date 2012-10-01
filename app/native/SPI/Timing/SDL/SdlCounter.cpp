#include "avocado-global.h"

#include "SdlCounter.h"

#include "SDL/SDL.h"

namespace avo {

AbstractFactory<SdlCounter> *SdlCounter::factory = new AbstractFactory<SdlCounter>();

SdlCounter::SdlCounter()
	: Counter()
{
	setCurrent(SDL_GetTicks());
}

SdlCounter::~SdlCounter() {

}

Counter &SdlCounter::operator =(const Counter &counter) {
	AVOCADO_UNUSED(counter);

	return *this;
}

double SdlCounter::current() {
	return SDL_GetTicks();
}

}
