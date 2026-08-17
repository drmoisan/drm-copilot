#!/usr/bin/env bats
# Unit tests for .claude/lib/bash/parallel-manifest-validate.sh and the CLI
# entry point .claude/lib/bash/validate-parallel-manifest.sh. Covers the M1
# through M8 orchestration order and the two default-resolving accessors for
# present, absent, and invalid `mode` and `max_concurrency` values, which is
# the AC4 evidence. Every input is a literal in this file or a checked-in
# fixture manifest; no temporary file is created.

setup() {
    REPO_ROOT="$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)"
    LIB_DIR="${REPO_ROOT}/.claude/lib/bash"
    ENTRY="${LIB_DIR}/validate-parallel-manifest.sh"
    FIXTURE_MANIFEST="${REPO_ROOT}/tests/fixtures/parallel_manifest_payload/parallel.md"
    # shellcheck source=/dev/null
    source "${LIB_DIR}/parallel-manifest-validate.sh"
    pc_enforce_c_locale
    STATES="proposed, admitted, prepared, scheduled, in_flight, merged, withdrawn, blocked"
}

# Render a minimal valid frontmatter document from the supplied identity lines.
# The explicit newline after %b restores the terminator that command
# substitution strips from the caller's block.
document() {
    printf -- '---\n%b\n---\n\n# Parallel Run\n' "$1"
}

# The canonical well-formed identity and items block.
valid_body() {
    printf -- 'parallel: alpha-run\nmode: closed\nmax_concurrency: 4\ncreated_at: "2026-08-10T00:00:00Z"\nitems:\n  - issue_num: 101\n    feature_folder: docs/a\n    kind: feature\n    state: proposed\n    blast_radius:\n      paths:\n        - src/a.ts\n      modules: []\n      shared_surfaces: []\n      contracts: []\n      source: derived\n      computed_at: "2026-08-10T00:00:00Z"'
}

@test "a valid manifest produces no errors" {
    pm_validate_text "$(document "$(valid_body)")"
    [ "$(pc_errors_count)" -eq 0 ]
}

@test "M1 missing opening fence short-circuits with one error" {
    pm_validate_text "$(printf 'parallel: x\n---\n')"
    [ "$(pc_errors_count)" -eq 1 ]
    [ "$(pc_errors_print)" = "Parallel manifest must open with a '---' frontmatter fence." ]
}

@test "M1 unterminated fence short-circuits with one error" {
    pm_validate_text "$(printf -- '---\nparallel: x\n')"
    [ "$(pc_errors_count)" -eq 1 ]
    [ "$(pc_errors_print)" = "Parallel manifest frontmatter block is not terminated by '---'." ]
}

@test "M1 non-mapping frontmatter short-circuits with one error" {
    pm_validate_text "$(printf -- '---\n- alpha\n---\n')"
    [ "$(pc_errors_count)" -eq 1 ]
    [ "$(pc_errors_print)" = "Parallel manifest frontmatter must be a mapping." ]
}

@test "M1 unparseable YAML short-circuits with the prefixed message" {
    pm_validate_text "$(printf -- '---\nparallel: "open\n---\n')"
    [ "$(pc_errors_count)" -eq 1 ]
    case "$(pc_errors_print)" in
    "Parallel manifest frontmatter is not valid YAML: "*) ;;
    *) return 1 ;;
    esac
}

@test "an out-of-subset construct is refused with exit status 2" {
    run pm_validate_text "$(printf -- '---\nitems: [1, 2]\n---\n')"
    [ "$status" -eq 2 ]
}

@test "identity errors are emitted in schema field order" {
    pm_validate_text "$(document "mode: paused\nmax_concurrency: 33\nitems: []")"
    [ "$(pc_errors_count)" -eq 4 ]
    [ "${PC_ERRORS[0]}" = "Parallel manifest parallel must be a non-empty string." ]
    [ "${PC_ERRORS[1]}" = "Parallel manifest mode must be one of closed, open; found: 'paused'." ]
    [ "${PC_ERRORS[2]}" = "Parallel manifest max_concurrency must be an integer from 1 through 32; found: 33." ]
    [ "${PC_ERRORS[3]}" = "Parallel manifest created_at must be a non-empty string." ]
}

@test "section order is identity, then prohibited keys, then items" {
    pm_validate_text "$(document "parallel: alpha-run\nmode: paused\ncreated_at: \"t\"\ndepends_on: []\nitems:\n  - issue_num: 101\n    feature_folder: docs/a\n    kind: feature\n    state: queued\n    blast_radius:\n      paths: []\n      modules: []\n      shared_surfaces: []\n      contracts: []\n      source: derived\n      computed_at: \"t\"")"
    [ "$(pc_errors_count)" -eq 3 ]
    [ "${PC_ERRORS[0]}" = "Parallel manifest mode must be one of closed, open; found: 'paused'." ]
    [ "${PC_ERRORS[1]}" = "Parallel manifest carries prohibited key 'depends_on' at <root>." ]
    [ "${PC_ERRORS[2]}" = "Parallel manifest items[0] state must be one of ${STATES}; found: 'queued'." ]
}

@test "M7 rejects integration_branch at the document root" {
    pm_validate_text "$(document "parallel: x\ncreated_at: \"t\"\nintegration_branch: epic/alpha\nitems: []")"
    [ "$(pc_errors_print)" = "Parallel manifest carries prohibited key 'integration_branch' at <root>." ]
}

@test "the accessors return declared present values" {
    pm_validate_text "$(document "parallel: x\nmode: open\nmax_concurrency: 32\ncreated_at: \"t\"\nitems: []")"
    [ "$(pc_errors_count)" -eq 0 ]
    [ "$(pm_manifest_mode)" = "open" ]
    [ "$(pm_manifest_max_concurrency)" = "32" ]
}

