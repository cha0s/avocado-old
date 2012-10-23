#include "Font.h"

namespace avo {

ResourceManager<Font> Font::manager;
FactoryManager<Font> Font::factoryManager;

Font::Font()
{
}

void Font::setUri(const boost::filesystem::path &uri) {
	m_uri = uri;
}

boost::filesystem::path Font::uri() const {
	return m_uri;
}

int Font::sizeInBytes() {
	return 4 * 1024 * 1024;
}

}
