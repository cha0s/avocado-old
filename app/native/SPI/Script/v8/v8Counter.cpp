#include "avocado-global.h"

#include "v8Counter.h"

using namespace v8;

namespace avo {

v8Counter::v8Counter(Handle<Object> wrapper)
{
	Wrap(wrapper);

	try {
		counter = Counter::factoryManager.instance()->create();
	}
	catch (FactoryManager<Counter>::factory_instance_error &e) {

		ThrowException(v8::Exception::ReferenceError(String::NewSymbol(
			e.what()
		)));
	}
}

v8Counter::~v8Counter() {
	delete counter;
}

void v8Counter::initialize(Handle<ObjectTemplate> target) {
	HandleScope scope;

	Handle<FunctionTemplate> constructor_template = FunctionTemplate::New(v8Counter::New);
	constructor_template->InstanceTemplate()->SetInternalFieldCount(1);
	constructor_template->SetClassName(String::NewSymbol("Counter"));

	V8_SET_PROTOTYPE_METHOD(constructor_template, "%current", v8Counter::Current);
	V8_SET_PROTOTYPE_METHOD(constructor_template, "%since", v8Counter::Since);

	target->Set(String::NewSymbol("Counter"), constructor_template);
}

Counter *v8Counter::wrappedCounter() {
	return counter;
}

v8::Handle<v8::Value> v8Counter::New(const v8::Arguments &args) {
	HandleScope scope;

	new v8Counter(args.Holder());

	return args.This();
}

v8::Handle<v8::Value> v8Counter::Current(const v8::Arguments &args) {
	HandleScope scope;

	v8Counter *counterWrapper = ObjectWrap::Unwrap<v8Counter>(args.Holder());

	if (NULL == counterWrapper) {
		return ThrowException(v8::Exception::ReferenceError(String::NewSymbol(
			"Counter::current(): NULL Holder."
		)));
	}

	return scope.Close(Number::New(counterWrapper->counter->current()));
}

v8::Handle<v8::Value> v8Counter::Since(const v8::Arguments &args) {
	HandleScope scope;

	v8Counter *counterWrapper = ObjectWrap::Unwrap<v8Counter>(args.Holder());

	if (NULL == counterWrapper) {
		return ThrowException(v8::Exception::ReferenceError(String::NewSymbol(
			"Counter::since(): NULL Holder."
		)));
	}

	return scope.Close(Number::New(counterWrapper->counter->since()));
}

}

