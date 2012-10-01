#include "avocado-global.h"

#include "GraphicsService.h"

namespace avo {

FactoryManager<GraphicsService> GraphicsService::factoryManager;

GraphicsService::GraphicsService()
{
}

GraphicsService::~GraphicsService() {
}

}
