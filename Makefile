

build_runner:
	flutter packages pub run build_runner watch --delete-conflicting-outputs


build_py:
	sudo rm -rf build
	export SERIOUS_PYTHON_SITE_PACKAGES=$(pwd)/build/site-packages
	dart run serious_python:main package app/src -p Darwin -r -r -r app/src/requirements.txt


