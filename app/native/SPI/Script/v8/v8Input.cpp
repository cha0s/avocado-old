#include "avocado-global.h"

#include "v8Input.h"

using namespace v8;

namespace avo {

#define SPECIAL_KEY(key)                \
    SpecialKeys->Set(                   \
        String::New(#key),              \
        Integer::New(specialKeyMap.key) \
    );

v8Input::v8Input(Handle<Object> wrapper)
{
	Wrap(wrapper);

	try {
		input = Input::factoryManager.instance()->create();
	}
	catch (FactoryManager<Input>::factory_instance_error &e) {

		ThrowException(v8::Exception::ReferenceError(String::NewSymbol(
			e.what()
		)));
	}
}

v8Input::~v8Input() {
	delete input;
}

void v8Input::initialize(Handle<ObjectTemplate> target) {
	HandleScope scope;

	Handle<FunctionTemplate> constructor_template = FunctionTemplate::New(v8Input::New);
	constructor_template->InstanceTemplate()->SetInternalFieldCount(1);
	constructor_template->SetClassName(String::NewSymbol("v8Input"));

	V8_SET_PROTOTYPE_METHOD(constructor_template, "poll", v8Input::Poll);

	target->Set(String::NewSymbol("Input"), constructor_template);
}

v8::Handle<v8::Value> v8Input::New(const Arguments &args) {
	HandleScope scope;

	v8Input *inputWrapper = new v8Input(args.Holder());

	Handle<Object> avo = Context::GetCurrent()->Global()->Get(
		String::New("avo")
	).As<Object>();

	Handle<Function> Mixin = avo->Get(
		String::New("Mixin")
	).As<Function>();

	Handle<Function> EventEmitter = Context::GetCurrent()->Global()->Get(
		String::New("EventEmitter")
	).As<Function>();

	Handle<Value> argv[] = {args.Holder(), EventEmitter};
	Mixin->Call(Context::GetCurrent()->Global(), 2, argv);

	Input::SpecialKeyMap specialKeyMap = inputWrapper->input->specialKeyMap();

	Handle<Object> SpecialKeys = Object::New();

	SPECIAL_KEY(UpArrow);
	SPECIAL_KEY(RightArrow);
	SPECIAL_KEY(DownArrow);
	SPECIAL_KEY(LeftArrow);

	args.Holder()->Set(String::New("SpecialKeys"), SpecialKeys);

	return args.Holder();
}

v8::Handle<v8::Value> v8Input::Poll(const v8::Arguments &args) {
	HandleScope scope;

	Handle<Object> holder = args.Holder();
	v8Input *inputWrapper = ObjectWrap::Unwrap<v8Input>(holder);

	if (NULL == inputWrapper) {
		return ThrowException(v8::Exception::ReferenceError(String::NewSymbol(
			"Input::poll(): NULL Holder."
		)));
	}

	bool anyResults = inputWrapper->input->poll();
	if (anyResults) {
		Input::PollResults &results = inputWrapper->input->results;

		Handle<Function> emitFunction = args.Holder()->Get(
			String::New("emit")
		).As<Function>();

		Handle<Value> argv[4];

		if (results.keyDown.size() > 0) {
			argv[0] = String::New("keyDown");
			for (unsigned int i = 0; i < results.keyDown.size(); i++) {

				argv[1] = Integer::New(results.keyDown[i].code);
				emitFunction->Call(holder, 2, argv);
			}
		}

		if (results.keyUp.size() > 0) {
			argv[0] = String::New("keyUp");
			for (unsigned int i = 0; i < results.keyUp.size(); i++) {

				argv[1] = Integer::New(results.keyUp[i].code);
				emitFunction->Call(holder, 2, argv);
			}
		}

		if (results.joyAxis.size() > 0) {

			argv[0] = String::New("joyAxis");
			for (unsigned int i = 0; i < results.joyAxis.size(); i++) {

				argv[1] = Integer::New(results.joyAxis[i].stick);
				argv[2] = Integer::New(results.joyAxis[i].axis);
				argv[3] = Number::New(results.joyAxis[i].value);
				emitFunction->Call(holder, 4, argv);
			}
		}

		if (results.joyButtonDown.size() > 0) {

			argv[0] = String::New("joyButtonDown");
			for (unsigned int i = 0; i < results.joyButtonDown.size(); i++) {

				argv[1] = Integer::New(results.joyButtonDown[i].stick);
				argv[2] = Integer::New(results.joyButtonDown[i].button);
				emitFunction->Call(holder, 3, argv);
			}
		}

		if (results.joyButtonUp.size() > 0) {

			argv[0] = String::New("joyButtonUp");
			for (unsigned int i = 0; i < results.joyButtonUp.size(); i++) {

				argv[1] = Integer::New(results.joyButtonUp[i].stick);
				argv[2] = Integer::New(results.joyButtonUp[i].button);
				emitFunction->Call(holder, 3, argv);
			}
		}

		if (results.mouseButtonDown.size() > 0) {

			argv[0] = String::New("mouseButtonDown");
			for (unsigned int i = 0; i < results.mouseButtonDown.size(); i++) {

				argv[1] = Integer::New(results.mouseButtonDown[i].button);
				emitFunction->Call(holder, 2, argv);
			}
		}

		if (results.mouseButtonUp.size() > 0) {

			argv[0] = String::New("mouseButtonUp");
			for (unsigned int i = 0; i < results.mouseButtonUp.size(); i++) {

				argv[1] = Integer::New(results.mouseButtonUp[i].button);
				emitFunction->Call(holder, 2, argv);
			}
		}

		if (results.mouseMove.size() > 0) {

			argv[0] = String::New("mouseMove");
			for (unsigned int i = 0; i < results.mouseMove.size(); i++) {

				argv[1] = Integer::New(results.mouseMove[i].x);
				argv[2] = Integer::New(results.mouseMove[i].y);
				emitFunction->Call(holder, 3, argv);
			}
		}

		if (results.resize.width && results.resize.height) {
			argv[0] = String::New("resize");

			Handle<Array> resize = Array::New(2);
			resize->Set(0, Integer::New(results.resize.width));
			resize->Set(1, Integer::New(results.resize.height));

			argv[1] = resize;
			emitFunction->Call(holder, 2, argv);
		}

		if (results.quit) {
			argv[0] = String::New("quit");

			argv[1] = Boolean::New(true);
			emitFunction->Call(holder, 2, argv);
		}
	}

	return scope.Close(Boolean::New(anyResults));
}

}

