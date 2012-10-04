#ifndef AVOCADO_SOUNDSYSTEM_H
#define AVOCADO_SOUNDSYSTEM_H

#include "avocado-global.h"

#include "Factory.h"

namespace avo {

/**
 * @addtogroup Sound
 * @{
 */

/**
 * %SoundService handles initialization and teardown of the sound
 * framework. Each concrete SPI implementation (SPII) also manages SPIIs
 * for Music and Sample.
 *
 * @ingroup SPI
 */
class SoundService {

public:

	SoundService();
	virtual ~SoundService();

	/**
	 * Close out the service.
	 */
	virtual void close();

	static FactoryManager<SoundService> factoryManager;

	static std::string name() {
		return "SoundService";
	}

};

/**
 * @ingroup Manufacturing
 * @ingroup SPI
 */
template <>
class AbstractFactory<SoundService> {

public:

	virtual ~AbstractFactory<SoundService>() {}

	virtual SoundService *create() = 0;

};

/**
 * @}
 */

}

#endif // AVOCADO_SOUNDSYSTEM_H
