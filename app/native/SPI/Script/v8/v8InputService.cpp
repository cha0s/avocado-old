#include "avocado-global.h"

#include "v8InputService.h"

#include "SPI/SpiiLoader.h"

using namespace v8;

namespace avo {

avo::SpiiLoader<avo::InputService> inputServiceSpiiLoader;

v8InputService::v8InputService(Handle<Object> wrapper)
{
	Wrap(wrapper);

	try {
		inputService = InputService::factoryManager.instance()->create();
	}
	catch (FactoryManager<InputService>::factory_instance_error &e) {

		ThrowException(v8::Exception::ReferenceError(String::NewSymbol(
			e.what()
		)));
	}
}

v8InputService::~v8InputService() {
	delete inputService;
}

void v8InputService::initialize(Handle<ObjectTemplate> target) {
	HandleScope scope;

	Handle<FunctionTemplate> constructor_template = FunctionTemplate::New(v8InputService::New);
	constructor_template->InstanceTemplate()->SetInternalFieldCount(1);
	constructor_template->SetClassName(String::NewSymbol("InputService"));

	V8_SET_PROTOTYPE_METHOD(constructor_template, "close", v8InputService::Close);

	constructor_template->Set(
		String::New("implementSpi"),
		FunctionTemplate::New(v8InputService::ImplementSpi)
	);

	target->Set(String::NewSymbol("InputService"), constructor_template);
}

v8::Handle<v8::Value> v8InputService::New(const Arguments &args) {
	HandleScope scope;

	new v8InputService(args.Holder());

	return args.Holder();
}

v8::Handle<v8::Value> v8InputService::ImplementSpi(const Arguments &args) {
	HandleScope scope;

	AVOCADO_UNUSED(args);

	try {

		// Attempt to load the SPII.
		inputServiceSpiiLoader.implementSpi(
			V8::stringToStdString(args[0]->ToString())
		);
	}
	catch (SpiiLoader<InputService>::spi_implementation_error &e) {

		// If it couldn't be loaded, throw an error.
		return ThrowException(v8::Exception::ReferenceError(String::NewSymbol(
			e.what()
		)));
	}

	return Undefined();
}

v8::Handle<v8::Value> v8InputService::Close(const Arguments &args) {
	HandleScope scope;

	v8InputService *inputServiceWrapper = ObjectWrap::Unwrap<v8InputService>(args.Holder());

	if (NULL == inputServiceWrapper) {
		return ThrowException(v8::Exception::ReferenceError(String::NewSymbol(
			"InputService::close(): NULL Holder."
		)));
	}

	inputServiceWrapper->inputService->close();

	return v8::Undefined();
}

}

