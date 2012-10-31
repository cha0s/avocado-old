#include "avocado-global.h"

#include <boost/filesystem/operations.hpp>

#include <boost/program_options/options_description.hpp>
#include <boost/program_options/parsers.hpp>
#include <boost/program_options/variables_map.hpp>

#include "deploy.h"
#include "FS.h"
#include "SPI/Script/ScriptService.h"
#include "SPI/SpiiLoader.h"

namespace po = boost::program_options;

/** Application entry point. */
int main(int argc, char **argv) {
	AVOCADO_UNUSED(argc);

	try {

		// Set <EXEPATH>.
		avo::FS::setExePath(boost::filesystem::canonical(boost::filesystem::absolute(
			boost::filesystem::path(argv[0]).parent_path(),
			boost::filesystem::current_path()
		)));

		// Set engine root to <EXEPATH>/engine.
		avo::FS::setEngineRoot(avo::FS::exePath() / "engine");

		// The native main code's filepath.
		boost::filesystem::path nativeMainPath = avo::FS::engineRoot() / "main" / "native";

		// Set resource root to <EXEPATH>/resource.
		avo::FS::setResourceRoot(avo::FS::exePath() / "resource");

		// Declare the supported options.
		po::options_description desc("Allowed options");
		desc.add_options()
		    ("help", "produce help message")
		    ("deploy", po::value<std::string>(), "deployment target (native, web)")
		;

		po::variables_map vm;
		po::store(po::parse_command_line(argc, argv, desc), vm);
		po::notify(vm);

		if (vm.count("help")) {
		    std::cout << desc << "\n";
		    return 1;
		}

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
		std::vector<boost::filesystem::path> scripts = ScriptService->loadCore();

		avo::Script *main = ScriptService->scriptFromFile(
			nativeMainPath / "Main.coffee"
		);

		if (vm.count("deploy")) {

			// Do the deployment.
			avo::deploy(
				argv[0],
				vm["deploy"].as<std::string>(),
				scripts,
				ScriptService
			);
		}
		else {

			// Execute the main loop.
			main->execute();
		}

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
