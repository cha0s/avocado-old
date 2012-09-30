#ifndef AVOCADO_SDLCORESERVICE_H
#define AVOCADO_SDLCORESERVICE_H

#include "avocado-global.h"

#include "../CoreService.h"

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
 * @ingroup @SDL
 */

/**
 * The %SdlCoreService SPI implementation handles initialization and quitting
 * SDL library.
 */
class SdlCoreService : public CoreService {

public:

	/**
	 * Initialize SDL.
	 */
	SdlCoreService();

	~SdlCoreService();

	/**
	 * Quit SDL.
	 */
	void close();

	static AbstractFactory<SdlCoreService> *factory;

};

/**
 * @ingroup Manufacturing
 */
template <>
class AbstractFactory<SdlCoreService> : public AbstractFactory<CoreService> {

public:

	virtual ~AbstractFactory<SdlCoreService>() {}

	/**
	 * Create a concrete CoreService.
	 */
	SdlCoreService *create() { return new SdlCoreService() ; }

};

/**
 * @}
 */

/**
 * @}
 */

/**
 * @}
 */

}

#endif // AVOCADO_SDLCORESERVICE_H
