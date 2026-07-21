#!/usr/bin/env bats
# Discovery unit tests for scripts/bash/shell_qc_lib.sh. Sources the library and
# exercises extract_shebang_command, is_shell_script, and discover_shell_scripts
# against the checked-in fixture tree tests/fixtures/shell_qc/. No temporary files.

setup() {
    REPO_ROOT="$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)"
    LIB="${REPO_ROOT}/scripts/bash/shell_qc_lib.sh"
    FIXTURE_ROOT="${REPO_ROOT}/tests/fixtures/shell_qc"
}

@test "extract_shebang_command reads extensionless env bash shebang" {
    run bash -c "source '${LIB}' && extract_shebang_command '${FIXTURE_ROOT}/scripts/with_shebang'"
    [ "$status" -eq 0 ]
    [ "$output" = "bash" ]
}

@test "extract_shebang_command handles env -S flags form" {
    run bash -c "source '${LIB}' && extract_shebang_command '${FIXTURE_ROOT}/scripts/env_s_bash'"
    [ "$status" -eq 0 ]
    [ "$output" = "bash" ]
}

@test "extract_shebang_command lowercases an uppercase shebang" {
    run bash -c "source '${LIB}' && extract_shebang_command '${FIXTURE_ROOT}/scripts/uppercase_bash'"
    [ "$status" -eq 0 ]
    [ "$output" = "bash" ]
}

@test "extract_shebang_command handles a plain sh shebang" {
    run bash -c "source '${LIB}' && extract_shebang_command '${FIXTURE_ROOT}/scripts/sh_shebang'"
    [ "$status" -eq 0 ]
    [ "$output" = "sh" ]
}

@test "is_shell_script accepts a .sh suffix" {
    run bash -c "source '${LIB}' && is_shell_script '${FIXTURE_ROOT}/tools/format_me.sh'"
    [ "$status" -eq 0 ]
}

@test "is_shell_script rejects a non-shell text file" {
    run bash -c "source '${LIB}' && is_shell_script '${FIXTURE_ROOT}/scripts/ignored.txt'"
    [ "$status" -ne 0 ]
}

@test "is_shell_script rejects a pwsh shebang" {
    run bash -c "source '${LIB}' && is_shell_script '${FIXTURE_ROOT}/scripts/pwsh_script.ps1'"
    [ "$status" -ne 0 ]
}

@test "discover_shell_scripts finds .sh suffix and every bash/sh shebang form" {
    run bash -c "cd '${FIXTURE_ROOT}' && source '${LIB}' && discover_shell_scripts"
    [ "$status" -eq 0 ]
    [[ "$output" == *"tools/format_me.sh"* ]]
    [[ "$output" == *"scripts/with_shebang"* ]]
    [[ "$output" == *"scripts/env_s_bash"* ]]
    [[ "$output" == *"scripts/uppercase_bash"* ]]
    [[ "$output" == *"scripts/sh_shebang"* ]]
}

@test "discover_shell_scripts prunes the excluded node_modules directory" {
    run bash -c "cd '${FIXTURE_ROOT}' && source '${LIB}' && discover_shell_scripts"
    [ "$status" -eq 0 ]
    [[ "$output" != *"node_modules"* ]]
    [[ "$output" != *"skip_me"* ]]
}

@test "discover_shell_scripts ignores non-shell files (txt and ps1)" {
    run bash -c "cd '${FIXTURE_ROOT}' && source '${LIB}' && discover_shell_scripts"
    [ "$status" -eq 0 ]
    [[ "$output" != *"ignored.txt"* ]]
    [[ "$output" != *"pwsh_script.ps1"* ]]
}

@test "discover_shell_scripts output is sorted and de-duplicated" {
    run bash -c "cd '${FIXTURE_ROOT}' && source '${LIB}' && discover_shell_scripts"
    [ "$status" -eq 0 ]
    [ "${#lines[@]}" -eq 5 ]
    [ "${lines[0]}" = "scripts/env_s_bash" ]
    [ "${lines[1]}" = "scripts/sh_shebang" ]
    [ "${lines[2]}" = "scripts/uppercase_bash" ]
    [ "${lines[3]}" = "scripts/with_shebang" ]
    [ "${lines[4]}" = "tools/format_me.sh" ]
}
