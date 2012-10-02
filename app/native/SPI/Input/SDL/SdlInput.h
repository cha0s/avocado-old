#ifndef AVOCADO_SDLINPUT_H
#define AVOCADO_SDLINPUT_H

#include "avocado-global.h"

#include "SDL/SDL.h"

#include "../Input.h"

namespace avo {

/**
 * @addtogroup Input
 * @{
 */

/**
 * SDL representation/gathering of user input.
 *
 * @ingroup SDL
 */
class SdlInput : public Input {

private:

	enum {
		JoystickMagnitude = 32767
	};

public:

	SdlInput();

	bool poll();

	SpecialKeyMap specialKeyMap();

	static AbstractFactory<SdlInput> *factory;

	int numJoysticks;
	SDL_Joystick **joystick;
};

/**
 * @ingroup Manufacturing
 * @ingroup SDL
 * @ingroup SPI
 */
template <>
class AbstractFactory<SdlInput> : public AbstractFactory<Input> {

public:

	virtual ~AbstractFactory<SdlInput>() {}

	virtual SdlInput *create() { return new SdlInput(); }

};

/**
 * @}
 */

}

#endif // AVOCADO_SDLINPUT_H
