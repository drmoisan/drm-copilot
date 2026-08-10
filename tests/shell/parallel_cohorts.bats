#!/usr/bin/env bats
# Unit tests for .claude/lib/bash/parallel-cohorts.sh and its two command-line
# entry points, compute-cohorts.sh and compute-concurrency-batches.sh. Covers
# the empty graph, a single item, disjoint items, a fully connected clique,
# deterministic tie-breaking, permuted-input determinism, negative keys, the
# fail-closed leading-zero rejection, all three cohort error messages, and
# batching including the max_concurrency rejection. Every input is a literal in
# this file; no temporary file is created.

setup() {
    REPO_ROOT="$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)"
    LIB_DIR="${REPO_ROOT}/.claude/lib/bash"
    COHORTS="${LIB_DIR}/compute-cohorts.sh"
    BATCHES="${LIB_DIR}/compute-concurrency-batches.sh"
    # shellcheck source=/dev/null
    source "${LIB_DIR}/parallel-cohorts.sh"
    pc_enforce_c_locale
}

@test "an empty graph yields no cohorts" {
    run bash "$COHORTS" --keys ""
    [ "$status" -eq 0 ]
    [ "$output" = "[]" ]
}

@test "a single item lands in cohort 0" {
    run bash "$COHORTS" --keys "7"
    [ "$status" -eq 0 ]
    [ "$output" = "[[7]]" ]
}

@test "disjoint items all share cohort 0" {
    run bash "$COHORTS" --keys "1 2 3"
    [ "$status" -eq 0 ]
    [ "$output" = "[[1,2,3]]" ]
}

@test "a fully connected triangle takes one cohort per vertex" {
    run bash "$COHORTS" --keys "1 2 3" --edges "1:2 1:3 2:3"
    [ "$status" -eq 0 ]
    [ "$output" = "[[1],[2],[3]]" ]
}

@test "Welsh-Powell visits the highest-degree vertex first" {
    run bash "$COHORTS" --keys "1 2 3" --edges "1:2 2:3"
    [ "$status" -eq 0 ]
    [ "$output" = "[[2],[1,3]]" ]
}

@test "equal degrees are broken by ascending item key" {
    run bash "$COHORTS" --keys "10 20 30 40" --edges "10:20 30:40"
    [ "$status" -eq 0 ]
    [ "$output" = "[[10,30],[20,40]]" ]
}

@test "permuted input produces identical output" {
    run bash "$COHORTS" --keys "40 30 20 10" --edges "40:30 20:10"
    [ "$status" -eq 0 ]
    [ "$output" = "[[10,30],[20,40]]" ]
}

@test "a reversed or repeated edge collapses to one adjacency entry" {
    run bash "$COHORTS" --keys "1 2" --edges "1:2 2:1 1:2"
    [ "$status" -eq 0 ]
    [ "$output" = "[[1],[2]]" ]
}

@test "negative and zero item keys order numerically" {
    run bash "$COHORTS" --keys "-3 -1 2" --edges "-3:2"
    [ "$status" -eq 0 ]
    [ "$output" = "[[-3,-1],[2]]" ]
    run bash "$COHORTS" --keys "0 1" --edges "0:1"
    [ "$status" -eq 0 ]
    [ "$output" = "[[0],[1]]" ]
}

@test "omitting --edges is equivalent to an empty edge list" {
    run bash "$COHORTS" --keys "1 2 3"
    [ "$status" -eq 0 ]
    first="$output"
    run bash "$COHORTS" --keys "1 2 3" --edges ""
    [ "$output" = "$first" ]
}

@test "a duplicate item key is rejected with the reference message" {
    run bash "$COHORTS" --keys "1 2 1"
    [ "$status" -eq 1 ]
    [ "$output" = "Duplicate item key 1 in item_keys; item keys must be unique because cohort ordering relies on key uniqueness." ]
}

@test "a self-loop edge is rejected with the reference message" {
    run bash "$COHORTS" --keys "1 2" --edges "1:1"
    [ "$status" -eq 1 ]
    [ "$output" = "Self-loop edge on item key 1; the conflict relation is defined over distinct items, so an item cannot conflict with itself." ]
}

@test "the self-loop check precedes the endpoint-membership check" {
    run bash "$COHORTS" --keys "2" --edges "5:5"
    [ "$status" -eq 1 ]
    [ "$output" = "Self-loop edge on item key 5; the conflict relation is defined over distinct items, so an item cannot conflict with itself." ]
}

@test "an unknown endpoint is rejected with the tuple repr" {
    run bash "$COHORTS" --keys "1 2" --edges "1:3"
    [ "$status" -eq 1 ]
    [ "$output" = "Conflict edge (1, 3) names item key 3, which is not a member of item_keys; every edge endpoint must be a declared item key." ]
}

