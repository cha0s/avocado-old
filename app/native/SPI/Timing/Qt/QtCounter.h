#ifndef AVOCADO_QTCOUNTER_H
#define AVOCADO_QTCOUNTER_H

#include "avocado-global.h"

#include <QtCore/QTime>

#include "../Counter.h"

namespace avo {

/**
 * @addtogroup Timing
 * @{
 */

/**
 * Counter class to count time passing between invocations.
 *
 * @ingroup Qt
 * @ingroup SPI
 */
class QtCounter : public Counter {

public:

	/**
	 * Counter constructor. Initialize the current ticks.
	 */
	QtCounter();

	~QtCounter();

	double current();

	static AbstractFactory<QtCounter> *factory;

private:

	QTime time;

};

/**
 * @ingroup Manufacturing
 * @ingroup Qt
 * @ingroup SPI
 */
template<>
class AbstractFactory<QtCounter> : public AbstractFactory<Counter> {

public:

	QtCounter *create() { return new QtCounter(); };

};

/**
 * @}
 */

}

#endif // AVOCADO_QTCOUNTER_H
