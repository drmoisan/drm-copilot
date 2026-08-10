#!/usr/bin/env bats
# Bash-lane assertions over the shared parallel-manifest parity corpus.
#
# Iterate every tests/fixtures/parallel_manifest_bash/*.json file and compare
# the bash validator's output byte for byte against the fixture's
# expected_errors list, plus the two accessor results where the fixture declares
# them. The same corpus is asserted by the Python lane in
# tests/scripts/dev_tools/test_parallel_manifest_bash_parity.py, so the fixtures
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
#      single-element error-list shape, because the underlying YAML library's
#      exception text is not reproducible across runtimes. The one fixture in
#      this class declares divergence: "M1_YAML_PARSE" and
#      expected_error_prefix, and this suite asserts the prefix and the
#      single-element shape only.
#   2. Non-printable string-repr escapes. A string containing a control
#      character other than \n, \r, or \t renders its escape differently
#      between the two lanes, so no corpus fixture contains one.
#
# The corpus files are committed and read-only here. No temporary file is
# created. python3 is used only to read a checked-in JSON fixture; it is a
# harness dependency of this suite, not of the code under test. The
# destination-portability property -- that the validator needs no Python -- is
# asserted separately by tests/shell/parallel_payload_only.bats, which removes
# python from PATH.

setup() {
    REPO_ROOT="$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)"
    LIB_DIR="${REPO_ROOT}/.claude/lib/bash"
    FIXTURE_DIR="${REPO_ROOT}/tests/fixtures/parallel_manifest_bash"
    # shellcheck source=/dev/null
    source "${LIB_DIR}/parallel-manifest-validate.sh"
    pc_enforce_c_locale
    # Floor on corpus size. A broken glob would make the iteration below assert
    # nothing, so the count is checked against this floor in its own case.
    MINIMUM_FIXTURE_COUNT=24
}

# Echo one JSON value from a fixture using a python3 expression over the parsed
# document. Bytes are written unencoded so a CRLF or CR fixture survives intact.
fixture_field() {
    python3 -c 'import json,sys
d = json.load(open(sys.argv[1]))
sys.stdout.buffer.write(eval(sys.argv[2], {"d": d, "json": json}).encode())' "$1" "$2"
}

@test "the manifest parity corpus meets the declared floor" {
    count="$(find "$FIXTURE_DIR" -maxdepth 1 -name '*.json' -type f | wc -l)"
    [ "$count" -ge "$MINIMUM_FIXTURE_COUNT" ]
}

@test "python3 is available to read the corpus" {
    run command -v python3
    [ "$status" -eq 0 ]
}

@test "the bash lane reproduces every manifest corpus fixture" {
    checked=0
    for fixture in "$FIXTURE_DIR"/*.json; do
        name="$(basename "$fixture" .json)"
        text="$(fixture_field "$fixture" 'd["manifest_text"]')"
        divergence="$(fixture_field "$fixture" 'd.get("divergence","")')"

        rc=0
        pm_validate_text "$text" || rc=$?
        if [ "$rc" -eq 2 ]; then
            echo "fixture $name: refused as out of subset: $PM_SUBSET_DETAIL" >&2
            return 1
        fi
        actual="$(pc_errors_print)"

        if [ "$divergence" = "M1_YAML_PARSE" ]; then
            prefix="$(fixture_field "$fixture" 'd["expected_error_prefix"]')"
            if [ "$(pc_errors_count)" -ne 1 ]; then
                echo "fixture $name: expected exactly one error, got $(pc_errors_count)" >&2
                return 1
            fi
            case "$actual" in
            "$prefix"*) ;;
            *)
                echo "fixture $name: [$actual] does not start with [$prefix]" >&2
                return 1
                ;;
            esac
        else
            expected="$(fixture_field "$fixture" 'chr(10).join(d["expected_errors"])')"
            if [ "$actual" != "$expected" ]; then
                echo "fixture $name: actual=[$actual] expected=[$expected]" >&2
                return 1
            fi
        fi

        expected_mode="$(fixture_field "$fixture" 'd.get("expected_mode","")')"
        if [ -n "$expected_mode" ] && [ "$(pm_manifest_mode)" != "$expected_mode" ]; then
            echo "fixture $name: mode=[$(pm_manifest_mode)] expected=[$expected_mode]" >&2
            return 1
        fi
        expected_cap="$(fixture_field "$fixture" 'str(d.get("expected_max_concurrency",""))')"
        if [ -n "$expected_cap" ] && [ "$(pm_manifest_max_concurrency)" != "$expected_cap" ]; then
            echo "fixture $name: cap=[$(pm_manifest_max_concurrency)] expected=[$expected_cap]" >&2
            return 1
        fi
        checked=$((checked + 1))
    done
    [ "$checked" -ge "$MINIMUM_FIXTURE_COUNT" ]
}
