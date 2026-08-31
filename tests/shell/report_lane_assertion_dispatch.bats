#!/usr/bin/env bats
# In-process dispatch tests for the CLI entry point
# .claude/lib/bash/report-lane-assertion.sh.
#
# Why this file exists, and why it is separate from
# tests/shell/parallel_lane_assertion.bats:
#
# 1. Size. The sibling suite stands at 458 lines against the 500-line cap in
#    .claude/rules/general-code-change.md. The plan's recorded remedy for that
#    cap is to split along @test group boundaries into a second bats file in the
#    same directory, which is what this file is.
#
# 2. Attribution. The sibling suite drives the entry point as a subprocess
#    (`run bash "$(ENTRY_POINT)" ...`), which is the correct shape for asserting
#    the process exit status of a CLI contract. kcov's bash line attribution,
#    however, does not credit lines inside `|| { ...; }` brace groups or inside
#    `case` branch bodies when the traced script is reached that way, so the
#    argument-dispatch arms of rla_main read as uncovered even though the
#    subprocess cases exercise and assert every one of them.
#
# These cases therefore call rla_main in process, after sourcing the entry point
# through its own `BASH_SOURCE[0] == $0` guard, so the dispatch arms are both
# executed and attributed. They assert the same observable behaviour as the
# subprocess cases -- return status, and which stream the usage text reached --
# and are additional to those cases rather than a replacement for them.
#
# Every input is a literal in this file or a checked-in fixture; no temporary
# file is created.

setup() {
    REPO_ROOT="$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)"
    LIB_DIR="${REPO_ROOT}/.claude/lib/bash"
    # The entry point guards its main invocation on BASH_SOURCE[0] == $0, so
    # sourcing it defines rla_usage, rla_manifest_unreadable_detail, rla_report
    # and rla_main without running anything.
    # shellcheck source=/dev/null
    source "${LIB_DIR}/report-lane-assertion.sh"
    USAGE_FIRST_LINE='Usage: report-lane-assertion.sh --manifest <path> [--edges "<a>:<b> ..."]'
}

# The checked-in payload manifest declares exactly issue_num 101 and 202 and
# asserts no expected_conflict_components.
PAYLOAD_MANIFEST() {
    printf -- '%s' "${REPO_ROOT}/tests/fixtures/parallel_manifest_payload/parallel.md"
}

@test "rla_usage prints the full usage text including both option lines" {
    run rla_usage
    [ "$status" -eq 0 ]
    [ "${lines[0]}" = "$USAGE_FIRST_LINE" ]
    # Both option lines and the advisory closing line are part of the contract:
    # they are what tells an operator that --edges is optional and that the
    # report never blocks.
    printf '%s\n' "$output" | grep -q -- '--manifest  Path to docs/features/parallel/<slug>/parallel.md (required).'
    printf '%s\n' "$output" | grep -q -- '--edges     Derived conflict edges as "<a>:<b> <c>:<d>" (optional).'
    printf '%s\n' "$output" | grep -q -- 'Advisory only: the report never blocks. Every non-usage path exits 0.'
}

@test "--help returns 0 and writes the usage text to stdout" {
    # --help is a successful request for the usage text, so it is not a usage
    # error and its text must not go to stderr.
    run rla_main --help
    [ "$status" -eq 0 ]
    [ "${lines[0]}" = "$USAGE_FIRST_LINE" ]
}

@test "-h is accepted as the short form of --help" {
    run rla_main -h
    [ "$status" -eq 0 ]
    [ "${lines[0]}" = "$USAGE_FIRST_LINE" ]
}

@test "--manifest without a value is a usage error" {
    # The flag is present but its value is absent, so the (($# >= 2)) guard on
    # the --manifest arm fires rather than the absent-manifest check below it.
    run rla_main --manifest
    [ "$status" -eq 2 ]
}

@test "--edges without a value is a usage error" {
    # The --edges arm has its own value guard, distinct from the --manifest arm.
    run rla_main --edges
    [ "$status" -eq 2 ]
}

@test "an absent --manifest is a usage error even when --edges is supplied" {
    # This reaches the manifest_seen check after the option loop drains, which
    # is a different arm from the two value guards above.
    run rla_main --edges "101:202"
    [ "$status" -eq 2 ]
}

@test "no arguments at all is a usage error" {
    run rla_main
    [ "$status" -eq 2 ]
}

@test "an unknown flag is a usage error" {
    run rla_main --unknown-flag
    [ "$status" -eq 2 ]
}

@test "an out-of-subset manifest returns 0 with the refusal line" {
    # pm_parse_manifest returns status 2 for a construct it declines to model.
    # The entry point reports that refusal on its own line and still exits 0,
    # because the diagnostic is advisory.
    run rla_main --manifest "${REPO_ROOT}/tests/fixtures/parallel_lane_assertion_bash/out-of-subset.md"
    [ "$status" -eq 0 ]
    [ "${#lines[@]}" -eq 1 ]
    case "${lines[0]}" in
    "Lane assertion: manifest outside the supported YAML subset ("*) ;;
    *) return 1 ;;
    esac
    case "${lines[0]}" in
    *"); no comparison made.") ;;
    *) return 1 ;;
    esac
}

@test "an unparseable manifest returns 0 with the M1 error line" {
    run rla_main --manifest "${REPO_ROOT}/tests/fixtures/parallel_lane_assertion_bash/not-a-mapping.md"
    [ "$status" -eq 0 ]
    [ "${lines[0]}" = "Lane assertion: manifest unparseable (Parallel manifest frontmatter must be a mapping.)." ]
}

@test "a missing manifest returns 0 with the unreadable line" {
    local missing="${REPO_ROOT}/tests/fixtures/parallel_lane_assertion_bash/no-such-manifest.md"
    [ ! -e "$missing" ]
    run rla_main --manifest "$missing"
    [ "$status" -eq 0 ]
    case "${lines[0]}" in
    "Lane assertion: manifest unreadable (no such file: "*) ;;
    *) return 1 ;;
    esac
}

@test "a directory manifest takes the unreadable path with its own detail" {
    # The three unreadable reasons are distinct branches of
    # rla_manifest_unreadable_detail, so the directory case is asserted on its
    # own detail text rather than only on the shared prefix.
    run rla_main --manifest "${REPO_ROOT}/tests/fixtures"
    [ "$status" -eq 0 ]
    case "${lines[0]}" in
    "Lane assertion: manifest unreadable (path is a directory: "*) ;;
    *) return 1 ;;
    esac
}

@test "a well-formed invocation returns 0 and reports the derived components" {
    run rla_main --manifest "$(PAYLOAD_MANIFEST)"
    [ "$status" -eq 0 ]
    [ "${lines[0]}" = "Lane assertion: 2 derived conflict component(s); 0 disagreement(s)." ]
}

@test "--edges is accepted with a value and does not change the exit status" {
    # Both flags parse in one invocation, which is the only path that shifts
    # twice through the option loop.
    run rla_main --manifest "$(PAYLOAD_MANIFEST)" --edges "101:202"
    [ "$status" -eq 0 ]
}
