#include "avocado-global.h"

#include "UiService.h"

#include "Window.h"

namespace avo {

FactoryManager<UiService> UiService::factoryManager;

UiService::UiService()
{
}

UiService::~UiService() {
}

void UiService::close() {
	Window::factoryManager.setInstance(NULL);
}

}
