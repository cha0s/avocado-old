#ifndef AVOCADO_SDLINPUTSERVICE_H
#define AVOCADO_SDLINPUTSERVICE_H

#include "avocado-global.h"

#include "../UiService.h"

namespace avo {

/**
 * @addtogroup Ui
 * @{
 */

/**
 * The %SdlUiService SPI implementation uses vanilla SDL to gather keyboard,
 * joystick and window events.
 *
 * @ingroup SDL
 */
class SdlUiService : public UiService {

public:

	SdlUiService();
	~SdlUiService();

	void close();

	static AbstractFactory<SdlUiService> *factory;

};

/**
 * @ingroup Manufacturing
 * @ingroup SDL
 * @ingroup SPI
 */
template <>
class AbstractFactory<SdlUiService> : public AbstractFactory<UiService> {

public:

	virtual ~AbstractFactory<SdlUiService>() {}

	SdlUiService *create() { return new SdlUiService(); }

};

/**
 * @}
 */

}

#endif // AVOCADO_SDLINPUTSERVICE_H
