#!/usr/bin/env bats
# Unit tests for .claude/lib/bash/parallel-common.sh, the bash port of the
# shared predicates and error-string builders in
# scripts/dev_tools/_parallel_state_common.py. Covers Python repr rendering
# including quote selection and the three printable control escapes, the type
# predicates (with the boolean exclusion from integer slots), the enum and item
# context builders, and the error accumulator. Every input is a literal in this
# file; no temporary file is created and no external process is started.

setup() {
    REPO_ROOT="$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)"
    LIB_DIR="${REPO_ROOT}/.claude/lib/bash"
    # shellcheck source=/dev/null
    source "${LIB_DIR}/parallel-common.sh"
    pc_enforce_c_locale
    pc_errors_reset
}

@test "pc_enforce_c_locale pins LC_ALL to C" {
    pc_enforce_c_locale
    [ "$LC_ALL" = "C" ]
}

@test "pc_repr_string single-quotes a plain string" {
    result="$(pc_repr_string "alpha")"
    [ "$result" = "'alpha'" ]
}

@test "pc_repr_string switches to double quotes for an apostrophe" {
    result="$(pc_repr_string "it's")"
    [ "$result" = '"it'"'"'s"' ]
}

@test "pc_repr_string keeps single quotes when only a double quote is present" {
    result="$(pc_repr_string 'say "hi"')"
    [ "$result" = "'say \"hi\"'" ]
}

@test "pc_repr_string escapes the apostrophe when both quote characters appear" {
    result="$(pc_repr_string 'both " and '"'"'')"
    [ "$result" = "'both \" and \\''" ]
}

@test "pc_repr_string escapes a backslash before the control escapes" {
    result="$(pc_repr_string 'a\b')"
    [ "$result" = "'a\\\\b'" ]
}

@test "pc_repr_string renders newline, carriage return, and tab escapes" {
    result="$(pc_repr_string "$(printf 'a\nb\tc')")"
    [ "$result" = "'a\\nb\\tc'" ]
    carriage="$(pc_repr_string "$(printf 'x\ry')")"
    [ "$carriage" = "'x\\ry'" ]
}

@test "pc_repr renders None for an absent key and for null" {
    [ "$(pc_repr absent "")" = "None" ]
    [ "$(pc_repr null "")" = "None" ]
}

@test "pc_repr renders Python boolean capitalization" {
    [ "$(pc_repr bool true)" = "True" ]
    [ "$(pc_repr bool false)" = "False" ]
}

@test "pc_repr passes integers and floats through unquoted" {
    [ "$(pc_repr int 12)" = "12" ]
    [ "$(pc_repr int -4)" = "-4" ]
    [ "$(pc_repr float 1.5)" = "1.5" ]
}

@test "pc_repr quotes strings through the repr rules" {
    [ "$(pc_repr str paused)" = "'paused'" ]
}

@test "pc_is_non_empty_string accepts a string with content" {
    run pc_is_non_empty_string str "alpha"
    [ "$status" -eq 0 ]
}

@test "pc_is_non_empty_string rejects a whitespace-only string" {
    run pc_is_non_empty_string str "   "
    [ "$status" -ne 0 ]
}

@test "pc_is_non_empty_string rejects a non-string type" {
    run pc_is_non_empty_string int 5
    [ "$status" -ne 0 ]
    run pc_is_non_empty_string absent ""
    [ "$status" -ne 0 ]
}

@test "pc_is_integer accepts an integer and excludes a boolean" {
    run pc_is_integer int
    [ "$status" -eq 0 ]
    run pc_is_integer bool
    [ "$status" -ne 0 ]
}

@test "pc_is_positive_integer rejects zero, negatives, and booleans" {
    run pc_is_positive_integer int 1
    [ "$status" -eq 0 ]
    run pc_is_positive_integer int 0
    [ "$status" -ne 0 ]
    run pc_is_positive_integer int -1
    [ "$status" -ne 0 ]
    run pc_is_positive_integer bool true
    [ "$status" -ne 0 ]
}

@test "pc_is_non_negative_integer accepts zero and rejects negatives" {
    run pc_is_non_negative_integer int 0
    [ "$status" -eq 0 ]
    run pc_is_non_negative_integer int -1
    [ "$status" -ne 0 ]
}

@test "pc_in_bounded_range enforces both inclusive bounds" {
    run pc_in_bounded_range int 1 1 8
    [ "$status" -eq 0 ]
    run pc_in_bounded_range int 8 1 8
    [ "$status" -eq 0 ]
    run pc_in_bounded_range int 0 1 8
    [ "$status" -ne 0 ]
    run pc_in_bounded_range int 9 1 8
    [ "$status" -ne 0 ]
}

@test "pc_in_bounded_range excludes booleans from the numeric slot" {
    run pc_in_bounded_range bool true 1 8
    [ "$status" -ne 0 ]
}

@test "pc_enum_error renders the canonical member order and the value repr" {
    result="$(pc_enum_error "Parallel manifest" "mode" "$PC_VALID_MODES" "$(pc_repr str paused)")"
    [ "$result" = "Parallel manifest mode must be one of closed, open; found: 'paused'." ]
}

@test "pc_item_context renders the positional item prefix" {
    [ "$(pc_item_context "Parallel manifest" 0)" = "Parallel manifest items[0]" ]
    [ "$(pc_item_context "Parallel checkpoint" 12)" = "Parallel checkpoint items[12]" ]
}

@test "pc_contains_word matches whole words only" {
    run pc_contains_word "merged worktree_removed" "merged"
    [ "$status" -eq 0 ]
    run pc_contains_word "merged worktree_removed" "merge"
    [ "$status" -ne 0 ]
}

@test "pc_enum_members_contains reads the comma-and-space joined member list" {
    run pc_enum_members_contains "$PC_VALID_KINDS" "bug"
    [ "$status" -eq 0 ]
    run pc_enum_members_contains "$PC_VALID_KINDS" "chore"
    [ "$status" -ne 0 ]
}

@test "the error accumulator preserves emission order and resets cleanly" {
    pc_error_add "first"
    pc_error_add "second"
    [ "$(pc_errors_count)" -eq 2 ]
    result="$(pc_errors_print)"
    [ "$result" = "$(printf 'first\nsecond')" ]
    pc_errors_reset
    [ "$(pc_errors_count)" -eq 0 ]
    [ -z "$(pc_errors_print)" ]
}
