#include "avocado-global.h"

#include "InputService.h"

namespace avo {

FactoryManager<InputService> InputService::factoryManager;

InputService::InputService()
{
}

InputService::~InputService() {
}

}
