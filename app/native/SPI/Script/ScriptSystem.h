#ifndef AVOCADO_SCRIPTSYSTEM_H
#define AVOCADO_SCRIPTSYSTEM_H

#include "avocado-global.h"

#include <string>
#include <vector>

#include "Factory.h"
#include "Script.h"

namespace avo {

/**
 * @addtogroup Script
 * @{
 */

/**
 * A %ScriptSystem is an embedded scripting engine e.g.
 * [V8](http://code.google.com/p/v8/).
 *
 * Bindings to C++ symbols are
 * initialized, and core engine scripts are discovered and loaded.
 */
class ScriptSystem {

public:

	/**
	 * @brief Thrown when script precompilation fails.
	 */
	class script_precompilation_error : public std::runtime_error {

	public:

		script_precompilation_error(const std::string &text)
			: std::runtime_error("Script precompilation failed: " + text)
		{
		}

	};

	/**
	 * @brief Thrown when script compilation fails.
	 */
	class script_compilation_error : public std::runtime_error {

	public:

		script_compilation_error(const std::string &text)
			: std::runtime_error("Script compilation failed: " + text)
		{
		}

	};

	ScriptSystem();
	virtual ~ScriptSystem();

	/**
	 * Initialize service provider interfaces as well as compilers.
	 */
	virtual void initialize();

	/**
	 * Load the engine core.
	 *
	 * @return
	 *   A vector of strings; the filenames in order of loading.
	 */
	std::vector<std::string> loadCore();

	/**
	 * Precompile the passed in code, inferring any precompiler from the
	 * extension of the filename passed in, if any.
	 */
	virtual std::string preCompileCode(const std::string &code, const boost::filesystem::path &filename = "<anonymous>") = 0;

	/**
	 * Compile a string of code, setting the filename, if any.
	 */
	virtual Script *scriptFromCode(const std::string &code, const boost::filesystem::path &filename = "<anonymous>") = 0;

	/**
	 * Compile a file.
	 */
	Script *scriptFromFile(const boost::filesystem::path &filename);

	/**
	 * Manages the concrete ScriptSystem factory instance.
	 */
	static FactoryManager<ScriptSystem> factoryManager;

};

/**
 * @ingroup Manufacturing
 */

template <>
class AbstractFactory<ScriptSystem> {

public:

	virtual ~AbstractFactory<ScriptSystem>() {}

	/**
	 * Reimplemented as non-virtual by concrete ScriptSystem factories.
	 */
	virtual ScriptSystem *create() = 0;

};

/**
 * @}
 */

/**
 * @}
 */

}

#endif // AVOCADO_SCRIPTSYSTEM_H
