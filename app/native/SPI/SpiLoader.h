#ifndef AVOCADO_SPILOADER_H
#define AVOCADO_SPILOADER_H

#include "avocado-global.h"

#include <boost/extension/shared_library.hpp>
#include <boost/function.hpp>

#include "FS.h"

namespace avo {

/**
 * @addtogroup SPI
 * @{
 */

/**
 * %SpiLoader handles dynamically loading SPI implementations. By default, SPI
 * implementations are located within \<EXEPATH\>/SPI.
 *
 * SPIs follow the naming convention:
 *
 *     [SPI_NAME]-[SPI_IMPLEMENTATION].spi
 *
 * For example, by default the v8 ScriptSystem SPI implementation will be
 * located at \<EXEPATH\>/SPI/ScriptSystem-v8.spi.
 */
template<typename T>
class SpiLoader {

private:

	/**
	 * @brief Thrown when loading an SPI implementation fails.
	 */
	class spi_implementation_error : public std::runtime_error {

	public:

		spi_implementation_error(const std::string &text)
			: std::runtime_error("SPI implemntation failure: " + text)
		{
		}

	};

public:

	SpiLoader<T>()
		: m_library(NULL)
	{
	}

	~SpiLoader() {

		// Unload any implementation.
		if (NULL != m_library) delete m_library;
	}

	/**
	 * This function handles dynamically loading an SPI implementation. It
	 * will clean up any previous SPI implementation (if any), then it'll pass
	 * T's factory manager to the %implementSpi() function located within
	 * the SPI implementation.
	 */
	void implementSpi(const std::string &implementation) {

		// Only one implementation may be loaded at once. If any previous
		// implementation exists, unload it.
		if (NULL != m_library) delete m_library;

		// By default, load SPI implementations from
		// <EXEPATH>/SPI/[SPI_NAME]-[SPI_IMPLEMENTATION].
		boost::filesystem::path spiPath = avo::FS::exePath();
		spiPath /= "SPI";
		spiPath /= T::name() + "-" + implementation + ".spi";

		// Load the shared library.
		m_library = new boost::extensions::shared_library(
			spiPath.string()
		);

		// Try opening it.
		if (!m_library->open()) {

			throw spi_implementation_error(
				"Couldn't load " + T::name() + "'s " + implementation + " SPI implementation."
			);
		}

		// Extract the implementSPI function from within the shared library.
		boost::function<void (FactoryManager<T> &)> implementSpi(
			m_library->get<void, FactoryManager<T> &>("implementSpi")
		);
		if (!implementSpi) {

			throw spi_implementation_error(
				"Couldn't find implementSpi() within " + T::name() + "'s " + implementation + " SPI implementation."
			);
		}

		// Pass the manager to implementSpi().
		implementSpi(T::factoryManager);
	}

private:

	boost::extensions::shared_library *m_library;

};

/**
 * @}
 */

}

#endif // AVOCADO_SPILOADER_H
