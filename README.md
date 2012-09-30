
NOTE: Currently, I am only building this on 32-bit xubuntu 12.04.1. More platforms will be coming.

### Preparation

	sudo apt-get install libboost-regex-dev libboost-filesystem-dev libboost-system-dev

### Make it (Be patient !)

	cd app/native
	qmake
	make everything
	cd ../..
	./avocado
	
### Test the engine

	make gtest
	
### Eat an avocado

	echo Yummy!
