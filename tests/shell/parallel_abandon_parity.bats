#!/usr/bin/env bats
# Bash-lane assertions over the shared parallel abandon parity corpus (issue #763).
#
# Iterate every tests/fixtures/parallel_abandon/*.json file, run the bundled port
# .claude/lib/bash/abandon-parallel-item.sh with the fixture's argument vector, and
# compare the exit code, the ordered side-effect argument vectors, and the stderr
# line against the fixture's expected block. The same corpus is asserted by the
# Python lane in tests/scripts/dev_tools/test_parallel_abandon_bash_parity.py, which
# runs the Python reference scripts/dev_tools/parallel_mutation_abandon_cli.py, so
# the fixtures are the single artifact that pins the two implementations together.
#
# Declared divergence classes (also listed in the Python lane header):
#   1. argparse usage text. A fixture whose stderr_mode is "usage" compares the
#      exit code only in the Python lane; this lane additionally requires one
#      stderr line beginning "PARALLEL_ABANDON_ERROR: usage error:".
#   2. Option abbreviations. argparse accepts a unique option prefix; the bash
#      port rejects it. Such a fixture declares "divergence", and its
#      "python_expected" block is asserted by the Python lane only.
#   The bash port additionally accepts only canonical decimal integers for --item
#   and --pr, treats -h and --help as unknown options, and treats an option value
#   beginning with -- as a missing value. All three are usage errors (exit 2).
#
# The script runs with PATH set to a checked-in shim directory only (the gh-less
# directory when a fixture names gh as missing) and bash is invoked by absolute
# path, so a real `gh pr close` or `git worktree remove` is unreachable.
#
# The corpus is read through "${PARALLEL_PARITY_PYTHON:-python3}". That
# interpreter is a harness dependency of this suite, not of the code under test;
# tests/shell/parallel_payload_only.bats proves the entry point needs no Python.
#
# No temporary file is created: the corpus and the shims are checked-in fixtures.

setup() {
    REPO_ROOT="$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)"
    SCRIPT="${REPO_ROOT}/.claude/lib/bash/abandon-parallel-item.sh"
    SHIM_PATH="${REPO_ROOT}/tests/fixtures/parallel_abandon_path"
    GIT_ONLY_PATH="${REPO_ROOT}/tests/fixtures/parallel_abandon_path_git_only"
    FIXTURE_DIR="${REPO_ROOT}/tests/fixtures/parallel_abandon"
    BASH_BIN="$(command -v bash)"
    PARITY_PYTHON="${PARALLEL_PARITY_PYTHON:-python3}"
    # Floor on corpus size. A broken glob would make the iteration below assert
    # nothing, so the count is checked against this floor in its own case.
    MINIMUM_FIXTURE_COUNT=9
    # Checked-in shims may be stored without the executable bit on some
    # platforms; make them runnable for this checkout. Idempotent; creates no
    # files.
    chmod +x "${SHIM_PATH}"/* "${GIT_ONLY_PATH}"/* 2>/dev/null || true
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

@test "the abandon parity corpus meets the declared floor" {
    count="$(find "$FIXTURE_DIR" -maxdepth 1 -name '*.json' -type f | wc -l)"
    [ "$count" -ge "$MINIMUM_FIXTURE_COUNT" ]
}

@test "the harness interpreter is available to read the corpus" {
    run command -v "$PARITY_PYTHON"
    [ "$status" -eq 0 ]
}

@test "the bash lane reproduces every abandon corpus fixture" {
    checked=0
    # Replay each fixture through the port and compare every observable.
    for fixture in "$FIXTURE_DIR"/*.json; do
        name="$(basename "$fixture" .json)"
        # The argument vector travels unit-separator joined, so no argument is
        # split on whitespace.
        mapfile -d $'\x1f' -t argv < <(fixture_field "$fixture" '"\x1f".join(d["argv"])')
        missing="$(fixture_field "$fixture" 'd["missing_executable"] or ""')"
        gh_exit="$(fixture_field "$fixture" 'str(d["shim_exit"]["gh"])')"
        git_exit="$(fixture_field "$fixture" 'str(d["shim_exit"]["git"])')"
        expected_exit="$(fixture_field "$fixture" 'str(d["expected"]["exit_code"])')"
        expected_calls="$(fixture_field "$fixture" '"\n".join(" ".join(c) for c in d["expected"]["calls"])')"
        mode="$(fixture_field "$fixture" 'd["expected"]["stderr_mode"]')"
        expected_stderr="$(fixture_field "$fixture" 'd["expected"]["stderr"] or ""')"

        run_path="$SHIM_PATH"
        if [ "$missing" = "gh" ]; then
            run_path="$GIT_ONLY_PATH"
        fi
        run env PATH="$run_path" ABANDON_SHIM_GH_EXIT="$gh_exit" \
            ABANDON_SHIM_GIT_EXIT="$git_exit" "$BASH_BIN" "$SCRIPT" "${argv[@]}"

        # Split the combined output into the recorded calls and the error lines;
        # any other line is a mismatch.
        actual_calls=""
        error_lines=()
        stray=0
        for line in "${lines[@]}"; do
            case "$line" in
            "SHIM-CALL "*) actual_calls+="${actual_calls:+$'\n'}${line#SHIM-CALL }" ;;
            "PARALLEL_ABANDON_ERROR:"*) error_lines+=("$line") ;;
            *) stray=1 ;;
            esac
        done

        mismatch=0
        if [ "$status" -ne "$expected_exit" ] || [ "$actual_calls" != "$expected_calls" ] || [ "$stray" -ne 0 ]; then
            mismatch=1
        fi
        # Apply the stderr mode: none forbids an error line, exact compares the
        # single reference line, and usage requires one usage-error line.
        case "$mode" in
        none)
            if [ "${#error_lines[@]}" -ne 0 ]; then mismatch=1; fi
            ;;
        exact)
            if [ "${#error_lines[@]}" -ne 1 ] || [ "${error_lines[0]}" != "$expected_stderr" ]; then mismatch=1; fi
            ;;
        usage)
            if [ "${#error_lines[@]}" -ne 1 ] || [[ "${error_lines[0]}" != "PARALLEL_ABANDON_ERROR: usage error:"* ]]; then mismatch=1; fi
            ;;
        *)
            mismatch=1
            ;;
        esac
        if [ "$mismatch" -ne 0 ]; then
            echo "abandon fixture mismatch: ${name} (status ${status})" >&2
            printf '%s\n' "${lines[@]}" >&2
            return 1
        fi
        checked=$((checked + 1))
    done
    [ "$checked" -ge "$MINIMUM_FIXTURE_COUNT" ]
}
