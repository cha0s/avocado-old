#ifndef AVOCADO_INPUTSERVICE_H
#define AVOCADO_INPUTSERVICE_H

#include "avocado-global.h"

#include "Factory.h"

namespace avo {

/**
 * @addtogroup Ui
 * @{
 */

/**
 * The %UiService SPI handles UI framework initialization as well as
 * the SPII for Window.
 */
class UiService {

public:

	UiService();
	virtual ~UiService();

	/** Standardize special key codes. */
	struct SpecialKeyCodes {
		int UpArrow;
		int RightArrow;
		int DownArrow;
		int LeftArrow;
	};

	/**
	 * Standardized special keys.
	 */
	virtual SpecialKeyCodes specialKeyCodes() = 0;

	/**
	 * Close out the service.
	 */
	virtual void close();

	static FactoryManager<UiService> factoryManager;

	static std::string name() {
		return "UiService";
	}

};

/**
 * @ingroup Manufacturing
 * @ingroup SPI
 */
template <>
class AbstractFactory<UiService> {

public:

	virtual ~AbstractFactory<UiService>() {}

	virtual UiService *create() = 0;

};

/**
 * @}
 */

}

#endif // AVOCADO_INPUTSERVICE_H
