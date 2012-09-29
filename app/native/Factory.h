#ifndef AVOCADO_FACTORY_H
#define AVOCADO_FACTORY_H

#include "avocado-global.h"

namespace avo {

/**
 * @addtogroup Manufacturing
 * @{
 */

/**
 * [Wikipedia](http://en.wikipedia.org/wiki/Abstract_factory_pattern) says:
 * > The abstract factory pattern is a software creational design pattern
 * > that provides a way to encapsulate a group of individual factories that
 * > have a common theme without specifying their concrete classes.
 */
template<class T>
class AbstractFactory {

public:

	virtual ~AbstractFactory<T>();

	/**
	 * Reimplemented as virtual by abstract factories, and non-virtual by
	 * concrete factories. Returns a new T, whose ownership is transferred to
	 * the caller.
	 */
	virtual T *create() = 0;
};

/**
 * A class used by abstract product classes to manage which factory instance
 * is responsible for instantiating concrete products.
 */
template<class T>
class FactoryManager {

private:

	/**
	 * An exception thrown by FactoryManager when a NULL factory instance is
	 * accessed.
	 */
	class factory_instance_error : public std::runtime_error {

	public:

		factory_instance_error()
			: std::runtime_error("NULL factory instance")
		{

		}
	};

public:

	FactoryManager<T>()
		: m_instance(NULL)
	{

	}

	/**
	 * Set the concrete factory instance responsible for creating concrete T
	 * instances.
	 */
	void setInstance(AbstractFactory<T> *instance) {
		m_instance = instance;
	}

	/**
	 * Retrieve the concrete factory instance responsible for creating
	 * concrete T instances.
	 */
	AbstractFactory<T> *instance() {

		if (NULL == m_instance) {
			throw factory_instance_error();
		}

		return m_instance;
	}

private:

	AbstractFactory<T> *m_instance;

};

/**
 * @}
 */

}

#endif // AVOCADO_FACTORY_H
