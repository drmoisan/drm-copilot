#!/usr/bin/env bats
# ------------------------------------------------------------------------------
# test_codex_web_setup_codex_installers.bats
#
# Purpose:
#   Cover the installer functions of .codex/codex-web-setup.sh (the Codex copy,
#   not the GitHub Codex copy): install_apt_packages, install_powershell,
#   install_nuget, and install_actionlint, including every skip and failure
#   branch (issue #824, kcov scope widening for PA-1).
#
# Determinism: every external command an installer reaches (apt-get, id, sudo,
# mktemp, curl, dpkg, rm, tar, mono, pwsh, nuget, actionlint) is replaced by a
# shell function that prints its arguments to stderr. A test that needs a tool
# to be absent runs through run_with_stub_path, which limits PATH and HOME to
# this test directory (it holds no executable), so only the functions the test
# defines satisfy `command -v`. Nothing is downloaded or installed and no
# temporary file is created. teardown removes the stubs before bats-core runs
# its own cleanup.
# ------------------------------------------------------------------------------

# Canonical absolute path, so kcov reports the sourced file as <repo>/.codex/codex-web-setup.sh.
SCRIPT_UNDER_TEST="$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)/.codex/codex-web-setup.sh"

setup() {
    # Sourcing defines the functions without running main (C824-1 pins the guard).
    source "${SCRIPT_UNDER_TEST}"
}

