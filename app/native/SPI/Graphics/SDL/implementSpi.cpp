#include "../../../avocado-global.h"

#include <boost/extension/extension.hpp>

#include "SdlGraphicsService.h"

/**
 * @addtogroup SPI
 * @{
 */

extern "C"
void BOOST_EXTENSION_EXPORT_DECL
implementSpi(avo::FactoryManager<avo::GraphicsService> &manager) {

	manager.setInstance(avo::SdlGraphicsService::factory);
}

/**
 * @}
 */
