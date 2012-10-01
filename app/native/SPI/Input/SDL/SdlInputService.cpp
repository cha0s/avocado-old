#include "avocado-global.h"

#include "SdlInputService.h"

#include "SdlInput.h"

namespace avo {

AbstractFactory<SdlInputService> *SdlInputService::factory = new AbstractFactory<SdlInputService>;

SdlInputService::SdlInputService() {

	Input::factoryManager.setInstance(SdlInput::factory);
}

SdlInputService::~SdlInputService() {
}

}
