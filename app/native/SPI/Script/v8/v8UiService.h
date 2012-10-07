#ifndef AVOCADO_V8INPUTSERVICE_H
#define AVOCADO_V8INPUTSERVICE_H

#include "avocado-global.h"

#include "avocado-v8.h"
#include "ObjectWrap.h"
#include "../../Ui/UiService.h"

namespace avo {

/**
 * @addtogroup Script
 * @{
 */

/**
 * %v8UiService provides the UiService SPI to V8 JavaScript.
 *
 * @ingroup Input
 * @ingroup SPI
 * @ingroup V8
 */
class v8UiService : public ObjectWrap {

public:

	~v8UiService();

	static void initialize(v8::Handle<v8::ObjectTemplate> target);

	UiService *uiService;

private:

	v8UiService(v8::Handle<v8::Object> wrapper);

	static v8::Handle<v8::Value> New(const v8::Arguments &args);

	/**
	 * Manage the UiService SPI implementation.
	 */
	static v8::Handle<v8::Value> ImplementSpi(const v8::Arguments &args);

	static v8::Handle<v8::Value> Close(const v8::Arguments &args);
};

/**
 * @}
 */

}

#endif // AVOCADO_V8INPUTSERVICE_H
