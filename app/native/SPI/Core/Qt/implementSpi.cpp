#include "../../../avocado-global.h"

#include <boost/extension/extension.hpp>

#include "QtCoreService.h"

/**
 * @addtogroup SPI
 * @{
 */

extern "C"
void BOOST_EXTENSION_EXPORT_DECL
implementSpi(avo::FactoryManager<AVOCADO_SPI(Core, Qt)> &manager) {

	manager.setInstance(avo::QtCoreService::factory);
}

/**
 * @}
 */
