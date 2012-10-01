#include "avocado-global.h"

#include "Counter.h"

namespace avo {

FactoryManager<Counter> Counter::factoryManager;

Counter::Counter()
	: m_current(0)
{
}

double Counter::since() {

	// Get the difference between current ticks and previous.
	int now = current();
	int result = now - m_current;

	// Update the current ticks.
	m_current = now;

	// Return the difference (delta).
	return result;
}

void Counter::setCurrent(double current) {
	m_current = current;
}

}
