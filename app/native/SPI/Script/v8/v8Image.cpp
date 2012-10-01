#include "avocado-global.h"

#include "v8Image.h"

using namespace v8;

namespace avo {

v8Image::v8Image(Handle<Object> wrapper, Image *image)
	: image(image)
	, owns(false)
{
	Wrap(wrapper);

	if (NULL == this->image) {

		try {
			this->image = Image::factoryManager.instance()->create();

			::V8::AdjustAmountOfExternalAllocatedMemory(
				this->image->sizeInBytes()
			);

			owns = true;
		}
		catch (FactoryManager<Image>::factory_instance_error &e) {

			ThrowException(v8::Exception::ReferenceError(String::NewSymbol(
				e.what()
			)));
		}
	}
}

v8Image::~v8Image() {
	releaseImage();
}

void v8Image::initialize(Handle<ObjectTemplate> target) {
	HandleScope scope;

	constructor_template = Persistent<FunctionTemplate>::New(
		FunctionTemplate::New(v8Image::New)
	);
	constructor_template->InstanceTemplate()->SetInternalFieldCount(1);
	constructor_template->SetClassName(String::NewSymbol("Image"));

	V8_SET_PROTOTYPE_METHOD(constructor_template, "%drawFilledBox", v8Image::DrawFilledBox);
	V8_SET_PROTOTYPE_METHOD(constructor_template, "%drawCircle"   , v8Image::DrawCircle   );
	V8_SET_PROTOTYPE_METHOD(constructor_template, "%drawLineBox"  , v8Image::DrawLineBox  );
	V8_SET_PROTOTYPE_METHOD(constructor_template, "%drawLine"     , v8Image::DrawLine     );
	V8_SET_PROTOTYPE_METHOD(constructor_template, "%fill"         , v8Image::Fill         );
	V8_SET_PROTOTYPE_METHOD(constructor_template, "%height"       , v8Image::Height       );
	V8_SET_PROTOTYPE_METHOD(constructor_template, "%pixelAt"      , v8Image::PixelAt      );
	V8_SET_PROTOTYPE_METHOD(constructor_template, "%render"       , v8Image::Render       );
	V8_SET_PROTOTYPE_METHOD(constructor_template, "%setPixelAt"   , v8Image::SetPixelAt   );
	V8_SET_PROTOTYPE_METHOD(constructor_template, "%width"        , v8Image::Width        );

	constructor_template->Set(
		String::New("%load"),
		FunctionTemplate::New(v8Image::Load)
	);

	target->Set(v8::String::NewSymbol("Image"), constructor_template);
}

Image *v8Image::wrappedImage() {
	return image;
}

void v8Image::releaseImage() {

	unsigned int size = image->sizeInBytes();

	if (owns) {

		::V8::AdjustAmountOfExternalAllocatedMemory(
			-size
		);

		delete image;
	}
	else {

		if (Image::manager.release(image->uri())) {

			::V8::AdjustAmountOfExternalAllocatedMemory(
				-size
			);
		}
	}
}

v8::Handle<v8::Value> v8Image::New(const Arguments &args) {
	HandleScope scope;

	Image *image = NULL;

	if (args.Length() > 0) {

		try {

			int width, height;

			if (args[0]->IsArray()) {
				width = args[0].As<Array>()->Get(0)->Int32Value();
				height = args[0].As<Array>()->Get(1)->Int32Value();
			}
			else {
				width = args[0]->Uint32Value();
				height = args[1]->Uint32Value();
			}

			image = Image::factoryManager.instance()->create(width, height);
		}
		catch (FactoryManager<Image>::factory_instance_error &e) {

			ThrowException(v8::Exception::ReferenceError(String::NewSymbol(
				e.what()
			)));
		}
	}

	new v8Image(args.Holder(), image);

	return args.This();
}

Handle<Object> v8Image::New(Image *image) {
	HandleScope scope;

	Handle<Object> instance = constructor_template->GetFunction()->NewInstance();

	v8Image *image_v8 = ObjectWrap::Unwrap<v8Image>(instance);

	image_v8->releaseImage();

	image_v8->owns = false;

	image_v8->image = image;

	return scope.Close(instance);
}

v8::Handle<v8::Value> v8Image::Load(const Arguments &args) {
	HandleScope scope;

	Handle<Object> when_ = Context::GetCurrent()->Global()->Get(
		String::NewSymbol("when_")
	).As<Object>();

	Handle<Object> defer = when_->Get(
		String::NewSymbol("defer")
	).As<Function>()->Call(when_, 0, NULL).As<Object>();

	try {

		Handle<Object> image;

		image = v8Image::New(
			Image::manager.load(
				V8::stringToStdString(args[0]->ToString())
			)
		);

		Handle<Value> resolveArgs[] = {
			image
		};
		defer->Get(
			String::NewSymbol("resolve")
		).As<Function>()->Call(defer, 1, resolveArgs);
	}
	catch (std::exception &e) {

		return ThrowException(
			v8::Exception::Error(String::New(e.what()))
		);
	}

	return scope.Close(defer->Get(String::NewSymbol("promise")));
}

v8::Handle<v8::Value> v8Image::DrawCircle(const Arguments &args) {
	HandleScope scope;

	v8Image *image_v8 = ObjectWrap::Unwrap<v8Image>(args.Holder());

	if (NULL == image_v8) {
		return ThrowException(v8::Exception::ReferenceError(String::NewSymbol(
			"Image::drawCircle(): NULL Holder."
		)));
	}

	Handle<Array> position = args[0].As<Array>();

	image_v8->image->drawCircle(
		position->Get(0)->Int32Value(),
		position->Get(1)->Int32Value(),
		args[1]->Uint32Value(),
		args[2]->Uint32Value(),
		args[3]->Uint32Value(),
		args[4]->Uint32Value(),
		args[5]->Uint32Value(),
		static_cast<Image::DrawMode>(args[6]->Uint32Value())
	);

	return v8::Undefined();
}

v8::Handle<v8::Value> v8Image::DrawFilledBox(const Arguments &args) {
	HandleScope scope;

	v8Image *image_v8 = ObjectWrap::Unwrap<v8Image>(args.Holder());

	if (NULL == image_v8) {
		return ThrowException(v8::Exception::ReferenceError(String::NewSymbol(
			"Image::drawFilledBox(): NULL Holder."
		)));
	}

	Handle<Array> dimensions = args[0].As<Array>();

	image_v8->image->drawFilledBox(
		dimensions->Get(0)->Int32Value(),
		dimensions->Get(1)->Int32Value(),
		dimensions->Get(2)->Int32Value(),
		dimensions->Get(3)->Int32Value(),
		args[1]->Uint32Value(),
		args[2]->Uint32Value(),
		args[3]->Uint32Value(),
		args[4]->Uint32Value(),
		static_cast<Image::DrawMode>(args[5]->Uint32Value())
	);

	return v8::Undefined();
}

v8::Handle<v8::Value> v8Image::DrawLine(const Arguments &args) {
	HandleScope scope;

	v8Image *image_v8 = ObjectWrap::Unwrap<v8Image>(args.Holder());

	if (NULL == image_v8) {
		return ThrowException(v8::Exception::ReferenceError(String::NewSymbol(
			"Image::drawLine(): NULL Holder."
		)));
	}

	Handle<Array> dimensions = args[0].As<Array>();

	image_v8->image->drawLine(
		dimensions->Get(0)->Int32Value(),
		dimensions->Get(1)->Int32Value(),
		dimensions->Get(2)->Int32Value(),
		dimensions->Get(3)->Int32Value(),
		args[1]->Uint32Value(),
		args[2]->Uint32Value(),
		args[3]->Uint32Value(),
		args[4]->Uint32Value(),
		static_cast<Image::DrawMode>(args[5]->Uint32Value())
	);

	return v8::Undefined();
}

v8::Handle<v8::Value> v8Image::DrawLineBox(const Arguments &args) {
	HandleScope scope;

	v8Image *image_v8 = ObjectWrap::Unwrap<v8Image>(args.Holder());

	if (NULL == image_v8) {
		return ThrowException(v8::Exception::ReferenceError(String::NewSymbol(
			"Image::drawLineBox(): NULL Holder."
		)));
	}

	Handle<Array> dimensions = args[0].As<Array>();

	image_v8->image->drawLineBox(
		dimensions->Get(0)->Int32Value(),
		dimensions->Get(1)->Int32Value(),
		dimensions->Get(2)->Int32Value(),
		dimensions->Get(3)->Int32Value(),
		args[1]->Uint32Value(),
		args[2]->Uint32Value(),
		args[3]->Uint32Value(),
		args[4]->Uint32Value(),
		static_cast<Image::DrawMode>(args[5]->Uint32Value())
	);

	return v8::Undefined();
}

v8::Handle<v8::Value> v8Image::Fill(const Arguments &args) {
	HandleScope scope;

	v8Image *image_v8 = ObjectWrap::Unwrap<v8Image>(args.Holder());

	if (NULL == image_v8) {
		return ThrowException(v8::Exception::ReferenceError(String::NewSymbol(
			"Image::fill(): NULL Holder."
		)));
	}

	image_v8->image->fill(
		args[0]->Uint32Value(),
		args[1]->Uint32Value(),
		args[2]->Uint32Value(),
		args[3]->Uint32Value()
	);

	return v8::Undefined();
}

v8::Handle<v8::Value> v8Image::Height(const Arguments &args) {
	HandleScope scope;

	v8Image *image_v8 = ObjectWrap::Unwrap<v8Image>(args.Holder());

	if (NULL == image_v8) {
		return ThrowException(v8::Exception::ReferenceError(String::NewSymbol(
			"Image::height(): NULL Holder."
		)));
	}

	return scope.Close(
		Integer::New(image_v8->image->height())
	);
}

v8::Handle<v8::Value> v8Image::PixelAt(const Arguments &args) {
	HandleScope scope;

	v8Image *image_v8 = ObjectWrap::Unwrap<v8Image>(args.Holder());

	if (NULL == image_v8) {
		return ThrowException(v8::Exception::ReferenceError(String::NewSymbol(
			"Image::pixelAt(): NULL Holder."
		)));
	}

	return scope.Close(Integer::New(
		image_v8->image->pixelAt(
			args[0]->Uint32Value(),
			args[1]->Uint32Value()
		)
	));
}

v8::Handle<v8::Value> v8Image::Render(const Arguments &args) {
	HandleScope scope;

	v8Image *image_v8 = ObjectWrap::Unwrap<v8Image>(args.Holder());

	if (NULL == image_v8) {
		return ThrowException(v8::Exception::ReferenceError(String::NewSymbol(
			"Image::render(): NULL Holder."
		)));
	}

	Handle<Array> dimensions = args[4].As<Array>();
	Handle<Array> position = args[0].As<Array>();

	v8Image *destination = ObjectWrap::Unwrap<v8Image>(args[1]->ToObject());

	if (NULL == destination) {
		return ThrowException(v8::Exception::ReferenceError(String::NewSymbol(
			"Image::render(): NULL destination."
		)));
	}

	image_v8->image->render(
		position->Get(0)->Int32Value(),
		position->Get(1)->Int32Value(),
		destination->image,
		args[2]->Int32Value(),
		static_cast<Image::DrawMode>(args[3]->Int32Value()),
		dimensions->Get(0)->Int32Value(),
		dimensions->Get(1)->Int32Value(),
		dimensions->Get(2)->Int32Value(),
		dimensions->Get(3)->Int32Value()
	);

	return v8::Undefined();
}

v8::Handle<v8::Value> v8Image::SetPixelAt(const Arguments &args) {
	HandleScope scope;

	v8Image *image_v8 = ObjectWrap::Unwrap<v8Image>(args.Holder());

	if (NULL == image_v8) {
		return ThrowException(v8::Exception::ReferenceError(String::NewSymbol(
			"Image::setPixelAt(): NULL Holder."
		)));
	}

	image_v8->image->setPixelAt(
		args[0]->Uint32Value(),
		args[1]->Uint32Value(),
		args[2]->Uint32Value()
	);

	return v8::Undefined();
}

v8::Handle<v8::Value> v8Image::Width(const Arguments &args) {
	HandleScope scope;

	v8Image *image_v8 = ObjectWrap::Unwrap<v8Image>(args.Holder());

	if (NULL == image_v8) {
		return ThrowException(v8::Exception::ReferenceError(String::NewSymbol(
			"Image::width(): NULL Holder."
		)));
	}

	return scope.Close(Integer::New(image_v8->image->width()));
}

Persistent<FunctionTemplate> v8Image::constructor_template;

}

