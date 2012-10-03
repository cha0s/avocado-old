#include "avocado-global.h"

#include "v8SoundService.h"

#include "SPI/SpiiLoader.h"

using namespace v8;

namespace avo {

avo::SpiiLoader<avo::SoundService> soundServiceSpiiLoader;

v8SoundService::v8SoundService(Handle<Object> wrapper)
{
	Wrap(wrapper);

	try {
		soundService = SoundService::factoryManager.instance()->create();
	}
	catch (FactoryManager<SoundService>::factory_instance_error &e) {

		ThrowException(v8::Exception::ReferenceError(String::NewSymbol(
			e.what()
		)));
	}
}

v8SoundService::~v8SoundService() {
	delete soundService;
}

void v8SoundService::initialize(Handle<ObjectTemplate> target) {
	HandleScope scope;

	Handle<FunctionTemplate> constructor_template = FunctionTemplate::New(v8SoundService::New);
	constructor_template->InstanceTemplate()->SetInternalFieldCount(1);
	constructor_template->SetClassName(String::NewSymbol("SoundService"));

	V8_SET_PROTOTYPE_METHOD(constructor_template, "close", v8SoundService::Close);

	constructor_template->Set(
		String::New("implementSpi"),
		FunctionTemplate::New(v8SoundService::ImplementSpi)
	);

	target->Set(String::NewSymbol("SoundService"), constructor_template);
}

v8::Handle<v8::Value> v8SoundService::New(const v8::Arguments &args) {
	HandleScope scope;

	new v8SoundService(args.Holder());

	return args.Holder();
}

v8::Handle<v8::Value> v8SoundService::ImplementSpi(const v8::Arguments &args) {
	HandleScope scope;

	AVOCADO_UNUSED(args);

	try {

		// Attempt to load the SPII.
		soundServiceSpiiLoader.implementSpi(
			V8::stringToStdString(args[0]->ToString())
		);
	}
	catch (SpiiLoader<SoundService>::spi_implementation_error &e) {

		// If it couldn't be loaded, throw an error.
		return ThrowException(v8::Exception::ReferenceError(String::NewSymbol(
			e.what()
		)));
	}

	return Undefined();
}

v8::Handle<v8::Value> v8SoundService::Close(const v8::Arguments &args) {
	HandleScope scope;

	v8SoundService *soundServiceWrapper = ObjectWrap::Unwrap<v8SoundService>(args.Holder());

	if (NULL == soundServiceWrapper) {
		return ThrowException(v8::Exception::ReferenceError(String::NewSymbol(
			"SoundService::close(): NULL Holder."
		)));
	}

	soundServiceWrapper->soundService->close();

	return v8::Undefined();
}

}

