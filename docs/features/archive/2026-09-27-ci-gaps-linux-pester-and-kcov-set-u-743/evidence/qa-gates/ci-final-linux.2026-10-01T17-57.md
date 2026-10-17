# Final Linux Hook-Suite Results (P7-T18)

Timestamp: 2026-10-01T17-57
Deviation: D9 (Python JUnit helper).
RUN_ID: 36901896617; job `poshqc / PowerShell hook suites (Linux)` databaseId 110502826491; CI_SHA ecba8829604f6265dc491c74cf42546f9d5aab57.

Command: gh run view 36901896617 --log --job 110502826491 | grep -F 'Tests Passed:'
EXIT_CODE: 0
Output Summary: `Tests Passed: 3400, Failed: 12, Skipped: 0, Inconclusive: 0, NotRun: 0`

Command: gh run download 36901896617 --name poshqc-linux-hook-test-results --dir <session-scratchpad>/linux-final
EXIT_CODE: 0
Output Summary: `pester-junit-linux-hooks.xml` downloaded.

Command: poetry run python <session-scratchpad>/pester_xml_summary.py junit <session-scratchpad>/linux-final/pester-junit-linux-hooks.xml
EXIT_CODE: 0
Output Summary: `JUNIT-ROOT: tests=3412 failures=12 errors=0`. 12 `FAIL:` lines: 8 in `tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1` and one each in `tests/scripts/claude-hooks/enforce-powershell-batch-budget-routing.Tests.ps1`, `tests/scripts/claude-hooks/enforce-python-batch-budget-routing.Tests.ps1`, `tests/scripts/codex-hooks/codex-powershell-batch-budget-routing.Tests.ps1`, and `tests/scripts/codex-hooks/codex-python-batch-budget-routing.Tests.ps1`. These are exactly P4-T4 inventory rows 1 to 12, all REMEDIATION-REQUIRED.

SUITE lines for the three modified Codex suites:

```
SUITE: tests/scripts/codex-hooks/enforce-epic-worktree-removal-gate-decision-surface.Tests.ps1 | tests=20 | failures=0 | errors=0 | skipped=0
SUITE: tests/scripts/codex-hooks/epic-child-launch-hardening.Tests.ps1 | tests=19 | failures=0 | errors=0 | skipped=0
SUITE: tests/scripts/codex-hooks/epic-child-worktree-launcher.Tests.ps1 | tests=22 | failures=0 | errors=0 | skipped=0
```

Acceptance evaluation:
- `Tests Passed:` reports `Failed: 12`, not `Failed: 0`: not met.
- `JUNIT-ROOT:` reports `failures=12`: not met.
- `FAIL:` lines are printed (12): not met.
- The three modified Codex suites show `failures=0`: met (AC-8 and AC-9 on Linux).
- Inventory rows 13 to 21 (the plan's own rows) are absent from the `FAIL:` output: met. Rows 1 to 12 remain: REMEDIATION-REQUIRED.

Result: REMEDIATION-REQUIRED (AC-6 and AC-10 unchecked). Every remaining failure is in a file outside this plan's file list.
