#!/usr/bin/env bats

@test "list-all does not return v versions" {
  run asdf list all k9s
  [ "$status" -eq 0 ]
  result="$(echo "$output" | grep -c "v" || true)"
  [ "$result" == "0" ]
}

@test "can install 0.13.0" {
  run asdf uninstall k9s 0.13.0
  run asdf install k9s 0.13.0
  [ "$status" -eq 0 ]
  asdf list k9s | grep 0.13.0
}

@test "can install 0.24.2" {
  run asdf uninstall k9s 0.24.2
  run asdf install k9s 0.24.2
  [ "$status" -eq 0 ]
  asdf list k9s | grep 0.24.2
}
