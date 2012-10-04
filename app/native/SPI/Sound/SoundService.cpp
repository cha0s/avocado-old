#include "avocado-global.h"

#include "SoundService.h"

#include "Music.h"
#include "Sample.h"

namespace avo {

FactoryManager<SoundService> SoundService::factoryManager;

SoundService::SoundService()
{
}

SoundService::~SoundService() {
}

void SoundService::close() {
	Sample::manager.forceReleaseAll();
	Sample::factoryManager.setInstance(NULL);

	Music::manager.forceReleaseAll();
	Music::factoryManager.setInstance(NULL);
}

}
