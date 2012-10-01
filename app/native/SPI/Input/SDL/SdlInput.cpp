#include "avocado-global.h"

#include "SdlInput.h"

#include "SDL/SDL.h"

#include <algorithm>
#include "math.h"

using namespace std;

namespace avo {

AbstractFactory<SdlInput> *SdlInput::factory = new AbstractFactory<SdlInput>;

SdlInput::SdlInput()
	: Input()
	, numJoysticks(0)
	, joystick(NULL)
{

	numJoysticks = SDL_NumJoysticks();

	if (numJoysticks > 0) {
	    SDL_JoystickEventState(SDL_ENABLE);

	    joystick = new SDL_Joystick *[numJoysticks];

	    for (int i = 0; i < numJoysticks; i++) {
		    joystick[i] = SDL_JoystickOpen(i);
	    }
	}
}

bool SdlInput::poll() {
	bool anyResults = Input::poll();

	static SDL_Event event;
	while (SDL_PollEvent(&event)) {

		switch (event.type) {

		case SDL_KEYDOWN: {
			anyResults = true;

			KeyDown keyDown = {event.key.keysym.sym};
			results.keyDown.push_back(keyDown);

			break;
		}

		case SDL_KEYUP: {
			anyResults = true;

			KeyUp keyUp = {event.key.keysym.sym};
			results.keyUp.push_back(keyUp);

			break;
		}

		case SDL_JOYAXISMOTION: {
			anyResults = true;

			JoyAxis joyAxis = {
				event.jaxis.which,
				event.jaxis.axis,
				event.jaxis.value / static_cast<double>(JoystickMagnitude)
			};

			deque<JoyAxis>::iterator i = find(
				results.joyAxis.begin(),
				results.joyAxis.end(),
				joyAxis
			);

			if (results.joyAxis.end() == i) {
				results.joyAxis.push_back(joyAxis);
			}
			else {
				i->value = joyAxis.value;
			}

			break;
		}

		case SDL_JOYBUTTONDOWN: {
			anyResults = true;

			JoyButtonDown joyButtonDown = {
				event.jbutton.which,
				event.jbutton.button
			};

			deque<JoyButtonDown>::iterator i = find(
				results.joyButtonDown.begin(),
				results.joyButtonDown.end(),
				joyButtonDown
			);

			if (results.joyButtonDown.end() == i) {
				results.joyButtonDown.push_back(joyButtonDown);
			}

			break;
		}

		case SDL_JOYBUTTONUP: {
			anyResults = true;

			JoyButtonUp joyButtonUp = {
				event.jbutton.which,
				event.jbutton.button
			};

			deque<JoyButtonUp>::iterator i = find(
				results.joyButtonUp.begin(),
				results.joyButtonUp.end(),
				joyButtonUp
			);

			if (results.joyButtonUp.end() == i) {
				results.joyButtonUp.push_back(joyButtonUp);
			}

			break;
		}

		case SDL_MOUSEBUTTONDOWN: {
			anyResults = true;

			MouseButtons button;
			switch (event.button.button) {
				case SDL_BUTTON_LEFT: button = LeftButton; break;
				case SDL_BUTTON_MIDDLE: button = MiddleButton; break;
				case SDL_BUTTON_RIGHT: button = RightButton; break;
				case SDL_BUTTON_WHEELUP: button = WheelUp; break;
				case SDL_BUTTON_WHEELDOWN: button = WheelDown; break;
			}
			MouseButtonDown mouseDown = {button};
			results.mouseButtonDown.push_back(mouseDown);

			break;
		}

		case SDL_MOUSEBUTTONUP: {
			anyResults = true;

			MouseButtons button;
			switch (event.button.button) {
				case SDL_BUTTON_LEFT: button = LeftButton; break;
				case SDL_BUTTON_MIDDLE: button = MiddleButton; break;
				case SDL_BUTTON_RIGHT: button = RightButton; break;
				case SDL_BUTTON_WHEELUP: button = WheelUp; break;
				case SDL_BUTTON_WHEELDOWN: button = WheelDown; break;
			}
			MouseButtonUp mouseUp = {button};
			results.mouseButtonUp.push_back(mouseUp);

			break;
		}

		case SDL_MOUSEMOTION: {
			anyResults = true;

			MouseMove mouseMove = {
				event.motion.x,
				event.motion.y
			};
			results.mouseMove.push_back(mouseMove);

			break;
		}

		case SDL_QUIT: {
			anyResults = true;

			results.quit = true;
			break;
		}

		case SDL_VIDEORESIZE: {
			anyResults = true;

			results.resize.width = event.resize.w;
			results.resize.height = event.resize.h;

			break;
		}

		default: {
			break;

		}

		}
	}

	return anyResults;
}
}
