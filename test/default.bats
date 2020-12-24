#!/usr/bin/env bats

@test "can list all" {
  asdf list all k9s
}

@test "can install latest" {
  asdf install k9s latest
}
