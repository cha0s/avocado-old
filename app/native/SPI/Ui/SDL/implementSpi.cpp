#include "../../../avocado-global.h"

#include <boost/extension/extension.hpp>

#include "SdlUiService.h"

/**
 * @addtogroup SPI
 * @{
 */

extern "C"
void BOOST_EXTENSION_EXPORT_DECL
implementSpi(avo::FactoryManager<AVOCADO_SPI(Ui, Sdl)> &manager) {

	manager.setInstance(avo::SdlUiService::factory);
}

/**
 * @}
 */
