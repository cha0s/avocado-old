#include "../../../avocado-global.h"

#include <boost/extension/extension.hpp>

#include "SfmlUiService.h"

/**
 * @addtogroup SPI
 * @{
 */

extern "C"
void BOOST_EXTENSION_EXPORT_DECL
implementSpi(avo::FactoryManager<AVOCADO_SPI(Ui, Sfml)> &manager) {

	manager.setInstance(avo::SfmlUiService::factory);
}

/**
 * @}
 */
