#!/usr/bin/env bats
# shellcheck disable=SC2034
BATS_TEST_FILENAME_BASENAME=$(basename "${BATS_TEST_FILENAME}")

# bats file_tags=type:code

banned_commands=(
  # Process substitution isn't POSIX compliant and cause trouble
  "<("
  # Command isn't included in the Ubuntu packages asdf depends on. Also not
  # defined in POSIX
  column
  # echo isn't consistent across operating systems, and sometimes output can
  # be confused with echo flags. printf does everything echo does and more.
  echo
  # It's best to avoid eval as it makes it easier to accidentally execute
  # arbitrary strings
  eval
  # realpath not available by default on OSX.
  realpath
  # source isn't POSIX compliant. . behaves the same and is POSIX compliant
  # Except in fish, where . is deprecated, and will be removed in the future.
  source
  # For consistency, [ should be used instead. There is a leading space so 'fail_test', etc. is not matched
  ' test'
)

banned_commands_regex=(
  # grep -y does not work on alpine and should be "grep -i" either way
  "grep.* -y"
  # grep -P is not a valid option in OSX.
  "grep.* -P"
  # Ban grep long commands as they do not work on alpine
  "grep[^|]+--\w{2,}"
  # readlink -f on OSX behaves differently from readlink -f on other Unix systems
  'readlink.+-.*f.+["$]'
  # sort --sort-version isn't supported everywhere
  "sort.*-V"
  "sort.*--sort-versions"

  # ls often gets used when we want to glob for files that match a pattern
  # or when we want to find all files/directories that match a pattern or are
  # found in a certain location. Using shell globs is preferred over ls, and
  # find is better at locating files that are in a certain location or that
  # match certain filename patterns.
  # https://github-wiki-see.page/m/koalaman/shellcheck/wiki/SC2012
  '\bls '

  # Ban recursive asdf calls as they are inefficient and may introduce bugs.
  # If you find yourself needing to invoke an `asdf` command from within
  # asdf code, please source the appropriate file and invoke the
  # corresponding function.
  #'\basdf '
)

@test "banned commands are not found in source code [${BATS_TEST_FILENAME_BASENAME}]" {
  # Assert command is not used in the lib and bin dirs
  # or expect an explicit comment at end of line, allowing it.
  # Also ignore matches that are contained in comments or a string or
  # followed by an underscore (indicating it's a variable and not a
  # command).
  for cmd in "${banned_commands[@]}"; do
    run bash -c "grep -nHR --include \*.bash --include \*.sh '$cmd' lib bin\
        | grep -v '#.*$cmd'\
        | grep -v '\".*$cmd.*\"' \
        | grep -v '${cmd}_'\
        | grep -v '# asdf_allow: $cmd'"

    # Only print output if we've found a banned command
    #if [ "$status" -ne 1 ]; then
    if [ "" != "$output" ]; then
      echo "banned command $cmd: $output"
    fi

    [ "$status" -eq 1 ]
    [ "" = "$output" ]
  done

  for cmd in "${banned_commands_regex[@]}"; do
    run bash -c "grep -nHRE --include \*.bash --include \*.sh '$cmd' lib bin\
        | grep -v '#.*$cmd'\
        | grep -v '\".*$cmd.*\"' \
        | grep -v '${cmd}_'\
        | grep -v '# asdf_allow: $cmd'"

    # Only print output if we've found a banned command
    #if [ "$status" -ne 1 ]; then
    if [ "" != "$output" ]; then
      echo "banned command $cmd: $output"
    fi

    [ "$status" -eq 1 ]
    [ "" = "$output" ]
  done
}
