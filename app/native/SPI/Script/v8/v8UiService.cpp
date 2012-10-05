#include "avocado-global.h"

#include "v8UiService.h"

#include "SPI/SpiiLoader.h"

using namespace v8;

namespace avo {

avo::SpiiLoader<avo::UiService> inputServiceSpiiLoader;

v8UiService::v8UiService(Handle<Object> wrapper)
{
	inputService = UiService::factoryManager.instance()->create();

	Wrap(wrapper);
}

v8UiService::~v8UiService() {
	delete inputService;
}

void v8UiService::initialize(Handle<ObjectTemplate> target) {
	HandleScope scope;

	Handle<FunctionTemplate> constructor_template = FunctionTemplate::New(v8UiService::New);
	constructor_template->InstanceTemplate()->SetInternalFieldCount(1);
	constructor_template->SetClassName(String::NewSymbol("UiService"));

	V8_SET_PROTOTYPE_METHOD(constructor_template, "close", v8UiService::Close);

	V8_SET_METHOD(constructor_template, "implementSpi", v8UiService::ImplementSpi);

	target->Set(String::NewSymbol("UiService"), constructor_template);
}

v8::Handle<v8::Value> v8UiService::New(const v8::Arguments &args) {
	HandleScope scope;

	try {
		new v8UiService(args.Holder());
	}
	catch (FactoryManager<UiService>::factory_instance_error &e) {

		return ThrowException(v8::Exception::ReferenceError(String::NewSymbol(
			e.what()
		)));
	}

	return args.Holder();
}

v8::Handle<v8::Value> v8UiService::ImplementSpi(const v8::Arguments &args) {
	HandleScope scope;

	AVOCADO_UNUSED(args);

	try {

		// Attempt to load the SPII.
		inputServiceSpiiLoader.implementSpi(
			V8::stringToStdString(args[0]->ToString())
		);
	}
	catch (SpiiLoader<UiService>::spi_implementation_error &e) {

		// If it couldn't be loaded, throw an error.
		return ThrowException(v8::Exception::ReferenceError(String::NewSymbol(
			e.what()
		)));
	}

	return Undefined();
}

v8::Handle<v8::Value> v8UiService::Close(const v8::Arguments &args) {
	HandleScope scope;

	v8UiService *inputServiceWrapper = ObjectWrap::Unwrap<v8UiService>(args.Holder());

	if (NULL == inputServiceWrapper) {
		return ThrowException(v8::Exception::ReferenceError(String::NewSymbol(
			"UiService::close(): NULL Holder."
		)));
	}

	inputServiceWrapper->inputService->close();

	return v8::Undefined();
}

}

