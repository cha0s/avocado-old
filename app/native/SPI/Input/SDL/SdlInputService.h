#ifndef AVOCADO_SDLINPUTSERVICE_H
#define AVOCADO_SDLINPUTSERVICE_H

#include "avocado-global.h"

#include "../InputService.h"

namespace avo {

/**
 * @addtogroup Input
 * @{
 */

/**
 * The %SdlInputService SPI implementation uses vanilla SDL to gather keyboard,
 * joystick and window events.
 *
 * @ingroup SDL
 */
class SdlInputService : public InputService {

public:

	SdlInputService();
	~SdlInputService();

	void close();

	static AbstractFactory<SdlInputService> *factory;

};

/**
 * @ingroup Manufacturing
 * @ingroup SDL
 * @ingroup SPI
 */
template <>
class AbstractFactory<SdlInputService> : public AbstractFactory<InputService> {

public:

	virtual ~AbstractFactory<SdlInputService>() {}

	SdlInputService *create() { return new SdlInputService(); }

};

/**
 * @}
 */

}

#endif // AVOCADO_SDLINPUTSERVICE_H
