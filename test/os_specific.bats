#!/usr/bin/env bats
# shellcheck disable=SC2034
BATS_TEST_FILENAME_BASENAME=$(basename "${BATS_TEST_FILENAME}")
# bats file_tags=type:os_specific

load '../lib/utils.bash'

@test "get_cpu on linux and version <= 0.26.7 [${BATS_TEST_FILENAME_BASENAME}]" {
  if [[ "$OSTYPE" == "darwin"* ]] && [[ "$(uname -m)" == "arm64" ]]; then
    skip "Skipping test on darwin/arm64"
  fi
  cpu=$(get_cpu "0.26.7")
  [ "${cpu}" == "x86_64" ]
}

@test "get_cpu on linux and version > 0.26.7 [${BATS_TEST_FILENAME_BASENAME}]" {
  if [[ "$OSTYPE" == "darwin"* ]] && [[ "$(uname -m)" == "arm64" ]]; then
    skip "Skipping test on darwin/arm64"
  fi
  cpu=$(get_cpu "0.27.0")
  [ "${cpu}" == "amd64" ]
}

@test "get_cpu on darwin and version <= 0.26.7 [${BATS_TEST_FILENAME_BASENAME}]" {
  if [[ "$OSTYPE" != "darwin"* ]] && [[ "$(uname -m)" != "arm64" ]]; then
    skip "Skipping test as not darwin/arm64"
  fi
  cpu=$(get_cpu "0.26.7")
  [ "${cpu}" == "arm64" ]
}

@test "get_cpu on darwin and version > 0.26.7 [${BATS_TEST_FILENAME_BASENAME}]" {
  if [[ "$OSTYPE" != "darwin"* ]] && [[ "$(uname -m)" != "arm64" ]]; then
    skip "Skipping test as not darwin/arm64"
  fi
  cpu=$(get_cpu "0.27.0")
  [ "${cpu}" == "arm64" ]
}
