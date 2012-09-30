#include "../../../avocado-global.h"

#include <boost/extension/extension.hpp>

#include "v8ScriptSystem.h"

/**
 * @addtogroup SPI
 * @{
 */

extern "C"
void BOOST_EXTENSION_EXPORT_DECL
implementSpi(avo::FactoryManager<avo::ScriptSystem> &manager) {

	manager.setInstance(avo::v8ScriptSystem::factory);
}

/**
 * @}
 */
