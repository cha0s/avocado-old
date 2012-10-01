#ifndef AVOCADO_QTCORESERVICE_H
#define AVOCADO_QTCORESERVICE_H

#include "avocado-global.h"

#include "../CoreService.h"

namespace avo {

/**
 * @addtogroup Core
 * @{
 */

/**
 * @ingroup Qt
 * @{
 */

/**
 * @ingroup SPI
 * @{
 */

/**
 * The %QtCoreService SPI implementation doesn't actually do anything at this
 * time.
 */
class QtCoreService : public CoreService {

public:

	static AbstractFactory<QtCoreService> *factory;

};

/**
 * @ingroup Manufacturing
 * @ingroup Qt
 * @ingroup SPI
 */
template <>
class AbstractFactory<QtCoreService> : public AbstractFactory<CoreService> {

public:

	virtual ~AbstractFactory<QtCoreService>() {}

	/**
	 * Create a concrete CoreService.
	 */
	QtCoreService *create() { return new QtCoreService() ; }

};

/**
 * @}
 */

/**
 * @}
 */

}

#endif // AVOCADO_QTCORESERVICE_H
