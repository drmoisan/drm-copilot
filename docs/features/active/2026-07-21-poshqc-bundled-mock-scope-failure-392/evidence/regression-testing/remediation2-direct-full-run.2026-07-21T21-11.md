Timestamp: 2026-07-21T21-11

Command: pwsh -NoProfile -Command "Invoke-Pester -Path scripts,tests/powershell,tests/scripts -Output Detailed"
EXIT_CODE: 0

Output Summary:
- Executed from a plain PowerShell session with no PoshQC module pre-imported (direct hosting,
  matching pester.runsettings.psd1's Run.Path).
- Test results: Tests Passed: 1341, Failed: 0, Skipped: 9, Inconclusive: 0, NotRun: 0. 0 failed.

## Direct-vs-bundled parity

Pass/fail/skip counts match P2-T1 (bundled) exactly:
- Direct:  1341 passed, 0 failed, 9 skipped.
- Bundled: 1341 passed, 0 failed, 9 skipped.

No divergence between direct and bundled hosting. The already-committed issue #392 global-hosting
trampoline fix is unaffected by the Candidate A parse-once-cache change.
