#include "avocado-global.h"

#include "v8CoreService.h"

#include "SPI/SpiiLoader.h"

using namespace v8;

namespace avo {

avo::SpiiLoader<avo::CoreService> coreServiceSpiiLoader;

v8CoreService::v8CoreService(Handle<Object> wrapper)
{
	Wrap(wrapper);

	try {
		coreService = CoreService::factoryManager.instance()->create();
	}
	catch (FactoryManager<CoreService>::factory_instance_error &e) {

		ThrowException(v8::Exception::ReferenceError(String::NewSymbol(
			e.what()
		)));
	}
}

v8CoreService::~v8CoreService() {
	delete coreService;
}

void v8CoreService::initialize(Handle<ObjectTemplate> target) {
	HandleScope scope;

	Handle<FunctionTemplate> constructor_template = FunctionTemplate::New(v8CoreService::New);
	constructor_template->InstanceTemplate()->SetInternalFieldCount(1);
	constructor_template->SetClassName(String::NewSymbol("CoreService"));

	// Set methods.
	V8_SET_PROTOTYPE_METHOD(constructor_template, "close", v8CoreService::Close);

	constructor_template->Set(
		String::New("implementSpi"),
		FunctionTemplate::New(v8CoreService::ImplementSpi)
	);

	constructor_template->Set(
		String::New("%writeStderr"),
		FunctionTemplate::New(v8CoreService::WriteStderr)
	);

	// Register.
	target->Set(String::NewSymbol("CoreService"), constructor_template);
}

v8::Handle<v8::Value> v8CoreService::New(const Arguments &args) {
	HandleScope scope;

	new v8CoreService(args.Holder());

	return args.Holder();
}

v8::Handle<v8::Value> v8CoreService::ImplementSpi(const Arguments &args) {
	HandleScope scope;

	AVOCADO_UNUSED(args);

	try {

		// Attempt to load the SPII.
		coreServiceSpiiLoader.implementSpi(
			V8::stringToStdString(args[0]->ToString())
		);
	}
	catch (SpiiLoader<CoreService>::spi_implementation_error &e) {

		// If it couldn't be loaded, throw an error.
		return ThrowException(v8::Exception::ReferenceError(String::NewSymbol(
			e.what()
		)));
	}

	return Undefined();
}

v8::Handle<v8::Value> v8CoreService::WriteStderr(const v8::Arguments& args) {
	HandleScope scope;

	for (int i = 0; i < args.Length(); i++) {

		Handle<String> argString;

		// Primitives sent verbatim.
		if (args[i]->IsString() || args[i]->IsNumber()) {

			argString = args[i]->ToString();
		}
		else {

			// Try JSON.stringify...
			Handle<Value> jsonResult = V8::toJson(args[i]);
			if (jsonResult->IsUndefined()) {

				// If it bombed, then return the result; it's an exception.
				return jsonResult;
			}

			argString = jsonResult.As<String>();
		}

		// Stream it.
		std::cerr << *String::Utf8Value(argString) << std::endl;
	}

	return Undefined();
}

v8::Handle<v8::Value> v8CoreService::Close(const Arguments &args) {
	HandleScope scope;

	// Check for fishyness.
	v8CoreService *coreServiceWrapper = ObjectWrap::Unwrap<v8CoreService>(args.Holder());
	if (NULL == coreServiceWrapper) {
		return ThrowException(v8::Exception::ReferenceError(String::NewSymbol(
			"CoreService::close(): NULL Holder."
		)));
	}

	coreServiceWrapper->coreService->close();

	return v8::Undefined();
}

}

