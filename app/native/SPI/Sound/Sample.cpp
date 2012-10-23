#include "avocado-global.h"

#include "Sample.h"

namespace avo {

ResourceManager<Sample> Sample::manager;
FactoryManager<Sample> Sample::factoryManager;

Sample::Sample()
{
}

Sample::~Sample() {
}

void Sample::setUri(const boost::filesystem::path &uri) {
	m_uri = uri;
}

boost::filesystem::path Sample::uri() const {
	return m_uri;
}

unsigned int Sample::sizeInBytes() {
	return 1024 * 200;
}

}
