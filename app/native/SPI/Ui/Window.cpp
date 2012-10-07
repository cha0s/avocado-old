#include "avocado-global.h"

#include "Window.h"

namespace avo {

FactoryManager<Window> Window::factoryManager;

Window::Window()
	: m_width(0)
	, m_height(0)
	, m_flags(0)
{
}

int Window::flags() const {
	return m_flags;
}

int Window::height() const {
	return m_height;
}

void Window::setFlags(WindowFlags flags) {
	m_flags = flags;
}

void Window::setSize(int width, int height) {
	m_width = width;
	m_height = height;
}

int Window::width() const {
	return m_width;
}

}

