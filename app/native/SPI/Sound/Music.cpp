#include "avocado-global.h"

#include "Music.h"

namespace avo {

ResourceManager<Music> Music::manager;
FactoryManager<Music> Music::factoryManager;

Music::Music()
{
}

Music::~Music() {
}

void Music::setUri(const boost::filesystem::path &uri) {
	m_uri = uri;
}

boost::filesystem::path Music::uri() const {
	return m_uri;
}

unsigned int Music::sizeInBytes() {
	return 1024 * 1024 * 4;
}

}
