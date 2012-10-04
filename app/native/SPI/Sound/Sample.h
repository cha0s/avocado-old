#ifndef AVOCADO_SAMPLE_H
#define AVOCADO_SAMPLE_H

#include "avocado-global.h"

#include <string>

#include "Factory.h"
#include "../ResourceManager.h"

namespace avo {

/**
 * @addtogroup Sound
 * @{
 */

/**
 * %Sample representation for a sound effect.
 *
 * @ingroup Resources
 */
class Sample {

public:

	enum PlaybackProperties {

		/** %Sound should loop forever. */
		LoopForever = -1
	};

	Sample();

	/**
	 * Release a sample resource.
	 */
	virtual ~Sample();

	/**
	 * Play a sample, looping the specified number of times.
	 */
	virtual int play(int loops = 0) = 0;

	/**
	 * Get the URI (if any) used to load this sample.
	 */
	boost::filesystem::path uri() const;

	/**
	 * Heuristic guess as to how much memory this sample is using in the system.
	 *
	 * Knowing how much memory a resource consumes is useful because we can
	 * notify any GC of scripting SPIIs using this object. That is, if we
	 * load a huge image and are using the V8 JavaScript engine, it's useful
	 * to inform V8 that the object holding the image represents a large
	 * amount of memory (since it can't infer this information itself: the
	 * objects are opaque). This way, it can release the object sooner to
	 * keep more memory free in the system.
	 *
	 * This calculation is extremely naive. 200KB
	 */
	virtual unsigned int sizeInBytes();

	/**
	 * Manages sample resources.
	 */
	static ResourceManager<Sample> manager;

	/**
	 * Manages the concrete %Sample factory instance.
	 */
	static FactoryManager<Sample> factoryManager;

protected:

	void setUri(const boost::filesystem::path &uri);

private:

	boost::filesystem::path m_uri;

};

/**
 * @ingroup Manufacturing
 * @ingroup Resources
 * @ingroup SPI
 */
template <>
class AbstractFactory<Sample> {

public:

	virtual ~AbstractFactory<Sample>() {}

	virtual Sample *create() = 0;
	virtual Sample *create(const boost::filesystem::path &uri) = 0;

};

/**
 * @}
 */

}

#endif // AVOCADO_SAMPLE_H
