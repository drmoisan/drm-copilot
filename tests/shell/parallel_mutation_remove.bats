#!/usr/bin/env bats
# Unit tests for .claude/lib/bash/parallel-mutation.sh and its command-line
# entry point remove-parallel-item.sh (issue #791). Covers every decide row of
# the removal behavior table, both recolor offset rules and its rejections,
# every entry contract rejection, the explicit and default --at values, every
# usage-error class of the command line, and the three library functions
# called directly after sourcing the library.
#
# Every case asserts the exit status and the exact single output line; usage
# errors assert the "PARALLEL_MUTATION_ERROR: usage error:" prefix. The default
# --at case asserts the timestamp format only, so no case reads or waits on the
# clock. Every input is a literal in this file; no temporary file is created.

setup() {
    REPO_ROOT="$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)"
    LIB_DIR="${REPO_ROOT}/.claude/lib/bash"
    SCRIPT="${LIB_DIR}/remove-parallel-item.sh"
    # shellcheck source=/dev/null
    source "${LIB_DIR}/parallel-mutation.sh"
    pc_enforce_c_locale
}

# Assert the most recent run printed exactly one line equal to $1.
assert_single_line() {
    [ "${#lines[@]}" -eq 1 ]
    [ "$output" = "$1" ]
}

# Assert the most recent run was a usage error: exit 2 and one prefixed line.
assert_usage_error() {
    [ "$status" -eq 2 ]
    [ "${#lines[@]}" -eq 1 ]
    [[ $output == "PARALLEL_MUTATION_ERROR: usage error:"* ]]
}

@test "decide withdraws a proposed item and recomputes" {
    run bash "$SCRIPT" decide --item 5 --state proposed
    [ "$status" -eq 0 ]
    assert_single_line '{"item_key":5,"prior_state":"proposed","new_state":"withdrawn","disposition":null,"triggers_recompute":true}'
}

@test "decide withdraws an admitted item and recomputes" {
    run bash "$SCRIPT" decide --item 5 --state admitted
    [ "$status" -eq 0 ]
    assert_single_line '{"item_key":5,"prior_state":"admitted","new_state":"withdrawn","disposition":null,"triggers_recompute":true}'
}

@test "decide withdraws a prepared item and recomputes" {
    run bash "$SCRIPT" decide --item 5 --state prepared
    [ "$status" -eq 0 ]
    assert_single_line '{"item_key":5,"prior_state":"prepared","new_state":"withdrawn","disposition":null,"triggers_recompute":true}'
}

@test "decide withdraws a scheduled item and recomputes" {
    run bash "$SCRIPT" decide --item 5 --state scheduled
    [ "$status" -eq 0 ]
    assert_single_line '{"item_key":5,"prior_state":"scheduled","new_state":"withdrawn","disposition":null,"triggers_recompute":true}'
}

@test "decide detaches an in-flight item without a recompute" {
    run bash "$SCRIPT" decide --item 7 --state in_flight --removal-disposition detach
    [ "$status" -eq 0 ]
    assert_single_line '{"item_key":7,"prior_state":"in_flight","new_state":"withdrawn","disposition":"detach","triggers_recompute":false}'
}

@test "decide abandons an in-flight item without a recompute" {
    run bash "$SCRIPT" decide --item 7 --state in_flight --removal-disposition abandon
    [ "$status" -eq 0 ]
    assert_single_line '{"item_key":7,"prior_state":"in_flight","new_state":"withdrawn","disposition":"abandon","triggers_recompute":false}'
}

@test "decide rejects an in-flight item without a disposition" {
    run bash "$SCRIPT" decide --item 7 --state in_flight
    [ "$status" -eq 1 ]
    assert_single_line 'Parallel mutation rejected: removal of in-flight item 7 requires an explicit disposition, one of detach, abandon; no default is inferred.'
}

@test "decide rejects a withdrawn item as unknown" {
    run bash "$SCRIPT" decide --item 3 --state withdrawn
    [ "$status" -eq 1 ]
    assert_single_line 'Parallel mutation rejected: item key 3 does not resolve to a tracked items[].issue_num.'
}

@test "decide rejects a blocked item as unknown" {
    run bash "$SCRIPT" decide --item 3 --state blocked
    [ "$status" -eq 1 ]
    assert_single_line 'Parallel mutation rejected: item key 3 does not resolve to a tracked items[].issue_num.'
}

@test "decide rejects a merged item" {
    run bash "$SCRIPT" decide --item 9 --state merged
    [ "$status" -eq 1 ]
    assert_single_line 'Parallel mutation rejected: item 9 is already merged into main and cannot be removed.'
}

@test "decide rejects an item with no state as unknown" {
    run bash "$SCRIPT" decide --item 11
    [ "$status" -eq 1 ]
    assert_single_line 'Parallel mutation rejected: item key 11 does not resolve to a tracked items[].issue_num.'
}

