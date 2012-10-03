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

double QtCounter::current() {
	return time.elapsed();
}

}
