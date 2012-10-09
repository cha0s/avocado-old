#include "avocado-global.h"

#include "SfmlImage.h"

namespace avo {

AbstractFactory<SfmlImage> *SfmlImage::factory = new AbstractFactory<SfmlImage>;

SfmlImage::SfmlImage()
	: Image()
	, renderTexture(new sf::RenderTexture())
{
}

SfmlImage::SfmlImage(int width, int height)
	: Image()
	, renderTexture(new sf::RenderTexture())
{
	if (!renderTexture->create(width, height)) throw std::runtime_error(
		"sf::RenderTexture::create(width, height) failed."
	);
	renderTexture->clear();
	renderTexture->display();
}

SfmlImage::SfmlImage(const boost::filesystem::path &uri)
	: Image()
	, renderTexture(new sf::RenderTexture())
{

	sf::Texture texture;
	if (!texture.loadFromFile(uri.c_str())) throw std::runtime_error(
		"SfmlImage::SfmlImage(uri): SFML couldn't load image."
	);
	sf::Sprite sprite(texture);
	sf::Vector2u vector = texture.getSize();
	renderTexture->create(vector.x, vector.y);
	renderTexture->clear();
	renderTexture->draw(sprite, sf::RenderStates(sf::BlendNone));
	renderTexture->display();

	setUri(uri);
}

SfmlImage::~SfmlImage() {
	if (renderTexture) delete renderTexture;
}

void SfmlImage::display() {
	renderTexture->display();
}

unsigned int SfmlImage::pixelAt(int x, int y) const {
	AVOCADO_UNUSED(x);
	AVOCADO_UNUSED(y);

	return 0;
}

void SfmlImage::drawCircle(int x, int y, int radius, int r, int g, int b, int a, DrawMode drawMode) {
	AVOCADO_UNUSED(x);
	AVOCADO_UNUSED(y);
	AVOCADO_UNUSED(radius);
	AVOCADO_UNUSED(r);
	AVOCADO_UNUSED(g);
	AVOCADO_UNUSED(b);
	AVOCADO_UNUSED(a);
	AVOCADO_UNUSED(drawMode);
}

void SfmlImage::drawFilledBox(int x, int y, int w, int h, int r, int g, int b, int a, DrawMode drawMode) {
	AVOCADO_UNUSED(x);
	AVOCADO_UNUSED(y);
	AVOCADO_UNUSED(w);
	AVOCADO_UNUSED(h);
	AVOCADO_UNUSED(r);
	AVOCADO_UNUSED(g);
	AVOCADO_UNUSED(b);
	AVOCADO_UNUSED(a);
	AVOCADO_UNUSED(drawMode);
}

void SfmlImage::drawLine(int x1, int y1, int x2, int y2, int r, int g, int b, int a, DrawMode drawMode) {
	AVOCADO_UNUSED(x1);
	AVOCADO_UNUSED(y1);
	AVOCADO_UNUSED(x2);
	AVOCADO_UNUSED(y2);
	AVOCADO_UNUSED(r);
	AVOCADO_UNUSED(g);
	AVOCADO_UNUSED(b);
	AVOCADO_UNUSED(a);
	AVOCADO_UNUSED(drawMode);
}

void SfmlImage::drawLineBox(int x, int y, int w, int h, int r, int g, int b, int a, DrawMode drawMode) {
	AVOCADO_UNUSED(x);
	AVOCADO_UNUSED(y);
	AVOCADO_UNUSED(w);
	AVOCADO_UNUSED(h);
	AVOCADO_UNUSED(r);
	AVOCADO_UNUSED(g);
	AVOCADO_UNUSED(b);
	AVOCADO_UNUSED(a);
	AVOCADO_UNUSED(drawMode);
}

void SfmlImage::fill(int r, int g, int b, int a) {
	renderTexture->clear(sf::Color(r, g, b, a));
}

int SfmlImage::height() const {
	return renderTexture->getSize().y;
}

void SfmlImage::render(int x, int y, Image *destination, int alpha, DrawMode mode, int sx, int sy, int sw, int sh) const {

	sf::Sprite sprite;
	sprite.setTexture(renderTexture->getTexture());
	sprite.setPosition(sf::Vector2f(x, y));
	sprite.setColor(sf::Color(255, 255, 255, alpha));
	sf::IntRect rect(sx, sy, sw, sh);
	if (0 == rect.width) {
		rect.width = width();
	}
	if (0 == rect.height) {
		rect.height = height();
	}
	sprite.setTextureRect(rect);

	sf::RenderStates renderStates;

	switch (mode) {
	case DrawMode_Replace:
		renderStates.blendMode = sf::BlendNone;
		break;
	default:
		break;
	}

	superCast<SfmlImage>(destination)->renderTexture->draw(
		sprite,
		renderStates
	);
}

void SfmlImage::setPixelAt(int x, int y, unsigned int pixel) {
	AVOCADO_UNUSED(x);
	AVOCADO_UNUSED(y);
	AVOCADO_UNUSED(pixel);
}

int SfmlImage::width() const {
	return renderTexture->getSize().x;
}

}
