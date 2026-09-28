# Final QA — PowerShell Pester Repository-Wide Coverage (P7-T3)

Timestamp: 2026-09-27T15-53

Iteration: 1

Command: sh `<scratchpad>`/run-ps.sh `<scratchpad>`/clear-pester-artifacts.ps1

EXIT_CODE: 0

```
pester-junit.xml PRESENT_AFTER_CLEAR=False
powershell-coverage.xml PRESENT_AFTER_CLEAR=False
```

Command: MCP mcp__drm-copilot__run_poshqc_test, workspace_root `<worktree root>`, no scan_folders override

EXIT_CODE: 0

Output: {"ok":true,"tool":"run_poshqc_test","workspace_root":"`<worktree root>`","summary":"Ran bundled PoshQC test against '`<worktree root>`'."}

Command: sh `<scratchpad>`/run-ps.sh `<scratchpad>`/poshqc-test.ps1

EXIT_CODE: 0

Output (tail):

```
Tests completed in 189.04s
Tests Passed: 5478, Failed: 0, Skipped: 10, Inconclusive: 0, NotRun: 0
Processing code coverage result.
Covered 95.28% / 0%. 14,744 analyzed Commands in 114 Files.
```

Command: sh `<scratchpad>`/run-ps.sh `<scratchpad>`/junit-report.ps1 -NameFilter "regression corpus for issue 452"

EXIT_CODE: 0

```
ALL total=5488 pass=5478 fail=0 skip=10
FILTER matched=26
PASS BlastRadius regression corpus for issue 452.Corpus contract.declares the contracted top-level shape
PASS BlastRadius regression corpus for issue 452.Corpus contract.matches the case shape contract for every case
PASS BlastRadius regression corpus for issue 452.Corpus contract.carries every Case List id exactly once and no other id
PASS BlastRadius regression corpus for issue 452.Corpus contract.expects a verdict consistent with each case direction
PASS BlastRadius regression corpus for issue 452.Corpus contract.resolves every pairing to an opposite-direction case of the same gap
PASS BlastRadius regression corpus for issue 452.Corpus contract.pins both directions for each gap
PASS BlastRadius regression corpus for issue 452.Corpus contract.follows the plan-line intent rule for every plan line
PASS BlastRadius regression corpus for issue 452.Detection-level verdicts.reports the corpus verdict for g1-plan-poetry-lock
PASS BlastRadius regression corpus for issue 452.Detection-level verdicts.reports the corpus verdict for g1-plan-package-lock
PASS BlastRadius regression corpus for issue 452.Detection-level verdicts.reports the corpus verdict for g1-plan-different-surfaces
PASS BlastRadius regression corpus for issue 452.Detection-level verdicts.reports the corpus verdict for g1-plan-unconfigured-root-file
PASS BlastRadius regression corpus for issue 452.Detection-level verdicts.reports the corpus verdict for g1-plan-quality-tiers-mandate-read
PASS BlastRadius regression corpus for issue 452.Detection-level verdicts.reports the corpus verdict for g1-radius-quality-tiers
PASS BlastRadius regression corpus for issue 452.Detection-level verdicts.reports the corpus verdict for g1-radius-quality-tiers-vs-poetry-lock
PASS BlastRadius regression corpus for issue 452.Detection-level verdicts.reports the corpus verdict for g2-dir-vs-glob
PASS BlastRadius regression corpus for issue 452.Detection-level verdicts.reports the corpus verdict for g2-glob-vs-dir
PASS BlastRadius regression corpus for issue 452.Detection-level verdicts.reports the corpus verdict for g2-dir-vs-sibling-glob
PASS BlastRadius regression corpus for issue 452.Detection-level verdicts.reports the corpus verdict for g2-sibling-glob-vs-dir
PASS BlastRadius regression corpus for issue 452.Detection-level verdicts.reports the corpus verdict for g2-artifacts-dir-vs-glob
PASS BlastRadius regression corpus for issue 452.Detection-level verdicts.reports the corpus verdict for g2-artifacts-glob-vs-dir
PASS BlastRadius regression corpus for issue 452.Detection-level verdicts.reports the corpus verdict for g2-artifacts-dir-vs-sibling-glob
PASS BlastRadius regression corpus for issue 452.Detection-level verdicts.reports the corpus verdict for g2-artifacts-sibling-glob-vs-dir
PASS BlastRadius regression corpus for issue 452.Detection-level verdicts.reports the corpus verdict for g2-empty-modules-dir-vs-glob
PASS BlastRadius regression corpus for issue 452.Detection-level verdicts.reports the corpus verdict for g2-empty-modules-dir-vs-sibling-glob
PASS BlastRadius regression corpus for issue 452.Bundled configuration parity.admits the same separator-free root surfaces from both committed tables
SKIP BlastRadius regression corpus for issue 452.Tolerance branch.keeps a scheduling edge for every must-conflict case at the strictest tolerance
```

No FAILED_ANY lines were printed.

Command: sh `<scratchpad>`/run-ps.sh `<scratchpad>`/coverage-line.ps1

EXIT_CODE: 0

```
LINE covered=10224 missed=422 percent=96.04
```

Issue #510 allowance: not applicable to this task (Execution Conventions scope P6-T5, P6-T6, and P8-T2 only).

## Acceptance evaluation

| Criterion | Required | Observed | Result |
| --- | --- | --- | --- |
| ALL total | P0-T27 5462 + 26 = 5488 | 5488 | pass |
| FAILED_ANY name set | subset of the P0-T27 set (empty) | empty | pass |
| FILTER matched | 26, no FAIL, 25 PASS and 1 SKIP (branch NOT FOUND) | 26; 25 PASS, 1 SKIP, 0 FAIL | pass |
| LINE percent | >= 85.00 and >= 96.04 | 96.04 | pass |

Output Summary: PASS (iteration 1). JUnit total 5488, pass 5478, fail 0, skip 10. The issue #452 regression consumer: 26 matched, 25 PASS, 1 SKIP (tolerance branch NOT FOUND). PowerShell repository-wide line coverage 96.04% (10224 covered, 422 missed), equal to the P0-T27 baseline. The "Bundled configuration parity" test passed.
