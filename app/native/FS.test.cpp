#include "FS.h"

#include "test/gtest/include/gtest/gtest.h"

namespace avo {

namespace FS {

class FS : public ::testing::Test {
protected:

	virtual void SetUp() {

		// Get info about the currently running test.
		const ::testing::TestInfo* const test_info = ::testing::UnitTest::GetInstance()->current_test_info();

		boost::filesystem::path root;

		// Set the engine root based on the test case running, if it exists.
		root = engineRoot() / test_info->test_case_name() / test_info->name();
		if (boost::filesystem::exists(root)) {
			setEngineRoot(root);
		}

		// Set the resource root based on the test case running, if it exists.
		root = resourceRoot() / test_info->test_case_name() / test_info->name();
		if (boost::filesystem::exists(root)) {
			setResourceRoot(root);
		}
	}

	virtual void TearDown() {

		// Set engine root to <EXEPATH>/test/resource.
		avo::FS::setEngineRoot(avo::FS::exePath() / "test" / "engine");

		// Set resource root to <EXEPATH>/test/resource.
		avo::FS::setResourceRoot(avo::FS::exePath() / "test" / "resource");
	}
};

TEST_F(FS, findFilenames) {

	// Discover all files in the resource directory.
	std::vector<boost::filesystem::path> filenames = findFilenames(
		resourceRoot()
	);

	// There should be 3.
	ASSERT_EQ(3U, filenames.size());

	// They should be sorted alphabetically.
	EXPECT_EQ(resourceRoot() / "one"  , filenames[0].string());
	EXPECT_EQ(resourceRoot() / "three", filenames[1].string());
	EXPECT_EQ(resourceRoot() / "two"  , filenames[2].string());
}

TEST_F(FS, readString) {

	// Read in a file.
	EXPECT_EQ(readString(resourceRoot() / "test.txt"), "foobar");
}

TEST_F(FS, writeString) {

	// Write a file.
	writeString(resourceRoot() / "test.txt", "hello");

	// Ensure it exists.
	ASSERT_TRUE(boost::filesystem::exists(resourceRoot() / "test.txt"));

	// Ensure it contains the correct text..
	EXPECT_EQ(readString(resourceRoot() / "test.txt"), "hello");

	boost::filesystem::remove(resourceRoot() / "test.txt");
}

TEST_F(FS, setEngineRoot) {

	// Set properly.
	EXPECT_EQ(
		engineRoot().string(),
		(exePath() / "test" / "engine" / "FS" / "setEngineRoot").string()
	);

	// Non-existent root.
	EXPECT_THROW(
		setEngineRoot("/this/will/throw"),
		boost::filesystem::filesystem_error
	);

}

TEST_F(FS, setResourceRoot) {

	// Set properly.
	EXPECT_EQ(
		resourceRoot().string(),
		(exePath() / "test" / "resource" / "FS" / "setResourceRoot").string()
	);

	// Non-existent root.
	EXPECT_THROW(
		setResourceRoot("/this/will/throw"),
		boost::filesystem::filesystem_error
	);

}

TEST_F(FS, qualifyPath) {

	// Normal usage.
	EXPECT_EQ(
		qualifyPath(resourceRoot(), "/test.txt").string(),
		resourceRoot() / "test.txt"
	);

	// Out and then back in.
	EXPECT_EQ(
		qualifyPath(
			resourceRoot(),
			boost::filesystem::path("..") / "qualifyPath" / "test.txt"
		).string(),
		resourceRoot() / "test.txt"
	);

	// Trying to break out.
	EXPECT_THROW(
		qualifyPath(
			resourceRoot(),
			boost::filesystem::path("..") / "setResourceRoot"
		).string(),
		std::runtime_error
	);

	// Doesn't exist.
	EXPECT_THROW(
		qualifyPath(resourceRoot(), "/doesNotExist").string(),
		boost::filesystem::filesystem_error
	);
}

TEST_F(FS, unqualifyPath) {

	// Normal usage.
	EXPECT_EQ(
		unqualifyPath(resourceRoot(), resourceRoot() / "test.txt").string(),
		"/test.txt"
	);

	// Out and then back in.
	EXPECT_EQ(
		unqualifyPath(
			resourceRoot(),
			resourceRoot() / ".." / "unqualifyPath" / "test.txt"
		).string(),
		"/test.txt"
	);

	// Trying to break out.
	EXPECT_THROW(
		unqualifyPath(
			resourceRoot(),
			resourceRoot() / ".." / "setResourceRoot"
		).string(),
		std::runtime_error
	);

	// Doesn't exist.
	EXPECT_THROW(
		unqualifyPath(resourceRoot(), resourceRoot() / ".." / "doesNotExist").string(),
		boost::filesystem::filesystem_error
	);
}

}

}
