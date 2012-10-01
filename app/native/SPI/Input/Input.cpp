#include "avocado-global.h"

#include "Input.h"
namespace avo {

FactoryManager<Input> Input::factoryManager;

Input::Input()
{
}

bool Input::poll() {
	results.reset();

	return false;
}

}
