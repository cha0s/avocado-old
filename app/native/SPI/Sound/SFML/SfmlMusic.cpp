#include "avocado-global.h"

#include "SfmlMusic.h"

namespace avo {

AbstractFactory<SfmlMusic> *SfmlMusic::factory = new AbstractFactory<SfmlMusic>;

SfmlMusic::SfmlMusic()
	: music(NULL)
{
}

SfmlMusic::SfmlMusic(const boost::filesystem::path &uri)
	: music(new sf::Music())
{
	if (!music->openFromFile(uri.c_str())) {
		throw std::runtime_error(
			"sf::Music::openFromFile() failed!"
		);
	}

	setUri(uri);
}

SfmlMusic::~SfmlMusic() {
	if (music) delete music;
}

int SfmlMusic::play(int loops) {
	music->setLoop(loops > 0);

	music->play();

	return 0;
}

void SfmlMusic::fadeIn(int loops, int ms, int position) {
	AVOCADO_UNUSED(position);
	AVOCADO_UNUSED(ms);

	music->setLoop(loops > 0);

	music->play();
}

void SfmlMusic::fadeOut(int ms) {
	AVOCADO_UNUSED(ms);

	music->stop();
}

void SfmlMusic::setVolume(int volume) {
	music->setVolume(volume);
}

int SfmlMusic::volume() {
	return music->getVolume();
}

void SfmlMusic::stop() {
	music->stop();
}

int SfmlMusic::isPlaying() {
	return music->getSampleRate() == sf::Music::Playing;
}

}
