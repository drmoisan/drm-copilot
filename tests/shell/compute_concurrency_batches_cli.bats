#!/usr/bin/env bats
# Unit tests for the argument-handling branches of
# .claude/lib/bash/compute-concurrency-batches.sh: the help flags, a missing
# value after each option, and an unknown option. Every input is a literal in
# this file; no temporary file is created. bats `run` merges stderr into
# $output and ${lines[0]}, so the usage text is checked regardless of the
# stream it is printed to.

setup() {
    REPO_ROOT="$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)"
    LIB_DIR="${REPO_ROOT}/.claude/lib/bash"
    BATCHES="${LIB_DIR}/compute-concurrency-batches.sh"
    USAGE_LINE='Usage: compute-concurrency-batches.sh --keys "<k1> <k2> ..." --max-concurrency <n>'
}

assert_usage_text() {
    # Assert that the merged output begins with the usage line and lists options.
    [ "${lines[0]}" = "$USAGE_LINE" ]
    [[ "$output" == *"Options:"* ]]
}

@test "--help exits 0 and prints the usage text" {
    run bash "$BATCHES" --help
    [ "$status" -eq 0 ]
    assert_usage_text
}

@test "-h is equivalent to --help" {
    run bash "$BATCHES" -h
    [ "$status" -eq 0 ]
    assert_usage_text
}

@test "--keys without a value is a usage error" {
    run bash "$BATCHES" --keys
    [ "$status" -eq 2 ]
    assert_usage_text
}

@test "--max-concurrency without a value is a usage error" {
    run bash "$BATCHES" --keys "1 2" --max-concurrency
    [ "$status" -eq 2 ]
    assert_usage_text
}

@test "an unknown option is a usage error" {
    run bash "$BATCHES" --bogus
    [ "$status" -eq 2 ]
    assert_usage_text
}
