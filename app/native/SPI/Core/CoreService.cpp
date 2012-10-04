#include "avocado-global.h"

#include "CoreService.h"

namespace avo {

FactoryManager<CoreService> CoreService::factoryManager;

void CoreService::close() {
}

}
