#!/usr/bin/env bats
# ------------------------------------------------------------------------------
# test_codex_web_setup_codex_verify.bats
#
# Purpose:
#   Cover the verification functions and main of .codex/codex-web-setup.sh (the
#   Codex copy, not the GitHub Codex copy): verify_formatting_capability,
#   is_windows_powershell_host, the Visual Studio test-tooling failure of
#   verify_windows_visual_studio_task_capability, verify_build_and_test_capability,
#   verify_required_task_tooling, and main (issue #824, kcov scope widening for
#   PA-1).
#
# Determinism: dotnet, dotnet-coverage, pwsh, and git are replaced by shell
# functions; main runs with every step it calls replaced by a function that
# records the step name, so nothing is installed and ~/.bashrc is not written.
# A test that needs a tool to be absent runs through run_with_stub_path, which
# limits PATH and HOME to this test directory. No temporary file is created.
# ------------------------------------------------------------------------------

# Canonical absolute path, so kcov reports the sourced file as <repo>/.codex/codex-web-setup.sh.
SCRIPT_UNDER_TEST="$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)/.codex/codex-web-setup.sh"
FIXTURES="$(cd "${BATS_TEST_DIRNAME}/../fixtures/codex_web_setup" && pwd)"

setup() {
    # Sourcing defines the functions without running main (C824-1 pins the guard).
    source "${SCRIPT_UNDER_TEST}"
}

teardown() {
    unset -f dotnet dotnet-coverage git pwsh
}

# Run a command with PATH and HOME limited to this test directory.
run_with_stub_path() {
    local PATH="${BATS_TEST_DIRNAME}"
    local HOME="${BATS_TEST_DIRNAME}"
    "$@"
}

# Print a replaced command's name and arguments to stderr, which run captures.
record() {
    printf '%s\n' "$*" >&2
}

@test "C824-48 verify_formatting_capability fails when dotnet is unavailable" {
    # Act
    run run_with_stub_path verify_formatting_capability
    # Assert
    [ "$status" -eq 1 ]
    [[ "$output" == *"Verifying formatting capability..."* ]]
    [[ "$output" == *"dotnet is not available after setup."* ]]
}

@test "C824-49 verify_formatting_capability fails when pwsh is unavailable" {
    # Arrange
    dotnet() { record "dotnet $*"; }
    # Act
    run run_with_stub_path verify_formatting_capability
    # Assert
    [ "$status" -eq 1 ]
    [[ "$output" == *"pwsh is not available after setup."* ]]
}

@test "C824-50 verify_formatting_capability fails when CSharpier is not runnable" {
    # Arrange
    REPO_ROOT="${BATS_TEST_DIRNAME}"
    dotnet() { return 1; }
    pwsh() { record "pwsh $*"; }
    # Act
    run verify_formatting_capability
    # Assert
    [ "$status" -eq 1 ]
    [[ "$output" == *"CSharpier is not runnable via 'dotnet tool run csharpier'."* ]]
}

@test "C824-51 verify_formatting_capability passes when dotnet, pwsh, and CSharpier are runnable" {
    # Arrange
    REPO_ROOT="${BATS_TEST_DIRNAME}"
    dotnet() { record "dotnet $*"; }
    pwsh() { record "pwsh $*"; }
    # Act
    run verify_formatting_capability
    # Assert
    [ "$status" -eq 0 ]
    [[ "$output" == *"dotnet tool run csharpier --version"* ]]
}

@test "C824-52 is_windows_powershell_host succeeds when pwsh reports a Windows host" {
    # Arrange
    pwsh() { return 0; }
    # Act
    run is_windows_powershell_host
    # Assert
    [ "$status" -eq 0 ]
}

@test "C824-53 is_windows_powershell_host fails when pwsh reports a non-Windows host" {
    # Arrange
    pwsh() { return 1; }
    # Act
    run is_windows_powershell_host
    # Assert
    [ "$status" -eq 1 ]
}

@test "C824-54 verify_windows_visual_studio_task_capability fails when the Visual Studio test tooling is unavailable" {
    # Arrange: the MSBuild probe (-File) succeeds and the vswhere/vstest probe (-Command) fails.
    pwsh() { [ "${4:-}" = "-File" ]; }
    REPO_ROOT="${BATS_TEST_DIRNAME}"
    SOLUTION_FILE="Alpha.sln"
    # Act
    run verify_windows_visual_studio_task_capability
    # Assert
    [ "$status" -eq 1 ]
    [[ "$output" == *"Visual Studio test tooling required by the MSTest tasks is unavailable."* ]]
    [[ "$output" != *"MSBuild tooling required"* ]]
}

