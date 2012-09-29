#include "avocado-global.h"

#include <boost/filesystem/operations.hpp>

#include "FS.h"
#include "SPI/Script/Script.h"

#include "SPI/Script/v8/v8ScriptSystem.h"

/** Application entry point. */
int main(int argc, char **argv) {
	AVOCADO_UNUSED(argc);

	// Set engine root to <EXEPATH>/engine
	avo::FS::setEngineRoot(
		boost::filesystem::canonical(boost::filesystem::absolute(
			boost::filesystem::path(argv[0]).parent_path() / "engine",
			boost::filesystem::current_path()
		))
	);

	// We're only using v8 as a Script SPI (for now).
	avo::ScriptSystem::factoryManager.setInstance(avo::v8ScriptSystem::factory);

	// Set resource root to <EXEPATH>/resource
	avo::FS::setResourceRoot(
		boost::filesystem::canonical(boost::filesystem::absolute(
			boost::filesystem::path(argv[0]).parent_path() / "resource",
			boost::filesystem::current_path()
		))
	);

	// Instantiate the Script system.
	avo::ScriptSystem *scriptSystem = avo::ScriptSystem::factoryManager.instance()->create();

	try {

		// The native main code's path.
		boost::filesystem::path nativeMainPath = avo::FS::engineRoot() / "main" / "native";

		// Initialize the engine.
		scriptSystem->initialize();
		avo::Script *initialize = scriptSystem->scriptFromFile(
			nativeMainPath / "Initialize.coffee"
		);
		initialize->execute();

		// Load core code.
		scriptSystem->loadCore();

		// Execute the main loop.
		avo::Script *main = scriptSystem->scriptFromFile(
			nativeMainPath / "Main.coffee"
		);
		main->execute();

		// Finish and clean up.
		avo::Script *finish = scriptSystem->scriptFromFile(
			nativeMainPath / "Finish.coffee"
		);
		finish->execute();

		delete finish;
		delete main;
		delete initialize;
	}
	catch (std::exception &e) {

		// Report any errors.
		std::cerr << e.what() << std::endl;
	}

	delete scriptSystem;

	return 0;
}
