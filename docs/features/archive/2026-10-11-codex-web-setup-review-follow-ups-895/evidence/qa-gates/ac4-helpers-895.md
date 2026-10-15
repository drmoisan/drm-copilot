# AC-4 check (issue 895)

Timestamp: 2026-10-12T18-05
Command: git grep -c -E -e "^(run_with_stub_path|record|setup)\(\)|^(SCRIPT_UNDER_TEST|FIXTURES)=" -- tests/shell/helpers/codex_web_setup_common.bash tests/shell/test_codex_web_setup_codex_installers.bats tests/shell/test_codex_web_setup_codex_dotnet.bats tests/shell/test_codex_web_setup_codex_verify.bats; git grep -c -F -e "helpers/codex_web_setup_common" -- tests/shell/test_codex_web_setup_codex_installers.bats tests/shell/test_codex_web_setup_codex_dotnet.bats tests/shell/test_codex_web_setup_codex_verify.bats
EXIT_CODE: 0
Output Summary: The first command prints exactly one line, tests/shell/helpers/codex_web_setup_common.bash:5, with no line for any suite (the helper holds the five definitions and no suite redefines them). The second prints exactly three lines, each ending in :1, one per suite:
tests/shell/test_codex_web_setup_codex_dotnet.bats:1
tests/shell/test_codex_web_setup_codex_installers.bats:1
tests/shell/test_codex_web_setup_codex_verify.bats:1
