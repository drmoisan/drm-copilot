#!/usr/bin/env bats
# ------------------------------------------------------------------------------
# test_codex_web_setup_codex_dotnet.bats
#
# Purpose:
#   Cover the .NET setup functions of .codex/codex-web-setup.sh (the Codex copy,
#   not the GitHub Codex copy): read_global_json_sdk_version, append_if_missing,
#   install_dotnet_sdk, install_dotnet_tools, and install_dotnet_coverage,
#   including every skip and failure branch (issue #824, kcov scope widening for
#   PA-1).
#
# Determinism: repository roots are the committed fixtures under
# tests/fixtures/codex_web_setup/ or this test directory. External commands that
# would download, install, or write (curl, bash, dotnet, dotnet-coverage, mkdir,
# mktemp, rm, touch) are replaced by shell functions that print to stderr, and
# append_if_missing is replaced wherever a caller would write to ~/.bashrc.
# append_if_missing itself is exercised against /dev/null and a fixture that
# already holds the line, so no file changes. No temporary file is created.
# ------------------------------------------------------------------------------

# Canonical absolute path, so kcov reports the sourced file as <repo>/.codex/codex-web-setup.sh.
SCRIPT_UNDER_TEST="$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)/.codex/codex-web-setup.sh"
FIXTURES="$(cd "${BATS_TEST_DIRNAME}/../fixtures/codex_web_setup" && pwd)"

setup() {
    # Sourcing defines the functions without running main (C824-1 pins the guard).
    source "${SCRIPT_UNDER_TEST}"
}

