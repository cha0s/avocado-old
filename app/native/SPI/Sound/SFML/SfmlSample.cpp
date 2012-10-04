#include "avocado-global.h"

#include "SfmlSample.h"

namespace avo {

AbstractFactory<SfmlSample> *SfmlSample::factory = new AbstractFactory<SfmlSample>;

SfmlSample::SfmlSample()
	: sound(NULL)
{
}

SfmlSample::SfmlSample(const boost::filesystem::path &uri)
	: sound(new sf::Sound())
{

	sf::SoundBuffer *buffer = new sf::SoundBuffer();

	if (!buffer->loadFromFile(uri.c_str())) {

		throw std::runtime_error(
			"sf::SoundBuffer::loadFromFile() failed!"
		);
	}

	sound->setBuffer(*buffer);

	setUri(uri);
}

SfmlSample::~SfmlSample() {
	if (sound) delete sound;
}

int SfmlSample::play(int loops) {
	sound->setLoop(loops > 0);
	sound->play();

	return 0;
}

}
