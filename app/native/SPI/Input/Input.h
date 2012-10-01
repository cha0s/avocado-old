#ifndef AVOCADO_INPUT_H
#define AVOCADO_INPUT_H

#include "avocado-global.h"

#include "Factory.h"

#include <deque>

namespace avo {

/**
 * @addtogroup Input
 * @{
 */

/**
 * Library-agnostic representation/gathering of user input.
 */
class Input {

public:

	Input();
	virtual ~Input() {}

	enum MouseButtons {
		LeftButton   = 1,
		MiddleButton = 2,
		RightButton  = 3,
		WheelUp      = 4,
		WheelDown    = 5
	};

	struct KeyDown {
		int code;
	};

	struct KeyUp {
		int code;
	};

	struct JoyAxis {
		int stick;
		int axis;
		double value;

		bool operator == (const JoyAxis &other) {
			return other.stick == stick && other.axis == axis;
		}
	};

	struct JoyButtonDown {
		int stick;
		int button;

		bool operator == (const JoyButtonDown &other) {
			return other.stick == stick && other.button == button;
		}
	};

	struct JoyButtonUp {
		int stick;
		int button;

		bool operator == (const JoyButtonUp &other) {
			return other.stick == stick && other.button == button;
		}
	};

	struct MouseButtonDown {
		MouseButtons button;
	};

	struct MouseButtonUp {
		MouseButtons button;
	};

	struct MouseMove {
		int x;
		int y;
	};

	struct Resize {
		int width;
		int height;
	};

	struct PollResults {

		std::deque<KeyDown> keyDown;
		std::deque<KeyUp> keyUp;

		std::deque<JoyAxis> joyAxis;
		std::deque<JoyButtonDown> joyButtonDown;
		std::deque<JoyButtonUp> joyButtonUp;

		std::deque<MouseButtonDown> mouseButtonDown;
		std::deque<MouseButtonUp> mouseButtonUp;
		std::deque<MouseMove> mouseMove;

		Resize resize;

		bool quit;

		PollResults()
		{
			reset();
		}

		void reset() {

			keyDown.clear();
			keyUp.clear();

			joyAxis.clear();
			joyButtonDown.clear();
			joyButtonUp.clear();

			mouseButtonDown.clear();
			mouseButtonUp.clear();
			mouseMove.clear();

			resize.width = resize.height = 0;
			quit = false;
		}
	};

	PollResults results;

	/**
	 * Get input from the concrete Input implementation.
	 */
	virtual bool poll();

	static FactoryManager<Input> factoryManager;
};

/**
 * @ingroup Manufacturing
 * @ingroup SPI
 */
template <>
class AbstractFactory<Input> {

public:

	virtual ~AbstractFactory<Input>() {}

	virtual Input *create() = 0;

};

/**
 * @}
 */

}

#endif // AVOCADO_INPUT_H
