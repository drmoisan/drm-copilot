#!/usr/bin/env bats
# Unit tests for .claude/lib/bash/parallel-items-validate.sh, the bash port of
# the shared work-item validators. Covers the item-record positive and negative
# paths, duplicate issue_num ordering, merge-status membership and its
# state-consistency rule, the blast-radius block checks, and the prohibited-key
# scan. Every input is a literal in this file; no temporary file is created and
# no external process is started.

setup() {
    REPO_ROOT="$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)"
    LIB_DIR="${REPO_ROOT}/.claude/lib/bash"
    # shellcheck source=/dev/null
    source "${LIB_DIR}/parallel-items-validate.sh"
    pc_enforce_c_locale
    CONTEXT="Parallel manifest"
    STATES="proposed, admitted, prepared, scheduled, in_flight, merged, withdrawn, blocked"
    MERGE_STATUSES="not_started, worktree_created, pr_open, ci_green, merged, worktree_removed, blocked_drift, blocked_ci_loop_limit"
}

# Parse a frontmatter document into the node table and reset the accumulator.
load_document() {
    pc_errors_reset
    yp_extract_frontmatter_body "$1" "$CONTEXT"
    yp_parse_body
}

# Render a well-formed items block carrying the supplied extra entry lines.
well_formed_item() {
    printf -- '  - issue_num: 101\n    feature_folder: docs/a\n    kind: feature\n    state: proposed\n%b    blast_radius:\n      paths:\n        - src/a.ts\n      modules: []\n      shared_surfaces: []\n      contracts: []\n      source: derived\n      computed_at: "2026-08-10T00:00:00Z"\n' "$1"
}

# Wrap an items block in a minimal valid frontmatter document. The explicit
# newline after %s restores the terminator that command substitution strips
# from the caller's items block.
document_with_items() {
    printf -- '---\nparallel: alpha-run\ncreated_at: "2026-08-10T00:00:00Z"\nitems:\n%s\n---\n' "$1"
}

@test "a well-formed item produces no errors" {
    load_document "$(document_with_items "$(well_formed_item "")")"
    pi_validate_items "items" "$CONTEXT" 1
    [ "$(pc_errors_count)" -eq 0 ]
}

@test "a non-list items value yields exactly one error" {
    load_document "$(printf -- '---\nparallel: x\ncreated_at: "t"\nitems: 5\n---\n')"
    pi_validate_items "items" "$CONTEXT" 1
    [ "$(pc_errors_count)" -eq 1 ]
    [ "$(pc_errors_print)" = "Parallel manifest items must be a list." ]
}

@test "an absent items key yields the same single list error" {
    load_document "$(printf -- '---\nparallel: x\ncreated_at: "t"\n---\n')"
    pi_validate_items "items" "$CONTEXT" 1
    [ "$(pc_errors_print)" = "Parallel manifest items must be a list." ]
}

@test "an empty items list is valid" {
    load_document "$(printf -- '---\nparallel: x\ncreated_at: "t"\nitems: []\n---\n')"
    pi_validate_items "items" "$CONTEXT" 1
    [ "$(pc_errors_count)" -eq 0 ]
}

@test "a scalar items entry yields exactly one error" {
    load_document "$(document_with_items "$(printf -- '  - just-a-string\n')")"
    pi_validate_items "items" "$CONTEXT" 1
    [ "$(pc_errors_count)" -eq 1 ]
    [ "$(pc_errors_print)" = "Parallel manifest items[0] must be an object." ]
}

@test "a non-positive issue_num is reported with its repr" {
    load_document "$(document_with_items "$(printf -- '  - issue_num: 0\n    feature_folder: docs/a\n    kind: feature\n    state: proposed\n    blast_radius:\n      paths: []\n      modules: []\n      shared_surfaces: []\n      contracts: []\n      source: derived\n      computed_at: "t"\n')")"
    pi_validate_items "items" "$CONTEXT" 1
    [ "$(pc_errors_print)" = "Parallel manifest items[0] issue_num must be a positive integer; found: 0." ]
}

@test "an absent issue_num renders as None" {
    load_document "$(document_with_items "$(printf -- '  - feature_folder: docs/a\n    kind: feature\n    state: proposed\n    blast_radius:\n      paths: []\n      modules: []\n      shared_surfaces: []\n      contracts: []\n      source: derived\n      computed_at: "t"\n')")"
    pi_validate_items "items" "$CONTEXT" 1
    [ "$(pc_errors_print)" = "Parallel manifest items[0] issue_num must be a positive integer; found: None." ]
}

