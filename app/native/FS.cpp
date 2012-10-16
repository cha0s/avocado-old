#include "avocado-global.h"

#include <algorithm>
#include <sstream>

#include <boost/algorithm/string/predicate.hpp>
#include <boost/filesystem/fstream.hpp>

#include "FS.h"

namespace avo {

namespace FS {

namespace fs = boost::filesystem;

void copyDirectoryRecursively(const boost::filesystem::path &source, const boost::filesystem::path &destination) {

	// Check whether the function call is valid
	if(!fs::exists(source) || !fs::is_directory(source)) {
		throw fs::filesystem_error(
			"Source directory " + source.string() + " does not exist or is not a directory.",
			boost::system::error_code()
		);
	}

	// Create the destination directory
	if (!fs::exists(destination) && !fs::create_directories(destination)) {
		throw fs::filesystem_error(
			"Unable to create destination directory" + destination.string(),
			boost::system::error_code()
		);
	}

    // Iterate through the source directory
    for (fs::directory_iterator file(source); file != fs::directory_iterator(); ++file) {
		fs::path current(file->path());
		if (fs::is_directory(current)) {
			// Found directory: Recursion
			copyDirectoryRecursively(
				current,
				destination / current.filename()
			);
		}
		else {
			// Found file: Copy
			fs::copy_file(
				current,
				destination / current.filename(),
				fs::copy_option::overwrite_if_exists
			);
		}
    }
}

std::vector<boost::filesystem::path> findFilenames(const boost::filesystem::path &path, const boost::regex &regex) {

	std::vector<fs::path> matches;

	for (fs::recursive_directory_iterator it(path); it != fs::recursive_directory_iterator(); ++it) {

		if (boost::regex_search(it->path().string(), regex)) {
			matches.push_back(it->path());
		}
	}

	std::sort(matches.begin(), matches.end(), ilexicographical_compare);

	return matches;
}

std::string readString(const boost::filesystem::path &filename) {

	fs::ifstream ifs(filename);

	return std::string(
		std::istreambuf_iterator<char>(ifs),
		std::istreambuf_iterator<char>()
	);
}

void writeString(const boost::filesystem::path &filename, const std::string &string) {

	fs::ofstream file(filename);
	std::istringstream buffer(string);

	if (file) {
		buffer >> file.rdbuf();

		file.close();
	}
}

boost::filesystem::path qualifyPath(const boost::filesystem::path &base, const boost::filesystem::path &uri) {

	std::string baseString = base.string();
	std::string uriString = fs::canonical(base / uri).string();

	std::string::size_type  pos;
	if (std::string::npos != (pos = uriString.find(baseString))) {
		return uriString;
	}
	else {
		throw std::runtime_error("qualifyPath() detected a directory traversal exploit!");
	}
}

boost::filesystem::path unqualifyPath(const boost::filesystem::path &base, const boost::filesystem::path &uri) {

	std::string baseString = base.string();
	std::string uriString = fs::canonical(uri).string();

	std::string::size_type  pos;
	if (std::string::npos != (pos = uriString.find(baseString))) {
		return uriString.substr(baseString.size());
	}
	else {
		throw std::runtime_error("unqualifyPath() detected a directory traversal exploit!");
	}
}

boost::filesystem::path m_exePath;

boost::filesystem::path exePath() {
	return m_exePath;
}

void setExePath(const boost::filesystem::path &path) {
	m_exePath = fs::canonical(path);
}

boost::filesystem::path m_engineRoot;

boost::filesystem::path engineRoot() {
	return m_engineRoot;
}

void setEngineRoot(const boost::filesystem::path &engineRoot) {
	m_engineRoot = fs::canonical(engineRoot);
}

boost::filesystem::path m_resourceRoot;

boost::filesystem::path resourceRoot() {
	return m_resourceRoot;
}

void setResourceRoot(const boost::filesystem::path &resourceRoot) {
	m_resourceRoot = fs::canonical(resourceRoot);
}

bool ilexicographical_compare(const boost::filesystem::path& l, const boost::filesystem::path& r) {

	return boost::algorithm::ilexicographical_compare(
		l.string(),
		r.string()
	);
}

}

}
