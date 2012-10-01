#ifndef AVOCADO_V8COUNTER_H
#define AVOCADO_V8COUNTER_H

#include "avocado-global.h"

#include "avocado-v8.h"
#include "ObjectWrap.h"
#include "../../Timing/Counter.h"

namespace avo {

class v8Counter : public ObjectWrap {

public:

	~v8Counter();

	static void initialize(v8::Handle<v8::ObjectTemplate> target);

	Counter *wrappedCounter();

private:

	v8Counter(v8::Handle<v8::Object> wrapper);

	static v8::Handle<v8::Value> New(const v8::Arguments &args);

	static v8::Handle<v8::Value> Current(const v8::Arguments &args);
	static v8::Handle<v8::Value> Since(const v8::Arguments &args);

	Counter *counter;
};

}

#endif // AVOCADO_V8COUNTER_H
