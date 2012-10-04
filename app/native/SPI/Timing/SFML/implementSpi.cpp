#include "../../../avocado-global.h"

#include <boost/extension/extension.hpp>

#include "SfmlTimingService.h"

/**
 * @addtogroup SPI
 * @{
 */

extern "C"
void BOOST_EXTENSION_EXPORT_DECL
implementSpi(avo::FactoryManager<AVOCADO_SPI(Timing, Sfml)> &manager) {

	manager.setInstance(avo::SfmlTimingService::factory);
}

/**
 * @}
 */
