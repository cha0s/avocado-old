#include "avocado-global.h"

#include "QtCounter.h"

namespace avo {

AbstractFactory<QtCounter> *QtCounter::factory = new AbstractFactory<QtCounter>();

QtCounter::QtCounter()
	: Counter()
	, time(QTime())
{

	time.start();
	setCurrent(time.elapsed());
}

QtCounter::~QtCounter() {
}

Counter &QtCounter::operator =(const Counter &counter) {
	AVOCADO_UNUSED(counter);

	return *this;
}

double QtCounter::current() {
	return time.elapsed();
}

}
