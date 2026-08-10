#!/usr/bin/env bats
# Unit tests for the restricted block-YAML parser split across
# .claude/lib/bash/parallel-yaml-scan.sh and parallel-yaml-emit.sh. Covers the
# three-terminator line splitting, both M1 fence errors, subset parsing of the
# manifest shape (nested blast_radius, sequences, quoted scalars, lexical
# typing), and fail-closed rejection of the constructs the subset does not
# model. Every input is a literal in this file; no temporary file is created
# and no external process is started.

setup() {
    REPO_ROOT="$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)"
    LIB_DIR="${REPO_ROOT}/.claude/lib/bash"
    # The YAML modules do not depend on parallel-common.sh, so the locale guard
    # is sourced explicitly here rather than arriving transitively.
    # shellcheck source=/dev/null
    source "${LIB_DIR}/parallel-common.sh"
    # shellcheck source=/dev/null
    source "${LIB_DIR}/parallel-yaml-emit.sh"
    pc_enforce_c_locale
    CONTEXT="Parallel manifest"
}

# Parse a frontmatter document and echo the resulting parse status.
parse_status_for() {
    if ! yp_extract_frontmatter_body "$1" "$CONTEXT"; then
        printf 'fence'
        return 0
    fi
    yp_parse_body || true
    printf '%s' "$YP_STATUS"
}

@test "yp_split_lines splits on LF" {
    yp_split_lines "$(printf 'a\nb')"
    [ "${#YP_LINES[@]}" -eq 2 ]
    [ "${YP_LINES[0]}" = "a" ]
    [ "${YP_LINES[1]}" = "b" ]
}

@test "yp_split_lines consumes CRLF as one terminator" {
    yp_split_lines "$(printf 'a\r\nb')"
    [ "${#YP_LINES[@]}" -eq 2 ]
    [ "${YP_LINES[0]}" = "a" ]
    [ "${YP_LINES[1]}" = "b" ]
}

@test "yp_split_lines splits on a bare CR" {
    yp_split_lines "$(printf 'a\rb')"
    [ "${#YP_LINES[@]}" -eq 2 ]
    [ "${YP_LINES[0]}" = "a" ]
    [ "${YP_LINES[1]}" = "b" ]
}

@test "M1 reports a missing opening fence" {
    run yp_extract_frontmatter_body "$(printf 'parallel: x\n---\n')" "$CONTEXT"
    [ "$status" -ne 0 ]
    yp_extract_frontmatter_body "$(printf 'parallel: x\n---\n')" "$CONTEXT" || true
    [ "$YP_FENCE_ERROR" = "Parallel manifest must open with a '---' frontmatter fence." ]
}

@test "M1 reports an unterminated fence" {
    yp_extract_frontmatter_body "$(printf -- '---\nparallel: x\n')" "$CONTEXT" || true
    [ "$YP_FENCE_ERROR" = "Parallel manifest frontmatter block is not terminated by '---'." ]
}

@test "M1 extraction returns the body between the two fences" {
    yp_extract_frontmatter_body "$(printf -- '---\nparallel: x\nmode: open\n---\nbody\n')" "$CONTEXT"
    [ "${#YP_BODY_LINES[@]}" -eq 2 ]
    [ "${YP_BODY_LINES[0]}" = "parallel: x" ]
    [ "${YP_BODY_LINES[1]}" = "mode: open" ]
}

@test "an empty frontmatter body is reported as not a mapping" {
    [ "$(parse_status_for "$(printf -- '---\n---\n')")" = "not_a_mapping" ]
}

@test "a sequence root is reported as not a mapping" {
    [ "$(parse_status_for "$(printf -- '---\n- alpha\n- beta\n---\n')")" = "not_a_mapping" ]
}

@test "an unterminated quoted scalar is a YAML error" {
    [ "$(parse_status_for "$(printf -- '---\nparallel: "open\n---\n')")" = "yaml_error" ]
}

@test "tab indentation is a YAML error" {
    [ "$(parse_status_for "$(printf -- '---\nparallel: x\n\tmode: open\n---\n')")" = "yaml_error" ]
}

@test "a line that is neither a mapping nor a sequence entry is a YAML error" {
    [ "$(parse_status_for "$(printf -- '---\nnot-an-entry\n---\n')")" = "yaml_error" ]
}

@test "a non-empty flow collection is rejected fail-closed" {
    [ "$(parse_status_for "$(printf -- '---\nitems: [1, 2]\n---\n')")" = "out_of_subset" ]
}

@test "an anchor is rejected fail-closed" {
    [ "$(parse_status_for "$(printf -- '---\nparallel: &anchor x\n---\n')")" = "out_of_subset" ]
}

@test "a block scalar is rejected fail-closed" {
    [ "$(parse_status_for "$(printf -- '---\nnotes: |\n---\n')")" = "out_of_subset" ]
}

