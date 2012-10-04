#ifndef AVOCADO_V8INPUT_H
#define AVOCADO_V8INPUT_H

#include "avocado-global.h"

#include "avocado-v8.h"
#include "ObjectWrap.h"
#include "../..//Input/Input.h"

namespace avo {

/**
 * @addtogroup Script
 * @{
 */

/**
 * %v8Input provides the Input SPI to V8 JavaScript.
 *
 * @ingroup Input
 * @ingroup SPI
 * @ingroup V8
 */
class v8Input : public ObjectWrap {

public:

	~v8Input();

	static void initialize(v8::Handle<v8::ObjectTemplate> target);

	Input *input;

private:

	v8Input(v8::Handle<v8::Object> wrapper);

	static v8::Handle<v8::Value> New(const v8::Arguments &args);

	static v8::Handle<v8::Value> Poll(const v8::Arguments &args);
};

}

#endif // AVOCADO_V8INPUT_H
