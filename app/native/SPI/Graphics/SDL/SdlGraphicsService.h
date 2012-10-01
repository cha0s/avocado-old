#ifndef AVOCADO_SDLGRAPHICSSERVICE_H
#define AVOCADO_SDLGRAPHICSSERVICE_H

#include "avocado-global.h"

#include "../GraphicsService.h"

namespace avo {

/**
 * @addtogroup Graphics
 * @{
 */

/**
 * @ingroup @SDL
 */
class SdlGraphicsService : public GraphicsService {

public:

	SdlGraphicsService();
	~SdlGraphicsService();

	static AbstractFactory<SdlGraphicsService> *factory;

};

/**
 * @ingroup Resources
 */
template <>
class AbstractFactory<SdlGraphicsService> : public AbstractFactory<GraphicsService> {

public:

	virtual ~AbstractFactory<SdlGraphicsService>() {}

	/**
	 * Create a concrete GraphicsService.
	 */
	SdlGraphicsService *create() { return new SdlGraphicsService(); }

};

/**
 * @}
 */

}

#endif // AVOCADO_SDLGRAPHICSSERVICE_H
