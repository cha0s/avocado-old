#include "avocado-global.h"

#include "Image.h"

namespace avo {

ResourceManager<Image> Image::manager;
FactoryManager<Image> Image::factoryManager;

Image::Image()
{
}

bool Image::isNull() const {
	return width() != 0 && height() != 0;
}

void Image::setUri(const boost::filesystem::path &uri) {
	m_uri = uri;
}

boost::filesystem::path Image::uri() const {
	return m_uri;
}

}