@test "an out-of-enum state renders the canonical member order" {
    load_document "$(document_with_items "$(printf -- '  - issue_num: 101\n    feature_folder: docs/a\n    kind: feature\n    state: queued\n    blast_radius:\n      paths: []\n      modules: []\n      shared_surfaces: []\n      contracts: []\n      source: derived\n      computed_at: "t"\n')")"
    pi_validate_items "items" "$CONTEXT" 1
    [ "$(pc_errors_print)" = "Parallel manifest items[0] state must be one of ${STATES}; found: 'queued'." ]
}

@test "kind is only required when the caller asks for it" {
    document="$(document_with_items "$(printf -- '  - issue_num: 101\n    feature_folder: docs/a\n    state: proposed\n    blast_radius:\n      paths: []\n      modules: []\n      shared_surfaces: []\n      contracts: []\n      source: derived\n      computed_at: "t"\n')")"
    load_document "$document"
    pi_validate_items "items" "$CONTEXT" 1
    [ "$(pc_errors_print)" = "Parallel manifest items[0] kind must be one of feature, bug; found: None." ]
    load_document "$document"
    pi_validate_items "items" "$CONTEXT" 0
    [ "$(pc_errors_count)" -eq 0 ]
}

@test "an absent merge_status contributes no error" {
    load_document "$(document_with_items "$(well_formed_item "")")"
    pi_validate_items "items" "$CONTEXT" 1
    [ "$(pc_errors_count)" -eq 0 ]
}

@test "an out-of-enum merge_status short-circuits the consistency rule" {
    load_document "$(document_with_items "$(well_formed_item "    merge_status: pending\n")")"
    pi_validate_items "items" "$CONTEXT" 1
    [ "$(pc_errors_count)" -eq 1 ]
    [ "$(pc_errors_print)" = "Parallel manifest items[0] merge_status must be one of ${MERGE_STATUSES}; found: 'pending'." ]
}

@test "a merged merge_status requires state merged" {
    load_document "$(document_with_items "$(well_formed_item "    merge_status: worktree_removed\n")")"
    pi_validate_items "items" "$CONTEXT" 1
    [ "$(pc_errors_print)" = "Parallel manifest items[0] merge_status 'worktree_removed' requires state 'merged'; found: 'proposed'." ]
}

@test "a blocked merge_status requires state blocked" {
    load_document "$(document_with_items "$(well_formed_item "    merge_status: blocked_ci_loop_limit\n")")"
    pi_validate_items "items" "$CONTEXT" 1
    [ "$(pc_errors_print)" = "Parallel manifest items[0] merge_status 'blocked_ci_loop_limit' requires state 'blocked'; found: 'proposed'." ]
}

@test "a non-terminal merge_status places no constraint on state" {
    load_document "$(document_with_items "$(well_formed_item "    merge_status: pr_open\n")")"
    pi_validate_items "items" "$CONTEXT" 1
    [ "$(pc_errors_count)" -eq 0 ]
}

@test "a missing blast_radius block yields exactly one error" {
    load_document "$(document_with_items "$(printf -- '  - issue_num: 101\n    feature_folder: docs/a\n    kind: feature\n    state: proposed\n')")"
    pi_validate_items "items" "$CONTEXT" 1
    [ "$(pc_errors_count)" -eq 1 ]
    [ "$(pc_errors_print)" = "Parallel manifest items[0] blast_radius must be an object." ]
}

@test "blast-radius field errors are reported in field order then source then computed_at" {
    load_document "$(document_with_items "$(printf -- '  - issue_num: 101\n    feature_folder: docs/a\n    kind: feature\n    state: proposed\n    blast_radius:\n      paths: notalist\n      modules: []\n      shared_surfaces: []\n      contracts: []\n      source: guessed\n')")"
    pi_validate_items "items" "$CONTEXT" 1
    [ "$(pc_errors_count)" -eq 3 ]
    [ "${PC_ERRORS[0]}" = "Parallel manifest items[0] blast_radius.paths must be a list of non-empty strings." ]
    [ "${PC_ERRORS[1]}" = "Parallel manifest items[0] blast_radius.source must be one of derived, declared, observed; found: 'guessed'." ]
    [ "${PC_ERRORS[2]}" = "Parallel manifest items[0] blast_radius.computed_at must be a non-empty string." ]
}

