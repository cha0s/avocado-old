#ifndef AVOCADO_WINDOW_H
#define AVOCADO_WINDOW_H

#include "avocado-global.h"

#include <string>

#include "Image.h"

namespace avo {

/**
 * @addtogroup Graphics
 * @{
 */

/**
 * A %Window for displaying graphics.
 */
class Window {

public:

	/**
	 * Flags used when creating a window.
	 */
	enum WindowFlags {

		/** Nothing special. */
		Flags_Default    = 0,

		/** Fullscreen window. */
		Flags_Fullscreen = 1
	};

	/**
	 * Destroy the window.
	 */
	virtual ~Window() {}

	/**
	 * %Window height.
	 */
	int height() const;

	/**
	 * Render an Image onto this window.
	 */
	virtual void render(Image *working) = 0;

	/**
	 * Set the window parameters.
	 */
	virtual void set(int width, int height, WindowFlags f = Flags_Default);

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
