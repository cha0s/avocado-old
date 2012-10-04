#ifndef AVOCADO_SFMLSSAMPLE_H
#define AVOCADO_SFMLSSAMPLE_H

#include "avocado-global.h"

#include <SFML/Audio.hpp>

#include "../Sample.h"

namespace avo {

/**
 * @addtogroup Sound
 * @{
 */

class SfmlSample;

/**
 * @ingroup Resources
 * @ingroup SFML
 */
class SfmlSample : public Sample {

public:

	SfmlSample();
	SfmlSample(const SfmlSample &counter);
	SfmlSample(const Sample &counter);

	/**
	 * Load a Mix_Chunk from a resource location.
	 */
	SfmlSample(const boost::filesystem::path &uri);

	/**
	 * Release a Mix_Chunk
	 */
	~SfmlSample();

	int play(int loops = 0);

	static AbstractFactory<SfmlSample> *factory;

private:

	sf::Sound *sound;

};

/**
 * @ingroup Manufacturing
 * @ingroup Resources
 * @ingroup SFML
 * @ingroup SPI
 */
template <>
class AbstractFactory<SfmlSample> : public AbstractFactory<Sample> {

public:

	virtual ~AbstractFactory<SfmlSample>() {}

	Sample *create() { return new SfmlSample(); }
	Sample *create(const boost::filesystem::path &uri) { return new SfmlSample(uri); }

};

/**
 * @}
 */

}

#endif // AVOCADO_SFMLSSAMPLE_H
