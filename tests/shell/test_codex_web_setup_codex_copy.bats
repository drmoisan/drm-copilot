#!/usr/bin/env bats
# ------------------------------------------------------------------------------
# test_codex_web_setup_codex_copy.bats
#
# Purpose:
#   Cover the lines issue #824 changed in .codex/codex-web-setup.sh (the Codex
#   copy, not the GitHub Codex copy): the source guard, solution-file
#   discovery, the skipped package restore, the MSBuild verification guard, and
#   the solution-neutral repository notes.
#
# Determinism: discovery is driven through functions that take their candidates
# as arguments; the only directories read are this test directory and the
# committed fixture tests/fixtures/codex_web_setup/populated-packages. External
# commands (nuget, pwsh) are replaced by shell functions that print to stderr.
# No temporary file is created.
# ------------------------------------------------------------------------------

# Canonical absolute path, so kcov reports the sourced file as <repo>/.codex/codex-web-setup.sh.
SCRIPT_UNDER_TEST="$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)/.codex/codex-web-setup.sh"
GUARD_LINE='if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then main "$@"; fi'

setup() {
    # Sourcing defines the functions without running main (C824-1 pins the guard).
    source "${SCRIPT_UNDER_TEST}"
}

@test "C824-1 the Codex copy ends with the BASH_SOURCE source guard" {
    # Arrange: the guard must be the script's last line.
    # Act
    run tail -n 1 "${SCRIPT_UNDER_TEST}"
    # Assert
    [ "$status" -eq 0 ]
    [ "$output" = "${GUARD_LINE}" ]
}

@test "C824-2 resolve_repo_root falls back to the working directory when no solution file is listed" {
    # Arrange
    local expected
    expected="$(pwd)"
    # Act
    run resolve_repo_root /script/root ""
    # Assert
    [ "$status" -eq 0 ]
    [ "$output" = "${expected}" ]
}

@test "C824-3 select_solution_file prints nothing when no solution file is listed" {
    # Act
    run select_solution_file ""
    # Assert
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

@test "C824-4 resolve_repo_root keeps the script-relative root when one solution file is listed" {
    # Act
    run resolve_repo_root /script/root "Alpha.sln"
    # Assert
    [ "$status" -eq 0 ]
    [ "$output" = "/script/root" ]
}

@test "C824-5 select_solution_file selects the only listed solution file" {
    # Act
    run select_solution_file "Alpha.sln"
    # Assert
    [ "$status" -eq 0 ]
    [ "$output" = "Alpha.sln" ]
}

@test "C824-6 select_solution_file selects the first of several solution files in LC_ALL=C order" {
    # Arrange: in C order uppercase sorts before lowercase, so Beta.sln precedes alpha.sln.
    local listed
    listed="$(printf '%s\n' alpha.sln Zeta.sln Beta.sln)"
    # Act
    run select_solution_file "${listed}"
    # Assert
    [ "$status" -eq 0 ]
    [ "$output" = "Beta.sln" ]
}

@test "C824-7 list_root_solution_files prints nothing for a directory without solution files" {
    # Act
    run list_root_solution_files "${BATS_TEST_DIRNAME}"
    # Assert
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

@test "C824-8 restore_packages_if_needed skips the restore with a warning when no solution file exists" {
    # Arrange
    nuget() { printf 'nuget-called %s\n' "$*" >&2; }
    REPO_ROOT="${BATS_TEST_DIRNAME}"
    SOLUTION_FILE=""
    # Act
    run restore_packages_if_needed
    # Assert
    [ "$status" -eq 0 ]
    [[ "$output" == *"No solution file was found at ${BATS_TEST_DIRNAME}; skipping package restore."* ]]
    [[ "$output" != *"nuget-called"* ]]
}

@test "C824-9 restore_packages_if_needed restores the selected solution file" {
    # Arrange
    nuget() { printf 'nuget-called %s\n' "$*" >&2; }
    REPO_ROOT="${BATS_TEST_DIRNAME}"
    SOLUTION_FILE="Alpha.sln"
    # Act
    run restore_packages_if_needed
    # Assert
    [ "$status" -eq 0 ]
    [[ "$output" == *"nuget-called restore ${BATS_TEST_DIRNAME}/Alpha.sln -PackagesDirectory ${BATS_TEST_DIRNAME}/packages"* ]]
}

@test "C824-10 restore_packages_if_needed skips the restore when packages/ is already populated" {
    # Arrange: the committed fixture carries a non-empty packages/ directory.
    nuget() { printf 'nuget-called %s\n' "$*" >&2; }
    REPO_ROOT="${BATS_TEST_DIRNAME}/../fixtures/codex_web_setup/populated-packages"
    SOLUTION_FILE="Alpha.sln"
    # Act
    run restore_packages_if_needed
    # Assert
    [ "$status" -eq 0 ]
    [[ "$output" == *"packages/ is already populated; skipping restore."* ]]
    [[ "$output" != *"nuget-called"* ]]
}

@test "C824-11 restore_packages_if_needed warns when nuget is unavailable" {
    # Arrange: PATH names only this test directory, which holds no nuget executable,
    # and no nuget function is defined.
    REPO_ROOT="${BATS_TEST_DIRNAME}"
    SOLUTION_FILE="Alpha.sln"
    restore_without_nuget() {
        local PATH="${BATS_TEST_DIRNAME}"
        restore_packages_if_needed
    }
    # Act
    run restore_without_nuget
    # Assert
    [ "$status" -eq 0 ]
    [[ "$output" == *"nuget is unavailable; cannot restore packages.config dependencies."* ]]
}

@test "C824-12 verify_windows_visual_studio_task_capability fails when no solution file exists" {
    # Arrange
    pwsh() { printf 'pwsh-called %s\n' "$*" >&2; }
    REPO_ROOT="${BATS_TEST_DIRNAME}"
    SOLUTION_FILE=""
    # Act
    run verify_windows_visual_studio_task_capability
    # Assert
    [ "$status" -eq 1 ]
    [[ "$output" == *"No solution file was found at ${BATS_TEST_DIRNAME}; MSBuild task verification needs one."* ]]
    [[ "$output" != *"pwsh-called"* ]]
}

@test "C824-13 verify_windows_visual_studio_task_capability passes the selected solution file to Invoke-VSBuild.ps1" {
    # Arrange
    pwsh() { printf 'pwsh-called %s\n' "$*" >&2; }
    REPO_ROOT="${BATS_TEST_DIRNAME}"
    SOLUTION_FILE="Alpha.sln"
    # Act
    run verify_windows_visual_studio_task_capability
    # Assert
    [ "$status" -eq 0 ]
    [[ "$output" == *"-SolutionPath Alpha.sln"* ]]
}

@test "C824-14 verify_windows_visual_studio_task_capability fails when the MSBuild tooling is unavailable" {
    # Arrange
    pwsh() { return 1; }
    REPO_ROOT="${BATS_TEST_DIRNAME}"
    SOLUTION_FILE="Alpha.sln"
    # Act
    run verify_windows_visual_studio_task_capability
    # Assert
    [ "$status" -eq 1 ]
    [[ "$output" == *"MSBuild tooling required by the restore/build/lint/type-check tasks is unavailable."* ]]
}

@test "C824-15 write_repo_notes names a solution-neutral placeholder" {
    # Act
    run write_repo_notes
    # Assert
    [ "$status" -eq 0 ]
    [[ "$output" == *"-SolutionPath <solution>.sln"* ]]
}
