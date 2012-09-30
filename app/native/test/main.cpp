#include <gtest/gtest.h>

#include "../FS.h"

int main(int argc, char **argv) {
	::testing::InitGoogleTest(&argc, argv);

	// Set <EXEPATH>.
	avo::FS::setExePath(
		boost::filesystem::canonical(boost::filesystem::absolute(
			boost::filesystem::path(argv[0]).parent_path(),
			boost::filesystem::current_path()
		))
	);

	// Set resource root to <EXEPATH>/test/resource.
	avo::FS::setResourceRoot(avo::FS::exePath() / "test" / "resource");

	// Set resource root to <EXEPATH>/test/resource.
	avo::FS::setEngineRoot(avo::FS::exePath() / "test" / "engine");

	return RUN_ALL_TESTS();
}
