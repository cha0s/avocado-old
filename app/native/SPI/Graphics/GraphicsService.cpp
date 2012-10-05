#include "avocado-global.h"

#include "GraphicsService.h"

#include "Image.h"

namespace avo {

FactoryManager<GraphicsService> GraphicsService::factoryManager;

GraphicsService::GraphicsService()
{
}

GraphicsService::~GraphicsService() {
}

void GraphicsService::close() {
	Image::manager.forceReleaseAll();
	Image::factoryManager.setInstance(NULL);
}

}
