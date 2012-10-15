#include "avocado-global.h"

#include "SfmlWindow.h"

#include "../../Graphics/SFML/SfmlImage.h"

using namespace std;

const double JoystickMagnitude = 100;

namespace avo {

AbstractFactory<SfmlWindow> *SfmlWindow::factory = new AbstractFactory<SfmlWindow>();

SfmlWindow::SfmlWindow()
	: Window()
	, window(new sf::RenderWindow())
{
}

SfmlWindow::~SfmlWindow() {
	delete window;
}

void SfmlWindow::display() {
	window->display();
}

Window::Event SfmlWindow::pollEvents() {

	Event event;
	sf::Event sfmlEvent;
	while (window->pollEvent(sfmlEvent)) {

		switch (sfmlEvent.type) {

		case sf::Event::KeyPressed: {

			Event::KeyDown keyDown = {sfmlEvent.key.code};
			event.keyDown.push_back(keyDown);

			break;
		}

		case sf::Event::KeyReleased: {

			Event::KeyUp keyUp = {sfmlEvent.key.code};
			event.keyUp.push_back(keyUp);

			break;
		}

		case sf::Event::JoystickMoved: {

			Event::JoyAxis joyAxis = {
				sfmlEvent.joystickMove.joystickId,
				sfmlEvent.joystickMove.axis,
				sfmlEvent.joystickMove.position / JoystickMagnitude
			};

			deque<Event::JoyAxis>::iterator i = find(
				event.joyAxis.begin(),
				event.joyAxis.end(),
				joyAxis
			);

			if (event.joyAxis.end() == i) {
				event.joyAxis.push_back(joyAxis);
			}
			else {
				i->value = joyAxis.value;
			}

			break;
		}

		case sf::Event::JoystickButtonPressed: {

			Event::JoyButtonDown joyButtonDown = {
				sfmlEvent.joystickButton.joystickId,
				sfmlEvent.joystickButton.button
			};

			deque<Event::JoyButtonDown>::iterator i = find(
				event.joyButtonDown.begin(),
				event.joyButtonDown.end(),
				joyButtonDown
			);

			if (event.joyButtonDown.end() == i) {
				event.joyButtonDown.push_back(joyButtonDown);
			}

			break;
		}

		case sf::Event::JoystickButtonReleased: {

			Event::JoyButtonUp joyButtonUp = {
				sfmlEvent.joystickButton.joystickId,
				sfmlEvent.joystickButton.button
			};

			deque<Event::JoyButtonUp>::iterator i = find(
				event.joyButtonUp.begin(),
				event.joyButtonUp.end(),
				joyButtonUp
			);

			if (event.joyButtonUp.end() == i) {
				event.joyButtonUp.push_back(joyButtonUp);
			}

			break;
		}

		case sf::Event::MouseButtonPressed: {

			Event::MouseButtons button;
			switch (sfmlEvent.mouseButton.button) {
				case sf::Mouse::Left: button = Event::LeftButton; break;
				case sf::Mouse::Middle: button = Event::MiddleButton; break;
				case sf::Mouse::Right: button = Event::RightButton; break;
				case sf::Mouse::XButton1: button = Event::WheelUp; break;
				case sf::Mouse::XButton2: button = Event::WheelDown; break;
				default: break;
			}
			Event::MouseButtonDown mouseDown = {
				sfmlEvent.mouseButton.x,
				sfmlEvent.mouseButton.y,
				button
			};
			event.mouseButtonDown.push_back(mouseDown);

			break;
		}

		case sf::Event::MouseButtonReleased: {

			Event::MouseButtons button;
			switch (sfmlEvent.mouseButton.button) {
				case sf::Mouse::Left: button = Event::LeftButton; break;
				case sf::Mouse::Middle: button = Event::MiddleButton; break;
				case sf::Mouse::Right: button = Event::RightButton; break;
				case sf::Mouse::XButton1: button = Event::WheelUp; break;
				case sf::Mouse::XButton2: button = Event::WheelDown; break;
				default: break;
			}
			Event::MouseButtonUp mouseUp = {
				sfmlEvent.mouseButton.x,
				sfmlEvent.mouseButton.y,
				button
			};
			event.mouseButtonUp.push_back(mouseUp);

			break;
		}

		case sf::Event::MouseMoved: {

			Event::MouseMove mouseMove = {
				sfmlEvent.mouseMove.x,
				sfmlEvent.mouseMove.y
			};
			event.mouseMove.push_back(mouseMove);

			break;
		}

		case sf::Event::Closed: {

			event.quit = true;
			break;
		}

		case sf::Event::Resized: {

			event.resize.width = sfmlEvent.size.width;
			event.resize.height = sfmlEvent.size.height;

			Window::setSize(sfmlEvent.size.width, sfmlEvent.size.height);

			break;
		}

		default: {
			break;

		}

		}
	}

	return event;
}

void SfmlWindow::render(Image *working, int x, int y, int w, int h) {
	AVOCADO_UNUSED(x);
	AVOCADO_UNUSED(y);
	AVOCADO_UNUSED(w);
	AVOCADO_UNUSED(h);
	sf::Sprite sprite(
		Image::superCast<SfmlImage>(working)->renderTexture->getTexture()
	);
	window->clear();
	window->draw(sprite);
}

void SfmlWindow::set() {

	// Translate Window flags to SFML flags.
	unsigned int sfmlStyle = sf::Style::Default;
	if (flags() & Flags_Fullscreen) sfmlStyle |= sf::Style::Fullscreen;

	window->create(
		sf::VideoMode(width(), height()),
		m_title,
		sfmlStyle
	);

	window->setKeyRepeatEnabled(false);
	window->setVerticalSyncEnabled(true);
	window->clear();
}

void SfmlWindow::setFlags(WindowFlags flags) {
	Window::setFlags(flags);

	set();
}

void SfmlWindow::setSize(int width, int height) {
	Window::setSize(width, height);

	set();
}

void SfmlWindow::setMouseVisibility(bool visible) {
	window->setMouseCursorVisible(visible);
}

void SfmlWindow::setWindowTitle(const std::string &title, const std::string &iconified) {
	AVOCADO_UNUSED(iconified);

	m_title = title;

	window->setTitle(m_title);
}

}

