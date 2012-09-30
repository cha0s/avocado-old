#include "avocado-global.h"

#include <QtCore/QThread>

#include "QtCoreService.h"

namespace avo {

AbstractFactory<QtCoreService> *QtCoreService::factory = new AbstractFactory<QtCoreService>;

}
