#ifndef AVOCADO_SFMLINPUTSERVICE_H
#define AVOCADO_SFMLINPUTSERVICE_H

#include "avocado-global.h"

#include "../UiService.h"

namespace avo {

/**
 * @addtogroup Ui
 * @{
 */

/**
 * The %SfmlUiService SPI implementation uses vanilla SFML to gather keyboard,
 * joystick and window events.
 *
 * @ingroup SFML
 */
class SfmlUiService : public UiService {

public:

	SfmlUiService();
	~SfmlUiService();

	void close();

	SpecialKeyCodes specialKeyCodes();

	static AbstractFactory<SfmlUiService> *factory;
};

/**
 * @ingroup Manufacturing
 * @ingroup SFML
 * @ingroup SPI
 */
template <>
class AbstractFactory<SfmlUiService> : public AbstractFactory<UiService> {

public:

	virtual ~AbstractFactory<SfmlUiService>() {}

	SfmlUiService *create() { return new SfmlUiService(); }

};

/**
 * @}
 */

}

#endif // AVOCADO_SFMLINPUTSERVICE_H
