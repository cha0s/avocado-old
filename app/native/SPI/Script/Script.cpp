#include "avocado-global.h"

#include "Script.h"

#include "FS.h"

namespace avo {

FactoryManager<Script> Script::factoryManager;

Script::Script()
{
}

Script::~Script() {
}

}
