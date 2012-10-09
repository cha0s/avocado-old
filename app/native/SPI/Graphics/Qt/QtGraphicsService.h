#ifndef AVOCADO_QTGRAPHICSSERVICE_H
#define AVOCADO_QTGRAPHICSSERVICE_H

#include "avocado-global.h"

#include "../GraphicsService.h"

namespace avo {

/**
 * @addtogroup Graphics
 * @{
 */

/**
 * @ingroup @QT
 */
class QtGraphicsService : public GraphicsService {

public:

	QtGraphicsService();
	~QtGraphicsService();

	SpecialKeyCodes specialKeyCodes();

	static AbstractFactory<QtGraphicsService> *factory;

};

/**
 * @ingroup Manufacturing
 * @ingroup Qt
 * @ingroup SPI
 */
template <>
class AbstractFactory<QtGraphicsService> : public AbstractFactory<GraphicsService> {

public:

	virtual ~AbstractFactory<QtGraphicsService>() {}

	/**
	 * Create a concrete GraphicsService.
	 */
	QtGraphicsService *create() { return new QtGraphicsService(); }

};

/**
 * @}
 */

}

#endif // AVOCADO_QTGRAPHICSSERVICE_H
