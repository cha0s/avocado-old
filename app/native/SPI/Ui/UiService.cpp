#include "avocado-global.h"

#include "UiService.h"

#include "Input.h"
#include "Window.h"

namespace avo {

FactoryManager<UiService> UiService::factoryManager;

UiService::UiService()
{
}

UiService::~UiService() {
}

void UiService::close() {
	Input::factoryManager.setInstance(NULL);
	Window::factoryManager.setInstance(NULL);
}

}
