#ifndef AVOCADO_V8SAMPLE_H
#define AVOCADO_V8SAMPLE_H

#include "avocado-global.h"

#include "avocado-v8.h"
#include "ObjectWrap.h"
#include "../../Sound/Sample.h"

namespace avo {

class v8Sample : public ObjectWrap {

public:

	~v8Sample();

	static void initialize(v8::Handle<v8::ObjectTemplate> target);

	static v8::Handle<v8::Object> New(Sample *sample);

	Sample *wrappedSample();

private:

	v8Sample(v8::Handle<v8::Object> wrapper, Sample *sample = NULL);

	static v8::Handle<v8::Value> New(const v8::Arguments &args);

	void releaseSample();

	static v8::Handle<v8::Value> Play(const v8::Arguments &args);

	static v8::Handle<v8::Value> Load(const v8::Arguments &args);

	static v8::Persistent<v8::FunctionTemplate> constructor_template;

	Sample *sample;
	bool owns;
};

}

#endif // AVOCADO_V8SAMPLE_H
