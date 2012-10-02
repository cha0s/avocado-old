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

	/** Standardize mouse buttons. */
	enum MouseButtons {
		LeftButton   = 1,
		MiddleButton = 2,
		RightButton  = 3,
		WheelUp      = 4,
		WheelDown    = 5
	};

	/** Standardize special key codes. */
	struct SpecialKeyMap {
		int UpArrow;
		int RightArrow;
		int DownArrow;
		int LeftArrow;
	};

	/** Standardize key down event. */
	struct KeyDown {
		int code;
	};

	/** Standardize key up event. */
	struct KeyUp {
		int code;
	};

	/** Standardize joystick axis event. */
	struct JoyAxis {
		int stick;
		int axis;
		double value;

		bool operator == (const JoyAxis &other) {
			return other.stick == stick && other.axis == axis;
		}
	};

	/** Standardize joystick button down event. */
	struct JoyButtonDown {
		int stick;
		int button;

		bool operator == (const JoyButtonDown &other) {
			return other.stick == stick && other.button == button;
		}
	};

	/** Standardize joystick button up event. */
	struct JoyButtonUp {
		int stick;
		int button;

		bool operator == (const JoyButtonUp &other) {
			return other.stick == stick && other.button == button;
		}
	};

	/** Standardize mouse button down event. */
	struct MouseButtonDown {
		MouseButtons button;
	};

	/** Standardize mouse button up event. */
	struct MouseButtonUp {
		MouseButtons button;
	};

	/** Standardize mouse move event. */
	struct MouseMove {
		int x;
		int y;
	};

	/** Standardize screen resize event. */
	struct Resize {
		int width;
		int height;
	};

	/** Input polling results. */
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
	 * Standardized map of spcial keys.
	 */
	virtual SpecialKeyMap specialKeyMap() = 0;

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
