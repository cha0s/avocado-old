#include "avocado-global.h"

#include "v8TimingService.h"

#include "SPI/SpiiLoader.h"

using namespace v8;

namespace avo {

avo::SpiiLoader<avo::TimingService> timingServiceSpiiLoader;

v8TimingService::v8TimingService(Handle<Object> wrapper)
{
	timingService = TimingService::factoryManager.instance()->create();

	Wrap(wrapper);
}

v8TimingService::~v8TimingService() {
	delete timingService;
}

void v8TimingService::initialize(Handle<ObjectTemplate> target) {
	HandleScope scope;

	Handle<FunctionTemplate> constructor_template = FunctionTemplate::New(v8TimingService::New);
	constructor_template->InstanceTemplate()->SetInternalFieldCount(1);
	constructor_template->SetClassName(String::NewSymbol("TimingService"));

	V8_SET_PROTOTYPE_METHOD(constructor_template, "close", v8TimingService::Close);
	V8_SET_PROTOTYPE_METHOD(constructor_template, "%sleep", v8TimingService::Sleep);

	V8_SET_METHOD(constructor_template, "implementSpi", v8TimingService::ImplementSpi);

	target->Set(String::NewSymbol("TimingService"), constructor_template);
}

v8::Handle<v8::Value> v8TimingService::New(const v8::Arguments &args) {
	HandleScope scope;

	try {
		new v8TimingService(args.Holder());
	}
	catch (FactoryManager<TimingService>::factory_instance_error &e) {

		return ThrowException(v8::Exception::ReferenceError(String::NewSymbol(
			e.what()
		)));
	}

	return args.Holder();
}

v8::Handle<v8::Value> v8TimingService::ImplementSpi(const v8::Arguments &args) {
	HandleScope scope;

	AVOCADO_UNUSED(args);

	try {

		// Attempt to load the SPII.
		timingServiceSpiiLoader.implementSpi(
			V8::stringToStdString(args[0]->ToString())
		);
	}
	catch (SpiiLoader<TimingService>::spi_implementation_error &e) {

		// If it couldn't be loaded, throw an error.
		return ThrowException(v8::Exception::ReferenceError(String::NewSymbol(
			e.what()
		)));
	}

	return Undefined();
}

v8::Handle<v8::Value> v8TimingService::Close(const v8::Arguments &args) {
	HandleScope scope;

	v8TimingService *timingServiceWrapper = ObjectWrap::Unwrap<v8TimingService>(args.Holder());

	if (NULL == timingServiceWrapper) {
		return ThrowException(v8::Exception::ReferenceError(String::NewSymbol(
			"TimingService::close(): NULL Holder."
		)));
	}

	timingServiceWrapper->timingService->close();

	return v8::Undefined();
}

v8::Handle<v8::Value> v8TimingService::Sleep(const v8::Arguments &args) {
	HandleScope scope;

	v8TimingService *timingServiceWrapper = ObjectWrap::Unwrap<v8TimingService>(args.Holder());

	timingServiceWrapper->timingService->sleep(
		args[0]->Int32Value()
	);

	return v8::Undefined();
}

}

