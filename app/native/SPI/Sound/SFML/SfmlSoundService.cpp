#include "avocado-global.h"

#include "SfmlSoundService.h"

#include <SFML/Audio.hpp>

#include "SfmlMusic.h"
#include "SfmlSample.h"

namespace avo {

AbstractFactory<SfmlSoundService> *SfmlSoundService::factory = new AbstractFactory<SfmlSoundService>;

SfmlSoundService::SfmlSoundService() {

	Sample::factoryManager.setInstance(SfmlSample::factory);
	Music::factoryManager.setInstance(SfmlMusic::factory);
}

SfmlSoundService::~SfmlSoundService() {
}

}
