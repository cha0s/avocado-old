#include "../../../avocado-global.h"

#include <boost/extension/extension.hpp>

#include "SfmlSoundService.h"

/**
 * @addtogroup SPI
 * @{
 */

extern "C"
void BOOST_EXTENSION_EXPORT_DECL
implementSpi(avo::FactoryManager<AVOCADO_SPI(Sound, Sfml)> &manager) {

	manager.setInstance(avo::SfmlSoundService::factory);
}

/**
 * @}
 */
