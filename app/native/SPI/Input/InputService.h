#ifndef AVOCADO_INPUTSERVICE_H
#define AVOCADO_INPUTSERVICE_H

#include "avocado-global.h"

#include "Factory.h"

namespace avo {

/**
 * @addtogroup Input
 * @{
 */

/**
 * The %InputService SPI handles input framework initialization as well as
 * the SPII for Input.
 */
class InputService {

public:

	InputService();
	virtual ~InputService();

	virtual void close() { }

	static FactoryManager<InputService> factoryManager;

	static std::string name() {
		return "InputService";
	}

};

/**
 * @ingroup Manufacturing
 * @ingroup SPI
 */
template <>
class AbstractFactory<InputService> {

public:

	virtual ~AbstractFactory<InputService>() {}

	virtual InputService *create() = 0;

};

/**
 * @}
 */

}

#endif // AVOCADO_INPUTSERVICE_H
