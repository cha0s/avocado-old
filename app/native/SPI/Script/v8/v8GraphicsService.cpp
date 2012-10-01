#include "avocado-global.h"

#include "v8GraphicsService.h"

#include "SPI/SpiiLoader.h"

using namespace v8;

namespace avo {

avo::SpiiLoader<avo::GraphicsService> graphicsServiceSpiiLoader;

v8GraphicsService::v8GraphicsService(Handle<Object> wrapper)
{
	Wrap(wrapper);

	try {
		graphicsService = GraphicsService::factoryManager.instance()->create();
	}
	catch (FactoryManager<GraphicsService>::factory_instance_error &e) {

		ThrowException(v8::Exception::ReferenceError(String::NewSymbol(
			e.what()
		)));
	}
}

v8GraphicsService::~v8GraphicsService() {
	delete graphicsService;
}

void v8GraphicsService::initialize(Handle<ObjectTemplate> target) {
	HandleScope scope;

	constructor_template = Persistent<FunctionTemplate>::New(
		FunctionTemplate::New(v8GraphicsService::New)
	);
	constructor_template->InstanceTemplate()->SetInternalFieldCount(1);
	constructor_template->SetClassName(String::NewSymbol("GraphicsService"));

	V8_SET_PROTOTYPE_METHOD(constructor_template, "close", v8GraphicsService::Close);

	constructor_template->Set(
		String::New("implementSpi"),
		FunctionTemplate::New(v8GraphicsService::ImplementSpi)
	);

	target->Set(String::NewSymbol("GraphicsService"), constructor_template);
}

v8::Handle<v8::Value> v8GraphicsService::New(const Arguments &args) {
	HandleScope scope;

	new v8GraphicsService(args.Holder());

	return args.Holder();
}

v8::Handle<v8::Value> v8GraphicsService::ImplementSpi(const Arguments &args) {
	HandleScope scope;

	AVOCADO_UNUSED(args);

	try {

		// Attempt to load the SPII.
		graphicsServiceSpiiLoader.implementSpi(
			V8::stringToStdString(args[0]->ToString())
		);
	}
	catch (SpiiLoader<GraphicsService>::spi_implementation_error &e) {

		// If it couldn't be loaded, throw an error.
		return ThrowException(v8::Exception::ReferenceError(String::NewSymbol(
			e.what()
		)));
	}

	return Undefined();
}

v8::Handle<v8::Value> v8GraphicsService::Close(const Arguments &args) {
	HandleScope scope;

	v8GraphicsService *graphicsServiceWrapper = ObjectWrap::Unwrap<v8GraphicsService>(args.Holder());

	if (NULL == graphicsServiceWrapper) {
		return ThrowException(v8::Exception::ReferenceError(String::NewSymbol(
			"GraphicsSystem::close(): NULL Holder."
		)));
	}

	graphicsServiceWrapper->graphicsService->close();

	return v8::Undefined();
}

Persistent<FunctionTemplate> v8GraphicsService::constructor_template;

}

