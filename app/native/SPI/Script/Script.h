#ifndef AVOCADO_SCRIPT_H
#define AVOCADO_SCRIPT_H

#include "avocado-global.h"

#include <boost/filesystem.hpp>

#include "Factory.h"

namespace avo {

/**
 * @addtogroup Script
 * @{
 */

/**
 * A %Script is an executable script. Scripts can be instantiated by filename
 * or a string containing code.
 */
class Script {

public:

	/**
	 * @brief Thrown when executing a script fails.
	 */
	class script_execution_error : public std::runtime_error {

	public:

		script_execution_error(const std::string &text)
			: std::runtime_error("Executing script failed: " + text)
		{
		}

	};

	Script();
	virtual ~Script();

	/**
	 * Execute a compiled script.
	 */
	virtual void execute() = 0;

	/**
	 * Manages the concrete Script factory instance.
	 */
	static FactoryManager<Script> factoryManager;

};

/**
 * @ingroup Manufacturing
 */

template <>
class AbstractFactory<Script> {

public:

	virtual ~AbstractFactory<Script>() {}

	/**
	 * Reimplemented as non-virtual by concrete Script factories.
	 */
	virtual Script *create() = 0;
};

/**
 * @}
 */

/**
 * @}
 */

}

#endif // AVOCADO_SCRIPT_H
