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

boost::filesystem::path m_resourceRoot;

boost::filesystem::path resourceRoot() {
	return m_resourceRoot;
}

void setResourceRoot(const boost::filesystem::path &root) {
	m_resourceRoot = root;
}

boost::filesystem::path unqualifyUri(const boost::filesystem::path &uri, const boost::filesystem::path &prefix) {

	std::string prefixedRoot = (resourceRoot() / prefix).string();
	std::string uriString = uri.string();

	std::string::size_type  pos;
	if (std::string::npos != (pos = uriString.find(prefixedRoot))) {
		return uriString.substr(prefixedRoot.size());
	}
	else {
		return "";
	}
}

boost::filesystem::path m_engineRoot;

boost::filesystem::path engineRoot() {
	return m_engineRoot;
}

void setEngineRoot(const boost::filesystem::path &root) {
	m_engineRoot = root;
}

boost::filesystem::path unqualifySource(const boost::filesystem::path &uri) {

	std::string prefixedRoot = engineRoot().string();
	std::string uriString = uri.string();

	std::string::size_type  pos;
	if (std::string::npos != (pos = uriString.find(prefixedRoot))) {
		return uriString.substr(prefixedRoot.size());
	}
	else {
		return "";
	}
}

bool ilexicographical_compare(const boost::filesystem::path& l, const boost::filesystem::path& r) {

	return boost::algorithm::ilexicographical_compare(
		l.string(),
		r.string()
	);
}

}

}
