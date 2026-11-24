# Review Run - Full Pester Gate (feature-review, S7)

Timestamp: 2026-11-24T08-29
Command: sh <worktree>/.claude/skills/test-execution-policy/scripts/run-test-suite.sh pester (one Invoke-PoshQCParallelTest run, 8 workers, integration and golden lanes excluded), run by the feature-review agent at head 40b69e354ea8bd667c295659be8ecd8143bf474c with a clean tracked tree; launcher exits 75 (machine test-suite lock held by other worktrees) from 2026-11-24T07:52Z to 08:13:53Z were queue timeouts and were retried; the recorded run started 2026-11-24T08:13:53Z and ended 08:26:48Z
EXIT_CODE: 0
Output Summary: Launcher exit 0; wall-clock 759.04 s. JUnit (artifacts/pester/pester-junit.xml): tests=29739, failures=0, errors=0, skipped=18, disabled=22; passed=29721. Repo-wide line coverage from artifacts/pester/powershell-coverage.xml: 96.87% (47676 covered, 1540 missed), equal to final-pester.2026-11-24T06-53.md and +0.02 percentage points over the Phase 0 baseline 96.85% (47360/48901). Per file: DocsFamilyCheck.psm1 95/95 (100%); DocsValidation.psm1 157/159 (98.74%, missed lines 173 and 289, neither changed by this item); DocsValidateCommands.psm1 105/105 (100%); DocsCoverageReport.psm1 97/97 (100%); DocsLedgerCommands.psm1 329/330 (99.70%, missed line 494, not changed by this item).

## Reason for the Run

The executor's final gate report (written 2026-11-24T06:53Z) predates the head commit 40b69e354 (07:42Z), which committed the test-side fix in DocsLedgerCommands.Tests.ps1 that the gate had run uncommitted. This run measures the committed head. The executor's coverage and JUnit reports were copied to the session scratch directory before the run; their figures equal this run's figures.
