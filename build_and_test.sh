#!/bin/bash

# Clean up
echo -e "------ \e[93mClean up\e[0m ------"
rm -rf CMakeCache.txt CMakeFiles wheelhouse Makefile bin tmp/*

# Build and Test
echo -e "------ \e[93mBuild\e[0m ------"
cmake -DCMAKE_BUILD_TYPE=Release -DUKV_BUILD_TESTS=1 -B ./build_release \
    -DUKV_BUILD_ENGINE_UMEM=1 -DUKV_BUILD_ENGINE_LEVELDB=1 -DUKV_BUILD_ENGINE_ROCKSDB=1 -DUKV_BUILD_API_FLIGHT=0 \
    .
make -j 32 -C ./build_release
echo -e "------ \e[92mBuild Passing\e[0m ------"

for test in $(ls ./build_release/build/bin/*test_units*); do
    echo -e "------ \e[93mRunning $test\e[0m ------"
    $test
done
echo -e "------ \e[92mTests Passing!\e[0m ------"

# Build and Test Python
rm -rf wheelhouse/*
pip install cibuildwheel twine
echo -e "------ \e[93mBuild and Test Python\e[0m ------"
CIBW_BUILD="cp39-*" cibuildwheel --platform linux
CIBW_BUILD="cp310-*" cibuildwheel --platform linux
echo -e "------ \e[92mPython Tests Passing!\e[0m ------"

# Build and Test Java
echo -e "------ \e[93mBuild and Test Java\e[0m ------"
export JAVA_HOME="/usr/lib/jvm/java-11-openjdk-amd64"
bash java/pack.sh
echo -e "------ \e[92mJava Tests Passing!\e[0m ------"

# Build GoLang
echo -e "------ \e[93mBuild GoLang\e[0m ------"
git submodule update --init --recursive --remote go-ukv/
bash go-ukv/pack.sh
echo -e "------ \e[92mGo Built!\e[0m ------"