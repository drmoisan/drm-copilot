#!/usr/bin/env bats
# Unit tests for the POSIX shim run-test-suite.sh of the test-execution launcher (issue #1158),
# for both the .claude and the .agents copy. The shim runs a stub instead of PowerShell 7:
# tests/fixtures/test-execution-policy/pwsh-stub.sh through TEST_SUITE_PWSH_BIN, or
# tests/fixtures/test-execution-policy/bin/pwsh through PATH. No temporary file is created. Most cases
# run the shim with bash so that kcov measures its lines; the PATH case runs it with sh, the form agents
# use, to prove that the shim is POSIX sh.

setup() {
    REPO_ROOT="$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)"
    FIXTURES="${REPO_ROOT}/tests/fixtures/test-execution-policy"
    STUB="${FIXTURES}/pwsh-stub.sh"
    SHIMS=(
        "${REPO_ROOT}/.claude/skills/test-execution-policy/scripts/run-test-suite.sh"
        "${REPO_ROOT}/.agents/skills/test-execution-policy/scripts/run-test-suite.sh"
    )
}

@test "passes -NoProfile, -File, the launcher path, the suite name, and hyphen-leading extras in order" {
    for shim in "${SHIMS[@]}"; do
        run env TEST_SUITE_PWSH_BIN="$STUB" bash "$shim" pytest -v -- -i
        [ "$status" -eq 0 ]
        [ "${lines[0]}" = "pwsh-stub" ]
        [ "${lines[1]}" = "-NoProfile" ]
        [ "${lines[2]}" = "-File" ]
        [[ "${lines[3]}" == */skills/test-execution-policy/scripts/Invoke-TestSuite.ps1 ]]
        [ "${lines[4]}" = "pytest" ]
        [ "${lines[5]}" = "-v" ]
        [ "${lines[6]}" = "--" ]
        [ "${lines[7]}" = "-i" ]
        [ "${#lines[@]}" -eq 8 ]
    done
}

@test "resolves the launcher path beside the shim that runs" {
    for shim in "${SHIMS[@]}"; do
        run env TEST_SUITE_PWSH_BIN="$STUB" bash "$shim" jest
        [ "$status" -eq 0 ]
        [ "${lines[3]}" = "$(cd "$(dirname "$shim")" && pwd)/Invoke-TestSuite.ps1" ]
    done
}

@test "propagates the launcher exit statuses 0, 1, and 75" {
    for code in 0 1 75; do
        for shim in "${SHIMS[@]}"; do
            run env TEST_SUITE_PWSH_BIN="$STUB" STUB_EXIT_CODE="$code" bash "$shim" pester
            [ "$status" -eq "$code" ]
        done
    done
}

@test "runs pwsh from PATH when TEST_SUITE_PWSH_BIN is unset" {
    for shim in "${SHIMS[@]}"; do
        run env -u TEST_SUITE_PWSH_BIN PATH="${FIXTURES}/bin:${PATH}" sh "$shim" bats
        [ "$status" -eq 0 ]
        [ "${lines[0]}" = "bin-pwsh" ]
        [ "${lines[4]}" = "bats" ]
    done
}
