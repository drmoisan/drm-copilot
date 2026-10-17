# No Temporary Files in Tests (P7-T2, AC19)

Timestamp: 2026-09-29T17-58
Command: git grep -n --untracked -E "tmp_path|tempfile|TemporaryDirectory|mkdtemp" -- "tests/scripts/dev_tools/test_push_down_claude_*.py" "extensions/drm-copilot/test/lib/push-down/claude-routing-merge-parity.test.ts"
EXIT_CODE: 1
ExpectedExitCode: 1

Output Summary:
- Exit code 1 with no output lines: no temporary-file API appears in any push-down Claude Python test module or in the new Jest test.
- Tests use `RecordingFileSystem` / `buildInMemoryFileSystem()` and injected directory listers.
