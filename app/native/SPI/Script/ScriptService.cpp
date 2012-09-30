#include "avocado-global.h"

#include <algorithm>
#include <map>
#include <string>
#include <vector>

#include "FS.h"
#include "Script.h"
#include "ScriptService.h"

#include "deps/v8/include/v8.h"

using namespace boost;
using namespace std;
using namespace v8;

namespace avo {

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
