#ifndef AVOCADO_GRAPHICSSERVICE_H
#define AVOCADO_GRAPHICSSERVICE_H

#include "avocado-global.h"

#include "Factory.h"

namespace avo {

/**
 * @addtogroup Graphics
 * @{
 */

/**
 * %GraphicsService handles initialization and teardown of the graphics
 * framework. Each concrete SPI implementation (SPII) also manages SPIIs
 * for Window, Image, and other graphics-related SPIs.
 *
 * @ingroup SPI
 */
class GraphicsService {

public:

	/** Standardize special key codes. */
	struct SpecialKeyCodes {
		int UpArrow;
		int RightArrow;
		int DownArrow;
		int LeftArrow;
	};

	GraphicsService();
	virtual ~GraphicsService();

	/**
	 * Close out the service.
	 */
	virtual void close();

	/**
	 * Standardized special keys.
	 */
	virtual SpecialKeyCodes specialKeyCodes() = 0;

	/**
	 * Manages the concrete %GraphicsService factory instance.
	 */
	static FactoryManager<GraphicsService> factoryManager;

	static std::string name() {
		return "GraphicsService";
	}

};

/**
 * @ingroup Manufacturing
 * @ingroup SPI
 */
template <>
class AbstractFactory<GraphicsService> {

public:

	virtual ~AbstractFactory<GraphicsService>() {}

	virtual GraphicsService *create() = 0;

};

/**
 * @}
 */

}

#endif // AVOCADO_GRAPHICSSERVICE_H
