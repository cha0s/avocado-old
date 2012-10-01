#include "../../../avocado-global.h"

#include <boost/extension/extension.hpp>

#include "SdlInputService.h"

/**
 * @addtogroup SPI
 * @{
 */

extern "C"
void BOOST_EXTENSION_EXPORT_DECL
implementSpi(avo::FactoryManager<AVOCADO_SPI(Input, Sdl)> &manager) {

	manager.setInstance(avo::SdlInputService::factory);
}

/**
 * @}
 */
