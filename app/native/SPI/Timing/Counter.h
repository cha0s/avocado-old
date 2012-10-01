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

	Counter(const Counter &counter);
	virtual Counter &operator =(const Counter &counter) = 0;

	double m_current;

};

/**
 * @ingroup Resources
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
