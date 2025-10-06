web-build:
	rm -rf build/html
	mkdir -p build/html
	godot --export-release Web build/html/index.html
	cd build/html && zip ../loot-goblin.zip *

