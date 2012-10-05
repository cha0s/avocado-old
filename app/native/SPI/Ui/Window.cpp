#include "avocado-global.h"

#include "Window.h"

namespace avo {

FactoryManager<Window> Window::factoryManager;

void Window::set(int width, int height, WindowFlags f) {
	AVOCADO_UNUSED(f);

	m_width = width;
	m_height = height;
}

int Window::width() const {
	return m_width;
}

int Window::height() const {
	return m_height;
}

}

