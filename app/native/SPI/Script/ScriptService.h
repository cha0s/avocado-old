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
 * @ingroup SPI
 * @{
 */

/**
 * @brief %ScriptService manages embedding a JavaScript interpreter within
 * the Avocado engine.
 *
 * %ScriptService handles SPII initialization for Script.
 *
 * This SPI allows for embedding C++ classes and objects within JavaScript,
 * handles discovery and compilation/execution of core engine scripts, and
 * manages the production of Script objects.
 *
 * Script objects can be instantiated from strings containing code, or
 * a filename which is loaded.
 *
 * %ScriptService also handles script precompilation (such as CoffeeScript ->
 * JavaScript), and exposes precompilation functionality for convenience.
 */
class ScriptService {

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
	class script_compilation_error : public std::exception {

	public:

		explicit script_compilation_error(const std::string &text, const std::string &precompiledCode = "");
		virtual ~script_compilation_error() throw() {}

		virtual const char *what() const throw();

	private:

		std::string m_what;

	};

	ScriptService();
	virtual ~ScriptService();

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
	 * Load the engine libraries. It's assumed these aren't under development
	 * and are guaranteed to compile and execute.
	 */
	void loadLibraries();

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
	 * Manages the concrete %ScriptService factory instance.
	 */
	static FactoryManager<ScriptService> factoryManager;

	static std::string name() {
		return "ScriptService";
	}

};

/**
 * @ingroup Manufacturing
 * @ingroup SPI
 */
template <>
class AbstractFactory<ScriptService> {

public:

	virtual ~AbstractFactory<ScriptService>() {}

	virtual ScriptService *create() = 0;

};

/**
 * @}
 */

/**
 * @}
 */

}

#endif // AVOCADO_SCRIPTSYSTEM_H
