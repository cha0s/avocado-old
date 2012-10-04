#ifndef AVOCADO_SFMLSOUNDSERVICE_H
#define AVOCADO_SFMLSOUNDSERVICE_H

#include "avocado-global.h"

#include "../SoundService.h"

namespace avo {

/**
 * @addtogroup Sound
 * @{
 */

/**
 * @ingroup SFML
 * @ingroup SPI
 */
class SfmlSoundService : public SoundService {

public:

	SfmlSoundService();
	~SfmlSoundService();

	void close();

	static AbstractFactory<SfmlSoundService> *factory;

};

/**
 * @ingroup Manufacturing
 * @ingroup SFML
 * @ingroup SPI
 */
template <>
class AbstractFactory<SfmlSoundService> : public AbstractFactory<SoundService> {

public:

	virtual ~AbstractFactory<SfmlSoundService>() {}

	SfmlSoundService *create() { return new SfmlSoundService(); }

};

/**
 * @}
 */

}

#endif // AVOCADO_SFMLSOUNDSERVICE_H
