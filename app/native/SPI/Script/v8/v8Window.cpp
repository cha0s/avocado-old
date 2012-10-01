#include "avocado-global.h"

#include "v8Window.h"

#include "v8Image.h"

using namespace v8;

namespace avo {

v8Window::v8Window(Handle<Object> wrapper)
{
	Wrap(wrapper);

	try {
		window = Window::factoryManager.instance()->create();
	}
	catch (FactoryManager<Window>::factory_instance_error &e) {

		ThrowException(v8::Exception::ReferenceError(String::NewSymbol(
			e.what()
		)));
	}
}

v8Window::~v8Window() {
	delete window;
}

void v8Window::initialize(Handle<ObjectTemplate> target) {
	HandleScope scope;

	Handle<FunctionTemplate> constructor_template = FunctionTemplate::New(v8Window::New);
	constructor_template->InstanceTemplate()->SetInternalFieldCount(1);
	constructor_template->SetClassName(String::NewSymbol("Window"));

	V8_SET_PROTOTYPE_METHOD(constructor_template, "%render", v8Window::Render);
	V8_SET_PROTOTYPE_METHOD(constructor_template, "%set", v8Window::Set);
	V8_SET_PROTOTYPE_METHOD(constructor_template, "%setMouseVisibility", v8Window::SetMouseVisibility);
	V8_SET_PROTOTYPE_METHOD(constructor_template, "%setWindowTitle", v8Window::SetWindowTitle);
	V8_SET_PROTOTYPE_METHOD(constructor_template, "%size", v8Window::Size);

	target->Set(String::NewSymbol("Window"), constructor_template);
}

v8::Handle<v8::Value> v8Window::New(const Arguments &args) {
	HandleScope scope;

	new v8Window(args.Holder());

	return args.Holder();
}

v8::Handle<v8::Value> v8Window::Render(const Arguments &args) {
	HandleScope scope;

	v8Window *windowWrapper = ObjectWrap::Unwrap<v8Window>(args.Holder());

	if (NULL == windowWrapper) {
		return ThrowException(v8::Exception::ReferenceError(String::NewSymbol(
			"Window::render(): NULL Holder."
		)));
	}

	v8Image *source = ObjectWrap::Unwrap<v8Image>(args[0]->ToObject());

	if (NULL == source) {
		return ThrowException(v8::Exception::ReferenceError(String::NewSymbol(
			"Window::render(): NULL source."
		)));
	}

	windowWrapper->window->render(
		source->wrappedImage()
	);

	return v8::Undefined();
}

v8::Handle<v8::Value> v8Window::Set(const Arguments &args) {
	HandleScope scope;

	v8Window *windowWrapper = ObjectWrap::Unwrap<v8Window>(args.Holder());

	if (NULL == windowWrapper) {
		return ThrowException(v8::Exception::ReferenceError(String::NewSymbol(
			"Window::set(): NULL Holder."
		)));
	}

	Handle<Array> dimensions = args[0].As<Array>();

	windowWrapper->window->set(
		dimensions->Get(0)->Int32Value(),
		dimensions->Get(1)->Int32Value(),
		static_cast<Window::WindowFlags>(args[1]->Int32Value())
	);

	return v8::Undefined();
}

v8::Handle<v8::Value> v8Window::SetMouseVisibility(const Arguments &args) {
	HandleScope scope;

	v8Window *windowWrapper = ObjectWrap::Unwrap<v8Window>(args.Holder());

	if (NULL == windowWrapper) {
		return ThrowException(v8::Exception::ReferenceError(String::NewSymbol(
			"Window::setMouseVisibility(): NULL Holder."
		)));
	}

	windowWrapper->window->setMouseVisibility(
		args[0]->BooleanValue()
	);

	return v8::Undefined();
}

v8::Handle<v8::Value> v8Window::SetWindowTitle(const Arguments &args) {
	HandleScope scope;

	v8Window *windowWrapper = ObjectWrap::Unwrap<v8Window>(args.Holder());

	if (NULL == windowWrapper) {
		return ThrowException(v8::Exception::ReferenceError(String::NewSymbol(
			"Window::setWindowTitle(): NULL Holder."
		)));
	}

	windowWrapper->window->setWindowTitle(
		V8::stringToStdString(args[0]->ToString()),
		V8::stringToStdString(args[1]->ToString())
	);

	return v8::Undefined();
}

v8::Handle<v8::Value> v8Window::Size(const Arguments &args) {
	HandleScope scope;

	v8Window *windowWrapper = ObjectWrap::Unwrap<v8Window>(args.Holder());

	if (NULL == windowWrapper) {
		return ThrowException(v8::Exception::ReferenceError(String::NewSymbol(
			"Window::size(): NULL Holder."
		)));
	}

	Handle<Array> size = Array::New();

	size->Set(0, Integer::New(windowWrapper->window->width()));
	size->Set(1, Integer::New(windowWrapper->window->height()));

	return scope.Close(size);
}

}

