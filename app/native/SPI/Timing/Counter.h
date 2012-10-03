#ifndef AVOCADO_COUNTER_H
#define AVOCADO_COUNTER_H

#include "avocado-global.h"

#include "Factory.h"

namespace avo {

/**
 * @addtogroup Timing
 * @{
 */

/**
 * Counter class to count time passing between invocations.
 *
 * @ingroup SPI
 */
class Counter {

public:

	Counter();
	virtual ~Counter() {}

	/**
	 * The current time measurement.
	 */
	virtual double current() = 0;

	/**
	 * Request the time delta in milliseconds since last invocation.
	 */
	double since();

	static FactoryManager<Counter> factoryManager;

protected:

	void setCurrent(double current);

private:

	double m_current;

};

/**
 * @ingroup Manufacturing
 * @ingroup SPI
 */
template<>
class AbstractFactory<Counter> {

public:

	virtual ~AbstractFactory<Counter>() {}

	virtual Counter *create() = 0;

};

/**
 * @}
 */

}

#endif // AVOCADO_COUNTER_H
