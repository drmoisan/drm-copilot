# AC-4 append-last absence check (issue #886)

Timestamp: 2026-10-12T11-20

ExpectedExitCode: 1

Command: git grep -n -E "sys\.path\[-1\]|appended last|appends_repo_root" -- tests

EXIT_CODE: 1

Output Summary: no line printed (git grep prints nothing and exits 1 on no match). The patterns were present at origin/main in tests/scripts/dev_tools/test_validate_orchestration_artifacts_invocation.py; the replacement test `test_file_path_bootstrap_prepends_repo_root_once` removed them, so no test asserts append-last behavior.
