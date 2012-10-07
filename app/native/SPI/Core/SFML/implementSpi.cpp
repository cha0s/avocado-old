#include "../../../avocado-global.h"

#include <boost/extension/extension.hpp>

#include "SfmlCoreService.h"

/**
 * @addtogroup SPI
 * @{
 */

extern "C"
void BOOST_EXTENSION_EXPORT_DECL
implementSpi(avo::FactoryManager<AVOCADO_SPI(Core, Sfml)> &manager) {

	manager.setInstance(avo::SfmlCoreService::factory);
}

/**
 * @}
 */
