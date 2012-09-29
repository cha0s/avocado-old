#ifndef AVOCADO_V8_H
#define AVOCADO_V8_H

#include "avocado-global.h"

#include <string>

#include "deps/v8/include/v8.h"

namespace avo {

/**
 * @addtogroup Script
 * @{
 */

/**
 * @namespace avo::V8
 *
 * @brief Utility functions and embed bindings for
 * [V8](http://code.google.com/p/v8/).
 */
namespace V8 {

/** Take a JS value and convert it to JSON. This returns v8::Value and not
 *  v8::String because when JSON.stringify fails, we have to throw/return an
 *  exception. */
v8::Handle<v8::Value> toJson(v8::Handle<v8::Value> value);

/** Write JS values to stderr. Primitives get written verbatim, everything else
 *  gets JSON.stringify'd and written. */
v8::Handle<v8::Value> writeStderr(const v8::Arguments& args);

/** Turn an exception from V8 into a string we can use to report the error. */
std::string stringifyException(const v8::TryCatch& try_catch, bool suppressBacktrace = false);

/** Convert a V8 string to a std::string. */
std::string stringToStdString(v8::Handle<v8::String> value);

}

/**
 * @}
 */

}

#endif // AVOCADO_V8_H
