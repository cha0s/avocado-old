#include "avocado-global.h"

#include "QtTimingService.h"

#include <QtCore/QThread>

#include "QtCounter.h"

namespace avo {

class I : public QThread {

public:

	static void sleep(unsigned long secs) {
		QThread::sleep(secs);
	}

	static void msleep(unsigned long msecs) {
		QThread::msleep(msecs);
	}

	static void usleep(unsigned long usecs) {
		QThread::usleep(usecs);
	}

};

AbstractFactory<QtTimingService> *QtTimingService::factory = new AbstractFactory<QtTimingService>;

QtTimingService::QtTimingService() {

	Counter::factoryManager.setInstance(QtCounter::factory);
}

QtTimingService::~QtTimingService() {
}

void QtTimingService::sleep(int ms) {
	I::msleep(ms);
}

}
