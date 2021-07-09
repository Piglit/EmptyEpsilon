#!/usr/bin/bash
set -e
set -x
sudo apt install build-essential libx11-dev cmake libxrandr-dev libglew-dev mesa-common-dev libglu1-mesa-dev libudev-dev libglew-dev libjpeg-dev libfreetype6-dev libopenal-dev libsndfile1-dev libxcb1-dev libxcb-image0-dev gcc g++ libsfml-dev mingw-w64 git unzip p7zip-full
mkdir ee
cd ee
git clone --depth 1 -b lan2020 https://github.com/piglit/emptyepsilon
git clone --depth 1 https://github.com/daid/seriousproton
cd emptyepsilon
mkdir _build
cd _build
cmake .. -DSERIOUS_PROTON_DIR=$(pwd)/../../seriousproton
make -j4
#make -j4 package # creates deb package
cd ..
mkdir _build_win32
cd _build_win32
cmake .. -DSERIOUS_PROTON_DIR=$(pwd)/../../seriousproton -DCMAKE_TOOLCHAIN_FILE=../cmake/mingw.toolchain -DCMAKE_MAKE_PROGRAM=make
make -j4 package

