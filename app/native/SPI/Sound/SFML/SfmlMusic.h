#ifndef AVOCADO_SFMLMUSIC_H
#define AVOCADO_SFMLMUSIC_H

#include "avocado-global.h"

#include <SFML/Audio.hpp>

#include "../Music.h"

namespace avo {

/**
 * @addtogroup Sound
 * @{
 */

class SfmlMusic;

/**
 * @ingroup Resources
 * @ingroup SFML
 */
class SfmlMusic : public Music {

public:

	/**
	 * Create an empty music resource.
	 */
	SfmlMusic();

	/**
	 * Load Mix_Music from a URI.
	 */
	SfmlMusic(const boost::filesystem::path &uri);

	/**
	 * Release Mix_Music.
	 */
	~SfmlMusic();

	void fadeIn(int loops = LoopForever, int ms = 3000, int position = 0);

	void fadeOut(int ms = 3000);

	int isPlaying();

	int play(int loops = LoopForever);

	void setVolume(int volume);

	void stop();

	int volume();

	static AbstractFactory<SfmlMusic> *factory;

private:

	sf::Music *music;

};

/**
 * @ingroup Manufacturing
 * @ingroup Resources
 * @ingroup SFML
 * @ingroup SPI
 */
template <>
class AbstractFactory<SfmlMusic> : public AbstractFactory<Music> {

public:

	virtual ~AbstractFactory<SfmlMusic>() {}

	SfmlMusic *create() { return new SfmlMusic(); }
	SfmlMusic *create(const boost::filesystem::path &uri) { return new SfmlMusic(uri); }

};

/**
 * @}
 */

}

#endif // AVOCADO_SFMLMUSIC_H
