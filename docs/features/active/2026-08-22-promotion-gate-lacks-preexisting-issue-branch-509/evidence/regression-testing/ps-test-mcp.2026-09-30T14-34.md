# PowerShell Pester Run via MCP — P5-T11

Timestamp: 2026-09-30T14-34
Task: P5-T11
Working directory: worktree root

Command: rm -f artifacts/pester/pester-junit.xml artifacts/pester/powershell-coverage.xml; ls artifacts/pester; mcp__drm-copilot__run_poshqc_test with workspace_root = worktree root and scan_folders = ["tests/scripts/claude-lib/orchestrator-state"]; ls artifacts/pester; then read artifacts/pester/pester-junit.xml with the Read tool.
EXIT_CODE: 0
MCP-Status: success

## Prior attempt (superseded)

A first attempt started at 2026-09-30T14-33 returned MCP status `failure` (`Command exited with code 1.`). The junit output showed one failed test, `OrchestratorState bundle mirror byte identity.mirrors every orchestrator-state module byte-identically into the bundle` in `tests/scripts/claude-lib/orchestrator-state/OrchestratorState.Manifest.Tests.ps1`: the bundle copy of the adoption module was stale after a source edit made after P5-T4. P5-T4 was repeated (see `ps-bundle-copy.2026-09-30T14-34.md`) and this task was rerun from its first step. In that attempt the two new files already reported 32 tests / 0 failures (parity) and 42 tests / 0 failures (unit).

## Output Summary

Listing before the run (after `rm -f`):
```
(empty listing; `ls artifacts/pester` printed nothing, exit 0)
```
Neither `pester-junit.xml` nor `powershell-coverage.xml` is present.

Listing after the run:
```
pester-junit.xml
powershell-coverage.koverage.xml
powershell-coverage.xml
```
`pester-junit.xml` is present, so the file read below was produced by this run.

Junit root `testsuites`: tests="469", errors="0", failures="0". Every `testsuite` in the file is under `tests/scripts/claude-lib/orchestrator-state/`, so the root totals equal the orchestrator-state folder sums.

Per-file `testsuite` counts (repository-relative names):

| Test file | tests | failures |
| --- | --- | --- |
| tests/scripts/claude-lib/orchestrator-state/OrchestratorState.Manifest.Tests.ps1 | 6 | 0 |
| tests/scripts/claude-lib/orchestrator-state/OrchestratorState.Tests.ps1 | 46 | 0 |
| tests/scripts/claude-lib/orchestrator-state/OrchestratorState.ValueContract.Tests.ps1 | 2 | 0 |
| tests/scripts/claude-lib/orchestrator-state/OrchestratorStateCheckpointValue.Tests.ps1 | 47 | 0 |
| tests/scripts/claude-lib/orchestrator-state/OrchestratorStateCodexModelReceipts.Tests.ps1 | 29 | 0 |
| tests/scripts/claude-lib/orchestrator-state/OrchestratorStateCodexTopologyReceipts.Tests.ps1 | 31 | 0 |
| tests/scripts/claude-lib/orchestrator-state/OrchestratorStateCompletion.Tests.ps1 | 20 | 0 |
| tests/scripts/claude-lib/orchestrator-state/OrchestratorStateCompletionChecks.Tests.ps1 | 41 | 0 |
| tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Parity.Tests.ps1 | 32 | 0 |
| tests/scripts/claude-lib/orchestrator-state/OrchestratorStateIssueAdoption.Tests.ps1 | 42 | 0 |
| tests/scripts/claude-lib/orchestrator-state/OrchestratorStateModelReceipts.Tests.ps1 | 31 | 0 |
| tests/scripts/claude-lib/orchestrator-state/OrchestratorStatePromotionType.Parity.Tests.ps1 | 15 | 0 |
| tests/scripts/claude-lib/orchestrator-state/OrchestratorStateReceipts.Tests.ps1 | 40 | 0 |
| tests/scripts/claude-lib/orchestrator-state/OrchestratorStateRoutingContract.Tests.ps1 | 37 | 0 |
| tests/scripts/claude-lib/orchestrator-state/OrchestratorStateRoutingMatrix.Tests.ps1 | 31 | 0 |
| tests/scripts/claude-lib/orchestrator-state/OrchestratorStateUnconditional.Tests.ps1 | 19 | 0 |

Orchestrator-state folder sums: tests 469, failures 0, passed 469.

- `OrchestratorStateIssueAdoption.Parity.Tests.ps1`: 32 tests, 0 failures (as required).
- `OrchestratorStateIssueAdoption.Tests.ps1`: 42 tests, 0 failures; `PS_UNIT_PASSED` = 42.
- `OrchestratorState.Manifest.Tests.ps1`: 6 tests, 0 failures.

Arithmetic: `PS_BASELINE_PASSED` (395) + `PS_UNIT_PASSED` (42) + 32 = 469, which equals the observed folder passed count 469.

No coverage figure is read in this task. No failure text, stack frame, hostname value, or properties content is copied from the junit file.

Result: PASS

## Absolute-path check (run last)

Command: grep -c -E -e "(^|[^A-Za-z])[A-Za-z]:[\\/]" docs/features/active/2026-08-22-promotion-gate-lacks-preexisting-issue-branch-509/evidence/regression-testing/ps-test-mcp.2026-09-30T14-34.md
EXIT_CODE: 1
Output Summary: `0`
