#include "avocado-global.h"

#include "QtImage.h"

namespace avo {

AbstractFactory<QtImage> *QtImage::factory = new AbstractFactory<QtImage>;

QPainter::CompositionMode mapCompositionMode(Image::DrawMode drawMode) {

	switch (drawMode) {
	default:
	case Image::DrawMode_Blend:
		return QPainter::CompositionMode_SourceOver;

	case Image::DrawMode_Replace:
		return QPainter::CompositionMode_Source;
	}
}

QtImage::QtImage()
	: Image()
	, qImage(NULL)
{
}

QtImage::QtImage(void *data, unsigned int length)
	: Image()
	, qImage(new QImage())
{
	*qImage = QImage::fromData(static_cast<unsigned char*>(data), length);
}

QtImage::QtImage(int width, int height)
	: Image()
	, qImage(new QImage(width, height, QImage::Format_ARGB32))
{
}

QtImage::QtImage(const boost::filesystem::path &uri)
	: Image()
{
	qImage = new QImage(uri.c_str());

	if (!qImage || qImage->isNull()) throw std::runtime_error(
		"Qt couldn't load the image."
	);

	setUri(uri);
}

QtImage::~QtImage() {
	if (qImage) delete qImage;
}

void QtImage::drawCircle(int x, int y, int radius, int r, int g, int b, int a, DrawMode drawMode) {
	if (NULL == qImage) return;

	QPainter painter(qImage);

	// Translate the rendering mode to Qt's composition mode.
	painter.setCompositionMode(mapCompositionMode(drawMode));

	painter.setPen(QPen(QColor(r, g, b, a)));
	painter.drawEllipse(QRect(x, y, radius * 2, radius * 2));
}

void QtImage::drawFilledBox(int x, int y, int w, int h, int r, int g, int b, int a, DrawMode drawMode) {
	if (NULL == qImage) return;

	QPainter painter(qImage);

	// Translate the rendering mode to Qt's composition mode.
	painter.setCompositionMode(mapCompositionMode(drawMode));

	painter.fillRect(QRect(x, y, w, h), QColor(r, g, b, a));
}

void QtImage::drawLine(int x1, int y1, int x2, int y2, int r, int g, int b, int a, DrawMode drawMode) {
	if (NULL == qImage) return;

	QPainter painter(qImage);

	// Translate the rendering mode to Qt's composition mode.
	painter.setCompositionMode(mapCompositionMode(drawMode));

	painter.setPen(QPen(QColor(r, g, b, a)));
	painter.drawLine(QLine(x1, y1, x2, y2));
}

void QtImage::drawLineBox(int x, int y, int w, int h, int r, int g, int b, int a, DrawMode drawMode) {
	if (NULL == qImage) return;

	QPainter painter(qImage);

	// Translate the rendering mode to Qt's composition mode.
	painter.setCompositionMode(mapCompositionMode(drawMode));

	painter.setPen(QPen(QColor(r, g, b, a)));
	painter.drawRect(QRect(x, y, w, h));
}

void QtImage::fill(int r, int g, int b, int a) {
	if (NULL == qImage) return;

	// @TODO Should we allow blending?
	drawFilledBox(
		0, 0, width(), height(),
		r, g, b, a,
		DrawMode_Replace
	);
}

int QtImage::height() const {
	if (NULL == qImage) return 0;

	return qImage->height();
}

unsigned int QtImage::pixelAt(int x, int y) const {
	if (NULL == qImage) return 0;

	return reinterpret_cast<unsigned int *>(qImage->scanLine(y))[x];
}

void QtImage::render(int x, int y, Image *destination, int alpha, DrawMode mode, int sx, int sy, int sw, int sh) const {
	if (NULL == qImage) return;

	QPainter painter(superCast<QtImage>(destination)->qImage);

	if (DrawMode_Blend == mode) painter.setOpacity((float)alpha / 255);

	// Translate the rendering mode to Qt's composition mode.
	painter.setCompositionMode(mapCompositionMode(mode));

	// If src_rect doesn't have a valid width or height, set them
	// to this Image object's dimensions. Not sure if Qt needs this
	// actually...
	if (0 == sw || 0 == sh) {
		sw = width();
		sh = height();
	}

	painter.drawImage(
		QPoint(x, y),
		*qImage,
		QRect(sx, sy, sw, sh)
	);
}

void QtImage::setPixelAt(int x, int y, unsigned int pixel) {
	if (NULL == qImage) return;

	reinterpret_cast<unsigned int *>(qImage->scanLine(y))[x] = pixel;
}

int QtImage::width() const {
	if (NULL == qImage) return 0;

	return qImage->width();
}

}

