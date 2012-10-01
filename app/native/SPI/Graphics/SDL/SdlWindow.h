#ifndef AVOCADO_SDLWINDOW_H
#define AVOCADO_SDLWINDOW_H

#include "avocado-global.h"

#include <string>

#include "../Window.h"

#include "SdlImage.h"

namespace avo {

/**
 * @addtogroup Graphics
 * @{
 */

/**
 * Represents the screen buffers and operations.
 *
 * @ingroup SDL
 */
class SdlWindow : public Window {

public:

	SdlWindow();
	~SdlWindow();

	void set(int width, int height, WindowFlags f = Flags_Default);
	void render(Image *working);

	void setMouseVisibility(bool visible);

	void setWindowTitle(const std::string &window, const std::string &iconified = "");

	static AbstractFactory<SdlWindow> *factory;

private:

	SdlImage *image;
};

/**
 * @ingroup Resources
 */
template <>
class AbstractFactory<SdlWindow> : public AbstractFactory<Window> {

public:

	virtual ~AbstractFactory<SdlWindow>() {}

	SdlWindow *create() {
		return new SdlWindow();
	}

};

/**
 * @}
 */

}

#endif // AVOCADO_SDLWINDOW_H
