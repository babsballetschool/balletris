.PHONE: clean

all: build/index.html build/resources/js/balletris.js build/resources/image/balletris/babsballetschool-logo.gif

build/index.html: _index.html build
	cp _index.html build/index.html

build/resources/js/balletris.js: build
	mkdir -p build/resources/js/
	elm make src/Main.elm --output build/resources/js/balletris.js

build/resources/image/balletris/babsballetschool-logo.gif: build
	mkdir -p build/resources/image/balletris/
	cp src/resources/image/balletris/babsballetschool-logo.gif build/resources/image/balletris

build:
	mkdir -p build

clean:
	rm -rf build
