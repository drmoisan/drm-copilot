#!/usr/bin/env bats
# Unit suite for the bundled parallel abandon entry point (issue #763).
#
# .claude/lib/bash/abandon-parallel-item.sh is the destination-runtime port of
# scripts/dev_tools/parallel_mutation_abandon_cli.py. These tests pin its
# argument surface, its two refusals, the ordering of its two side effects, and
# its failure reporting.
#
# Every invocation runs bash by absolute path with PATH set to a checked-in shim
# directory only: tests/fixtures/parallel_abandon_path exposes a gh shim and a git
# shim, and tests/fixtures/parallel_abandon_path_git_only exposes only the git
# shim. Each shim records its argument vector as one "SHIM-CALL" line on stderr
# and exits with the code the test selects, so a real `gh pr close` or
# `git worktree remove` is unreachable. `env` is used without -i so a coverage
# harness environment survives into the child.
#
# No temporary file is created: the shims are checked-in fixtures and every
# assertion reads the captured output.

setup() {
    REPO_ROOT="$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)"
    SCRIPT="${REPO_ROOT}/.claude/lib/bash/abandon-parallel-item.sh"
    SHIM_PATH="${REPO_ROOT}/tests/fixtures/parallel_abandon_path"
    GIT_ONLY_PATH="${REPO_ROOT}/tests/fixtures/parallel_abandon_path_git_only"
    BASH_BIN="$(command -v bash)"
    # Checked-in shims may be stored without the executable bit on some
    # platforms; make them runnable for this checkout. Idempotent; creates no
    # files.
    chmod +x "${SHIM_PATH}"/* "${GIT_ONLY_PATH}"/* 2>/dev/null || true
    # The base argument vector of a confirmed abandon of item 42.
    BASE_ARGS=(--item 42 --disposition abandon --confirm-abandon --pr 7 --worktree ../wt-42)
}

# Run the abandon script with the shim-only PATH. GH_EXIT and GIT_EXIT select
# the shim exit codes; RUN_PATH replaces the shim directory when a test needs a
# PATH that lacks one of the executables.
run_abandon() {
    run env PATH="${RUN_PATH:-$SHIM_PATH}" ABANDON_SHIM_GH_EXIT="${GH_EXIT:-0}" \
        ABANDON_SHIM_GIT_EXIT="${GIT_EXIT:-0}" "$BASH_BIN" "$SCRIPT" "$@"
}

# Assert a usage error: exit 2, no side effect, one usage-error line.
assert_usage_error() {
    [ "$status" -eq 2 ]
    [ "${#lines[@]}" -eq 1 ]
    [[ "${lines[0]}" == "PARALLEL_ABANDON_ERROR: usage error:"* ]]
    [[ "$output" != *"SHIM-CALL"* ]]
}

@test "the abandon script exists in the repository library" {
    [ -f "$SCRIPT" ]
}

@test "success closes the pull request before removing the worktree" {
    run_abandon "${BASE_ARGS[@]}"
    [ "$status" -eq 0 ]
    [ "${#lines[@]}" -eq 2 ]
    [ "${lines[0]}" = "SHIM-CALL gh pr close 7" ]
    [ "${lines[1]}" = "SHIM-CALL git worktree remove ../wt-42" ]
}

@test "success writes nothing to stdout" {
    # The shims write to stderr only, so discarding stderr leaves exactly what
    # the script itself wrote to stdout.
    run "$BASH_BIN" -c '"$0" "$@" 2>/dev/null' env PATH="$SHIM_PATH" \
        "$BASH_BIN" "$SCRIPT" "${BASE_ARGS[@]}"
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

@test "a detach disposition exits 2 with the reference message and no side effect" {
    run_abandon --item 42 --disposition detach --confirm-abandon --pr 7 --worktree ../wt-42
    [ "$status" -eq 2 ]
    [ "${#lines[@]}" -eq 1 ]
    [ "${lines[0]}" = "PARALLEL_ABANDON_ERROR: this CLI executes the 'abandon' disposition only; got 'detach'." ]
}

@test "a missing confirmation marker exits 2 with the reference message and no side effect" {
    run_abandon --item 42 --disposition abandon --pr 7 --worktree ../wt-42
    [ "$status" -eq 2 ]
    [ "${#lines[@]}" -eq 1 ]
    [ "${lines[0]}" = "PARALLEL_ABANDON_ERROR: refusing to abandon item 42 without the explicit --confirm-abandon confirmation marker; no side effect was performed." ]
}

@test "a gh failure exits 1 and does not invoke git" {
    GH_EXIT=1 run_abandon "${BASE_ARGS[@]}"
    [ "$status" -eq 1 ]
    [ "${#lines[@]}" -eq 2 ]
    [ "${lines[0]}" = "SHIM-CALL gh pr close 7" ]
    [ "${lines[1]}" = "PARALLEL_ABANDON_ERROR: abandon side effect failed with exit code 1: gh pr close 7" ]
}

@test "a git failure exits 1 with the reference message" {
    GIT_EXIT=128 run_abandon "${BASE_ARGS[@]}"
    [ "$status" -eq 1 ]
    [ "${#lines[@]}" -eq 3 ]
    [ "${lines[0]}" = "SHIM-CALL gh pr close 7" ]
    [ "${lines[1]}" = "SHIM-CALL git worktree remove ../wt-42" ]
    [ "${lines[2]}" = "PARALLEL_ABANDON_ERROR: abandon side effect failed with exit code 128: git worktree remove ../wt-42" ]
}

@test "an absent gh executable reports exit code -1" {
    RUN_PATH="$GIT_ONLY_PATH" run_abandon "${BASE_ARGS[@]}"
    [ "$status" -eq 1 ]
    [ "${#lines[@]}" -eq 1 ]
    [ "${lines[0]}" = "PARALLEL_ABANDON_ERROR: abandon side effect failed with exit code -1: gh pr close 7" ]
}

@test "an unknown option exits 2 with no side effect" {
    run_abandon "${BASE_ARGS[@]}" --force
    assert_usage_error
}

@test "an option abbreviation exits 2 with no side effect" {
    run_abandon --item 42 --disp abandon --confirm-abandon --pr 7 --worktree ../wt-42
    assert_usage_error
}

@test "the joined option form is accepted" {
    run_abandon --item=42 --disposition=abandon --confirm-abandon --pr=7 --worktree=../wt-42
    [ "$status" -eq 0 ]
    [ "${#lines[@]}" -eq 2 ]
    [ "${lines[0]}" = "SHIM-CALL gh pr close 7" ]
    [ "${lines[1]}" = "SHIM-CALL git worktree remove ../wt-42" ]
}

@test "a missing required option exits 2 with no side effect" {
    run_abandon --item 42 --disposition abandon --confirm-abandon --worktree ../wt-42
    assert_usage_error
}

@test "a non-integer item key exits 2 with no side effect" {
    run_abandon --item abc --disposition abandon --confirm-abandon --pr 7 --worktree ../wt-42
    assert_usage_error
}

@test "the script declares the option tokens as named constants" {
    # Each token is declared once, on its own readonly line; the seam test reads
    # the same three lines.
    [ "$(grep -c -F -e "readonly ABANDON_DISPOSITION_OPTION='--disposition'" "$SCRIPT")" -eq 1 ]
    [ "$(grep -c -F -e "readonly ABANDON_DISPOSITION_VALUE='abandon'" "$SCRIPT")" -eq 1 ]
    [ "$(grep -c -F -e "readonly ABANDON_CONFIRM_OPTION='--confirm-abandon'" "$SCRIPT")" -eq 1 ]
}
