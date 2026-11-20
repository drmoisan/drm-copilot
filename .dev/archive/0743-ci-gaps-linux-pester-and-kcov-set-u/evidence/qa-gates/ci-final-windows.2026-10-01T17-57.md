# Final Windows Results (P7-T19, AC-7)

Timestamp: 2026-10-01T17-57
Deviation: D9 (Python JUnit helper).
RUN_ID: 36901896617; job `poshqc / PowerShell QC` databaseId 110502826187; CI_SHA ecba8829604f6265dc491c74cf42546f9d5aab57; conclusion `success`.

Command: gh run view 36901896617 --log --job 110502826187 | grep -F 'Tests Passed:'
EXIT_CODE: 0
Output Summary: `Tests Passed: 6091, Failed: 0, Skipped: 10, Inconclusive: 0, NotRun: 0`

Command: gh run download 36901896617 --name poshqc-test-results --dir <session-scratchpad>/windows-final
EXIT_CODE: 0
Output Summary: pester-junit.xml, powershell-coverage.xml, powershell-coverage.koverage.xml downloaded.

Command: poetry run python <session-scratchpad>/pester_xml_summary.py junit <session-scratchpad>/windows-final/pester-junit.xml
EXIT_CODE: 0
Output Summary: `JUNIT-ROOT: tests=6101 failures=0 errors=0`; no `FAIL:` line.

```
SUITE: tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-decision-surface.Tests.ps1 | tests=20 | failures=0 | errors=0 | skipped=0
SUITE: tests/scripts/codex-hooks/epic-child-launch-hardening.Tests.ps1 | tests=19 | failures=0 | errors=0 | skipped=0
SUITE: tests/scripts/codex-hooks/epic-child-worktree-launcher.Tests.ps1 | tests=22 | failures=0 | errors=0 | skipped=0
SUITE: tests/scripts/workflows/PoshQcWorkflow.Tests.ps1 | tests=7 | failures=0 | errors=0 | skipped=0
```

Acceptance: `Failed: 0`; no `FAIL:` line; the four named suites show `failures=0` and `errors=0`. Met.
