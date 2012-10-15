#ifndef AVOCADO_FONT_H
#define AVOCADO_FONT_H

#include "avocado-global.h"

#include "../Font.h"
#include "SfmlImage.h"

namespace avo {

/**
 * @addtogroup Graphics
 * @{
 */

/**
 * @brief The %Font SPI handles loading and rendering with fonts.
 *
 * @ingroup Resources
 */
class SfmlFont : public Font {

public:

	/**
	 * NULL Font constructor.
	 */
	SfmlFont();

	/**
	 * Build a font from a filename.
	 */
	SfmlFont(const boost::filesystem::path &uri);

	~SfmlFont();

	/**
	 * Render this image at x, y onto another image with the given alpha
	 * blending and draw mode, using the given sx, sy, sw, sh source rectangle
	 * to clip.
	 */
	void render(int x, int y, Image *destination, const std::string &text, int cx, int cy, int cw, int ch) const;

	/**
	 * Set the font size.
	 */
	void setSize(int size);

	/**
	 * Set the font style.
	 */
	void setStyle(FontStyle style = FontStyle_Default);

	/**
	 * Get the height of some text.
	 */
	int textHeight(const std::string &text);

	/**
	 * Get the height of some text.
	 */
	int textWidth(const std::string &text);

	/**
	 * Manages image resources.
	 */
	static AbstractFactory<Font> *factory;

private:

	sf::Font *font;
	sf::RenderTexture *texture;
	sf::Text::Style sfmlStyle;
	int size;
};

/**
 * @ingroup Manufacturing
 * @ingroup Resources
 * @ingroup SPI
 */
template <>
class AbstractFactory<SfmlFont> : public AbstractFactory<Font> {

public:

	virtual ~AbstractFactory<SfmlFont>() {}

	virtual Font *create() {
		return new SfmlFont();
	}

	virtual Font *create(const boost::filesystem::path &uri) {
		return new SfmlFont(uri);
	}

};

/**
 * @}
 */

}

#endif // AVOCADO_FONT_H