@test "decide records no disposition for an unstarted item" {
    run bash "$SCRIPT" decide --item 5 --state proposed --removal-disposition detach
    [ "$status" -eq 0 ]
    assert_single_line '{"item_key":5,"prior_state":"proposed","new_state":"withdrawn","disposition":null,"triggers_recompute":true}'
}

@test "decide treats an out-of-enum state as a usage error" {
    run bash "$SCRIPT" decide --item 5 --state bogus
    assert_usage_error
}

@test "decide treats an out-of-enum disposition as a usage error" {
    run bash "$SCRIPT" decide --item 7 --state in_flight --removal-disposition purge
    assert_usage_error
}

@test "recolor of an empty unstarted set only advances the generation" {
    run bash "$SCRIPT" recolor --unstarted "" --pinned "4" --generation 3 --current-cohort 0 --highest-pinned-cohort 0
    [ "$status" -eq 0 ]
    assert_single_line '{"cohort_assignments":{},"generation":4}'
}

@test "recolor without a pinned edge offsets by current_cohort" {
    run bash "$SCRIPT" recolor --unstarted "1 2 3" --edges "1:2" --pinned "4" --generation 2 --current-cohort 1 --highest-pinned-cohort 1
    [ "$status" -eq 0 ]
    assert_single_line '{"cohort_assignments":{"1":1,"2":2,"3":1},"generation":3}'
}

@test "recolor with a pinned edge offsets above the highest pinned cohort" {
    run bash "$SCRIPT" recolor --unstarted "1 2" --edges "1:4" --pinned "4" --generation 0 --current-cohort 0 --highest-pinned-cohort 2
    [ "$status" -eq 0 ]
    assert_single_line '{"cohort_assignments":{"1":3,"2":3},"generation":1}'
}

@test "recolor rejects a key that is both unstarted and pinned" {
    run bash "$SCRIPT" recolor --unstarted "2 4 6" --pinned "6 4" --generation 0 --current-cohort 0 --highest-pinned-cohort 0
    [ "$status" -eq 1 ]
    assert_single_line 'Parallel mutation rejected: item key 4 does not resolve to a tracked items[].issue_num.'
}

@test "recolor rejects a negative current cohort" {
    run bash "$SCRIPT" recolor --unstarted "1" --pinned "" --generation 0 --current-cohort -1 --highest-pinned-cohort 0
    [ "$status" -eq 1 ]
    assert_single_line 'current_cohort must be >= 0 per F3 invariant 12; received -1.'
}

@test "recolor propagates the duplicate unstarted key error" {
    run bash "$SCRIPT" recolor --unstarted "2 2" --pinned "" --generation 0 --current-cohort 0 --highest-pinned-cohort 0
    [ "$status" -eq 1 ]
    assert_single_line 'Duplicate item key 2 in item_keys; item keys must be unique because cohort ordering relies on key uniqueness.'
}

@test "recolor treats a malformed edge token as a usage error" {
    run bash "$SCRIPT" recolor --unstarted "1 2" --edges "1-2" --pinned "" --generation 0 --current-cohort 0 --highest-pinned-cohort 0
    assert_usage_error
}

@test "recolor treats a malformed key token as a usage error" {
    run bash "$SCRIPT" recolor --unstarted "1 x" --pinned "" --generation 0 --current-cohort 0 --highest-pinned-cohort 0
    assert_usage_error
}

@test "entry stamps the next generation when the removal recomputes" {
    run bash "$SCRIPT" entry --item 5 --prior-state scheduled --recompute true --generation 2 --at 2026-10-08T14-00
    [ "$status" -eq 0 ]
    assert_single_line '{"op":"remove","item_key":5,"at":"2026-10-08T14-00","prior_state":"scheduled","new_state":"withdrawn","disposition":null,"recolor_generation":3}'
}

@test "entry keeps the generation when the removal does not recompute" {
    run bash "$SCRIPT" entry --item 5 --prior-state scheduled --recompute false --generation 2 --at 2026-10-08T14-00
    [ "$status" -eq 0 ]
    assert_single_line '{"op":"remove","item_key":5,"at":"2026-10-08T14-00","prior_state":"scheduled","new_state":"withdrawn","disposition":null,"recolor_generation":2}'
}

@test "entry records the abandon disposition of an in-flight removal" {
    run bash "$SCRIPT" entry --item 7 --prior-state in_flight --removal-disposition abandon --recompute false --generation 2 --at 2026-10-08T14-00
    [ "$status" -eq 0 ]
    assert_single_line '{"op":"remove","item_key":7,"at":"2026-10-08T14-00","prior_state":"in_flight","new_state":"withdrawn","disposition":"abandon","recolor_generation":2}'
}

@test "entry rejects an in-flight removal without a disposition" {
    run bash "$SCRIPT" entry --item 7 --prior-state in_flight --recompute false --generation 2 --at 2026-10-08T14-00
    [ "$status" -eq 1 ]
    assert_single_line "Parallel mutation entry rejected: disposition None violates the F3 mutations[] contract for op 'remove'."
}

