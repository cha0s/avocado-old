#include "FS.h"

#include "test/gtest/include/gtest/gtest.h"

namespace avo {

namespace FS {

TEST(Filesystem, FindFilenamesTest) {

	std::vector<boost::filesystem::path> filenames = findFilenames(
		"test/gtest/include",
		boost::regex(".*\\.h")
	);

	EXPECT_EQ(24U, filenames.size());
}


}

}
