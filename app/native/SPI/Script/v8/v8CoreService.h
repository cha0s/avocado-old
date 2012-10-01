#ifndef AVOCADO_V8CORESERVICE_H
#define AVOCADO_V8CORESERVICE_H

#include "avocado-global.h"

#include "avocado-v8.h"
#include "ObjectWrap.h"
#include "../../Core/CoreService.h"

namespace avo {

/**
 * @addtogroup Core
 * @{
 */

/**
 * @ingroup V8
 * @{
 */

/**
 * @ingroup SPI
 * @{
 */

/**
 * %v8CoreService handles providing the CoreService SPI to V8 JavaScript.
 */
class v8CoreService : public ObjectWrap {

public:

	~v8CoreService();

	static void initialize(v8::Handle<v8::ObjectTemplate> target);

	CoreService *coreService;

private:

	v8CoreService(v8::Handle<v8::Object> wrapper);

	static v8::Handle<v8::Value> New(const v8::Arguments &args);

	/**
	 * Manage the CoreService SPII implementation.
	 */
	static v8::Handle<v8::Value> ImplementSpi(const v8::Arguments &args);

	/**
	 * Write JS values to stderr. Primitives get written verbatim, everything else
	 * gets JSON.stringify'd and written.
	 */
	static v8::Handle<v8::Value> WriteStderr(const v8::Arguments& args);

	static v8::Handle<v8::Value> Close(const v8::Arguments &args);
};

/**
 * @}
 */

/**
 * @}
 */

}

#endif // AVOCADO_V8CORESERVICE_H
