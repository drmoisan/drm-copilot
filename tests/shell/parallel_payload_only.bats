#!/usr/bin/env bats
# Payload-only destination-portability proof (issue #462, AC16 bats half).
#
# Invokes the four published bash entry points from the bundle root
# extensions/drm-copilot/resources/claude-customizations/ -- the directory that
# contains only what a destination workspace receives -- with a restricted PATH
# that contains no python, python3, or poetry. A passing run demonstrates that
# the parallel surface's cohort computation, concurrency batching, and manifest
# validation are available to a workspace with no Python interpreter and no
# repository checkout.
#
# A directory-level PATH restriction cannot work here: on ubuntu-latest the same
# /usr/bin that holds sort and cut also holds python3. PATH is therefore set to
# the single checked-in shim directory tests/fixtures/parallel_payload_path/,
# which exposes only the four external utilities the library actually uses
# (sort, cut, cat, dirname) and no interpreter of any kind. bash itself is
# invoked by absolute path. The suite fails rather than skips when the payload
# directory is missing, so it can never pass vacuously.
#
# No temporary file is created: the manifest under test is the checked-in
# fixture tests/fixtures/parallel_manifest_payload/parallel.md and the PATH
# shims are checked-in fixtures.

setup() {
    REPO_ROOT="$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)"
    PAYLOAD_ROOT="${REPO_ROOT}/extensions/drm-copilot/resources/claude-customizations"
    PAYLOAD_LIB="${PAYLOAD_ROOT}/.claude/lib/bash"
    FIXTURE_MANIFEST="${REPO_ROOT}/tests/fixtures/parallel_manifest_payload/parallel.md"
    BASH_BIN="$(command -v bash)"
    RESTRICTED_PATH="${REPO_ROOT}/tests/fixtures/parallel_payload_path"
    # Checked-in shims may be stored without the executable bit on some
    # platforms; make them runnable for this checkout. Idempotent; creates no
    # files.
    chmod +x "${RESTRICTED_PATH}"/* 2>/dev/null || true
}

# Run a payload entry point with the restricted PATH from the payload root.
run_payload() {
    local script="$1"
    shift
    run env -i PATH="$RESTRICTED_PATH" HOME="$HOME" \
        "$BASH_BIN" "${PAYLOAD_LIB}/${script}" "$@"
}

@test "the payload directory carries the four entry points" {
    [ -d "$PAYLOAD_ROOT" ]
    [ -f "${PAYLOAD_LIB}/compute-cohorts.sh" ]
    [ -f "${PAYLOAD_LIB}/compute-concurrency-batches.sh" ]
    [ -f "${PAYLOAD_LIB}/validate-parallel-manifest.sh" ]
    [ -f "${PAYLOAD_LIB}/report-lane-assertion.sh" ]
}

@test "the payload directory carries the config tree and the parallel rule" {
    [ -f "${PAYLOAD_ROOT}/config/orchestration-routing.json" ]
    [ -f "${PAYLOAD_ROOT}/config/blast-radius.json" ]
    [ -f "${PAYLOAD_ROOT}/.claude/rules/parallel-orchestration.md" ]
}

@test "the restricted PATH exposes no Python interpreter" {
    run env -i PATH="$RESTRICTED_PATH" "$BASH_BIN" -c 'command -v python'
    [ "$status" -ne 0 ]
    run env -i PATH="$RESTRICTED_PATH" "$BASH_BIN" -c 'command -v python3'
    [ "$status" -ne 0 ]
    run env -i PATH="$RESTRICTED_PATH" "$BASH_BIN" -c 'command -v poetry'
    [ "$status" -ne 0 ]
}

@test "the restricted PATH exposes the four utilities the library needs" {
    for tool in sort cut cat dirname; do
        run env -i PATH="$RESTRICTED_PATH" "$BASH_BIN" -c "command -v $tool"
        [ "$status" -eq 0 ]
    done
}

@test "the payload computes cohorts without Python on PATH" {
    run_payload compute-cohorts.sh --keys "1 2 3" --edges "1:2 2:3"
    [ "$status" -eq 0 ]
    [ "$output" = "[[2],[1,3]]" ]
}

@test "the payload reports a cohort input error without Python on PATH" {
    run_payload compute-cohorts.sh --keys "1 2" --edges "1:1"
    [ "$status" -eq 1 ]
    [ "$output" = "Self-loop edge on item key 1; the conflict relation is defined over distinct items, so an item cannot conflict with itself." ]
}

@test "the payload computes concurrency batches without Python on PATH" {
    run_payload compute-concurrency-batches.sh --keys "5 1 3 2" --max-concurrency 2
    [ "$status" -eq 0 ]
    [ "$output" = "[[1,2],[3,5]]" ]
}

@test "the payload validates a manifest without Python on PATH" {
    run_payload validate-parallel-manifest.sh "$FIXTURE_MANIFEST"
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

@test "the payload resolves both manifest accessors without Python on PATH" {
    run_payload validate-parallel-manifest.sh --print-mode "$FIXTURE_MANIFEST"
    [ "$status" -eq 0 ]
    [ "$output" = "closed" ]
    run_payload validate-parallel-manifest.sh --print-max-concurrency "$FIXTURE_MANIFEST"
    [ "$status" -eq 0 ]
    [ "$output" = "4" ]
}

@test "the payload reports manifest errors without Python on PATH" {
    run_payload validate-parallel-manifest.sh \
        "${REPO_ROOT}/tests/fixtures/parallel_manifest_payload/parallel-invalid.md"
    [ "$status" -eq 1 ]
    [ "${lines[0]}" = "Parallel manifest parallel must be a non-empty string." ]
    [ "${lines[1]}" = "Parallel manifest created_at must be a non-empty string." ]
}

@test "the payload runs the lane-assertion diagnostic without Python on PATH" {
    run_payload report-lane-assertion.sh --manifest "$FIXTURE_MANIFEST"
    [ "$status" -eq 0 ]
    [ "${lines[0]}" = "Lane assertion: 2 derived conflict component(s); 0 disagreement(s)." ]
}
