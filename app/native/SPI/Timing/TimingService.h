#ifndef AVOCADO_TIMINGSERVICE_H
#define AVOCADO_TIMINGSERVICE_H

#include "avocado-global.h"

#include "Factory.h"

namespace avo {

/**
 * @addtogroup Timing
 * @{
 */

/**
 * %TimingService handles initialization and teardown of the timing
 * framework. Each concrete SPI implementation (SPII) also manages SPIIs
 * for Counter. Also provides CPU scheduling helpers.
 */
class TimingService {

public:

	TimingService();
	virtual ~TimingService();

	/**
	 * Close out the service.
	 */
	virtual void close() {}

	/**
	 * Delay execution by a given number of milliseconds.
	 */
	virtual void sleep(int ms) = 0;

	static FactoryManager<TimingService> factoryManager;

	static std::string name() {
		return "TimingService";
	}

};

/**
 * @ingroup Manufacturing
 * @ingroup SPI
 */
template <>
class AbstractFactory<TimingService> {

public:

	virtual ~AbstractFactory<TimingService>() {}

	virtual TimingService *create() = 0;

};

/**
 * @}
 */

}

#endif // AVOCADO_TIMINGSERVICE_H
