#include "../../../avocado-global.h"

#include <boost/extension/extension.hpp>

#include "SfmlGraphicsService.h"

/**
 * @addtogroup SPI
 * @{
 */

extern "C"
void BOOST_EXTENSION_EXPORT_DECL
implementSpi(avo::FactoryManager<AVOCADO_SPI(Graphics, Sfml)> &manager) {

	manager.setInstance(avo::SfmlGraphicsService::factory);
}

/**
 * @}
 */
