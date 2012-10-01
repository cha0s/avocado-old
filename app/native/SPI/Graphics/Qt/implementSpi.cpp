#include "../../../avocado-global.h"

#include <boost/extension/extension.hpp>

#include "QtGraphicsService.h"

/**
 * @addtogroup SPI
 * @{
 */

extern "C"
void BOOST_EXTENSION_EXPORT_DECL
implementSpi(avo::FactoryManager<AVOCADO_SPI(Graphics, Qt)> &manager) {

	manager.setInstance(avo::QtGraphicsService::factory);
}

/**
 * @}
 */
