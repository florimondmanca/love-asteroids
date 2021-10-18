all: clean build love

install:
	./scripts/deps

build:
	cd src && zip -r ../app.love * && cd ..

love:
	love app.love

test:
	lua tests/main.lua

clean:
	rm -f app.love
