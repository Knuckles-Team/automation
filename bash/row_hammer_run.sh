#!/bin/bash

git clone https://github.com/google/rowhammer-test.git
./rowhammer-test/make.sh
./rowhammer-test/rowhammer_test &
