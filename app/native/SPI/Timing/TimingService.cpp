#include "avocado-global.h"

#include "TimingService.h"

#include "Counter.h"

namespace avo {

FactoryManager<TimingService> TimingService::factoryManager;

TimingService::TimingService()
{
}

TimingService::~TimingService() {
}

void TimingService::close() {
	Counter::factoryManager.setInstance(NULL);
}

}
