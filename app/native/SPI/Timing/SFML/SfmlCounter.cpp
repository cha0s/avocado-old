#include "avocado-global.h"

#include "SfmlCounter.h"

#include "SDL/SDL.h"

namespace avo {

AbstractFactory<SfmlCounter> *SfmlCounter::factory = new AbstractFactory<SfmlCounter>();

SfmlCounter::SfmlCounter()
	: Counter()
	, clock(new sf::Clock())
{
	clock->restart();
}

SfmlCounter::~SfmlCounter() {
	delete clock;
}

double SfmlCounter::current() {
	return clock->getElapsedTime().asMilliseconds();
}

}