@test "endpoints are checked in supplied order" {
    run bash "$COHORTS" --keys "2 3" --edges "1:2"
    [ "$status" -eq 1 ]
    [ "$output" = "Conflict edge (1, 2) names item key 1, which is not a member of item_keys; every edge endpoint must be a declared item key." ]
}

@test "a leading-zero key token is rejected fail-closed with exit 2" {
    run bash "$COHORTS" --keys "01 2"
    [ "$status" -eq 2 ]
    case "$output" in
    *"must be a decimal integer matching -?(0|[1-9][0-9]*)"*) ;;
    *) return 1 ;;
    esac
}

@test "a leading-zero edge endpoint is rejected fail-closed with exit 2" {
    run bash "$COHORTS" --keys "1 2" --edges "1:02"
    [ "$status" -eq 2 ]
}

@test "a malformed edge token is rejected fail-closed with exit 2" {
    run bash "$COHORTS" --keys "1 2" --edges "1-2"
    [ "$status" -eq 2 ]
    run bash "$COHORTS" --keys "1 2" --edges "1:2:3"
    [ "$status" -eq 2 ]
}

@test "a missing --keys flag is a usage error" {
    run bash "$COHORTS"
    [ "$status" -eq 2 ]
    run bash "$COHORTS" --unknown
    [ "$status" -eq 2 ]
}

@test "--help exits 0 and prints usage" {
    run bash "$COHORTS" --help
    [ "$status" -eq 0 ]
    case "$output" in
    "Usage: compute-cohorts.sh"*) ;;
    *) return 1 ;;
    esac
}

@test "batching chunks an exact multiple into equal batches" {
    run bash "$BATCHES" --keys "1 2 3 4" --max-concurrency 2
    [ "$status" -eq 0 ]
    [ "$output" = "[[1,2],[3,4]]" ]
}

@test "only the final batch may be shorter than the cap" {
    run bash "$BATCHES" --keys "1 2 3 4 5" --max-concurrency 2
    [ "$status" -eq 0 ]
    [ "$output" = "[[1,2],[3,4],[5]]" ]
}

@test "an empty cohort yields no batches" {
    run bash "$BATCHES" --keys "" --max-concurrency 4
    [ "$status" -eq 0 ]
    [ "$output" = "[]" ]
}

@test "batching sorts the cohort itself rather than trusting the caller" {
    run bash "$BATCHES" --keys "5 1 3" --max-concurrency 2
    [ "$status" -eq 0 ]
    [ "$output" = "[[1,3],[5]]" ]
}

@test "a cap of 1 serializes the cohort in ascending key order" {
    run bash "$BATCHES" --keys "3 1 2" --max-concurrency 1
    [ "$status" -eq 0 ]
    [ "$output" = "[[1],[2],[3]]" ]
}

@test "a cap larger than the cohort yields a single batch" {
    run bash "$BATCHES" --keys "7 8" --max-concurrency 8
    [ "$status" -eq 0 ]
    [ "$output" = "[[7,8]]" ]
}

@test "batching orders negative keys numerically" {
    run bash "$BATCHES" --keys "-2 -5 3" --max-concurrency 2
    [ "$status" -eq 0 ]
    [ "$output" = "[[-5,-2],[3]]" ]
}

@test "a cap below 1 is rejected with the reference message" {
    run bash "$BATCHES" --keys "1 2" --max-concurrency 0
    [ "$status" -eq 1 ]
    [ "$output" = "max_concurrency must be >= 1; received 0." ]
    run bash "$BATCHES" --keys "1" --max-concurrency -3
    [ "$status" -eq 1 ]
    [ "$output" = "max_concurrency must be >= 1; received -3." ]
}

@test "batching rejects a leading-zero token fail-closed with exit 2" {
    run bash "$BATCHES" --keys "01" --max-concurrency 2
    [ "$status" -eq 2 ]
    run bash "$BATCHES" --keys "1" --max-concurrency 02
    [ "$status" -eq 2 ]
}

@test "batching requires both flags" {
    run bash "$BATCHES" --keys "1 2"
    [ "$status" -eq 2 ]
    run bash "$BATCHES" --max-concurrency 2
    [ "$status" -eq 2 ]
}

@test "the sourced library exposes the same results as the entry points" {
    pcoh_compute_cohorts "1 2 3" "1:2 2:3"
    [ "$PCOH_RESULT" = "[[2],[1,3]]" ]
    pcoh_compute_concurrency_batches "3 1 2" 2
    [ "$PCOH_RESULT" = "[[1,2],[3]]" ]
}
