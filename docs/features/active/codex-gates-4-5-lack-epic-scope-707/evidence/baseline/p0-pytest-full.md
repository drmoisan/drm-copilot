# Phase 0 Full Python Suite Baseline ([P0-T10])

Timestamp: 2026-09-27T06-38
Command: sh <SCRATCHPAD>/p0-pytest-full.sh (step 1, fresh PowerShell 7 process running <SCRATCHPAD>/p0-state.ps1: delete every file under .claude/state/, then Get-ChildItem -Force -File -Recurse -LiteralPath .claude/state; step 2, poetry run pytest -q; both steps in one script so no hook invocation could write state between the deletion and the test run)
EXIT_CODE: 0
Output Summary: .claude/state/ held no files before deletion (none present) and the listing after deletion reads none. Full suite: 5132 passed, 5 skipped; no failed or errored test. No failure attributable to gitignored local state or a Windows-only path was observed (orchestrator directive 4 and issue #510 did not apply on this run).

Run window (local): RUN_START_LOCAL 2026-09-27T06-38-24, RUN_END_LOCAL 2026-09-27T06-38-35.

Deleted files: none present

Recorded listing (`Get-ChildItem -Force -File -Recurse -LiteralPath .claude/state`, fresh process):

```
none
```

Final summary line:

```
5132 passed, 5 skipped in 8.89s
```

Skipped tests (informational, from the short test summary): five parametrized cases of `tests/scripts/dev_tools/test_parallel_manifest_bash_parity.py:231`, each reporting that its manifest fixture declares no accessor expectation.

Failed or errored node IDs: none
