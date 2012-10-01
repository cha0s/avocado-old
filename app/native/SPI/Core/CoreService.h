#ifndef AVOCADO_CORESERVICE_H
#define AVOCADO_CORESERVICE_H

#include "avocado-global.h"

#include <string>
#include <vector>

#include "Factory.h"

namespace avo {

/**
 * @addtogroup Core
 * @{
 */

/**
 * @ingroup SPI
 * @{
 */

/**
 * The %CoreService SPI handles core framework initialization as well as
 * general-purpose tools such as filesystem access.
 */
class CoreService {

public:

	virtual ~CoreService() { }

	/**
	 * Close out the service.
	 */
	virtual void close() { }

	/**
	 * Manages the concrete %CoreService factory instance.
	 */
	static FactoryManager<CoreService> factoryManager;

	static std::string name() {
		return "CoreService";
	}

};

/**
 * @ingroup Manufacturing
 */
template <>
class AbstractFactory<CoreService> {

public:

	virtual ~AbstractFactory<CoreService>() {}

	virtual CoreService *create() = 0;

};

/**
 * @}
 */

/**
 * @}
 */

}

#endif // AVOCADO_CORESERVICE_H
