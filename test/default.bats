#!/usr/bin/env bats
# shellcheck disable=SC2034
BATS_TEST_FILENAME_BASENAME=$(basename "${BATS_TEST_FILENAME}")
# bats file_tags=type:features

@test "can list all [${BATS_TEST_FILENAME_BASENAME}]" {
  asdf list all k9s
}

@test "can install latest [${BATS_TEST_FILENAME_BASENAME}]" {
  asdf install k9s latest
}
