#!/usr/bin/env bats

@test "can list all" {
  run asdf list all k9s
  [ "$status" -eq 0 ]
}
