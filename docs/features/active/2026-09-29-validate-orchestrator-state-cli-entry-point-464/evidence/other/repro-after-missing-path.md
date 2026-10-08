# Repro After Fix, Missing Path (Issue #464)

Timestamp: 2026-09-30T09-20
Command: poetry run python -m scripts.dev_tools.validate_orchestrator_state artifacts/nonexistent.json --require-complete
EXIT_CODE: 2
ExpectedExitCode: 2
Output Summary:
- stdout: empty.
- stderr (one line, no `Traceback`): `orchestrator-state checkpoint could not be read: artifacts/nonexistent.json: FileNotFoundError: [Errno 2] No such file or directory: 'artifacts\\nonexistent.json'`
- The line starts with `orchestrator-state checkpoint could not be read: artifacts/nonexistent.json` (the path argument as given, forward slashes).
- Before the fix (`evidence/baseline/repro-before-fix.md`): `EXIT_CODE: 0`, empty stdout, empty stderr. After the fix: `EXIT_CODE: 2` with the diagnostic above.
