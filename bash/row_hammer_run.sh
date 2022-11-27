#!/bin/bash

git clone https://github.com/google/rowhammer-test.git
pushd rowhammer-test
./make.sh
./rowhammer_test
popd