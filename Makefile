.PHONE: clean

all: build/index.html build/js/balletris.js build/image/balletboetiek-logo.gif

build/index.html: _index.html build
	cp _index.html build/index.html

build/js/balletris.js: build
	elm make src/Main.elm --output build/js/balletris.js

build/image/balletboetiek-logo.gif: build/image
	cp src/image/balletboetiek-logo.gif build/image

build/image: build
	mkdir -p build/image

build:
	mkdir -p build

clean:
	rm -rf build
