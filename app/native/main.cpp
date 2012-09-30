#include "avocado-global.h"

#include <boost/filesystem/operations.hpp>

#include "FS.h"
#include "SPI/Script/ScriptService.h"
#include "SPI/SpiiLoader.h"

/** Application entry point. */
int main(int argc, char **argv) {
	AVOCADO_UNUSED(argc);

	// Set <EXEPATH>.
	avo::FS::setExePath(
		boost::filesystem::canonical(boost::filesystem::absolute(
			boost::filesystem::path(argv[0]).parent_path(),
			boost::filesystem::current_path()
		))
	);

	// Set engine root to <EXEPATH>/engine.
	avo::FS::setEngineRoot(avo::FS::exePath() / "engine");

	// The native main code's filepath.
	boost::filesystem::path nativeMainPath = avo::FS::engineRoot() / "main" / "native";

	// Set resource root to <EXEPATH>/resource.
	avo::FS::setResourceRoot(avo::FS::exePath() / "resource");

	try {

		// We're only using v8 as a Script SPII (for now).
		avo::SpiiLoader<avo::ScriptService> scriptServiceSpiiLoader;
		scriptServiceSpiiLoader.implementSpi("v8");

		// Instantiate the Script system.
		avo::ScriptService *ScriptService = avo::ScriptService::factoryManager.instance()->create();

		// Initialize the engine.
		avo::Script *initialize = ScriptService->scriptFromFile(
			nativeMainPath / "Initialize.coffee"
		);
		initialize->execute();

		// Load core code.
		ScriptService->loadCore();

		// Execute the main loop.
		avo::Script *main = ScriptService->scriptFromFile(
			nativeMainPath / "Main.coffee"
		);
		main->execute();

		// Finish and clean up.
		avo::Script *finish = ScriptService->scriptFromFile(
			nativeMainPath / "Finish.coffee"
		);
		finish->execute();

		delete finish;
		delete main;
		delete initialize;

		delete ScriptService;
	}
	catch (std::exception &e) {

		// Report any errors.
		std::cerr << "Uncaught exception: " << e.what() << std::endl;
	}

	return 0;
}
