#!/usr/bin/env bats
# Bash-lane assertions over the shared parallel-cohort parity corpus.
#
# Iterate every tests/fixtures/parallel_cohorts/*.json file and compare the bash
# entry points' stdout, stderr, and exit code against the fixture's
# expected_cohorts, expected_batches, or expected_error block. The same corpus
# is asserted by the Python lane in
# tests/scripts/dev_tools/test_parallel_cohort_bash_parity.py, so the fixtures
# are the single artifact that pins the two implementations together; neither
# suite may relax an expectation without the other observing the change.
#
# Verified scope and declared divergence classes. Parity between the Python and
# bash lanes is byte-exact for every fixture in this corpus, including Python
# repr quote selection, with exactly two declared exceptions recorded in all
# four parity-suite headers for this feature:
#
#   1. The M1 YAML-parse-failure message. Parity is scoped to the prefix
#      "Parallel manifest frontmatter is not valid YAML: " plus the
#      single-element error-list shape. This class does not arise in the cohort
#      corpus; it is restated here so all four headers carry the same scope.
#   2. Non-printable string-repr escapes. A string containing a control
#      character other than \n, \r, or \t renders its escape differently
#      between the two lanes, so no corpus fixture contains one.
#
# Additionally excluded from the corpus by the pinned lexical rule: integer
# tokens with leading zeros (-?0[0-9]+). The bash entry points reject them with
# a bash-side lexical error before any shared code runs, so they have no Python
# counterpart; tests/shell/parallel_cohorts.bats asserts that rejection
# directly.
#
# The corpus files are committed and read-only here. No temporary file is
# created. python3 is used only to read a checked-in JSON fixture; it is a
# harness dependency of this suite, not of the code under test. The
# destination-portability property -- that the entry points need no Python --
# is asserted separately by tests/shell/parallel_payload_only.bats, which
# removes python from PATH.

setup() {
    REPO_ROOT="$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)"
    LIB_DIR="${REPO_ROOT}/.claude/lib/bash"
    COHORTS="${LIB_DIR}/compute-cohorts.sh"
    BATCHES="${LIB_DIR}/compute-concurrency-batches.sh"
    FIXTURE_DIR="${REPO_ROOT}/tests/fixtures/parallel_cohorts"
    # Floor on corpus size. A broken glob would make the iteration below assert
    # nothing, so the count is checked against this floor in its own case.
    MINIMUM_FIXTURE_COUNT=20
}

# Echo one JSON value from a fixture using a python3 expression over the parsed
# document. Fails the calling test when python3 is unavailable, so the suite can
# never pass vacuously on a runner without it.
fixture_field() {
    python3 -c 'import json,sys
d = json.load(open(sys.argv[1]))
sys.stdout.write(eval(sys.argv[2], {"d": d, "json": json}))' "$1" "$2"
}

@test "the cohort parity corpus meets the declared floor" {
    count="$(find "$FIXTURE_DIR" -maxdepth 1 -name '*.json' -type f | wc -l)"
    [ "$count" -ge "$MINIMUM_FIXTURE_COUNT" ]
}

@test "python3 is available to read the corpus" {
    run command -v python3
    [ "$status" -eq 0 ]
}

@test "the bash lane reproduces every cohort corpus fixture" {
    checked=0
    for fixture in "$FIXTURE_DIR"/*.json; do
        name="$(basename "$fixture" .json)"
        kind="$(fixture_field "$fixture" '"batch" if "cohort_item_keys" in d["input"] else "cohort"')"
        expected_error="$(fixture_field "$fixture" 'd.get("expected_error","")')"

        if [ "$kind" = "batch" ]; then
            keys="$(fixture_field "$fixture" '" ".join(str(k) for k in d["input"]["cohort_item_keys"])')"
            cap="$(fixture_field "$fixture" 'str(d["input"]["max_concurrency"])')"
            run bash "$BATCHES" --keys "$keys" --max-concurrency "$cap"
            expected_out="$(fixture_field "$fixture" 'json.dumps(d["expected_batches"],separators=(",",":")) if "expected_batches" in d else ""')"
        else
            keys="$(fixture_field "$fixture" '" ".join(str(k) for k in d["input"]["item_keys"])')"
            edges="$(fixture_field "$fixture" '" ".join(f"{a}:{b}" for a,b in d["input"]["conflict_edges"])')"
            run bash "$COHORTS" --keys "$keys" --edges "$edges"
            expected_out="$(fixture_field "$fixture" 'json.dumps(d["expected_cohorts"],separators=(",",":")) if "expected_cohorts" in d else ""')"
        fi

        if [ -n "$expected_error" ]; then
            if [ "$status" -ne 1 ] || [ "$output" != "$expected_error" ]; then
                echo "fixture $name: status=$status output=[$output] expected=[$expected_error]" >&2
                return 1
            fi
        else
            if [ "$status" -ne 0 ] || [ "$output" != "$expected_out" ]; then
                echo "fixture $name: status=$status output=[$output] expected=[$expected_out]" >&2
                return 1
            fi
        fi
        checked=$((checked + 1))
    done
    [ "$checked" -ge "$MINIMUM_FIXTURE_COUNT" ]
}