@test "an unquoted timestamp is rejected fail-closed" {
    [ "$(parse_status_for "$(printf -- '---\ncreated_at: 2026-08-10T00:00:00Z\n---\n')")" = "out_of_subset" ]
}

@test "a float scalar is rejected fail-closed" {
    [ "$(parse_status_for "$(printf -- '---\nratio: 0.25\n---\n')")" = "out_of_subset" ]
}

@test "a leading-zero integer is rejected fail-closed" {
    [ "$(parse_status_for "$(printf -- '---\nmax_concurrency: 04\n---\n')")" = "out_of_subset" ]
}

@test "a trailing comment is rejected fail-closed" {
    [ "$(parse_status_for "$(printf -- '---\nparallel: x # slug\n---\n')")" = "out_of_subset" ]
}

@test "the manifest shape parses into typed nodes at addressable paths" {
    document="$(printf -- '---\nparallel: alpha-run\nmode: closed\nmax_concurrency: 4\nenabled: true\nnotes:\nitems:\n  - issue_num: 101\n    feature_folder: docs/a\n    blast_radius:\n      paths:\n        - src/a.ts\n      modules: []\n      source: derived\n---\n')"
    yp_extract_frontmatter_body "$document" "$CONTEXT"
    yp_parse_body
    [ "$YP_STATUS" = "ok" ]
    [ "$(yp_type_of parallel)" = "str" ]
    [ "$(yp_value_of parallel)" = "alpha-run" ]
    [ "$(yp_type_of max_concurrency)" = "int" ]
    [ "$(yp_value_of max_concurrency)" = "4" ]
    [ "$(yp_type_of enabled)" = "bool" ]
    [ "$(yp_value_of enabled)" = "true" ]
    [ "$(yp_type_of notes)" = "null" ]
    [ "$(yp_type_of items)" = "seq" ]
    [ "$(yp_count_of items)" = "1" ]
    [ "$(yp_type_of 'items[0]')" = "map" ]
    [ "$(yp_type_of 'items[0].issue_num')" = "int" ]
    [ "$(yp_value_of 'items[0].feature_folder')" = "docs/a" ]
    [ "$(yp_type_of 'items[0].blast_radius')" = "map" ]
    [ "$(yp_type_of 'items[0].blast_radius.paths')" = "seq" ]
    [ "$(yp_count_of 'items[0].blast_radius.paths')" = "1" ]
    [ "$(yp_value_of 'items[0].blast_radius.paths[0]')" = "src/a.ts" ]
    [ "$(yp_type_of 'items[0].blast_radius.modules')" = "seq" ]
    [ "$(yp_count_of 'items[0].blast_radius.modules')" = "0" ]
}

@test "quoted scalars keep their quoted text and stay strings" {
    yp_extract_frontmatter_body "$(printf -- '---\ncreated_at: "2026-08-10T00:00:00Z"\nblank: ""\nsingle: '"'"'plain'"'"'\n---\n')" "$CONTEXT"
    yp_parse_body
    [ "$YP_STATUS" = "ok" ]
    [ "$(yp_type_of created_at)" = "str" ]
    [ "$(yp_value_of created_at)" = "2026-08-10T00:00:00Z" ]
    [ "$(yp_type_of blank)" = "str" ]
    [ -z "$(yp_value_of blank)" ]
    [ "$(yp_value_of single)" = "plain" ]
}

@test "an absent path reports the absent type and no value" {
    yp_extract_frontmatter_body "$(printf -- '---\nparallel: x\n---\n')" "$CONTEXT"
    yp_parse_body
    [ "$(yp_type_of nowhere)" = "absent" ]
    [ -z "$(yp_value_of nowhere)" ]
    [ "$(yp_count_of nowhere)" = "0" ]
    run yp_has nowhere
    [ "$status" -ne 0 ]
}

@test "document order is preserved in YP_ORDER" {
    yp_extract_frontmatter_body "$(printf -- '---\nparallel: x\nmode: open\nitems: []\n---\n')" "$CONTEXT"
    yp_parse_body
    [ "${YP_ORDER[0]}" = "parallel" ]
    [ "${YP_ORDER[1]}" = "mode" ]
    [ "${YP_ORDER[2]}" = "items" ]
}

@test "root keys record the <root> parent label and nested keys record their owner" {
    yp_extract_frontmatter_body "$(printf -- '---\nparallel: x\nitems:\n  - issue_num: 1\n---\n')" "$CONTEXT"
    yp_parse_body
    [ "${YP_PARENT[parallel]}" = "<root>" ]
    [ "${YP_PARENT['items[0].issue_num']}" = "items[0]" ]
    [ "${YP_KEY['items[0].issue_num']}" = "issue_num" ]
}
