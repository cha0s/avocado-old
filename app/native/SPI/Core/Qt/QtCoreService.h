#ifndef AVOCADO_QTCORESERVICE_H
#define AVOCADO_QTCORESERVICE_H

#include "avocado-global.h"

#include "../CoreService.h"

namespace avo {

/**
 * @addtogroup Core
 * @{
 */

/**
 * @ingroup @Qt
 */
class QtCoreService : public CoreService {

public:

	static AbstractFactory<QtCoreService> *factory;

};

/**
 * @ingroup Resources
 */
template <>
class AbstractFactory<QtCoreService> : public AbstractFactory<CoreService> {

public:

	virtual ~AbstractFactory<QtCoreService>() {}

	QtCoreService *create() { return new QtCoreService() ; }

};

/**
 * @}
 */

}

#endif // AVOCADO_QTCORESERVICE_H
