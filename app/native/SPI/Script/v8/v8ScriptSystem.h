#ifndef AVOCADO_V8SCRIPTSYSTEM_H
#define AVOCADO_V8SCRIPTSYSTEM_H

#include "avocado-global.h"

#include "avocado-v8.h"

#include "../ScriptSystem.h"

namespace avo {

/**
 * @addtogroup Script
 * @{
 */

/**
 * %v8ScriptSystem implements the
 * [V8 JavaScript engine](http://code.google.com/p/v8/) by providing a bridge
 * between the C++ SPIs and engine code.
 */
class v8ScriptSystem : public ScriptSystem {

public:

	v8ScriptSystem();
	~v8ScriptSystem();

	/** SPI embedding. */
	void initialize();

	/**
	 * Precompile the passed in code, inferring any precompiler from the
	 * extension of the filename passed in, if any.
	 */
	std::string preCompileCode(const std::string &code, const boost::filesystem::path &filename = "<anonymous>");

	/**
	 * Compile a string of code, setting the filename, if any.
	 */
	Script *scriptFromCode(const std::string &code, const boost::filesystem::path &filename = "<anonymous>");

	/**
	 * Concrete ScriptSystem factory instance.
	 */
	static AbstractFactory<v8ScriptSystem> *factory;

private:

	v8::Persistent<v8::Context> context;

};

/**
 * @ingroup Manufacturing
 */

template <>
class AbstractFactory<v8ScriptSystem> : public AbstractFactory<ScriptSystem> {

public:

	virtual ~AbstractFactory<v8ScriptSystem>() {}

	/**
	 * Create a concrete ScriptSystem.
	 */
	v8ScriptSystem *create() {
		return new v8ScriptSystem();
	}

};

/**
 * @}
 */

/**
 * @}
 */

}

#endif // AVOCADO_V8SCRIPTSYSTEM_H
