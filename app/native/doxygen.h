/** @mainpage Avocado
 *
 * @section whaa What's going on here?
 *
 * An ambitious project to create an open, thoroughly moddable game engine
 * accessible to anyone willing to invest the time needed to figure out how
 * to use it.
 *
 * @section whycome How come it sucks?
 *
 * Because programming is hard.
 *
 * @section naaw No way man, keep at it!
 *
 * Thanks! Will do.
 */

/**
 * @namespace avo
 *
 * @brief Everything here is organized underneath the avo namespace.
 */

/**
 * @defgroup SPI Service Provider Interfaces
 *
 * @brief Simply put, SPI implementations (SPIIs) provide an way for the engine
 * to do interesting and dynamic things.
 *
 * [Wikipedia quotes Java's official documentation](http://en.wikipedia.org/wiki/Service_provider_interface):
 *
 * > A service is a well-known set of interfaces and (usually abstract) classes. A service provider is a specific implementation of a service. The classes in a provider typically implement the interfaces and subclass the classes defined in the service itself. Service providers can be installed in an implementation of the Java platform in the form of extensions, that is, jar files placed into any of the usual extension directories. Providers can also be made available by adding them to the application's class path or by some other platform-specific means.
 *
 * The canonical example of a SPI is the @link ScriptService scripting engine
 * interface @endlink. This SPI is the most core in the Avocado engine, as all
 * other SPIIs are managed through it. Therefore, the script SPII always
 * precludes all other SPIIs.
 *
 * The default script SPII in Avocado is the
 * [V8 JavaScript engine](http://code.google.com/p/v8/).
 *
 */

/**
 * @defgroup Manufacturing Manufacturing
 *
 * @brief Manufacturing functionality handles @link AbstractFactory abstract
 * factory @endlink definition and managing concrete factory instances.
 *
 * Concrete factory implementations are determined by SPI implementations.
 */

/**
 * @defgroup Global Globals and miscellany
 *
 * @brief Global macros and other miscellany.
 */