teardown() {
    unset -f actionlint apt-get curl dpkg id mktemp mono nuget pwsh rm sudo tar
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

@test "C824-16 install_apt_packages warns and skips when apt-get is unavailable" {
    # Act
    run run_with_stub_path install_apt_packages
    # Assert
    [ "$status" -eq 0 ]
    [[ "$output" == *"apt-get is unavailable; skipping OS package installation."* ]]
}

@test "C824-17 install_apt_packages installs directly when running as root" {
    # Arrange
    id() { printf '%s\n' 0; }
    apt-get() { record "apt-get $*"; }
    # Act
    run run_with_stub_path install_apt_packages
    # Assert
    [ "$status" -eq 0 ]
    [[ "$output" == *"Installing Codex Web dependencies with apt-get..."* ]]
    [[ "$output" == *"apt-get update"* ]]
    [[ "$output" == *"apt-get install -y ca-certificates curl git jq lsb-release mono-complete ripgrep unzip zip"* ]]
    [[ "$output" != *"sudo"* ]]
}

@test "C824-18 install_apt_packages runs apt-get through sudo when not root" {
    # Arrange
    id() { printf '%s\n' 1000; }
    sudo() { record "sudo $*"; }
    apt-get() { record "apt-get $*"; }
    # Act
    run run_with_stub_path install_apt_packages
    # Assert
    [ "$status" -eq 0 ]
    [[ "$output" == *"sudo apt-get update"* ]]
    [[ "$output" == *"sudo apt-get install -y ca-certificates"* ]]
}

@test "C824-19 install_apt_packages warns and skips when not root and sudo is unavailable" {
    # Arrange
    id() { printf '%s\n' 1000; }
    apt-get() { record "apt-get $*"; }
    # Act
    run run_with_stub_path install_apt_packages
    # Assert
    [ "$status" -eq 0 ]
    [[ "$output" == *"apt-get requires root and sudo is unavailable; skipping OS package installation."* ]]
    [[ "$output" != *"apt-get update"* ]]
}

@test "C824-20 install_powershell skips when pwsh is already available" {
    # Arrange
    pwsh() { record "pwsh $*"; }
    # Act
    run install_powershell
    # Assert
    [ "$status" -eq 0 ]
    [[ "$output" == *"PowerShell is already available; skipping."* ]]
}

@test "C824-21 install_powershell warns and skips when apt-get is unavailable" {
    # Act
    run run_with_stub_path install_powershell
    # Assert
    [ "$status" -eq 0 ]
    [[ "$output" == *"apt-get is unavailable; skipping PowerShell installation."* ]]
}

@test "C824-22 install_powershell warns and skips when not root and sudo is unavailable" {
    # Arrange
    id() { printf '%s\n' 1000; }
    apt-get() { record "apt-get $*"; }
    # Act
    run run_with_stub_path install_powershell
    # Assert
    [ "$status" -eq 0 ]
    [[ "$output" == *"PowerShell installation requires root; skipping."* ]]
}

@test "C824-23 install_powershell registers the Microsoft repository and installs through sudo" {
    # Arrange: lsb_release is absent, so the Ubuntu version falls back to 24.04.
    id() { printf '%s\n' 1000; }
    sudo() { record "sudo $*"; }
    apt-get() { record "apt-get $*"; }
    mktemp() { printf '%s\n' /nonexistent/packages-microsoft-prod.deb; }
    curl() { record "curl $*"; }
    rm() { record "rm $*"; }
    # Act
    run run_with_stub_path install_powershell
    # Assert
    [ "$status" -eq 0 ]
    [[ "$output" == *"Registering Microsoft package repository for PowerShell (Ubuntu 24.04)..."* ]]
    [[ "$output" == *"curl -fsSL https://packages.microsoft.com/config/ubuntu/24.04/packages-microsoft-prod.deb -o /nonexistent/packages-microsoft-prod.deb"* ]]
    [[ "$output" == *"sudo dpkg -i /nonexistent/packages-microsoft-prod.deb"* ]]
    [[ "$output" == *"rm -f /nonexistent/packages-microsoft-prod.deb"* ]]
    [[ "$output" == *"sudo apt-get install -y powershell"* ]]
}

@test "C824-24 install_powershell warns and skips when the repository package download fails" {
    # Arrange
    id() { printf '%s\n' 0; }
    apt-get() { record "apt-get $*"; }
    mktemp() { printf '%s\n' /nonexistent/packages-microsoft-prod.deb; }
    curl() { return 1; }
    rm() { record "rm $*"; }
    # Act
    run run_with_stub_path install_powershell
    # Assert
    [ "$status" -eq 0 ]
    [[ "$output" == *"rm -f /nonexistent/packages-microsoft-prod.deb"* ]]
    [[ "$output" == *"Could not download Microsoft package repo; skipping PowerShell installation."* ]]
    [[ "$output" != *"apt-get install"* ]]
}

@test "C824-25 install_nuget skips when nuget is already available" {
    # Arrange
    nuget() { record "nuget $*"; }
    # Act
    run install_nuget
    # Assert
    [ "$status" -eq 0 ]
    [[ "$output" == *"nuget is already available; skipping."* ]]
}

@test "C824-26 install_nuget warns when mono is unavailable" {
    # Act
    run run_with_stub_path install_nuget
    # Assert
    [ "$status" -eq 0 ]
    [[ "$output" == *"mono is unavailable; cannot install nuget wrapper."* ]]
}

@test "C824-27 install_nuget writes the mono wrapper through sudo when not root" {
    # Arrange: the sudo stub drains the wrapper text that tee would receive.
    id() { printf '%s\n' 1000; }
    mono() { record "mono $*"; }
    curl() { record "curl $*"; }
    sudo() {
        if [ "${1:-}" = "tee" ]; then
            while IFS= read -r _wrapper_line; do :; done
        fi
        record "sudo $*"
    }
    # Act
    run run_with_stub_path install_nuget
    # Assert
    [ "$status" -eq 0 ]
    [[ "$output" == *"Downloading nuget.exe and creating mono wrapper..."* ]]
    [[ "$output" == *"curl -fsSL https://dist.nuget.org/win-x86-commandline/latest/nuget.exe -o /usr/local/bin/nuget.exe"* ]]
    [[ "$output" == *"sudo tee /usr/local/bin/nuget"* ]]
    [[ "$output" == *"sudo chmod +x /usr/local/bin/nuget"* ]]
    [[ "$output" == *"nuget wrapper installed at /usr/local/bin/nuget."* ]]
}

@test "C824-28 install_nuget warns when the nuget.exe download fails" {
    # Arrange
    id() { printf '%s\n' 0; }
    mono() { record "mono $*"; }
    curl() { return 1; }
    # Act
    run run_with_stub_path install_nuget
    # Assert
    [ "$status" -eq 0 ]
    [[ "$output" == *"Could not download nuget.exe; skipping."* ]]
    [[ "$output" != *"nuget wrapper installed"* ]]
}

@test "C824-29 install_actionlint skips when actionlint is already available" {
    # Arrange
    actionlint() { record "actionlint $*"; }
    # Act
    run install_actionlint
    # Assert
    [ "$status" -eq 0 ]
    [[ "$output" == *"actionlint is already available; skipping."* ]]
}

@test "C824-30 install_actionlint warns when tar is unavailable" {
    # Act
    run run_with_stub_path install_actionlint
    # Assert
    [ "$status" -eq 0 ]
    [[ "$output" == *"tar is unavailable; skipping actionlint installation."* ]]
}

@test "C824-31 install_actionlint warns when not root and sudo is unavailable" {
    # Arrange
    id() { printf '%s\n' 1000; }
    tar() { record "tar $*"; }
    # Act
    run run_with_stub_path install_actionlint
    # Assert
    [ "$status" -eq 0 ]
    [[ "$output" == *"actionlint installation requires root or sudo; skipping."* ]]
}

@test "C824-32 install_actionlint installs the pinned release through sudo" {
    # Arrange
    id() { printf '%s\n' 1000; }
    sudo() { record "sudo $*"; }
    tar() { record "tar $*"; }
    mktemp() { printf '%s\n' /nonexistent/actionlint-tmp; }
    curl() { record "curl $*"; }
    rm() { record "rm $*"; }
    # Act
    run run_with_stub_path install_actionlint
    # Assert
    [ "$status" -eq 0 ]
    [[ "$output" == *"Installing actionlint v1.7.7..."* ]]
    [[ "$output" == *"tar -xzf /nonexistent/actionlint-tmp/actionlint.tar.gz -C /nonexistent/actionlint-tmp actionlint"* ]]
    [[ "$output" == *"sudo install -m 0755 /nonexistent/actionlint-tmp/actionlint /usr/local/bin/actionlint"* ]]
    [[ "$output" == *"actionlint installed at /usr/local/bin/actionlint."* ]]
    [[ "$output" == *"rm -rf /nonexistent/actionlint-tmp"* ]]
}

@test "C824-33 install_actionlint warns when the release download fails" {
    # Arrange
    id() { printf '%s\n' 0; }
    tar() { record "tar $*"; }
    mktemp() { printf '%s\n' /nonexistent/actionlint-tmp; }
    curl() { return 1; }
    rm() { record "rm $*"; }
    # Act
    run run_with_stub_path install_actionlint
    # Assert
    [ "$status" -eq 0 ]
    [[ "$output" == *"Could not download actionlint; skipping."* ]]
    [[ "$output" == *"rm -rf /nonexistent/actionlint-tmp"* ]]
}
