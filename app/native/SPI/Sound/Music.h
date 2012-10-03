#ifndef AVOCADO_MUSIC_H
#define AVOCADO_MUSIC_H

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
 * %Music class.
 *
 * @ingroup Resources
 */
class Music {

public:

	enum MusicProperties {

		/** %Sound should loop forever. */
		LoopForever = -1

		/** Any free channel is suitable for playing. */
		, AnyChannel = -1
	};

	/**
	 * Create an empty music resource.
	 */
	Music();

	/**
	 * Load music from a resource location.
	 */
	Music(const boost::filesystem::path &uri);

	/**
	 * Release a music resource.
	 */
	virtual ~Music();

	/**
	 * Play music, looping the specified number of time, fading it in for the
	 * specified number of milliseconds, starting at the specified position.
	 */
	virtual void fadeIn(int loops = LoopForever, int ms = 3000, int position = 0) = 0;

	/**
	 * Stop music, fading it out for the specified number of milliseconds.
	 */
	virtual void fadeOut(int ms = 3000) =0;

	/**
	 * Play music for the specified number of loops.
	 */
	virtual int play(int loops = LoopForever) = 0;

	/**
	 * Query whether there is music currently playing.
	 */
	virtual int isPlaying() = 0;

	/**
	 * Get the current music volume.
	 */
	virtual int volume() = 0;

	/**
	 * Set the global music volume.
	 */
	virtual void setVolume(int volume) = 0;

	/**
	 * Stop music playing.
	 */
	virtual  void stop() = 0;

	/**
	 * Get the URI (if any) used to load this music.
	 */
	boost::filesystem::path uri() const;

	/**
	 * Heuristic guess as to how much memory this music is using in the system.
	 *
	 * Knowing how much memory a resource consumes is useful because we can
	 * notify any GC of scripting SPIIs using this object. That is, if we
	 * load a huge image and are using the V8 JavaScript engine, it's useful
	 * to inform V8 that the object holding the image represents a large
	 * amount of memory (since it can't infer this information itself: the
	 * objects are opaque). This way, it can release the object sooner to
	 * keep more memory free in the system.
	 *
	 * This calculation is extremely naive. 4MB
	 */
	virtual unsigned int sizeInBytes();

	/**
	 * Manages music resources.
	 */
	static ResourceManager<Music> manager;

	/**
	 * Manages the concrete %Music factory instance.
	 */
	static FactoryManager<Music> factoryManager;

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
class AbstractFactory<Music> {

public:

	virtual ~AbstractFactory<Music>() {}

	virtual Music *create() = 0;
	virtual Music *create(const boost::filesystem::path &uri) = 0;

};

/**
 * @}
 */

}

#endif // AVOCADO_MUSIC_H
