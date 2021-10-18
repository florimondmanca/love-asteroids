all: clean build run

install:
	./scripts/deps

build:
	cd src && zip -r ../app.love * && cd ..

run:
	love app.love

clean:
	rm -f app.love
