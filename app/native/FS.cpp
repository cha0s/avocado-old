#include "avocado-global.h"

#include <algorithm>
#include <sstream>

#include <boost/algorithm/string/predicate.hpp>
#include <boost/filesystem/fstream.hpp>

#include "FS.h"

namespace avo {

namespace FS {

std::vector<boost::filesystem::path> findFilenames(const boost::filesystem::path &path, const boost::regex &regex) {

	std::vector<boost::filesystem::path> matches;

	for (boost::filesystem::recursive_directory_iterator it(path); it != boost::filesystem::recursive_directory_iterator(); ++it) {

		if (boost::regex_search(it->path().string(), regex)) {
			matches.push_back(it->path());
		}
	}

	std::sort(matches.begin(), matches.end(), ilexicographical_compare);

	return matches;
}

std::string readString(const boost::filesystem::path &filename) {

	boost::filesystem::ifstream ifs(filename);

	return std::string(
		std::istreambuf_iterator<char>(ifs),
		std::istreambuf_iterator<char>()
	);
}

void writeString(const boost::filesystem::path &filename, const std::string &string) {

	boost::filesystem::ofstream file(filename);
	std::istringstream buffer(string);

	if (file) {
		buffer >> file.rdbuf();

		file.close();
	}
}

boost::filesystem::path qualifyPath(const boost::filesystem::path &base, const boost::filesystem::path &uri) {

	std::string baseString = base.string();
	std::string uriString = boost::filesystem::canonical(base / uri).string();

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
	std::string uriString = boost::filesystem::canonical(uri).string();

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
	m_exePath = boost::filesystem::canonical(path);
}

boost::filesystem::path m_engineRoot;

boost::filesystem::path engineRoot() {
	return m_engineRoot;
}

void setEngineRoot(const boost::filesystem::path &engineRoot) {
	m_engineRoot = boost::filesystem::canonical(engineRoot);
}

boost::filesystem::path m_resourceRoot;

boost::filesystem::path resourceRoot() {
	return m_resourceRoot;
}

void setResourceRoot(const boost::filesystem::path &resourceRoot) {
	m_resourceRoot = boost::filesystem::canonical(resourceRoot);
}

bool ilexicographical_compare(const boost::filesystem::path& l, const boost::filesystem::path& r) {

	return boost::algorithm::ilexicographical_compare(
		l.string(),
		r.string()
	);
}

}

}
