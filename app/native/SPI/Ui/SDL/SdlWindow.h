#ifndef AVOCADO_SDLWINDOW_H
#define AVOCADO_SDLWINDOW_H

#include "avocado-global.h"

#include <string>

#include "../Window.h"

#include "../../Graphics/SDL/SdlImage.h"

namespace avo {

/**
 * @addtogroup Ui
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

	Event pollEvents();

	void render(Image *working);

	void set(int width, int height, WindowFlags f = Flags_Default);

	void setMouseVisibility(bool visible);

	void setWindowTitle(const std::string &window, const std::string &iconified = "");

	static AbstractFactory<SdlWindow> *factory;

private:

	SdlImage *image;
};

/**
 * @ingroup Manufacturing
 * @ingroup SDL
 * @ingroup SPI
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
