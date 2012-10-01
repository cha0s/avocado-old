#ifndef AVOCADO_V8INPUTSERVICE_H
#define AVOCADO_V8INPUTSERVICE_H

#include "avocado-global.h"

#include "avocado-v8.h"
#include "ObjectWrap.h"
#include "../../Input/InputService.h"

namespace avo {

class v8InputService : public ObjectWrap {

public:

	~v8InputService();

	static void initialize(v8::Handle<v8::ObjectTemplate> target);

	InputService *inputService;

private:

	v8InputService(v8::Handle<v8::Object> wrapper);

	static v8::Handle<v8::Value> New(const v8::Arguments &args);

	/**
	 * Manage the InputService SPI implementation.
	 */
	static v8::Handle<v8::Value> ImplementSpi(const v8::Arguments &args);

	static v8::Handle<v8::Value> Close(const v8::Arguments &args);
};

}

#endif // AVOCADO_V8INPUTSERVICE_H
