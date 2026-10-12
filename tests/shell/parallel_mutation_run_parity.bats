#!/usr/bin/env bats
# Bash-lane assertions over the shared parallel run-mutation parity corpus
# (issue #890).
#
# Iterate every tests/fixtures/parallel_mutation_run/*.json file, run the port
# .claude/lib/bash/mutate-parallel-run.sh with the fixture's argument vector, and
# compare the exit code, the stdout literal, and the stderr literal against the
# fixture's expected block. The same corpus is asserted by the Python lane in
# tests/scripts/dev_tools/test_parallel_mutation_run_bash_parity.py, which runs
# decide_admission, recolor_unstarted, build_add_entry, decide_close,
# build_close_entry, and build_requeue_entry directly, so the fixtures are the
# single artifact that pins the two implementations together.
#
# Declared divergences (also listed in the script header and in the Python lane):
#   1. A duplicate key in `close --items` is a usage error (exit 2); the Python
#      mapping would silently keep the last record for that key.
#   2. `at` is a caller-supplied string instead of a `datetime`.
#   3. Option abbreviations are rejected.
#   4. `admit` has no rejection branch, in either implementation, so its
#      fixtures are success cases only.
# No corpus fixture exercises a usage error; usage errors are covered by
# tests/shell/parallel_mutation_run.bats only.
#
# The corpus is read through "${PARALLEL_PARITY_PYTHON:-python3}". That
# interpreter is a harness dependency of this suite, not of the code under test;
# tests/shell/parallel_payload_only.bats proves the entry point needs no Python.
#
# No temporary file is created: the corpus is a set of checked-in fixtures and
# stdout and stderr are captured in memory by two separate runs.

setup() {
    REPO_ROOT="$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)"
    SCRIPT="${REPO_ROOT}/.claude/lib/bash/mutate-parallel-run.sh"
    FIXTURE_DIR="${REPO_ROOT}/tests/fixtures/parallel_mutation_run"
    BASH_BIN="$(command -v bash)"
    PARITY_PYTHON="${PARALLEL_PARITY_PYTHON:-python3}"
    # Floor on corpus size. A broken glob would make the iteration below assert
    # nothing, so the count is checked against this floor in its own case.
    MINIMUM_FIXTURE_COUNT=21
}

# Echo one value from a fixture using a Python expression over the parsed
# document. Carriage returns are removed, because a Windows interpreter writes
# CRLF line endings. Fails the calling test when the interpreter is unavailable,
# so the suite can never pass vacuously.
fixture_field() {
    local value
    value="$("$PARITY_PYTHON" -c 'import json,sys
d = json.load(open(sys.argv[1], encoding="utf-8"))
sys.stdout.write(eval(sys.argv[2], {"d": d, "json": json}))' "$1" "$2")" || return 1
    printf '%s' "${value//$'\r'/}"
}

# Run the port and keep only its stdout.
run_stdout() {
    "$BASH_BIN" "$SCRIPT" "$@" 2>/dev/null
}

# Run the port and keep only its stderr.
run_stderr() {
    "$BASH_BIN" "$SCRIPT" "$@" 2>&1 >/dev/null
}

@test "the run parity corpus meets the declared floor" {
    count="$(find "$FIXTURE_DIR" -maxdepth 1 -name '*.json' -type f | wc -l)"
    [ "$count" -ge "$MINIMUM_FIXTURE_COUNT" ]
}

@test "the harness interpreter is available to read the corpus" {
    run command -v "$PARITY_PYTHON"
    [ "$status" -eq 0 ]
}

@test "the bash lane reproduces every run corpus fixture" {
    checked=0
    # Replay each fixture through the port and compare every observable.
    for fixture in "$FIXTURE_DIR"/*.json; do
        name="$(basename "$fixture" .json)"
        # Every argument is terminated by a unit separator, so an empty argument
        # (an empty --in-flight or --pinned list) survives as its own element and
        # no argument is split on whitespace.
        mapfile -d $'\x1f' -t argv < <(fixture_field "$fixture" '"".join(a + "\x1f" for a in d["argv"])')
        expected_exit="$(fixture_field "$fixture" 'str(d["expected"]["exit_code"])')"
        expected_stdout="$(fixture_field "$fixture" 'd["expected"]["stdout"] or ""')"
        expected_stderr="$(fixture_field "$fixture" 'd["expected"]["stderr"] or ""')"

        run run_stdout "${argv[@]}"
        actual_exit="$status"
        actual_stdout="$output"
        run run_stderr "${argv[@]}"
        actual_stderr="$output"

        if [ "$actual_exit" -ne "$expected_exit" ] || [ "$status" -ne "$expected_exit" ] ||
            [ "$actual_stdout" != "$expected_stdout" ] || [ "$actual_stderr" != "$expected_stderr" ]; then
            echo "run fixture mismatch: ${name} (status ${actual_exit})" >&2
            echo "stdout: ${actual_stdout}" >&2
            echo "stderr: ${actual_stderr}" >&2
            return 1
        fi
        checked=$((checked + 1))
    done
    [ "$checked" -ge "$MINIMUM_FIXTURE_COUNT" ]
}
