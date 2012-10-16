#ifndef AVOCADO_DEPLOY_H
#define AVOCADO_DEPLOY_H

#include "SPI/Script/ScriptService.h"

namespace avo {

void deploy(char *exeName, const std::string &target, const std::vector<std::string> &successfullyLoadedFiles, ScriptService *scriptService);

}

#endif // AVOCADO_DEPLOY_H
