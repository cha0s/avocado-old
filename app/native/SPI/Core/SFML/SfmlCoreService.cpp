#include "avocado-global.h"

#include "SfmlCoreService.h"

namespace avo {

AbstractFactory<SfmlCoreService> *SfmlCoreService::factory = new AbstractFactory<SfmlCoreService>;

SfmlCoreService::SfmlCoreService()
{
}

SfmlCoreService::~SfmlCoreService() {
	close();
}

void SfmlCoreService::close() {
	CoreService::close();
}

}