@test "entry rejects a disposition on a removal that is not in flight" {
    run bash "$SCRIPT" entry --item 5 --prior-state scheduled --removal-disposition detach --recompute true --generation 0 --at 2026-10-08T14-00
    [ "$status" -eq 1 ]
    assert_single_line "Parallel mutation entry rejected: disposition 'detach' violates the F3 mutations[] contract for op 'remove'."
}

@test "entry rejects a negative generation" {
    run bash "$SCRIPT" entry --item 7 --prior-state in_flight --removal-disposition detach --recompute false --generation -1 --at 2026-10-08T14-00
    [ "$status" -eq 1 ]
    assert_single_line "Parallel mutation entry rejected: recolor_generation -1 violates the F3 mutations[] contract for op 'remove'."
}

@test "entry rejects a non-positive item key" {
    run bash "$SCRIPT" entry --item 0 --prior-state scheduled --recompute true --generation 0 --at 2026-10-08T14-00
    [ "$status" -eq 1 ]
    assert_single_line "Parallel mutation entry rejected: item_key 0 violates the F3 mutations[] contract for op 'remove'."
}

@test "entry rejects an out-of-enum prior state" {
    run bash "$SCRIPT" entry --item 5 --prior-state bogus --recompute true --generation 0 --at 2026-10-08T14-00
    [ "$status" -eq 1 ]
    assert_single_line "Parallel mutation rejected: item 5 state 'bogus' is not one of proposed, admitted, prepared, scheduled, in_flight, merged, withdrawn, blocked."
}

@test "entry echoes an explicit --at value" {
    run bash "$SCRIPT" entry --item 5 --prior-state scheduled --recompute true --generation 0 --at 2026-01-02T03-04
    [ "$status" -eq 0 ]
    assert_single_line '{"op":"remove","item_key":5,"at":"2026-01-02T03-04","prior_state":"scheduled","new_state":"withdrawn","disposition":null,"recolor_generation":1}'
}

@test "entry defaults --at to a UTC minute timestamp" {
    run bash "$SCRIPT" entry --item 5 --prior-state scheduled --recompute true --generation 0
    [ "$status" -eq 0 ]
    [ "${#lines[@]}" -eq 1 ]
    # Format only: the value is the current minute, so it is never compared.
    at_pattern='^\{"op":"remove","item_key":5,"at":"([^"]*)","prior_state":"scheduled","new_state":"withdrawn","disposition":null,"recolor_generation":1\}$'
    [[ $output =~ $at_pattern ]]
    format='^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}-[0-9]{2}$'
    [[ ${BASH_REMATCH[1]} =~ $format ]]
}

@test "entry treats an invalid --recompute value as a usage error" {
    run bash "$SCRIPT" entry --item 5 --prior-state scheduled --recompute maybe --generation 0 --at 2026-10-08T14-00
    assert_usage_error
}

@test "entry treats an --at value containing a space as a usage error" {
    run bash "$SCRIPT" entry --item 5 --prior-state scheduled --recompute true --generation 0 --at "2026-10-08 14-00"
    assert_usage_error
}

@test "the command line rejects a missing subcommand" {
    run bash "$SCRIPT"
    assert_usage_error
}

@test "the command line rejects an unknown subcommand" {
    run bash "$SCRIPT" purge --item 5
    assert_usage_error
}

@test "the command line rejects an unknown option" {
    run bash "$SCRIPT" decide --item 5 --bogus 1
    assert_usage_error
}

@test "the command line rejects an abbreviated option" {
    run bash "$SCRIPT" entry --item 5 --prior-state scheduled --recompute true --gen 2 --at 2026-10-08T14-00
    assert_usage_error
}

@test "the command line rejects an option whose value is missing" {
    run bash "$SCRIPT" decide --item
    assert_usage_error
}

@test "the command line rejects a missing required option" {
    run bash "$SCRIPT" recolor --unstarted "1" --pinned "" --generation 0 --current-cohort 0
    assert_usage_error
}

@test "pm_decide_removal sets PM_RESULT for an unstarted item" {
    pm_decide_removal 5 scheduled ""
    [ "$PM_RESULT" = '{"item_key":5,"prior_state":"scheduled","new_state":"withdrawn","disposition":null,"triggers_recompute":true}' ]
    [ -z "$PM_ERROR" ]
}

@test "pm_recolor_unstarted sets PM_ERROR on an overlap" {
    rc=0
    pm_recolor_unstarted "2 4" "" "4" 0 0 0 || rc=$?
    [ "$rc" -eq 1 ]
    [ "$PM_ERROR" = 'Parallel mutation rejected: item key 4 does not resolve to a tracked items[].issue_num.' ]
    [ -z "$PM_RESULT" ]
}

@test "pm_build_remove_entry sets PM_RESULT for an in-flight detach" {
    pm_build_remove_entry 7 in_flight detach false 2 2026-10-08T14-00
    [ "$PM_RESULT" = '{"op":"remove","item_key":7,"at":"2026-10-08T14-00","prior_state":"in_flight","new_state":"withdrawn","disposition":"detach","recolor_generation":2}' ]
    [ -z "$PM_ERROR" ]
}
