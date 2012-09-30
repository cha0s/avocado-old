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
 * @ingroup @SDL
 */
class SdlCoreService : public CoreService {

public:

	SdlCoreService();
	~SdlCoreService();

	/**
	 * Quit SDL.
	 */
	void close();

	static AbstractFactory<SdlCoreService> *factory;

};

/**
 * @ingroup Resources
 */
template <>
class AbstractFactory<SdlCoreService> : public AbstractFactory<CoreService> {

public:

	virtual ~AbstractFactory<SdlCoreService>() {}

	SdlCoreService *create() { return new SdlCoreService() ; }

};

/**
 * @}
 */

}

#endif // AVOCADO_SDLCORESERVICE_H
