#include "Font.h"

namespace avo {

ResourceManager<Font> Font::manager;
FactoryManager<Font> Font::factoryManager;

Font::Font()
{
}

int Font::sizeInBytes() {
	return 4 * 1024 * 1024;
}

}
