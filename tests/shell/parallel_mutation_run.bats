#!/usr/bin/env bats
# Unit tests for .claude/lib/bash/parallel-mutation-ops.sh and its command-line
# entry point mutate-parallel-run.sh (issue #890). Covers every success and
# rejection case of the run-mutation parity corpus through the command line,
# admission with the edge in each direction and with empty member sets, the
# explicit and default --at values of the three entry builders, every
# usage-error class of the command line, and each library function called
# directly after sourcing the library.
#
# Every case asserts the exit status and the exact single output line; usage
# errors assert the "PARALLEL_MUTATION_ERROR: usage error:" prefix. The default
# --at cases assert the timestamp format only, so no case reads or waits on the
# clock. Every input is a literal in this file; no temporary file is created.

setup() {
    REPO_ROOT="$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)"
    LIB_DIR="${REPO_ROOT}/.claude/lib/bash"
    SCRIPT="${LIB_DIR}/mutate-parallel-run.sh"
    # shellcheck source=/dev/null
    source "${LIB_DIR}/parallel-mutation-ops.sh"
    pc_enforce_c_locale
    AT_FORMAT='^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}-[0-9]{2}$'
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

@test "admit admits a candidate with no current-cohort conflict" {
    run bash "$SCRIPT" admit --candidate 9 --edges "9:5" --in-flight "1" --current-cohort-members "1 2"
    [ "$status" -eq 0 ]
    assert_single_line '{"candidate":9,"outcome":"admit_current_cohort","triggers_recompute":false}'
}

@test "admit defers a candidate conflicting with an in-flight item" {
    run bash "$SCRIPT" admit --candidate 9 --edges "1:9" --in-flight "1" --current-cohort-members "1 2"
    [ "$status" -eq 0 ]
    assert_single_line '{"candidate":9,"outcome":"defer_and_recolor","triggers_recompute":true}'
}

@test "admit defers a candidate conflicting with a scheduled member" {
    run bash "$SCRIPT" admit --candidate 9 --edges "9:2" --in-flight "1" --current-cohort-members "1 2"
    [ "$status" -eq 0 ]
    assert_single_line '{"candidate":9,"outcome":"defer_and_recolor","triggers_recompute":true}'
}

@test "admit admits a candidate whose conflict lies outside the cohort" {
    run bash "$SCRIPT" admit --candidate 9 --edges "9:7" --in-flight "1" --current-cohort-members "1 2"
    [ "$status" -eq 0 ]
    assert_single_line '{"candidate":9,"outcome":"admit_current_cohort","triggers_recompute":false}'
}

@test "admit defers when the candidate is the first edge endpoint" {
    run bash "$SCRIPT" admit --candidate 9 --edges "9:1" --in-flight "1" --current-cohort-members "1"
    [ "$status" -eq 0 ]
    assert_single_line '{"candidate":9,"outcome":"defer_and_recolor","triggers_recompute":true}'
}

@test "admit admits when the in-flight and cohort member sets are empty" {
    run bash "$SCRIPT" admit --candidate 9 --edges "9:1" --in-flight "" --current-cohort-members ""
    [ "$status" -eq 0 ]
    assert_single_line '{"candidate":9,"outcome":"admit_current_cohort","triggers_recompute":false}'
}

@test "admit admits when no edge is supplied" {
    run bash "$SCRIPT" admit --candidate 9 --in-flight "1" --current-cohort-members "1"
    [ "$status" -eq 0 ]
    assert_single_line '{"candidate":9,"outcome":"admit_current_cohort","triggers_recompute":false}'
}

@test "recolor with a pinned edge offsets above the highest pinned cohort" {
    run bash "$SCRIPT" recolor --unstarted "1 2" --edges "1:4" --pinned "4" --generation 0 --current-cohort 0 --highest-pinned-cohort 2
    [ "$status" -eq 0 ]
    assert_single_line '{"cohort_assignments":{"1":3,"2":3},"generation":1}'
}

@test "recolor without a pinned edge offsets by current_cohort" {
    run bash "$SCRIPT" recolor --unstarted "1 2 3" --edges "1:2" --pinned "4" --generation 2 --current-cohort 1 --highest-pinned-cohort 1
    [ "$status" -eq 0 ]
    assert_single_line '{"cohort_assignments":{"1":1,"2":2,"3":1},"generation":3}'
}

@test "recolor rejects a key that is both unstarted and pinned" {
    run bash "$SCRIPT" recolor --unstarted "2 4 6" --pinned "6 4" --generation 0 --current-cohort 0 --highest-pinned-cohort 0
    [ "$status" -eq 1 ]
    assert_single_line 'Parallel mutation rejected: item key 4 does not resolve to a tracked items[].issue_num.'
}

@test "add-entry keeps the generation for a no-conflict admit" {
    run bash "$SCRIPT" add-entry --item 9 --deferred false --generation 3 --at 2026-10-11T08-29
    [ "$status" -eq 0 ]
    assert_single_line '{"op":"add","item_key":9,"at":"2026-10-11T08-29","prior_state":null,"new_state":"scheduled","disposition":null,"recolor_generation":3}'
}

@test "add-entry stamps the next generation for a deferred add" {
    run bash "$SCRIPT" add-entry --item 9 --deferred true --generation 3 --at 2026-10-11T08-29
    [ "$status" -eq 0 ]
    assert_single_line '{"op":"add","item_key":9,"at":"2026-10-11T08-29","prior_state":null,"new_state":"scheduled","disposition":null,"recolor_generation":4}'
}

@test "add-entry accepts a deferred add from generation minus one" {
    run bash "$SCRIPT" add-entry --item 9 --deferred true --generation -1 --at 2026-10-11T08-29
    [ "$status" -eq 0 ]
    assert_single_line '{"op":"add","item_key":9,"at":"2026-10-11T08-29","prior_state":null,"new_state":"scheduled","disposition":null,"recolor_generation":0}'
}

@test "add-entry rejects a negative stamped generation" {
    run bash "$SCRIPT" add-entry --item 9 --deferred false --generation -1 --at 2026-10-11T08-29
    [ "$status" -eq 1 ]
    assert_single_line "Parallel mutation entry rejected: recolor_generation -1 violates the F3 mutations[] contract for op 'add'."
}

@test "add-entry rejects a non-positive item key" {
    run bash "$SCRIPT" add-entry --item 0 --deferred false --generation 3 --at 2026-10-11T08-29
    [ "$status" -eq 1 ]
    assert_single_line "Parallel mutation entry rejected: item_key 0 violates the F3 mutations[] contract for op 'add'."
}

@test "add-entry defaults --at to a UTC minute timestamp" {
    run bash "$SCRIPT" add-entry --item 9 --deferred false --generation 3
    [ "$status" -eq 0 ]
    [ "${#lines[@]}" -eq 1 ]
    pattern='^\{"op":"add","item_key":9,"at":"([^"]*)","prior_state":null,"new_state":"scheduled","disposition":null,"recolor_generation":3\}$'
    [[ $output =~ $pattern ]]
    [[ ${BASH_REMATCH[1]} =~ $AT_FORMAT ]]
}

@test "close is permitted when no item is in flight" {
    run bash "$SCRIPT" close --items "3:scheduled 7:merged"
    [ "$status" -eq 0 ]
    assert_single_line '{"close_permitted":true}'
}

@test "close is permitted for an empty item list" {
    run bash "$SCRIPT" close --items ""
    [ "$status" -eq 0 ]
    assert_single_line '{"close_permitted":true}'
}

@test "close rejects in-flight items and lists every key ascending" {
    run bash "$SCRIPT" close --items "7:in_flight 3:in_flight 5:scheduled"
    [ "$status" -eq 1 ]
    assert_single_line 'Parallel mutation rejected: close requires no item in flight; still in flight: [3, 7].'
}

@test "close rejects an out-of-enum state with the item-state members" {
    run bash "$SCRIPT" close --items "4:paused"
    [ "$status" -eq 1 ]
    assert_single_line "Parallel mutation rejected: item 4 state 'paused' is not one of proposed, admitted, prepared, scheduled, in_flight, merged, withdrawn, blocked."
}

@test "close rejects a non-positive key as unknown" {
    run bash "$SCRIPT" close --items "0:scheduled"
    [ "$status" -eq 1 ]
    assert_single_line 'Parallel mutation rejected: item key 0 does not resolve to a tracked items[].issue_num.'
}

@test "close reports the first invalid token in supplied order" {
    run bash "$SCRIPT" close --items "5:paused -2:scheduled"
    [ "$status" -eq 1 ]
    assert_single_line "Parallel mutation rejected: item 5 state 'paused' is not one of proposed, admitted, prepared, scheduled, in_flight, merged, withdrawn, blocked."
}

@test "close-entry stamps the generation unchanged" {
    run bash "$SCRIPT" close-entry --generation 4 --at 2026-10-11T08-29
    [ "$status" -eq 0 ]
    assert_single_line '{"op":"close","item_key":null,"at":"2026-10-11T08-29","prior_state":null,"new_state":null,"disposition":null,"recolor_generation":4}'
}

@test "close-entry rejects a negative generation" {
    run bash "$SCRIPT" close-entry --generation -1 --at 2026-10-11T08-29
    [ "$status" -eq 1 ]
    assert_single_line "Parallel mutation entry rejected: recolor_generation -1 violates the F3 mutations[] contract for op 'close'."
}

@test "close-entry defaults --at to a UTC minute timestamp" {
    run bash "$SCRIPT" close-entry --generation 4
    [ "$status" -eq 0 ]
    [ "${#lines[@]}" -eq 1 ]
    pattern='^\{"op":"close","item_key":null,"at":"([^"]*)","prior_state":null,"new_state":null,"disposition":null,"recolor_generation":4\}$'
    [[ $output =~ $pattern ]]
    [[ ${BASH_REMATCH[1]} =~ $AT_FORMAT ]]
}

@test "requeue-entry stamps the next generation" {
    run bash "$SCRIPT" requeue-entry --item 7 --generation 4 --at 2026-10-11T08-29
    [ "$status" -eq 0 ]
    assert_single_line '{"op":"requeue","item_key":7,"at":"2026-10-11T08-29","prior_state":"in_flight","new_state":"blocked","disposition":null,"recolor_generation":5}'
}

@test "requeue-entry accepts generation minus one" {
    run bash "$SCRIPT" requeue-entry --item 7 --generation -1 --at 2026-10-11T08-29
    [ "$status" -eq 0 ]
    assert_single_line '{"op":"requeue","item_key":7,"at":"2026-10-11T08-29","prior_state":"in_flight","new_state":"blocked","disposition":null,"recolor_generation":0}'
}

@test "requeue-entry rejects a negative stamped generation" {
    run bash "$SCRIPT" requeue-entry --item 7 --generation -2 --at 2026-10-11T08-29
    [ "$status" -eq 1 ]
    assert_single_line "Parallel mutation entry rejected: recolor_generation -1 violates the F3 mutations[] contract for op 'requeue'."
}

@test "requeue-entry rejects a non-positive item key" {
    run bash "$SCRIPT" requeue-entry --item 0 --generation 4 --at 2026-10-11T08-29
    [ "$status" -eq 1 ]
    assert_single_line "Parallel mutation entry rejected: item_key 0 violates the F3 mutations[] contract for op 'requeue'."
}

@test "requeue-entry defaults --at to a UTC minute timestamp" {
    run bash "$SCRIPT" requeue-entry --item 7 --generation 4
    [ "$status" -eq 0 ]
    [ "${#lines[@]}" -eq 1 ]
    pattern='^\{"op":"requeue","item_key":7,"at":"([^"]*)","prior_state":"in_flight","new_state":"blocked","disposition":null,"recolor_generation":5\}$'
    [[ $output =~ $pattern ]]
    [[ ${BASH_REMATCH[1]} =~ $AT_FORMAT ]]
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
    run bash "$SCRIPT" close-entry --generation 4 --bogus 1
    assert_usage_error
}

@test "the command line rejects an abbreviated option" {
    run bash "$SCRIPT" close-entry --gen 4
    assert_usage_error
}

@test "the command line rejects a --name=value option" {
    run bash "$SCRIPT" close-entry --generation=4
    assert_usage_error
}

@test "the command line rejects a repeated option" {
    run bash "$SCRIPT" close-entry --generation 4 --generation 5
    assert_usage_error
}

@test "the command line rejects an option whose value is missing" {
    run bash "$SCRIPT" requeue-entry --item 7 --generation
    assert_usage_error
}

@test "the command line rejects a missing required option" {
    run bash "$SCRIPT" admit --candidate 9 --in-flight "1"
    assert_usage_error
}

@test "the command line rejects a malformed integer" {
    run bash "$SCRIPT" add-entry --item 09 --deferred false --generation 3
    assert_usage_error
}

@test "the command line rejects a malformed edge" {
    run bash "$SCRIPT" admit --candidate 9 --edges "9-1" --in-flight "1" --current-cohort-members "1"
    assert_usage_error
}

@test "the command line rejects an invalid --deferred value" {
    run bash "$SCRIPT" add-entry --item 9 --deferred maybe --generation 3
    assert_usage_error
}

@test "the command line rejects a malformed --items token" {
    run bash "$SCRIPT" close --items "3-scheduled"
    assert_usage_error
}

@test "the command line rejects a duplicate --items key" {
    run bash "$SCRIPT" close --items "3:scheduled 3:in_flight"
    assert_usage_error
}

@test "the command line rejects an invalid --at value" {
    run bash "$SCRIPT" close-entry --generation 4 --at "2026-10-11 08-29"
    assert_usage_error
}

@test "pm_decide_admission sets PM_RESULT for a deferral" {
    pm_decide_admission 9 "2:9" "1" "1 2"
    [ "$PM_RESULT" = '{"candidate":9,"outcome":"defer_and_recolor","triggers_recompute":true}' ]
    [ -z "$PM_ERROR" ]
}

@test "pm_build_add_entry sets PM_ERROR for a non-positive key" {
    rc=0
    pm_build_add_entry -4 false 1 2026-10-11T08-29 || rc=$?
    [ "$rc" -eq 1 ]
    [ -z "$PM_RESULT" ]
    [ "$PM_ERROR" = "Parallel mutation entry rejected: item_key -4 violates the F3 mutations[] contract for op 'add'." ]
}

@test "pm_decide_close sets PM_ERROR naming every in-flight key" {
    rc=0
    pm_decide_close "12:in_flight 2:in_flight" || rc=$?
    [ "$rc" -eq 1 ]
    [ -z "$PM_RESULT" ]
    [ "$PM_ERROR" = 'Parallel mutation rejected: close requires no item in flight; still in flight: [2, 12].' ]
}

@test "pm_build_close_entry sets PM_RESULT with a null item key" {
    pm_build_close_entry 0 2026-10-11T08-29
    [ "$PM_RESULT" = '{"op":"close","item_key":null,"at":"2026-10-11T08-29","prior_state":null,"new_state":null,"disposition":null,"recolor_generation":0}' ]
    [ -z "$PM_ERROR" ]
}

@test "pm_build_requeue_entry sets PM_RESULT for a requeue" {
    pm_build_requeue_entry 7 0 2026-10-11T08-29
    [ "$PM_RESULT" = '{"op":"requeue","item_key":7,"at":"2026-10-11T08-29","prior_state":"in_flight","new_state":"blocked","disposition":null,"recolor_generation":1}' ]
    [ -z "$PM_ERROR" ]
}

@test "pm_entry_contract_message names an explicit op" {
    run pm_entry_contract_message item_key 0 requeue
    [ "$status" -eq 0 ]
    [ "$output" = "Parallel mutation entry rejected: item_key 0 violates the F3 mutations[] contract for op 'requeue'." ]
}

@test "pm_entry_contract_message defaults the op to remove" {
    run pm_entry_contract_message item_key 0
    [ "$status" -eq 0 ]
    [ "$output" = "Parallel mutation entry rejected: item_key 0 violates the F3 mutations[] contract for op 'remove'." ]
}
