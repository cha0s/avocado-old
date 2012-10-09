#ifndef AVOCADO_WINDOW_H
#define AVOCADO_WINDOW_H

#include "avocado-global.h"

#include <string>

#include "../Graphics/Image.h"

namespace avo {

/**
 * @addtogroup Ui
 * @{
 */

/**
 * A %Window for displaying graphics.
 */
class Window {

public:

	/** Event polling. */
	struct Event {

		/** Standardize mouse buttons. */
		enum MouseButtons {
			LeftButton   = 1,
			MiddleButton = 2,
			RightButton  = 3,
			WheelUp      = 4,
			WheelDown    = 5
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
			int stickIndex;
			int axis;
			double value;

			bool operator == (const JoyAxis &other) {
				return other.stickIndex == stickIndex && other.axis == axis;
			}
		};

		/** Standardize joystick button down event. */
		struct JoyButtonDown {
			int stickIndex;
			int button;

			bool operator == (const JoyButtonDown &other) {
				return other.stickIndex == stickIndex && other.button == button;
			}
		};

		/** Standardize joystick button up event. */
		struct JoyButtonUp {
			int stickIndex;
			int button;

			bool operator == (const JoyButtonUp &other) {
				return other.stickIndex == stickIndex && other.button == button;
			}
		};

		/** Standardize mouse button down event. */
		struct MouseButtonDown {
			int x;
			int y;
			MouseButtons button;
		};

		/** Standardize mouse button up event. */
		struct MouseButtonUp {
			int x;
			int y;
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

		Event()
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

			resize.width = resize.height = -1;
			quit = false;
		}

		bool empty() {

			if (keyDown.size() > 0) return false;
			if (keyUp.size() > 0) return false;

			if (joyAxis.size() > 0) return false;
			if (joyButtonDown.size() > 0) return false;
			if (joyButtonUp.size() > 0) return false;

			if (mouseButtonDown.size() > 0) return false;
			if (mouseMove.size() > 0) return false;
			if (mouseButtonUp.size() > 0) return false;

			if (resize.width != -1 && resize.height != -1) return false;

			if (quit) return false;

			return true;
		}
	};

	/**
	 * Flags used when creating a window.
	 */
	enum WindowFlags {

		/** Nothing special. */
		Flags_Default    = 0,

		/** Fullscreen window. */
		Flags_Fullscreen = 1
	};

	Window();

	/**
	 * Destroy the window.
	 */
	virtual ~Window() {}

	/**
	 * Show the window.
	 */
	virtual void display() {}

	/**
	 * %Window flags.
	 */
	int flags() const;

	/**
	 * %Window height.
	 */
	int height() const;

	/**
	 * Poll events.
	 */
	virtual Event pollEvents() = 0;

	/**
	 * Render an Image onto this window.
	 */
	virtual void render(Image *working) = 0;

	/**
	 * Set the window flags.
	 */
	virtual void setFlags(WindowFlags flags = Flags_Default);

	/**
	 * Set the window size.
	 */
	virtual void setSize(int width, int height);

	/**
	 * Set whether the mouse is visible while hovering over the window.
	 */
	virtual void setMouseVisibility(bool visible) = 0;

	/**
	 * Set the window title.
	 */
	virtual void setWindowTitle(const std::string &window, const std::string &iconified = "") = 0;

	/**
	 * %Window width.
	 */
	int width() const;

	/**
	 * Manages the concrete %Window factory instance.
	 */
	static FactoryManager<Window> factoryManager;

private:

	int m_width;
	int m_height;

	int m_flags;
};

/**
 * @ingroup Manufacturing
 * @ingroup SPI
 */
template <>
class AbstractFactory<Window> {

public:

	virtual ~AbstractFactory<Window>() {}

	virtual Window *create() = 0;

};

/**
 * @}
 */

}

#endif // AVOCADO_WINDOW_H
