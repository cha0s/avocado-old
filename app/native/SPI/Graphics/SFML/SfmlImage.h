#ifndef AVOCADO_SFMLIMAGE_H
#define AVOCADO_SFMLIMAGE_H

#include "avocado-global.h"

#include <SFML/Graphics.hpp>

#include "../Image.h"

namespace avo {

/**
 * @addtogroup Graphics
 * @{
 */

/**
 * SFML image SPI implementation (SPII). The SPII uses sf::RenderTexture to
 * implement the image operations.
 *
 * @ingroup Resources
 * @ingroup SFML
 */
class SfmlImage : public Image {

public:

	friend class SfmlFont;
	friend class SfmlWindow;

	/**
	 * Build a NULL sf::RenderTexture.
	 */
	SfmlImage();

	/**
	 * Load an sf::RenderTexture from memory.
	 */
	SfmlImage(void *data, unsigned int length);

	/**
	 * Load an sf::RenderTexture from a filename.
	 */
	SfmlImage(const boost::filesystem::path &uri);

	/**
	 * Build an sf::RenderTexture to given width/height specifications.
	 */
	SfmlImage(int width, int height);

	/**
	 * Destroy sf::RenderTexture.
	 */
	~SfmlImage();

	void display();

	void drawCircle(int x, int y, int radius, int r, int g, int b, int a = 255, DrawMode drawMode = DrawMode_Blend);

	void drawFilledBox(int x, int y, int w, int h, int r, int g, int b, int a = 255, DrawMode drawMode = DrawMode_Blend);

	void drawLine(int x1, int y1, int x2, int y2, int r, int g, int b, int a = 255, DrawMode drawMode = DrawMode_Blend);

	void drawLineBox(int x, int y, int w, int h, int r, int g, int b, int a = 255, DrawMode drawMode = DrawMode_Blend);

	void fill(int r, int g, int b, int a = 255);

	int height() const;

	bool isValid() const { return width() != 0 && height() != 0; }

	unsigned int pixelAt(int x, int y) const;

	void render(int x, int y, Image *destination, int alpha = 255, DrawMode mode = DrawMode_Blend, int sx = 0, int sy = 0, int sw = 0, int sh = 0) const AVOCADO_ENSURE_STACK_ALIGNED_FOR_SSE;

	void setPixelAt(int x, int y, unsigned int pixel);

	int width() const;

	static AbstractFactory<SfmlImage> *factory;

private:

	sf::RenderTexture *renderTexture;

};

/**
 * @ingroup Manufacturing
 * @ingroup Resources
 * @ingroup SFML
 * @ingroup SPI
 */
template <>
class AbstractFactory<SfmlImage> : public AbstractFactory<Image> {

	virtual ~AbstractFactory<SfmlImage>() {}

	SfmlImage *create(void *data, unsigned int length) {
		return new SfmlImage(data, length);
	}

	SfmlImage *create(const boost::filesystem::path &uri) {
		return new SfmlImage(uri);
	}

	SfmlImage *create(int width, int height) {
		return new SfmlImage(width, height);
	}

	SfmlImage *create() {
		return new SfmlImage();
	}

};

/**
 * @}
 */

}

#endif // AVOCADO_SFMLIMAGE_H
