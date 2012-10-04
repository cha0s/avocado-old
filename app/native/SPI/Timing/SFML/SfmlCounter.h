#ifndef AVOCADO_SFMLCOUNTER_H
#define AVOCADO_SFMLCOUNTER_H

#include "avocado-global.h"

#include <SFML/System/Clock.hpp>

#include "../Counter.h"

namespace avo {

/**
 * @addtogroup Timing
 * @{
 */

/**
 * Counter class to count time passing between invocations.
 *
 * @ingroup SFML
 * @ingroup SPI
 */
class SfmlCounter : public Counter {

public:

	/**
	 * Counter constructor. Initialize the current ticks.
	 */
	SfmlCounter();

	~SfmlCounter();

	static AbstractFactory<SfmlCounter> *factory;

	double current();

private:

	sf::Clock *clock;

};

/**
 * @ingroup Manufacturing
 * @ingroup SFML
 * @ingroup SPI
 */
template<>
class AbstractFactory<SfmlCounter> : public AbstractFactory<Counter> {

public:

	virtual ~AbstractFactory<SfmlCounter>() {}

	SfmlCounter *create() { return new SfmlCounter(); };

};

/**
 * @}
 */

}

#endif // AVOCADO_SFMLCOUNTER_H