@test "C824-55 verify_build_and_test_capability fails when pwsh is unavailable" {
    # Act
    run run_with_stub_path verify_build_and_test_capability
    # Assert
    [ "$status" -eq 1 ]
    [[ "$output" == *"Verifying restore/build/lint/type-check/test capability..."* ]]
    [[ "$output" == *"pwsh is not available after setup."* ]]
}

@test "C824-56 verify_build_and_test_capability fails when dotnet-coverage is unavailable" {
    # Arrange
    pwsh() { record "pwsh $*"; }
    # Act
    run run_with_stub_path verify_build_and_test_capability
    # Assert
    [ "$status" -eq 1 ]
    [[ "$output" == *"dotnet-coverage is not available after setup."* ]]
}

@test "C824-57 verify_build_and_test_capability fails when coverage.config is missing" {
    # Arrange
    REPO_ROOT="${BATS_TEST_DIRNAME}"
    pwsh() { record "pwsh $*"; }
    dotnet-coverage() { record "dotnet-coverage $*"; }
    # Act
    run verify_build_and_test_capability
    # Assert
    [ "$status" -eq 1 ]
    [[ "$output" == *"coverage.config is missing from the repository root."* ]]
}

@test "C824-58 verify_build_and_test_capability warns and skips the Visual Studio checks on a non-Windows host" {
    # Arrange
    REPO_ROOT="${FIXTURES}/dotnet-repo"
    pwsh() { return 1; }
    dotnet-coverage() { record "dotnet-coverage $*"; }
    verify_windows_visual_studio_task_capability() { record "vs-verification-called"; }
    # Act
    run verify_build_and_test_capability
    # Assert
    [ "$status" -eq 0 ]
    [[ "$output" == *"Skipping Windows-only Visual Studio task verification because this host is not Windows."* ]]
    [[ "$output" != *"vs-verification-called"* ]]
}

@test "C824-59 verify_build_and_test_capability runs the Visual Studio checks on a Windows host" {
    # Arrange
    REPO_ROOT="${FIXTURES}/dotnet-repo"
    pwsh() { return 0; }
    dotnet-coverage() { record "dotnet-coverage $*"; }
    verify_windows_visual_studio_task_capability() { record "vs-verification-called"; }
    # Act
    run verify_build_and_test_capability
    # Assert
    [ "$status" -eq 0 ]
    [[ "$output" == *"vs-verification-called"* ]]
}

@test "C824-60 verify_required_task_tooling runs the formatting and the build checks" {
    # Arrange
    verify_formatting_capability() { record "formatting-checked"; }
    verify_build_and_test_capability() { record "build-checked"; }
    # Act
    run verify_required_task_tooling
    # Assert
    [ "$status" -eq 0 ]
    [[ "$output" == *"formatting-checked"*"build-checked"* ]]
}

@test "C824-61 main runs every setup step in order and reports completion" {
    # Arrange: every step main calls is replaced, so main writes nothing and installs nothing.
    REPO_ROOT="${BATS_TEST_DIRNAME}"
    append_if_missing() { record "append $2"; }
    install_apt_packages() { record "step install_apt_packages"; }
    install_powershell() { record "step install_powershell"; }
    install_nuget() { record "step install_nuget"; }
    install_dotnet_sdk() { record "step install_dotnet_sdk"; }
    install_dotnet_tools() { record "step install_dotnet_tools"; }
    install_dotnet_coverage() { record "step install_dotnet_coverage"; }
    verify_required_task_tooling() { record "step verify_required_task_tooling"; }
    install_actionlint() { record "step install_actionlint"; }
    restore_packages_if_needed() { record "step restore_packages_if_needed"; }
    write_repo_notes() { record "step write_repo_notes"; }
    git() { record "git $*"; }
    # Act
    run main
    # Assert
    [ "$status" -eq 0 ]
    [[ "$output" == *"Bootstrapping a Codex Web environment for ${BATS_TEST_DIRNAME}"* ]]
    [[ "$output" == *"append export CI=true"*"append export NUGET_XMLDOC_MODE=skip"* ]]
    [[ "$output" == *"step install_apt_packages"*"step install_powershell"*"step install_nuget"*"step install_dotnet_sdk"*"step install_dotnet_tools"*"step install_dotnet_coverage"*"step verify_required_task_tooling"*"step install_actionlint"*"step restore_packages_if_needed"* ]]
    [[ "$output" == *"git config --global core.autocrlf input"*"step write_repo_notes"*"Setup complete."* ]]
}
