![avocado logo](https://raw.github.com/cha0s/avocado/master/resource/image/avocado.png)

## Fun should be free

### [Check out the documentation](http://cha0s.github.com/avocado/index.html)

NOTE: Currently, I am only building this on 32-bit xubuntu 12.04.1. More platforms will be coming.

### Preparation

	sudo apt-get install libboost-regex-dev libboost-filesystem-dev libboost-system-dev

### Make it (Be patient !)

	cd app/native
	qmake
	make -j4 everything
	cd ../..
	./avocado
	
### Test the engine

	cd app/native
	make -j4 gtest
	
### Eat an avocado

	echo Yummy!
