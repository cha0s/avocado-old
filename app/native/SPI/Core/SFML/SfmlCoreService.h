#ifndef AVOCADO_SFMLCORESERVICE_H
#define AVOCADO_SFMLCORESERVICE_H

#include "avocado-global.h"

#include "../CoreService.h"

namespace avo {

/**
 * @addtogroup Core
 * @{
 */

/**
 * @ingroup SFML
 * @{
 */

/**
 * @ingroup SPI
 * @{
 */

/**
 * The %SfmlCoreService SPI implementation handles initialization and quitting
 * SFML library.
 */
class SfmlCoreService : public CoreService {

public:

	/**
	 * Initialize SFML.
	 */
	SfmlCoreService();

	~SfmlCoreService();

	/**
	 * Quit SFML.
	 */
	void close();

	static AbstractFactory<SfmlCoreService> *factory;

};

/**
 * @ingroup Manufacturing
 * @ingroup SFML
 * @ingroup SPI
 */
template <>
class AbstractFactory<SfmlCoreService> : public AbstractFactory<CoreService> {

public:

	virtual ~AbstractFactory<SfmlCoreService>() {}

	/**
	 * Create a concrete CoreService.
	 */
	SfmlCoreService *create() { return new SfmlCoreService() ; }

};

/**
 * @}
 */

/**
 * @}
 */

}

#endif // AVOCADO_SFMLCORESERVICE_H
