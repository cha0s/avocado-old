#include "../../../avocado-global.h"

#include <boost/extension/extension.hpp>

#include "SdlCoreService.h"

/**
 * @addtogroup SPI
 * @{
 */

extern "C"
void BOOST_EXTENSION_EXPORT_DECL
implementSpi(avo::FactoryManager<avo::CoreService> &manager) {

	manager.setInstance(avo::SdlCoreService::factory);
}

/**
 * @}
 */
