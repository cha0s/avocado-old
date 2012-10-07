#include "avocado-global.h"

#include "v8UiService.h"

#include "SPI/SpiiLoader.h"

using namespace v8;

namespace avo {

#define SPECIAL_KEY(Keys, keys, key)                \
    Keys->Set(                   \
        String::New(#key),              \
        Integer::New(keys.key) \
    );

avo::SpiiLoader<avo::UiService> uiServiceSpiiLoader;

v8UiService::v8UiService(Handle<Object> wrapper)
{
	uiService = UiService::factoryManager.instance()->create();

	Wrap(wrapper);
}

v8UiService::~v8UiService() {
	delete uiService;
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
		v8UiService *uiServiceWrapper = new v8UiService(args.Holder());

		Handle<Object> SpecialKeyCodes = Object::New();
		UiService::SpecialKeyCodes specialKeys = uiServiceWrapper->uiService->specialKeyCodes();

		SPECIAL_KEY(SpecialKeyCodes, specialKeys, UpArrow);
		SPECIAL_KEY(SpecialKeyCodes, specialKeys, RightArrow);
		SPECIAL_KEY(SpecialKeyCodes, specialKeys, DownArrow);
		SPECIAL_KEY(SpecialKeyCodes, specialKeys, LeftArrow);

		args.Holder()->Set(String::New("SpecialKeyCodes"), SpecialKeyCodes);
	}
	catch (std::exception &e) {

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
		uiServiceSpiiLoader.implementSpi(
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

	v8UiService *uiServiceWrapper = ObjectWrap::Unwrap<v8UiService>(args.Holder());

	if (NULL == uiServiceWrapper) {
		return ThrowException(v8::Exception::ReferenceError(String::NewSymbol(
			"UiService::close(): NULL Holder."
		)));
	}

	uiServiceWrapper->uiService->close();

	return v8::Undefined();
}

}

