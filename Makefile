.PHONE: clean

all: build/index.html build/js/balletris.js build/image/balletris/babsballetschool-logo.gif

build/index.html: _index.html build
	cp _index.html build/index.html

build/js/balletris.js: build
	elm make src/Main.elm --output build/js/balletris.js

build/image/balletris/babsballetschool-logo.gif: build/image/balletris
	cp src/image/balletris/babsballetschool-logo.gif build/image/balletris

build/image/balletris: build/image
	mkdir -p build/image/balletris

build/image: build
	mkdir -p build/image

build:
	mkdir -p build

clean:
	rm -rf build
