#!/usr/bin/env bats
# Command-path tests for scripts/bash/shell-qc.sh. Drives the wrapper end-to-end
# through the SHELL_QC_<TOOL>_BIN seam using checked-in recording stubs under
# tests/fixtures/shell_qc/stub-bin/, plus SHELL_QC_KCOV_OUT_DIR for the coverage
# path. Asserts the byte-identical skip markers consumed by fix_all.py, the
# missing-tool block, max-exit semantics, argv shapes, and the usage/exit-code
# contract. No temporary files are created for fixtures.

setup() {
    REPO_ROOT="$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)"
    LIB="${REPO_ROOT}/scripts/bash/shell_qc_lib.sh"
    WRAPPER="${REPO_ROOT}/scripts/bash/shell-qc.sh"
    FIXTURE_ROOT="${REPO_ROOT}/tests/fixtures/shell_qc"
    STUB_DIR="${FIXTURE_ROOT}/stub-bin"
    # Coverage output is redirected under the gitignored /artifacts tree so the
    # tracked fixture tree is never written to.
    KCOV_OUT="${REPO_ROOT}/artifacts/pester/kcov-bats"
    MISSING="/nonexistent/definitely-not-a-tool"
    # Checked-in stubs may be stored without the executable bit on some platforms;
    # make them runnable for this checkout. Idempotent; creates no files.
    chmod +x "${STUB_DIR}"/* 2>/dev/null || true
}

teardown() {
    # Remove any coverage output produced by the coverage-path tests.
    rm -rf "${KCOV_OUT}" 2>/dev/null || true
}

@test "check prints the no-scripts skip message and exits 0" {
    run bash -c "cd '${FIXTURE_ROOT}/cov' && bash '${WRAPPER}' check"
    [ "$status" -eq 0 ]
    [ "$output" = "No shell scripts found; skipping." ]
}

@test "check exits 127 with the five-line block when shfmt is missing" {
    run env SHELL_QC_SHFMT_BIN="${MISSING}" \
        bash -c "cd '${FIXTURE_ROOT}' && bash '${WRAPPER}' check"
    [ "$status" -eq 127 ]
    [[ "$output" == *"Missing required tool: shfmt"* ]]
    [[ "$output" == *"Devcontainer install (apt-get): apt-get update && apt-get install -y shfmt"* ]]
    [[ "$output" == *"macOS (Homebrew): brew install shfmt"* ]]
    [[ "$output" == *"Ubuntu/Debian: sudo apt-get update && sudo apt-get install -y shfmt"* ]]
    [[ "$output" == *"On Windows, use WSL for best results."* ]]
}

@test "check exits 127 with the block when shellcheck is missing" {
    run env SHELL_QC_SHFMT_BIN="${STUB_DIR}/shfmt" SHELL_QC_SHELLCHECK_BIN="${MISSING}" \
        bash -c "cd '${FIXTURE_ROOT}' && bash '${WRAPPER}' check"
    [ "$status" -eq 127 ]
    [[ "$output" == *"Missing required tool: shellcheck"* ]]
}

@test "check returns the shfmt exit code when only shfmt fails" {
    run env SHELL_QC_SHFMT_BIN="${STUB_DIR}/shfmt" SHELL_QC_SHELLCHECK_BIN="${STUB_DIR}/shellcheck" \
        STUB_SHFMT_EXIT=1 STUB_SHELLCHECK_EXIT=0 \
        bash -c "cd '${FIXTURE_ROOT}' && bash '${WRAPPER}' check"
    [ "$status" -eq 1 ]
}

@test "check returns the shellcheck exit code when only shellcheck fails" {
    run env SHELL_QC_SHFMT_BIN="${STUB_DIR}/shfmt" SHELL_QC_SHELLCHECK_BIN="${STUB_DIR}/shellcheck" \
        STUB_SHFMT_EXIT=0 STUB_SHELLCHECK_EXIT=2 \
        bash -c "cd '${FIXTURE_ROOT}' && bash '${WRAPPER}' check"
    [ "$status" -eq 2 ]
}

@test "check returns the maximum exit code when both tools fail" {
    run env SHELL_QC_SHFMT_BIN="${STUB_DIR}/shfmt" SHELL_QC_SHELLCHECK_BIN="${STUB_DIR}/shellcheck" \
        STUB_SHFMT_EXIT=1 STUB_SHELLCHECK_EXIT=3 \
        bash -c "cd '${FIXTURE_ROOT}' && bash '${WRAPPER}' check"
    [ "$status" -eq 3 ]
}

@test "check invokes shfmt once over the full list and shellcheck once per file" {
    run env SHELL_QC_SHFMT_BIN="${STUB_DIR}/shfmt" SHELL_QC_SHELLCHECK_BIN="${STUB_DIR}/shellcheck" \
        bash -c "cd '${FIXTURE_ROOT}' && bash '${WRAPPER}' check"
    [ "$status" -eq 0 ]
    shfmt_calls="$(printf '%s\n' "$output" | grep -c '^shfmt -d ' || true)"
    shellcheck_calls="$(printf '%s\n' "$output" | grep -c '^shellcheck ' || true)"
    [ "$shfmt_calls" -eq 1 ]
    [ "$shellcheck_calls" -eq 5 ]
    [[ "$output" == *"shfmt -d "*"tools/format_me.sh"* ]]
}

@test "format passes -w to shfmt" {
    run env SHELL_QC_SHFMT_BIN="${STUB_DIR}/shfmt" \
        bash -c "cd '${FIXTURE_ROOT}' && bash '${WRAPPER}' format"
    [ "$status" -eq 0 ]
    [[ "$output" == *"shfmt -w "* ]]
}

@test "test prints the exact no-test-directory skip marker and exits 0" {
    run bash -c "cd '${FIXTURE_ROOT}/tools' && bash '${WRAPPER}' test"
    [ "$status" -eq 0 ]
    [ "$output" = "No shell test directories found; skipping." ]
}

@test "test prints the exact bats-missing skip marker and exits 0" {
    run env SHELL_QC_BATS_BIN="${MISSING}" \
        bash -c "cd '${FIXTURE_ROOT}' && bash '${WRAPPER}' test"
    [ "$status" -eq 0 ]
    [ "$output" = "bats not installed; skipping shell tests." ]
}

@test "test --coverage exits 127 with the coverage message when bats is missing" {
    run env SHELL_QC_BATS_BIN="${MISSING}" \
        bash -c "cd '${FIXTURE_ROOT}' && bash '${WRAPPER}' test --coverage"
    [ "$status" -eq 127 ]
    [ "$output" = "bats not installed; cannot run shell tests with coverage." ]
}

@test "test --coverage exits 127 with message and block when kcov is missing" {
    run env SHELL_QC_BATS_BIN="${STUB_DIR}/bats" SHELL_QC_KCOV_BIN="${MISSING}" \
        bash -c "cd '${FIXTURE_ROOT}' && bash '${WRAPPER}' test --coverage"
    [ "$status" -eq 127 ]
    [[ "$output" == *"kcov not installed; cannot run shell tests with coverage."* ]]
    [[ "$output" == *"Missing required tool: kcov"* ]]
}

@test "test --coverage builds the kcov argv and merges the runs" {
    run env SHELL_QC_BATS_BIN="${STUB_DIR}/bats" SHELL_QC_KCOV_BIN="${STUB_DIR}/kcov" \
        SHELL_QC_KCOV_OUT_DIR="${KCOV_OUT}" \
        bash -c "cd '${FIXTURE_ROOT}' && bash '${WRAPPER}' test --coverage"
    [ "$status" -eq 0 ]
    [[ "$output" == *"kcov --cobertura-only"* ]]
    [[ "$output" == *"--include-pattern="*"/tools,"*"/scripts"* ]]
    [[ "$output" == *"--exclude-pattern="*"/tests"* ]]
    [[ "$output" == *"tests/shell"* ]]
    [[ "$output" == *"kcov --merge ${KCOV_OUT}"* ]]
}

@test "extract_cobertura_line_rate reads the fixture line-rate" {
    run bash -c "source '${LIB}' && extract_cobertura_line_rate '${FIXTURE_ROOT}/cov/cov.xml'"
    [ "$status" -eq 0 ]
    [ "$output" = "0.75" ]
}

@test "print_coverage_summary formats the fixture line-rate to one decimal percent" {
    run bash -c "source '${LIB}' && print_coverage_summary '${FIXTURE_ROOT}/cov/cov.xml'"
    [ "$status" -eq 0 ]
    [ "$output" = "Bash coverage (lines): 75.0%" ]
}

@test "--help prints usage and exits 0" {
    run bash "${WRAPPER}" --help
    [ "$status" -eq 0 ]
    [[ "$output" == *"Usage: shell-qc.sh"* ]]
}

@test "help subcommand prints usage and exits 0" {
    run bash "${WRAPPER}" help
    [ "$status" -eq 0 ]
    [[ "$output" == *"Usage: shell-qc.sh"* ]]
}

@test "an unknown subcommand prints usage and exits 2" {
    run bash "${WRAPPER}" bogus
    [ "$status" -eq 2 ]
    [[ "$output" == *"Usage: shell-qc.sh"* ]]
}

@test "an unknown test flag exits 2" {
    run bash -c "cd '${FIXTURE_ROOT}' && bash '${WRAPPER}' test --bogus"
    [ "$status" -eq 2 ]
}
