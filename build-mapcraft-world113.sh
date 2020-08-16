#!/usr/bin/env bash
###################
# Builds mapcrafter from source for modern minecraft support

apt install g++ cmake build-essential libturbojpeg libturbojpeg-dev libblkid-dev e2fslibs-dev libboost-all-dev libaudit-dev git -y
git install https://github.com/mapcrafter/mapcrafter --branch world113

cd mapcrafter

CXX=g++ cmake $PWD
make install

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib
cd ..
rm -rf mapcrafter
