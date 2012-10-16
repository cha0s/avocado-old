#include "deploy.h"

#include "FS.h"

namespace avo {

void deploy(char *exeName, const std::string &target, const std::vector<std::string> &successfullyLoadedFiles, ScriptService *scriptService) {

	boost::filesystem::path targetPath;
	boost::filesystem::path targetEnginePath;
	boost::filesystem::path targetResourcePath;

	targetPath = FS::exePath() / "deploy" / target;
	targetEnginePath = targetPath / "engine";
	targetResourcePath = targetPath / "resource";

	if (
		!boost::filesystem::exists(targetPath)
		&& !boost::filesystem::create_directories(targetPath)
	) {
		throw boost::filesystem::filesystem_error(
			"Unable to create target directory.",
			boost::system::error_code()
		);
	}

	if ("native" == target) {
		std::cerr << "Deploying for native application..." << std::endl;

		// Copy main binary.
		boost::filesystem::path exeFilename = boost::filesystem::path(exeName).filename();
		boost::filesystem::copy_file(
			FS::exePath() / exeFilename,
			targetPath / exeFilename,
			boost::filesystem::copy_option::overwrite_if_exists
		);

		// Copy SPIIs.
		FS::copyDirectoryRecursively(
			FS::exePath() / "SPII",
			targetPath / "SPII"
		);

		// Copy main code.
		FS::copyDirectoryRecursively(
			FS::engineRoot() / "main" / target,
			targetEnginePath / "main" / target
		);
	}
	else if ("web" == target) {
		std::cerr << "Deploying for web browser..." << std::endl;

		// Copy main code.
		if (
			!boost::filesystem::exists(targetEnginePath / "main" / target / "Bindings")
			&& !boost::filesystem::create_directories(targetEnginePath / "main" / target / "Bindings")
		) {
			throw boost::filesystem::filesystem_error(
				"Unable to create core engine directory.",
				boost::system::error_code()
			);
		}

		std::vector<boost::filesystem::path> filenames = FS::findFilenames(
			FS::engineRoot() / "main" / target,
			boost::regex("(.*\\.js|.*\\.coffee)")
		);

		for (unsigned int i = 0; i < filenames.size(); ++i) {
			boost::filesystem::path filename = filenames[i];

			std::string code = scriptService->preCompileCode(
				FS::readString(filename),
				filename
			);

			boost::filesystem::path path = targetEnginePath / "main" / target;
			if ("Bindings" == filename.parent_path().stem().string()) {
				path /= "Bindings";
			}

			FS::writeString(
				path / (filename.stem().string() + ".js"),
				code
			);
		}

//		// Copy main code.
//		FS::copyDirectoryRecursively(
//			FS::engineRoot() / "main" / target,
//			targetEnginePath / "main" / target
//		);
	}

	// Copy resources.
	FS::copyDirectoryRecursively(
		FS::resourceRoot(),
		targetResourcePath
	);

	// Copy compilers.
	FS::copyDirectoryRecursively(
		FS::engineRoot() / "compiler",
		targetEnginePath / "compiler"
	);

	// Copy libraries.
	FS::copyDirectoryRecursively(
		FS::engineRoot() / "library",
		targetEnginePath / "library"
	);

	// Copy core engine code.
	if (
		!boost::filesystem::exists(targetEnginePath / "core")
		&& !boost::filesystem::create_directories(targetEnginePath / "core")
	) {
		throw boost::filesystem::filesystem_error(
			"Unable to create core engine directory.",
			boost::system::error_code()
		);
	}

	std::string aggregate;
	for (unsigned int i = 0; i < successfullyLoadedFiles.size(); ++i) {
		std::string filename = successfullyLoadedFiles[i];
		std::cerr << "Deploying " << filename << "..." << std::endl;

		std::string code = FS::readString(filename);

		aggregate += scriptService->preCompileCode(code, filename);
	}

	FS::writeString(
		targetEnginePath / "core" / "aggregate.js", aggregate
	);

}

}

