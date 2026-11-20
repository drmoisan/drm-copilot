# AC-6 suppression tree check (issue #886)

Timestamp: 2026-10-12T11-23

ExpectedExitCode: 1

Command: git grep -n -E "noqa|E402" -- scripts/dev_tools/validate_orchestration_artifacts.py tests/scripts/dev_tools/test_validate_orchestration_artifacts_invocation.py pyproject.toml

EXIT_CODE: 1

Output Summary: no line printed (git grep exits 1 on no match). None of the three files contains `noqa` or `E402`.
