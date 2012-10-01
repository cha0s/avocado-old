#include "avocado-global.h"

#include "TimingService.h"

namespace avo {

FactoryManager<TimingService> TimingService::factoryManager;

TimingService::TimingService()
{
}

TimingService::~TimingService() {
}

}
