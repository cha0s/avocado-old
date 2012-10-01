#include "../../../avocado-global.h"

#include <boost/extension/extension.hpp>

#include "QtTimingService.h"

/**
 * @addtogroup SPI
 * @{
 */

extern "C"
void BOOST_EXTENSION_EXPORT_DECL
implementSpi(avo::FactoryManager<AVOCADO_SPI(Timing, Qt)> &manager) {

	manager.setInstance(avo::QtTimingService::factory);
}

/**
 * @}
 */
