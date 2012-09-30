#include "../../../avocado-global.h"

#include <boost/extension/extension.hpp>

#include "v8ScriptService.h"

/**
 * @addtogroup SPI
 * @{
 */

extern "C"
void BOOST_EXTENSION_EXPORT_DECL
implementSpi(avo::FactoryManager<avo::ScriptService> &manager) {

	manager.setInstance(avo::v8ScriptService::factory);
}

/**
 * @}
 */
