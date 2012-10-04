#include "avocado-global.h"

#include "InputService.h"

#include "Input.h"

namespace avo {

FactoryManager<InputService> InputService::factoryManager;

InputService::InputService()
{
}

InputService::~InputService() {
}

void InputService::close() {
	Input::factoryManager.setInstance(NULL);
}

}
