# AC-5 check (issue 895)

Timestamp: 2026-10-12T18-05
Command: git grep -n -F -e "fixture precondition (C824-37)" -- tests/shell/test_codex_web_setup_codex_dotnet.bats; git grep -n -F -e 'run append_if_missing "${FIXTURES}/bashrc-with-ci.txt"' -- tests/shell/test_codex_web_setup_codex_dotnet.bats
EXIT_CODE: 0
Output Summary: Each command prints exactly one line. The precondition is at line 59 and the act step is at line 63, so the precondition precedes the act step (the act step was at line 80 before the edit and moved earlier because the shared helper removed the duplicated definitions):
tests/shell/test_codex_web_setup_codex_dotnet.bats:59:    # Arrange: fixture precondition (C824-37), the file holds the line exactly once.
tests/shell/test_codex_web_setup_codex_dotnet.bats:63:    run append_if_missing "${FIXTURES}/bashrc-with-ci.txt" 'export CI=true'
