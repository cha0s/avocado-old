#ifndef AVOCADO_FS_H
#define AVOCADO_FS_H

#include "avocado-global.h"

#include <string>

#include <boost/filesystem.hpp>
#include <boost/regex.hpp>

namespace avo {

namespace FS {

/**
 * Find a sorted list of filenames.
 */
std::vector<boost::filesystem::path> findFilenames(const boost::filesystem::path &path, const boost::regex &regex = boost::regex(".*"));

/**
 * Read filename into a string.
 */
std::string readString(const boost::filesystem::path &filename);

/**
 * Write a string to filename.
 */
void writeString(const boost::filesystem::path &filename, const std::string &string);

/**
 * Strip off the qualifying part of a path. For example, calling like:
 *
 *     unqualifyPath("/one/two", "/one/two/three.txt");
 *
 * will return
 *
 *     "/three.txt"
 */
boost::filesystem::path unqualifyPath(const boost::filesystem::path &base, const boost::filesystem::path &uri);

/**
 * Get the path of the executable.
 */
boost::filesystem::path exePath();

/**
 * Set the path of the executable.
 */
void setExePath(const boost::filesystem::path &root);

/**
 * Get the root path of engine code.
 */
boost::filesystem::path engineRoot();

/**
 * Set the root path of engine code.
 */
void setEngineRoot(const boost::filesystem::path &engineRoot);

/**
 * Get the root path of resources.
 */
boost::filesystem::path resourceRoot();

/**
 * Set the root path of resources.
 */
void setResourceRoot(const boost::filesystem::path &resourceRoot);

/**
 * Helper function to compare two paths case-insensitively.
 */
bool ilexicographical_compare(const boost::filesystem::path& l, const boost::filesystem::path& r);

}

}

#endif // AVOCADO_FS_H