teardown() {
    unset -f append_if_missing bash curl dotnet dotnet-coverage grep mkdir mktemp rm touch
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

@test "C824-34 read_global_json_sdk_version fails when global.json is absent" {
    # Arrange
    REPO_ROOT="${BATS_TEST_DIRNAME}"
    # Act
    run read_global_json_sdk_version
    # Assert
    [ "$status" -eq 1 ]
    [ -z "$output" ]
}

@test "C824-35 read_global_json_sdk_version prints the pinned SDK version" {
    # Arrange
    REPO_ROOT="${FIXTURES}/dotnet-repo"
    # Act
    run read_global_json_sdk_version
    # Assert
    [ "$status" -eq 0 ]
    [ "$output" = "8.0.100" ]
}

@test "C824-36 append_if_missing appends a line the file does not contain" {
    # Arrange: /dev/null never contains the line, so the append branch runs and nothing is kept.
    touch() { record "touch $*"; }
    # Act
    run append_if_missing /dev/null 'export CI=true'
    # Assert
    [ "$status" -eq 0 ]
    [[ "$output" == *"touch /dev/null"* ]]
}

@test "C824-37 append_if_missing leaves a file that already contains the line" {
    # Arrange
    touch() { record "touch $*"; }
    # Act
    run append_if_missing "${FIXTURES}/bashrc-with-ci.txt" 'export CI=true'
    # Assert
    [ "$status" -eq 0 ]
    [[ "$output" == *"touch ${FIXTURES}/bashrc-with-ci.txt"* ]]
    run grep -c -x 'export CI=true' "${FIXTURES}/bashrc-with-ci.txt"
    [ "$output" = "1" ]
}

@test "C824-38 install_dotnet_sdk warns and skips when global.json names no SDK version" {
    # Arrange
    REPO_ROOT="${BATS_TEST_DIRNAME}"
    append_if_missing() { record "append $*"; }
    # Act
    run install_dotnet_sdk
    # Assert
    [ "$status" -eq 0 ]
    [[ "$output" == *"Could not read the SDK version from global.json; skipping repo-local .NET SDK installation."* ]]
    [[ "$output" != *"append"* ]]
}

@test "C824-39 install_dotnet_sdk reuses a repo-local SDK that is already installed" {
    # Arrange: the fixture's .dotnet-sdk/dotnet is a directory, which satisfies [ -x ].
    REPO_ROOT="${FIXTURES}/dotnet-sdk-installed"
    append_if_missing() { record "append $*"; }
    # Act
    run install_dotnet_sdk
    # Assert
    [ "$status" -eq 0 ]
    [[ "$output" == *"Repo-local .NET SDK 8.0.100 is already available at ${FIXTURES}/dotnet-sdk-installed/.dotnet-sdk."* ]]
    [[ "$output" == *"export DOTNET_ROOT=\"${FIXTURES}/dotnet-sdk-installed/.dotnet-sdk\""* ]]
}

@test "C824-40 install_dotnet_sdk downloads and runs the installer when the SDK is missing" {
    # Arrange
    REPO_ROOT="${FIXTURES}/dotnet-repo"
    append_if_missing() { record "append $*"; }
    mktemp() { printf '%s\n' /nonexistent/dotnet-install.sh; }
    curl() { record "curl $*"; }
    bash() { record "bash $*"; }
    rm() { record "rm $*"; }
    # Act
    run install_dotnet_sdk
    # Assert
    [ "$status" -eq 0 ]
    [[ "$output" == *"Installing repo-local .NET SDK 8.0.100 into ${FIXTURES}/dotnet-repo/.dotnet-sdk..."* ]]
    [[ "$output" == *"curl -fsSL https://dot.net/v1/dotnet-install.sh -o /nonexistent/dotnet-install.sh"* ]]
    [[ "$output" == *"bash /nonexistent/dotnet-install.sh --version 8.0.100 --install-dir ${FIXTURES}/dotnet-repo/.dotnet-sdk"* ]]
    [[ "$output" == *"rm -f /nonexistent/dotnet-install.sh"* ]]
    [[ "$output" == *"export PATH=\"${FIXTURES}/dotnet-repo/.dotnet-sdk:\$PATH\""* ]]
}

@test "C824-41 install_dotnet_tools fails when dotnet is unavailable" {
    # Arrange
    REPO_ROOT="${FIXTURES}/dotnet-repo"
    # Act
    run run_with_stub_path install_dotnet_tools
    # Assert
    [ "$status" -eq 1 ]
    [[ "$output" == *"dotnet is unavailable; cannot restore the required dotnet tool manifest."* ]]
}

@test "C824-42 install_dotnet_tools fails when the tool manifest is missing" {
    # Arrange
    REPO_ROOT="${BATS_TEST_DIRNAME}"
    dotnet() { record "dotnet $*"; }
    # Act
    run install_dotnet_tools
    # Assert
    [ "$status" -eq 1 ]
    [[ "$output" == *"Required dotnet tool manifest not found at ${BATS_TEST_DIRNAME}/dotnet-tools.json."* ]]
}

@test "C824-43 install_dotnet_tools restores the repo-local tool manifest" {
    # Arrange
    REPO_ROOT="${FIXTURES}/dotnet-repo"
    dotnet() { record "dotnet $*"; }
    # Act
    run install_dotnet_tools
    # Assert
    [ "$status" -eq 0 ]
    [[ "$output" == *"Restoring repo-local dotnet tools from dotnet-tools.json..."* ]]
    [[ "$output" == *"dotnet tool restore --tool-manifest ${FIXTURES}/dotnet-repo/dotnet-tools.json"* ]]
}

@test "C824-44 install_dotnet_coverage fails when dotnet is unavailable" {
    # Act
    run run_with_stub_path install_dotnet_coverage
    # Assert
    [ "$status" -eq 1 ]
    [[ "$output" == *"dotnet is unavailable; cannot install dotnet-coverage."* ]]
}

@test "C824-45 install_dotnet_coverage skips when dotnet-coverage is already available" {
    # Arrange
    dotnet() { record "dotnet $*"; }
    dotnet-coverage() { record "dotnet-coverage $*"; }
    mkdir() { record "mkdir $*"; }
    append_if_missing() { record "append $*"; }
    # Act
    run install_dotnet_coverage
    # Assert
    [ "$status" -eq 0 ]
    [[ "$output" == *"mkdir -p "*"/.dotnet/tools"* ]]
    [[ "$output" == *"dotnet-coverage is already available; skipping."* ]]
}

@test "C824-46 install_dotnet_coverage updates the global tool when it is already listed" {
    # Arrange: the grep stub reports that dotnet tool list names dotnet-coverage.
    dotnet() { record "dotnet $*"; }
    grep() { return 0; }
    mkdir() { record "mkdir $*"; }
    append_if_missing() { record "append $*"; }
    # Act
    run run_with_stub_path install_dotnet_coverage
    # Assert
    [ "$status" -eq 0 ]
    [[ "$output" == *"Installing dotnet-coverage as a global dotnet tool..."* ]]
    [[ "$output" == *"dotnet tool update --global dotnet-coverage"* ]]
}

@test "C824-47 install_dotnet_coverage installs the global tool when it is not listed" {
    # Arrange: the grep stub reports that dotnet tool list does not name dotnet-coverage.
    dotnet() { record "dotnet $*"; }
    grep() { return 1; }
    mkdir() { record "mkdir $*"; }
    append_if_missing() { record "append $*"; }
    # Act
    run run_with_stub_path install_dotnet_coverage
    # Assert
    [ "$status" -eq 0 ]
    [[ "$output" == *"dotnet tool install --global dotnet-coverage"* ]]
    [[ "$output" != *"dotnet tool update"* ]]
}
