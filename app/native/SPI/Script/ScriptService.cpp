#include "avocado-global.h"

#include <algorithm>
#include <map>
#include <string>
#include <sstream>
#include <vector>

#include "boost/format.hpp"
#include <boost/tokenizer.hpp>
#include <boost/lexical_cast.hpp>

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
}

std::vector<std::string> ScriptService::loadCore() {

	// Gather up all the core files.
	vector<filesystem::path> filenames = FS::findFilenames(
		FS::engineRoot() / "core",
		regex("(.*\\.js|.*\\.coffee)")
	);

	// Compile the core files.
	map<filesystem::path, Script *> scripts;
	for (unsigned int i = 0; i < filenames.size(); i++) {

		Script *script;

		try {

			// Try compiling...
			script = scriptFromFile(filenames[i]);
		}
		catch (std::exception &e) {

			// If it fails, rethrow it as a core failure.
			throw script_system_load_core_error(e.what());
		}

		scripts[filenames[i]] = script;
	}

	// Start running the core files. Keep track of the order which they were
	// successfully run.
	vector<string> scriptsSuccessfullyRun;
	while (scripts.size() > 0) {

		unsigned int size = scripts.size();

		vector<filesystem::path>::iterator i = filenames.begin();
		while (i != filenames.end()) {

			try {

				// Try executing the script. If there isn't any error,
				scripts[*i]->execute();

				// add it to the successfully run scripts list,
				scriptsSuccessfullyRun.push_back(i->string());

				// deallocate and pull it out of the queue.
				delete scripts[*i];
				scripts.erase(*i);
				i = filenames.erase(i);
			}
			catch (std::exception &e) {

				// If it didn't run successfully, just keep on trying the next.
				++i;
			}
		}

		// If no more scripts were successfully run, then all attempts must
		// have failed; we have to bail.
		if (size == scripts.size()) {

			// Build a message.
			string message;
			map<filesystem::path, Script *>::iterator i = scripts.begin();
			while (i != scripts.end()) {

				try {

					// At this point, we know it's going to fail...
					(i->second)->execute();
				}
				catch (std::exception &e) {

					// So just add in whatever exception text came back into
					// our report message.
					message += e.what();
				}

				// Deallocate and pull it out of the queue.
				delete i->second;
				scripts.erase(i++);
			}

			// Throw a core exception.
			throw script_system_load_core_error(message);
		}
	}

	return scriptsSuccessfullyRun;
}

Script *ScriptService::scriptFromFile(const boost::filesystem::path &filename) {
	return scriptFromCode(avo::FS::readString(filename), filename);
}

}
