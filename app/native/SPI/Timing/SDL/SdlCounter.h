#ifndef AVOCADO_SDLCOUNTER_H
#define AVOCADO_SDLCOUNTER_H

#include "avocado-global.h"

#include <SDL/SDL.h>

#include "../Counter.h"

namespace avo {

/**
 * @addtogroup Timing
 * @{
 */

/**
 * Counter class to count time passing between invocations.
 *
 * @ingroup SDL
 * @ingroup SPI
 */
class SdlCounter : public Counter {

public:

	/**
	 * Counter constructor. Initialize the current ticks.
	 */
	SdlCounter();

	~SdlCounter();

	static AbstractFactory<SdlCounter> *factory;

	double current();

private:

	SdlCounter(const Counter &counter);
	Counter &operator =(const Counter &counter);

};

/**
 * @ingroup Resources
 * @ingroup SDL
 */
template<>
class AbstractFactory<SdlCounter> : public AbstractFactory<Counter> {

public:

	virtual ~AbstractFactory<SdlCounter>() {}

	SdlCounter *create() { return new SdlCounter(); };

};

/**
 * @}
 */

}

#endif // AVOCADO_SDLCOUNTER_H
