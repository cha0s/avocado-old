#include "avocado-global.h"

#include "v8ScriptService.h"

#include "FS.h"
#include "../Script.h"
#include "v8Script.h"

#include "v8CoreService.h"
#include "v8GraphicsService.h"
#include "v8InputService.h"
#include "v8TimingService.h"
#include "v8SoundService.h"

#include "v8Counter.h"
#include "v8Image.h"
#include "v8Input.h"
#include "v8Window.h"
#include "v8Music.h"
#include "v8Sample.h"

using namespace v8;
using namespace std;

namespace avo {

AbstractFactory<v8ScriptService> *v8ScriptService::factory = new AbstractFactory<v8ScriptService>;

v8ScriptService::v8ScriptService()
	: ScriptService()
{

	Script::factoryManager.setInstance(v8Script::factory);

	HandleScope scope;

	Handle<ObjectTemplate> global = ObjectTemplate::New();

	Handle<ObjectTemplate> avo = ObjectTemplate::New();

	v8CoreService::initialize(avo);
	v8GraphicsService::initialize(avo);
	v8InputService::initialize(avo);
	v8TimingService::initialize(avo);
	v8SoundService::initialize(avo);

	v8Counter::initialize(avo);
	v8Image::initialize(avo);
	v8Input::initialize(avo);
	v8Window::initialize(avo);
	v8Music::initialize(avo);
	v8Sample::initialize(avo);

	global->Set(String::New("avo"), avo);

	context = Context::New(NULL, global);

	context->Enter();

	ScriptService::initialize();
}

std::string v8ScriptService::preCompileCode(const std::string &code, const boost::filesystem::path &filename) {
	HandleScope scope;

	std::string filenameString = FS::unqualifyPath(FS::engineRoot(), filename).string();

	// Compile coffeescript to JS.
	if (std::string::npos != filenameString.find(".coffee")) {

		Handle<Object> CoffeeScript = Context::GetCurrent()->Global()->Get(String::New("CoffeeScript")).As<Object>();
		Handle<Function> compile = CoffeeScript->Get(String::New("compile")).As<Function>();

		Handle<Object> options = Object::New();
		options->Set(String::New("filename"), String::New(
			filename.c_str()
		));
		Handle<Value> args[] = {
			String::New(code.c_str()),
			options
		};

		TryCatch exception;

		Handle<Value> result = compile->Call(compile, 2, args);

		if (exception.HasCaught()) {
			throw script_precompilation_error(V8::stringifyException(exception, true));
		}

		return V8::stringToStdString(result->ToString());
	}
	else {

		return code;
	}
}

Script *v8ScriptService::scriptFromCode(const std::string &code, const boost::filesystem::path &filename) {
	HandleScope scope;

	// Precompile the code.
	std::string precompiledCode = preCompileCode(code, filename);

	// Instantiate the v8 script.
	TryCatch exception;
	Handle<v8::Script> script = v8::Script::New(
		String::New(precompiledCode.c_str()),
		String::New(FS::unqualifyPath(FS::engineRoot(), filename).string().c_str())
	);
	if (exception.HasCaught()) {

		throw script_compilation_error(
			V8::stringifyException(exception),
			precompiledCode
		);
	}

	// Cast and ensure the factory is correct.
	AbstractFactory<v8Script> *v8ScriptFactory;
	v8ScriptFactory = dynamic_cast<AbstractFactory<v8Script> *>(
		Script::factoryManager.instance()
	);
	if (NULL == v8ScriptFactory) {
		throw script_compilation_error("Concrete v8 factory mismatch!");
	}

	// Instantiate our script and return it.
	return v8ScriptFactory->create(script);
}

v8ScriptService::~v8ScriptService() {

	// Leave the context and dispose of it.
	context->Exit();
	context.Dispose();
}

}
