#ifndef AVOCADO_RESOURCEMANAGER_H
#define AVOCADO_RESOURCEMANAGER_H

#include "avocado-global.h"

#include <map>
#include <string>

#include "Factory.h"
#include "FS.h"

namespace avo {

/**
 * @addtogroup Resources
 * @{
 */

/**
 * Manage resources of a given type.
 */
template <class T>
class ResourceManager {

private:

	/**
	 * Wrapper around each resource to manage reference counts..
	 */
	class Resource {

	public:

		/** The resource pointer. */
		T *data;

		/** How many times this resource has been loaded. */
		int referenceCount;
	};

public:

	/**
	 * Shut down a ResourceManager. Unconditionally destroy cached resources
	 * and metadata.
	 */
	~ResourceManager() {
		forceReleaseAll();
	}

	/**
	 * Load a resource. If the resource hasn't been loaded then it will be
	 * cached and the cache will hit on subsequent loads of the same
	 * resource.
	 *
	 * Each load will increment the reference counter for the resource.
	 */
	T *load (const boost::filesystem::path &uri) {

		T *resource = NULL;

		try {

			// Qualify the URI with the resource root. Throws if the resource
			// doesn't exist, or if the resource isn't within the resource
			// root.
			boost::filesystem::path qualified = FS::qualifyPath(
				FS::resourceRoot(),
				uri
			);

			// We only have to load from the factory if it hasn't been cached
			// yet. This will throw if the factory fails to load the resource.
			if ((!resourceIsCached(qualified))) {
				resourceMap[qualified].data = T::factoryManager.instance()->create(qualified);
			}

			// Increment the reference count;
			resourceMap[qualified].referenceCount++;

			resource = resourceMap[qualified].data;
		}
		catch (std::exception &e) {
			throw std::runtime_error(std::string("Resource loading failed: ") + e.what());
		}

		return resource;
	}

	/**
	 * Decrement the reference count for a resource. If it reaches 0, the
	 * resource will be released immediately.
	 */
	bool release(const boost::filesystem::path &uri) {
		return m_release(uri);
	}

	/**
	 * Force release all resources immediately.
	 */
	void forceReleaseAll() {
		while (!resourceMap.empty()) {
			m_release(resourceMap.begin()->first, false);
		}
	}

private:

	bool m_release(const boost::filesystem::path &uri, bool referenceCheck = true) {
		if (!resourceIsCached(uri)) return false;

		// If we have a record of this resource, decrement the
		// references. If the references have reached 0, or
		// if the check has been overidden, release the resource.
		if (--resourceMap[uri].referenceCount != 0 && referenceCheck) return false;

		// Release the resource.
		delete resourceMap[uri].data;
		resourceMap.erase(uri);

		return true;
	}

	bool resourceIsCached(const boost::filesystem::path &uri) {
		return (resourceMap.find(uri) != resourceMap.end());
	}

	std::map<boost::filesystem::path, Resource> resourceMap;

};

/**
 * @}
 */

}

#endif // AVOCADO_RESOURCEMANAGER_H
