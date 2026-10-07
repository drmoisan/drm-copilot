# P8-T17 Tests Create No Temporary Files and Start No Processes (pass 2, expect-fail search)

Timestamp: 2026-10-02T03-41
Command: git grep -n -E "tmp_path|tmpdir|tempfile|Popen|check_output|check_call|os\.system|subprocess\.run|import subprocess|from subprocess import" -- tests/scripts/dev_tools/test_quality_tiers_contract.py tests/scripts/dev_tools/test_check_quality_tiers.py
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: No match in either committed test file. File contents, tracked-file lists, the git runner, and the git resolver are injected; the only file write uses the in-memory `mem_fs_path` fixture.
