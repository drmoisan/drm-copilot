#!/usr/bin/env bats
# Bash-lane assertions over the shared lane-assertion parity corpus.
#
# Iterate every tests/fixtures/parallel_lane_assertion/*.json record and compare
# the output of .claude/lib/bash/report-lane-assertion.sh, invoked as a
# subprocess, byte for byte against the record's expected_stdout, and its exit
# status against expected_status. The same corpus is asserted by the Python lane
# in tests/scripts/dev_tools/test_parallel_lane_assertion_bash_parity.py, so the
# records are the single artifact that pins the two implementations together;
# neither suite may relax an expectation without the other observing the change.
# Every expected_stdout in the corpus was derived by running the Python
# authority scripts/dev_tools/parallel_lane_assertion.py over the record's
# manifest and edges value, never hand authored.
#
# The entry point is invoked as a subprocess rather than sourced so that this
# lane pins the exit status as well as stdout. The Python lane starts no
# subprocess and calls main() directly.
#
# Verified scope and declared divergence classes. Parity between the Python and
# bash lanes is byte-exact for every record in this corpus, with exactly five
# declared classes, stated identically in the Python lane's module docstring:
#
#   1. (inherited) The M1 YAML-parse-failure message. The bash YP_DETAIL text is
#      not PyYAML's exception text, so a record exercising that branch would pin
#      the prefix only. No record in this corpus exercises it.
#   2. (inherited) Non-printable string-repr escapes. A string carrying a control
#      character other than \n, \r, or \t renders its escape differently between
#      the two lanes, so no corpus record contains one.
#   3. The --edges integer lexis. The port applies the strict lexis
#      ^-?(0|[1-9][0-9]*)$ used at .claude/lib/bash/compute-cohorts.sh:59 rather
#      than reproducing Python int()'s permissiveness. The excluded input class
#      has EXACTLY FOUR MEMBERS: an endpoint token bearing a leading zero, a
#      leading +, an underscore digit separator, or a non-ASCII decimal digit.
#      All four are excluded from this corpus and are pinned bash-side by
#      tests/shell/parallel_lane_assertion.bats. The case
#      "no corpus fixture carries an excluded edges endpoint form" below is the
#      independent assertion that none of the four reached the corpus.
#
#      WHITESPACE INSIDE AN ENDPOINT IS NOT A MEMBER OF CLASS 3. Both
#      implementations split the --edges value on whitespace before partitioning
#      a token on its first colon, so neither can observe interior whitespace and
#      the two CONVERGE on it. It is therefore carried inside this corpus as the
#      convergence record edges_endpoint_interior_whitespace, whose report is
#      byte-identical to the edges_empty record for the same manifest. Do not
#      move it into class 3.
#   4. The manifest-unreadable detail text. Python emits the OSError string,
#      which bash cannot reproduce, so only the prefix
#      "Lane assertion: manifest unreadable (" is parity scoped and the class is
#      excluded from this corpus and covered bash-side.
#   5. Out-of-subset manifests. pm_parse_manifest returns status 2 for constructs
#      the Python authority parses, so the Python lane has no counterpart. The
#      port prints a distinct refusal line and exits 0. The class is excluded
#      from this corpus and covered bash-side; its fixtures live under
#      tests/fixtures/parallel_lane_assertion_bash/, outside the corpus
#      directory, so the exclusion holds by construction.
#
# The corpus files are committed and read-only here. No temporary file is
# created. python3 is used only to read a checked-in JSON record; it is a harness
# dependency of this suite, not of the code under test. The
# destination-portability property -- that the diagnostic needs no Python -- is
# asserted separately by tests/shell/parallel_payload_only.bats, which removes
# every interpreter from PATH.

setup() {
    REPO_ROOT="$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)"
    ENTRY_POINT="${REPO_ROOT}/.claude/lib/bash/report-lane-assertion.sh"
    FIXTURE_DIR="${REPO_ROOT}/tests/fixtures/parallel_lane_assertion"
    # Floor on corpus size. A broken glob would make the iterations below assert
    # nothing, so the count is checked against this floor in its own case.
    MINIMUM_FIXTURE_COUNT=20
}

# Echo one JSON value from a record using a python3 expression over the parsed
# document. Bytes are written unencoded so no expected string is re-escaped.
fixture_field() {
    python3 -c 'import json,sys
d = json.load(open(sys.argv[1], encoding="utf-8"))
sys.stdout.buffer.write(eval(sys.argv[2], {"d": d, "json": json}).encode())' "$1" "$2"
}

@test "the lane-assertion parity corpus meets the declared floor" {
    count="$(find "$FIXTURE_DIR" -maxdepth 1 -name '*.json' -type f | wc -l)"
    [ "$count" -ge "$MINIMUM_FIXTURE_COUNT" ]
}

@test "python3 is available to read the corpus" {
    run command -v python3
    [ "$status" -eq 0 ]
}

