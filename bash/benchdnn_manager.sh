#!/bin/bash

function compile_benchdnn(){
  if [[ -d "oneDNN" ]]; then
    echo "oneDNN exists on your filesystem."
  else
    git clone https://github.com/oneapi-src/oneDNN.git
  fi
  cd oneDNN || echo "Git Repo not cloned"
  mkdir -p build
  cd build || echo "build directory not created"
  export CC=icc
  export CXX=icpc
  cmake .. \
        -DDNNL_CPU_RUNTIME=DPCPP
  make -j
}

function run_benchdnn(){
  # https://github.com/oneapi-src/oneDNN/blob/master/tests/benchdnn/README.md
  # ./benchdnn --DRIVER [COMMON-OPTIONS] [DRIVER-OPTIONS] PROBLEM-DESCRIPTION
  ./benchdnn --conv --cfg f32bf16bf16
}

compile_benchdnn
run_benchdnn