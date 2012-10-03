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

}

