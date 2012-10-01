#ifndef AVOCADO_QTIMAGE_H
#define AVOCADO_QTIMAGE_H

#include "avocado-global.h"

#include <QtGui/QImage>
#include <QtGui/QPainter>
#include <QtGui/QPaintEvent>
#include <QtGui/QSlider>

#include "FS.h"
#include "../Image.h"

namespace avo {

/**
 * @addtogroup Graphics
 * @{
 */

/**
 * Qt image SPI implementation (SPII). The SPII uses QImage to implement the
 * image operations.
 *
 * @ingroup Qt
 */
class QtImage : public Image {

public:

	/**
	 * Build a NULL QImage.
	 */
	QtImage();

	/**
	 * Load a QImage from a filename.
	 */
	QtImage(const boost::filesystem::path &uri);

	/**
	 * Build a QImage to given width/height specifcations.
	 */
	QtImage(int width, int height);

	/**
	 * Destroy QImage.
	 */
	~QtImage();

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

	static AbstractFactory<QtImage> *factory;

private:

	QtImage(const QtImage &image);
	Image &operator =(const Image &image);

	QImage *qImage;

};

/**
 * @ingroup Manufacturing
 * @ingroup Qt
 * @ingroup Resources
 * @ingroup SPI
 */
template <>
class AbstractFactory<QtImage> : public AbstractFactory<Image> {

public:

	virtual ~AbstractFactory<QtImage>() {}

	QtImage *create(const boost::filesystem::path &uri) {
		return new QtImage(uri);
	}

	QtImage *create(int width, int height) {
		return new QtImage(width, height);
	}

	QtImage *create() {
		return new QtImage();
	}

};

/**
 * @}
 */

}

#endif // AVOCADO_QTIMAGE_H
