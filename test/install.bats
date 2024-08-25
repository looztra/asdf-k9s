#!/usr/bin/env bats
# shellcheck disable=SC2034
BATS_TEST_FILENAME_BASENAME=$(basename "${BATS_TEST_FILENAME}")
# bats file_tags=type:features

@test "list-all does not return v versions [${BATS_TEST_FILENAME_BASENAME}]" {
  run asdf list all k9s
  [ "$status" -eq 0 ]
  result="$(echo "$output" | grep -c "v" || true)"
  [ "$result" == "0" ]
}

@test "can install 0.13.0 on linux [${BATS_TEST_FILENAME_BASENAME}]" {
  if [[ "$OSTYPE" == "darwin"* ]] && [[ "$(uname -m)" == "arm64" ]]; then
    skip "Skipping test on darwin/arm64"
  fi
  run asdf uninstall k9s 0.13.0
  run asdf install k9s 0.13.0
  [ "$status" -eq 0 ]
  asdf list k9s | grep 0.13.0
}

@test "can install 0.24.2 on linux [${BATS_TEST_FILENAME_BASENAME}]" {
  if [[ "$OSTYPE" == "darwin"* ]] && [[ "$(uname -m)" == "arm64" ]]; then
    skip "Skipping test on darwin/arm64"
  fi
  run asdf uninstall k9s 0.24.2
  run asdf install k9s 0.24.2
  [ "$status" -eq 0 ]
  asdf list k9s | grep 0.24.2
}

@test "cannot install 0.24.2 on Darwin/arm64 [${BATS_TEST_FILENAME_BASENAME}]" {
  if [[ "$OSTYPE" != "darwin"* ]] && [[ "$(uname -m)" != "arm64" ]]; then
    skip "Skipping test as not darwin/arm64"
  fi
  run asdf uninstall k9s 0.24.2
  run asdf install k9s 0.24.2
  [ "$status" -ne 0 ]
}

@test "can install 0.26.0 [${BATS_TEST_FILENAME_BASENAME}]" {
  run asdf uninstall k9s 0.26.0
  run asdf install k9s 0.26.0
  [ "$status" -eq 0 ]
  asdf list k9s | grep 0.26.0
}

@test "can install 0.27.0 [${BATS_TEST_FILENAME_BASENAME}]" {
  run asdf uninstall k9s 0.27.0
  run asdf install k9s 0.27.0
  [ "$status" -eq 0 ]
  asdf list k9s | grep 0.27.0
}
