#ifndef AVOCADO_QTTIMINGSERVICE_H
#define AVOCADO_QTTIMINGSERVICE_H

#include "avocado-global.h"

#include "../TimingService.h"

namespace avo {

/**
 * @addtogroup Timing
 * @{
 */

/**
 * @ingroup @QT
 * @ingroup SPI
 */
class QtTimingService : public TimingService {

public:

	QtTimingService();
	~QtTimingService();

	void sleep(int ms);

	static AbstractFactory<QtTimingService> *factory;

};

/**
 * @ingroup Manufacturing
 * @ingroup Qt
 * @ingroup SPI
 */
template <>
class AbstractFactory<QtTimingService> : public AbstractFactory<TimingService> {

public:

	virtual ~AbstractFactory<QtTimingService>() {}

	QtTimingService *create() { return new QtTimingService(); }

};

/**
 * @}
 */

}

#endif // AVOCADO_QTTIMINGSERVICE_H
