#ifndef AVOCADO_V8SCRIPT_H
#define AVOCADO_V8SCRIPT_H

#include "avocado-global.h"

#include "avocado-v8.h"

#include "../Script.h"

namespace avo {

/**
 * @addtogroup Script
 * @{
 */

/**
 * @ingroup V8
 * @{
 */

/**
 * %v8Script is an executable script wrapping the v8::Script class.
 */
class v8Script : public Script {

public:

	v8Script();

	/** Instantiate from a v8::Script. */
	v8Script(v8::Handle<v8::Script> script);
	~v8Script();

	/** Execute the script. */
	void execute();

	/**
	 * Concrete Script factory instance.
	 */
	static AbstractFactory<v8Script> *factory;

private:

	v8::Persistent<v8::Script> script;

};

template <>
class AbstractFactory<v8Script> : public AbstractFactory<Script> {

public:

	virtual ~AbstractFactory<v8Script>() {};

	/**
	 * Create a concrete Script.
	 */
	v8Script *create() {
		return new v8Script();
	}

	/**
	 * Create a concrete Script from a v8::Script.
	 */
	v8Script *create(v8::Handle<v8::Script> script) {
		return new v8Script(script);
	}

};

/**
 * @}
 */

}

#endif // AVOCADO_V8SCRIPT_H
