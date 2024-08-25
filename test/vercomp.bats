#!/usr/bin/env bats
# shellcheck disable=SC2034
BATS_TEST_FILENAME_BASENAME=$(basename "${BATS_TEST_FILENAME}")
# bats file_tags=type:code,func:vercomp

load '../lib/utils.bash'

@test "0.0.1 should be less than 0.0.2 [${BATS_TEST_FILENAME_BASENAME}]" {
  op=$(vercomp "0.0.1" "0.0.2")
  [ "${op}" == "<" ]
}

@test "0.0.1 should be less than 1.0.0 [${BATS_TEST_FILENAME_BASENAME}]" {
  op=$(vercomp "0.0.1" "1.0.0")
  [ "${op}" == "<" ]
}

@test "1.2.3 should be equal to 1.2.3 [${BATS_TEST_FILENAME_BASENAME}]" {
  op=$(vercomp "1.2.3" "1.2.3")
  [ "${op}" == "=" ]
}

@test "1.2.3 should be greater than 1.2.2 [${BATS_TEST_FILENAME_BASENAME}]" {
  op=$(vercomp "1.2.3" "1.2.2")
  [ "${op}" == ">" ]
}

@test "1.12.3 should be greater than 1.0.0 [${BATS_TEST_FILENAME_BASENAME}]" {
  op=$(vercomp "1.12.3" "1.0.0")
  [ "${op}" == ">" ]
}

@test "0.27.0 should be greater than 0.26.7 [${BATS_TEST_FILENAME_BASENAME}]" {
  op=$(vercomp "0.27.0" "0.26.7")
  [ "${op}" == ">" ]
}