@test "the bash lane reproduces every lane-assertion corpus fixture" {
    checked=0
    for fixture in "$FIXTURE_DIR"/*.json; do
        name="$(basename "$fixture" .json)"
        manifest="$(fixture_field "$fixture" 'd["manifest_path"]')"
        edges="$(fixture_field "$fixture" 'd["edges"]')"
        expected="$(fixture_field "$fixture" 'd["expected_stdout"]')"
        expected_status="$(fixture_field "$fixture" 'str(d["expected_status"])')"

        # A subprocess, so the exit status is pinned alongside stdout. cd into
        # the repository root first because manifest_path is repo-relative.
        actual="$(cd "$REPO_ROOT" && bash "$ENTRY_POINT" --manifest "$manifest" --edges "$edges")"
        status_actual=$?

        if [ "$actual" != "$expected" ]; then
            echo "fixture $name: actual=[$actual] expected=[$expected]" >&2
            return 1
        fi
        if [ "$status_actual" != "$expected_status" ]; then
            echo "fixture $name: status=[$status_actual] expected=[$expected_status]" >&2
            return 1
        fi
        checked=$((checked + 1))
    done
    [ "$checked" -ge "$MINIMUM_FIXTURE_COUNT" ]
}

@test "every finding class appears in the corpus" {
    # The four class tokens the report renders inside its ADVISORY brackets. A
    # corpus that exercised only some of them would let a renderer regression in
    # an unexercised class pass both lanes unobserved.
    for kind in expected_together_derived_apart expected_apart_derived_together \
        member_names_no_item item_covered_by_no_component; do
        seen=0
        for fixture in "$FIXTURE_DIR"/*.json; do
            expected="$(fixture_field "$fixture" 'd["expected_stdout"]')"
            case "$expected" in
            *"ADVISORY [$kind]"*)
                seen=1
                break
                ;;
            esac
        done
        if [ "$seen" -ne 1 ]; then
            echo "finding class $kind appears in no corpus expected_stdout" >&2
            return 1
        fi
    done
}

@test "at least one corpus fixture carries an ADVISORY line and status 0" {
    advisory_seen=0
    for fixture in "$FIXTURE_DIR"/*.json; do
        name="$(basename "$fixture" .json)"
        expected_status="$(fixture_field "$fixture" 'str(d["expected_status"])')"
        if [ "$expected_status" != "0" ]; then
            echo "fixture $name: expected_status=[$expected_status], expected [0]" >&2
            return 1
        fi
        expected="$(fixture_field "$fixture" 'd["expected_stdout"]')"
        case "$expected" in
        *ADVISORY*) advisory_seen=1 ;;
        esac
    done
    # An advisory finding must not be expressible as a non-zero exit status, so
    # the corpus has to contain at least one record that reports one and still
    # declares status 0; otherwise the status assertion above is vacuous.
    [ "$advisory_seen" -eq 1 ]
}

@test "every corpus record's manifest_text matches its manifest_path" {
    for fixture in "$FIXTURE_DIR"/*.json; do
        name="$(basename "$fixture" .json)"
        manifest="$(fixture_field "$fixture" 'd["manifest_path"]')"
        # Piped into cmp rather than captured into a variable: command
        # substitution strips trailing newlines from both sides, which would
        # make a trailing-newline drift between the record and the file invisible
        # to the comparison. This form is byte exact.
        if ! fixture_field "$fixture" 'd["manifest_text"]' | cmp -s - "${REPO_ROOT}/${manifest}"; then
            echo "fixture $name: manifest_text differs from $manifest" >&2
            return 1
        fi
    done
}

@test "the whitespace endpoint fixture converges with the empty-edges fixture" {
    # Interior whitespace inside an --edges endpoint is unreachable in both
    # implementations, so the two converge on it. The property is asserted as an
    # equality between two corpus records rather than as a divergence class.
    whitespace="${FIXTURE_DIR}/edges_endpoint_interior_whitespace.json"
    empty="${FIXTURE_DIR}/edges_empty.json"
    [ -f "$whitespace" ]
    [ -f "$empty" ]

    [ "$(fixture_field "$whitespace" 'd["manifest_path"]')" = "$(fixture_field "$empty" 'd["manifest_path"]')" ]
    [ "$(fixture_field "$whitespace" 'd["expected_stdout"]')" = "$(fixture_field "$empty" 'd["expected_stdout"]')" ]
    # The two records must differ in the input, or the equality above is trivial.
    [ "$(fixture_field "$whitespace" 'd["edges"]')" != "$(fixture_field "$empty" 'd["edges"]')" ]
}

# Report every corpus endpoint matching one of the four excluded divergence
# class 3 forms, one line per offender. Silence means the corpus is clean. The
# non-ASCII decimal-digit test needs the Unicode category table, which is why
# this scan runs in the harness interpreter rather than in a bash pattern.
excluded_endpoint_offenders() {
    python3 -c '
import json, pathlib, re, sys, unicodedata

LEADING_ZERO = re.compile(r"^0[0-9]")


def reasons(endpoint):
    found = []
    if LEADING_ZERO.match(endpoint):
        found.append("a leading zero followed by a further digit")
    if endpoint.startswith("+"):
        found.append("a leading plus")
    if "_" in endpoint:
        found.append("an underscore digit separator")
    if any(unicodedata.category(c) == "Nd" and not c.isascii() for c in endpoint):
        found.append("a non-ASCII decimal digit")
    return found


for path in sorted(pathlib.Path(sys.argv[1]).glob("*.json")):
    record = json.load(open(path, encoding="utf-8"))
    for token in record["edges"].split():
        first, separator, second = token.partition(":")
        if not separator:
            continue
        for endpoint in (first, second):
            for reason in reasons(endpoint):
                print(
                    f"{path.name}: token {token!r} endpoint {endpoint!r} carries {reason}"
                )
' "$1"
}

@test "no corpus fixture carries an excluded edges endpoint form" {
    # The independent, non-vacuous assertion that divergence class 3 is excluded
    # from the shared corpus. It is stated over the four excluded forms rather
    # than as "every endpoint matches ^-?(0|[1-9][0-9]*)$", because the stricter
    # phrasing would fail on legitimate members: the convergence record
    # edges_endpoint_interior_whitespace carries the edges value "101 : 202",
    # whose bare ":" token has empty endpoints that match no integer lexis. No
    # record and no token is exempted; an exemption would let a genuine class 3
    # form sit inside an exempted record undetected.
    offenders="$(excluded_endpoint_offenders "$FIXTURE_DIR")"
    if [ -n "$offenders" ]; then
        echo "$offenders" >&2
        return 1
    fi
}
