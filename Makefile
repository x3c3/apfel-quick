.PHONY: build test install clean

build:
	swift build -c release

test:
	swift test

install: build
	cp -r .build/release/apfel-quick /usr/local/bin/apfel-quick

clean:
	swift package clean

run:
	swift run apfel-quick
