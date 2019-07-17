#!/bin/bash

set -x
if [[ "$TRAVIS_OS_NAME" == "linux" ]]; then
  shellcheck -V
  shellcheck bin/*
fi
if [[ "$TRAVIS_OS_NAME" == "osx" ]]; then
  echo "I don't have shellchek installed and I'm too slow to install it, giving up on shellcheck."
fi