@test "the accessors resolve the documented defaults when both keys are absent" {
    pm_validate_text "$(document "parallel: x\ncreated_at: \"t\"\nitems: []")"
    [ "$(pc_errors_count)" -eq 0 ]
    [ "$(pm_manifest_mode)" = "closed" ]
    [ "$(pm_manifest_max_concurrency)" = "4" ]
}

@test "an invalid non-string mode falls back to the default while still erroring" {
    pm_validate_text "$(document "parallel: x\nmode: 5\ncreated_at: \"t\"\nitems: []")"
    [ "$(pc_errors_print)" = "Parallel manifest mode must be one of closed, open; found: 5." ]
    [ "$(pm_manifest_mode)" = "closed" ]
}

@test "an invalid string mode is reported but still returned by the accessor" {
    pm_validate_text "$(document "parallel: x\nmode: paused\ncreated_at: \"t\"\nitems: []")"
    [ "$(pc_errors_print)" = "Parallel manifest mode must be one of closed, open; found: 'paused'." ]
    [ "$(pm_manifest_mode)" = "paused" ]
}

@test "a boolean max_concurrency is rejected and falls back to 4" {
    pm_validate_text "$(document "parallel: x\nmax_concurrency: true\ncreated_at: \"t\"\nitems: []")"
    [ "$(pc_errors_print)" = "Parallel manifest max_concurrency must be an integer from 1 through 32; found: True." ]
    [ "$(pm_manifest_max_concurrency)" = "4" ]
}

@test "a non-integer max_concurrency is rejected and falls back to 4" {
    pm_validate_text "$(document "parallel: x\nmax_concurrency: \"four\"\ncreated_at: \"t\"\nitems: []")"
    [ "$(pc_errors_print)" = "Parallel manifest max_concurrency must be an integer from 1 through 32; found: 'four'." ]
    [ "$(pm_manifest_max_concurrency)" = "4" ]
}

@test "an out-of-range max_concurrency is reported but still returned" {
    pm_validate_text "$(document "parallel: x\nmax_concurrency: 33\ncreated_at: \"t\"\nitems: []")"
    [ "$(pc_errors_print)" = "Parallel manifest max_concurrency must be an integer from 1 through 32; found: 33." ]
    [ "$(pm_manifest_max_concurrency)" = "33" ]
}

@test "the CLI validates the checked-in fixture manifest and exits 0 silently" {
    run bash "$ENTRY" "$FIXTURE_MANIFEST"
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

@test "the CLI prints the resolved mode and cap for the fixture manifest" {
    run bash "$ENTRY" --print-mode "$FIXTURE_MANIFEST"
    [ "$status" -eq 0 ]
    [ "$output" = "closed" ]
    run bash "$ENTRY" --print-max-concurrency "$FIXTURE_MANIFEST"
    [ "$status" -eq 0 ]
    [ "$output" = "4" ]
}

@test "the CLI exits 2 for a missing manifest and for a usage error" {
    run bash "$ENTRY" "${REPO_ROOT}/tests/fixtures/parallel_manifest_payload/no-such-file.md"
    [ "$status" -eq 2 ]
    run bash "$ENTRY"
    [ "$status" -eq 2 ]
    run bash "$ENTRY" --unknown-flag "$FIXTURE_MANIFEST"
    [ "$status" -eq 2 ]
}

@test "the CLI exits 1 and prints one error per line for an invalid manifest" {
    run bash "$ENTRY" "${REPO_ROOT}/tests/fixtures/parallel_manifest_payload/parallel-invalid.md"
    [ "$status" -eq 1 ]
    [ "${lines[0]}" = "Parallel manifest parallel must be a non-empty string." ]
    [ "${lines[1]}" = "Parallel manifest created_at must be a non-empty string." ]
    [ "${#lines[@]}" -eq 2 ]
}

@test "M8 accepts a named block-sequence expected_conflict_components entry" {
    pm_validate_text "$(document "$(valid_body)\nexpected_conflict_components:\n  - name: hooks-lane\n    members:\n      - 101")"
    [ "$(pc_errors_count)" -eq 0 ]
}

@test "M8 accepts an unnamed block-sequence entry, since name is optional" {
    pm_validate_text "$(document "$(valid_body)\nexpected_conflict_components:\n  - members:\n      - 101")"
    [ "$(pc_errors_count)" -eq 0 ]
}

@test "M8 contributes no error when the key is absent" {
    pm_validate_text "$(document "$(valid_body)")"
    [ "$(pc_errors_count)" -eq 0 ]
}

@test "M8 rejects a non-list expected_conflict_components value" {
    pm_validate_text "$(document "$(valid_body)\nexpected_conflict_components: hooks-lane")"
    [ "$(pc_errors_print)" = "Parallel manifest expected_conflict_components must be a list." ]
}

@test "M8 rejects a component whose members key is missing" {
    pm_validate_text "$(document "$(valid_body)\nexpected_conflict_components:\n  - name: hooks-lane")"
    [ "$(pc_errors_print)" = "Parallel manifest expected_conflict_components[0] members must be a non-empty list of positive integers." ]
}

@test "M8 rejects a member that resolves to no items[] issue_num" {
    pm_validate_text "$(document "$(valid_body)\nexpected_conflict_components:\n  - members:\n      - 999")"
    [ "$(pc_errors_print)" = "Parallel manifest expected_conflict_components[0] members[0] does not resolve to an items[] issue_num; found: 999." ]
}