@test "a blank entry fails the whole radius list" {
    load_document "$(document_with_items "$(printf -- '  - issue_num: 101\n    feature_folder: docs/a\n    kind: feature\n    state: proposed\n    blast_radius:\n      paths:\n        - ""\n      modules: []\n      shared_surfaces: []\n      contracts: []\n      source: derived\n      computed_at: "t"\n')")"
    pi_validate_items "items" "$CONTEXT" 1
    [ "$(pc_errors_print)" = "Parallel manifest items[0] blast_radius.paths must be a list of non-empty strings." ]
}

@test "duplicate issue_num values are reported after the per-entry pass in ascending order" {
    load_document "$(document_with_items "$(printf -- '  - issue_num: 202\n    feature_folder: docs/b\n    kind: feature\n    state: proposed\n    blast_radius:\n      paths: []\n      modules: []\n      shared_surfaces: []\n      contracts: []\n      source: derived\n      computed_at: "t"\n  - issue_num: 101\n    feature_folder: docs/a\n    kind: feature\n    state: proposed\n    blast_radius:\n      paths: []\n      modules: []\n      shared_surfaces: []\n      contracts: []\n      source: derived\n      computed_at: "t"\n  - issue_num: 202\n    feature_folder: docs/c\n    kind: bug\n    state: proposed\n    blast_radius:\n      paths: []\n      modules: []\n      shared_surfaces: []\n      contracts: []\n      source: derived\n      computed_at: "t"\n  - issue_num: 101\n    feature_folder: docs/d\n    kind: bug\n    state: proposed\n    blast_radius:\n      paths: []\n      modules: []\n      shared_surfaces: []\n      contracts: []\n      source: derived\n      computed_at: "t"\n')")"
    pi_validate_items "items" "$CONTEXT" 1
    [ "$(pc_errors_count)" -eq 2 ]
    [ "${PC_ERRORS[0]}" = "Parallel manifest has duplicate items[].issue_num: 101." ]
    [ "${PC_ERRORS[1]}" = "Parallel manifest has duplicate items[].issue_num: 202." ]
}

@test "a key repeated three times still yields exactly one duplicate error" {
    load_document "$(document_with_items "$(printf -- '  - issue_num: 7\n    feature_folder: docs/a\n    kind: feature\n    state: proposed\n    blast_radius:\n      paths: []\n      modules: []\n      shared_surfaces: []\n      contracts: []\n      source: derived\n      computed_at: "t"\n  - issue_num: 7\n    feature_folder: docs/b\n    kind: feature\n    state: proposed\n    blast_radius:\n      paths: []\n      modules: []\n      shared_surfaces: []\n      contracts: []\n      source: derived\n      computed_at: "t"\n  - issue_num: 7\n    feature_folder: docs/c\n    kind: feature\n    state: proposed\n    blast_radius:\n      paths: []\n      modules: []\n      shared_surfaces: []\n      contracts: []\n      source: derived\n      computed_at: "t"\n')")"
    pi_validate_items "items" "$CONTEXT" 1
    [ "$(pc_errors_count)" -eq 1 ]
    [ "$(pc_errors_print)" = "Parallel manifest has duplicate items[].issue_num: 7." ]
}

@test "the prohibited-key scan reports a nested key at its owning mapping path" {
    load_document "$(document_with_items "$(well_formed_item "    depends_on: []\n")")"
    pi_scan_prohibited_keys "$CONTEXT" "depends_on" "integration_branch"
    [ "$(pc_errors_print)" = "Parallel manifest carries prohibited key 'depends_on' at items[0]." ]
}

@test "the prohibited-key scan reports a root key with the <root> label" {
    load_document "$(printf -- '---\nparallel: x\ncreated_at: "t"\ndepends_on: []\nitems: []\n---\n')"
    pi_scan_prohibited_keys "$CONTEXT" "depends_on" "integration_branch"
    [ "$(pc_errors_print)" = "Parallel manifest carries prohibited key 'depends_on' at <root>." ]
}

@test "integration_branch is rejected at the root only" {
    load_document "$(printf -- '---\nparallel: x\ncreated_at: "t"\nintegration_branch: epic/alpha\nitems: []\n---\n')"
    pi_scan_prohibited_keys "$CONTEXT" "depends_on" "integration_branch"
    [ "$(pc_errors_print)" = "Parallel manifest carries prohibited key 'integration_branch' at <root>." ]

    load_document "$(document_with_items "$(well_formed_item "    integration_branch: epic/alpha\n")")"
    pi_scan_prohibited_keys "$CONTEXT" "depends_on" "integration_branch"
    [ "$(pc_errors_count)" -eq 0 ]
}
