.PHONY: all web-build macos-build

all: web-build macos-build

web-build:
	rm -rf build/html
	mkdir -p build/html
	godot --verbose --export-release Web build/html/index.html
	cd build/html && zip ../loot-goblin-web.zip *

macos-build:
	mkdir -p build
	godot --verbose --export-release macOS "build/Loot Goblin.dmg"

windows-build:
	rm -rf build/windows
	mkdir -p build/windows/
	godot --verbose --export-release Windows "build/windows/Loot Goblin.exe"
	cd build/windows && zip ../loot-goblin-windows.zip *

