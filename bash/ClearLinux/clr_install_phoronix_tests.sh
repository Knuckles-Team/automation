#!/bin/sh

# Install dependency
sudo swupd bundle-add os-test-phoronix

# Batch Setup
phoronix-test-suite batch-setup

# Show Tests
phoronix-test-suite list-tests

# Install Tests Needed
phoronix-test-suite install povray
phoronix-test-suite install stress-ng
phoronix-test-suite install pybench
phoronix-test-suite install tensorflow
phoronix-test-suite install gromacs
phoronix-test-suite install geekbench
phoronix-test-suite install ffmpeg
phoronix-test-suite install nginx
