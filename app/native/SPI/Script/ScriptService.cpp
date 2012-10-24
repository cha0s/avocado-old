#include "avocado-global.h"

#include <algorithm>
#include <map>
#include <string>
#include <sstream>
#include <vector>

#include <boost/algorithm/string/replace.hpp>
#include <boost/format.hpp>
#include <boost/lexical_cast.hpp>
#include <boost/tokenizer.hpp>

#include "FS.h"
#include "Script.h"
#include "ScriptService.h"

using namespace boost;
using namespace std;

namespace avo {

ScriptService::script_compilation_error::script_compilation_error(const std::string &text, const std::string &precompiledCode)
{
	m_what = "Script compilation failed: " + text;

	if ("" != precompiledCode) {
		m_what += "\nPrecompiled code follows:\n\n";

		stringstream precompiledCodeStream(precompiledCode);
		string precompiledCodeLine;

		int lineNumber = 1;
		int lineCount = std::count(
			precompiledCode.begin(),
			precompiledCode.end(),
			'\n'
		);
		int lineCountWidth = boost::lexical_cast<std::string>(lineCount).length();

		while (getline(precompiledCodeStream, precompiledCodeLine)) {

			m_what += (
				boost::format(
					"%" + boost::lexical_cast<std::string>(lineCountWidth) + "d"
				) % lineNumber++
			).str();
			m_what += " | ";
			m_what += precompiledCodeLine;
			m_what += "\n";
		}
	}
}

const char *ScriptService::script_compilation_error::what() const throw() {
	return m_what.c_str();
}

/**
 * Thrown when ScriptService::loadCore fails.
 */
class script_system_load_core_error : public runtime_error {

public:

	script_system_load_core_error(const string &text)
		: runtime_error("Engine initialization failed: " + text)
	{
	}

};

FactoryManager<ScriptService> ScriptService::factoryManager;

ScriptService::ScriptService()
{
}

ScriptService::~ScriptService() {
}

void ScriptService::initialize() {

	// CoffeeScript. <3
	Script *coffeeCompiler = scriptFromFile(
		FS::engineRoot() / "compiler" / "CoffeeScript.js"
	);
	coffeeCompiler->execute();
}

std::vector<boost::filesystem::path> ScriptService::loadCore() {

	// Gather up all the core files.
	vector<filesystem::path> filenames = FS::findFilenames(
		FS::engineRoot() / "core",
		regex("(.*\\.js|.*\\.coffee)")
	);

	// Compile the core files.
	vector<boost::filesystem::path> scripts;
	for (unsigned int i = 0; i < filenames.size(); i++) {

		try {

			// Try compiling...
			scriptFromCode(
				wrapFile(filenames[i]),
				FS::unqualifyPath(
					FS::engineRoot(),
					filenames[i]
				)
			)->execute();

			scripts.push_back(filenames[i]);
		}
		catch (std::exception &e) {

			// If it fails, rethrow it as a core failure.
			throw script_system_load_core_error(e.what());
		}
	}

	return scripts;
}

void ScriptService::loadLibraries() {

	// Gather up all the libraries.
	vector<filesystem::path> filenames = FS::findFilenames(
		FS::engineRoot() / "library",
		regex("(.*\\.js|.*\\.coffee)")
	);

	// Compile and execute the libraries.
	for (unsigned int i = 0; i < filenames.size(); i++) {

		scriptFromCode(
			wrapFile(filenames[i]),
			FS::unqualifyPath(
				FS::engineRoot(),
				filenames[i]
			)
		)->execute();
	}
}

Script *ScriptService::scriptFromFile(const boost::filesystem::path &filename) {

	std::string code = avo::FS::readString(filename);

	return scriptFromCode(preCompileCode(code, filename), filename);
}

std::string ScriptService::wrapFile(const boost::filesystem::path &filename) {

	boost::filesystem::path path = FS::unqualifyPath(
		FS::engineRoot(),
		filename
	);
	path = path.remove_filename() / path.stem();

	std::string moduleName = path.string().substr(1);

	std::string wrapped = "requires_['" + moduleName + "'] = function(module, exports) {\n";
	wrapped += preCompileCode(
		avo::FS::readString(filename),
		filename
	);
	wrapped += "}\n";

	return wrapped;
}

}
