#include "SfmlFont.h"

namespace avo {

AbstractFactory<Font> *SfmlFont::factory = new AbstractFactory<SfmlFont>;

SfmlFont::SfmlFont()
	: font(new sf::Font())
	, texture(new sf::RenderTexture())
{
}

SfmlFont::SfmlFont(const boost::filesystem::path &uri)
	: font(new sf::Font())
	, texture(new sf::RenderTexture())
{

	if (!font->loadFromFile(uri.c_str())) throw std::runtime_error(
		"sf::Font::loadFromFile(uri) failed."
	);
}

SfmlFont::~SfmlFont() {

	// Bug?
//	delete font;
}

void SfmlFont::render(int x, int y, Image *destination, const std::string &text, int cx, int cy, int cw, int ch) const {
	AVOCADO_UNUSED(cx);
	AVOCADO_UNUSED(cy);
	AVOCADO_UNUSED(cw);
	AVOCADO_UNUSED(ch);

	sf::Text sfmlText = sf::Text(text, *font, size);
	texture->clear(sf::Color(0, 0, 0, 0));
	texture->display();
	texture->draw(sfmlText);

	sf::Sprite sprite;
	sprite.setTexture(texture->getTexture());
	sprite.setPosition(sf::Vector2f(x, y));
	sf::IntRect rect(cx, cy, cw, ch);
	sf::FloatRect frect = sfmlText.getGlobalBounds();

	if (0 == rect.width) {
		rect.width = frect.width;
	}
	if (0 == rect.height) {
		rect.height = frect.height * 2;
	}
	sprite.setTextureRect(rect);

	Image::superCast<SfmlImage>(destination)->renderTexture->draw(
		sprite
	);
}

void SfmlFont::setSize(int size) {
	this->size = size;

	texture->create(640, size * 2);
}

void SfmlFont::setStyle(FontStyle style) {

	sfmlStyle = sf::Text::Regular;

	if (FontStyle_Bold & style) {
		sfmlStyle = static_cast<sf::Text::Style>(sfmlStyle | sf::Text::Bold);
	}
	if (FontStyle_Italic & style) {
		sfmlStyle = static_cast<sf::Text::Style>(sfmlStyle | sf::Text::Italic);
	}
	if (FontStyle_Underline & style) {
		sfmlStyle = static_cast<sf::Text::Style>(sfmlStyle | sf::Text::Underlined);
	}
}

int SfmlFont::textHeight(const std::string &text) {
	sf::Text sfmlText = sf::Text(text, *font, size);
	return sfmlText.getGlobalBounds().height * 2;
}

int SfmlFont::textWidth(const std::string &text) {
	sf::Text sfmlText = sf::Text(text, *font, size);
	return sfmlText.getGlobalBounds().width;
}

}
