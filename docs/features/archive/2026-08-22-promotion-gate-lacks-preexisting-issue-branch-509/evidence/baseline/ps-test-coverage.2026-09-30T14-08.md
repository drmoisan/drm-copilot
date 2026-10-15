# PowerShell Pester and Coverage Baseline (P0-T19)

Timestamp: 2026-09-30T14-08
Task: [P0-T19]
Location: worktree root
Inputs read: `evidence/baseline/poshqc-local/pester-junit.xml`, `evidence/baseline/poshqc-local/powershell-coverage.xml`, `evidence/baseline/poshqc-local/run-record.md` (all present). No PowerShell command ran in this task.

## Copied test run (H0, Source B)

Command (quoted from `run-record.md`):
- `gh workflow run _poshqc.yml --ref bug/promotion-gate-lacks-preexisting-issue-branch-exec-509`
- `gh run list --workflow=_poshqc.yml --branch bug/promotion-gate-lacks-preexisting-issue-branch-exec-509 --limit 1 --json databaseId,headSha,conclusion`
- `gh run view 36725543249 --json jobs`
- `gh run download 36725543249 -n poshqc-test-results -D <session scratchpad outside the evidence tree>`

EXIT_CODE: 0 (quoted from `run-record.md`; each of the four commands records `EXIT_CODE: 0`, run conclusion `success`)

Output Summary:
- Source used: B.
- SourceB-Dispatched: 2026-09-30T13:58:06Z. P0-T17 completion time: 2026-09-30T13:57:15Z. The dispatch value follows the P0-T17 completion time.
- Limit (c) headSha equality: run 36725543249 headSha `127635e94f51e855c7b82f21c87d575bf5acfdad`; `git rev-parse HEAD` at 2026-09-30T14:07:52Z = `127635e94f51e855c7b82f21c87d575bf5acfdad`. Equal.
- Sanitization line quoted from `run-record.md`: `sanitized: root, absolute-paths, properties, hostname`
- Sanitization check results (all pass; see commands below): each of the three counting greps printed `:0` for both XML files and exited 1; the hostname extraction printed only `hostname="HOST"`.
- Junit root (repository-wide scope under limit (b)): `tests="6109"`, `failures="0"` (also `errors="0"`, `disabled="10"`).
- Orchestrator-state folder sums (14 `testsuite` elements whose `name` contains `tests\scripts\claude-lib\orchestrator-state\`):
  - OrchestratorState.Manifest.Tests.ps1: tests 6, failures 0
  - OrchestratorState.Tests.ps1: tests 46, failures 0
  - OrchestratorState.ValueContract.Tests.ps1: tests 2, failures 0
  - OrchestratorStateCheckpointValue.Tests.ps1: tests 47, failures 0
  - OrchestratorStateCodexModelReceipts.Tests.ps1: tests 29, failures 0
  - OrchestratorStateCodexTopologyReceipts.Tests.ps1: tests 31, failures 0
  - OrchestratorStateCompletion.Tests.ps1: tests 20, failures 0
  - OrchestratorStateCompletionChecks.Tests.ps1: tests 41, failures 0
  - OrchestratorStateModelReceipts.Tests.ps1: tests 31, failures 0
  - OrchestratorStatePromotionType.Parity.Tests.ps1: tests 15, failures 0
  - OrchestratorStateReceipts.Tests.ps1: tests 40, failures 0
  - OrchestratorStateRoutingContract.Tests.ps1: tests 37, failures 0
  - OrchestratorStateRoutingMatrix.Tests.ps1: tests 31, failures 0
  - OrchestratorStateUnconditional.Tests.ps1: tests 19, failures 0
  - Sum tests: 6+46+2+47+29+31+20+41+31+15+40+37+31+19 = 395; sum failures: 0.
  - PS_BASELINE_PASSED: 395 (395 tests - 0 failures)
- Per-file counts:
  - `tests/scripts/claude-hooks/validate-orchestrator-output.Tests.ps1`: tests 27, failures 0
  - `tests/scripts/claude-hooks/validate-orchestrator-output.model-routing.Tests.ps1`: tests 6, failures 0
  - `tests/scripts/claude-hooks/validate-orchestrator-output.artifact-type-dispatch.Tests.ps1`: tests 17, failures 0
  - `tests/scripts/claude-runtime/checkpoint-hygiene-skill-contract.Tests.ps1`: tests 11, failures 0
  - `tests/scripts/codex-hooks/codex-epic-runtime-contracts.Tests.ps1`: tests 10, failures 0
- Failed tests across all four folders: none. The file contains no `<failure` element and no `failures` attribute with a non-zero value (search count 0).
  - PS_BASELINE_FAILED: {} (empty set)
- Line coverage for `OrchestratorStateRoutingContract.psm1` (package `WORKTREE_ROOT/.claude/lib/orchestrator-state`, `sourcefile` at line 10423, counter at line 10532): `<counter type="LINE" missed="1" covered="106" />`
  - PS_ROUTING_BASELINE_LINE: 99.1% (106 / (1 + 106) = 106 / 107 = 0.99065)
- No failure inside the orchestrator-state folder; nothing to escalate.

## Sanitization check commands

Timestamp: 2026-09-30T14:08:51Z

Command: grep -c -E -e "(^|[^A-Za-z])[A-Za-z]:[\\/]" docs/features/active/2026-08-22-promotion-gate-lacks-preexisting-issue-branch-509/evidence/baseline/poshqc-local/pester-junit.xml docs/features/active/2026-08-22-promotion-gate-lacks-preexisting-issue-branch-509/evidence/baseline/poshqc-local/powershell-coverage.xml
EXIT_CODE: 1
Output Summary: `pester-junit.xml:0`, `powershell-coverage.xml:0`

Command: grep -c -F -e "/home/runner" docs/features/active/2026-08-22-promotion-gate-lacks-preexisting-issue-branch-509/evidence/baseline/poshqc-local/pester-junit.xml docs/features/active/2026-08-22-promotion-gate-lacks-preexisting-issue-branch-509/evidence/baseline/poshqc-local/powershell-coverage.xml
EXIT_CODE: 1
Output Summary: `pester-junit.xml:0`, `powershell-coverage.xml:0`

Command: grep -c -F -e "<property " docs/features/active/2026-08-22-promotion-gate-lacks-preexisting-issue-branch-509/evidence/baseline/poshqc-local/pester-junit.xml docs/features/active/2026-08-22-promotion-gate-lacks-preexisting-issue-branch-509/evidence/baseline/poshqc-local/powershell-coverage.xml
EXIT_CODE: 1
Output Summary: `pester-junit.xml:0`, `powershell-coverage.xml:0`

Command: grep -o -h -E -e "hostname=\"[^\"]*\"" docs/features/active/2026-08-22-promotion-gate-lacks-preexisting-issue-branch-509/evidence/baseline/poshqc-local/pester-junit.xml | sort -u
EXIT_CODE: 0
Output Summary: `hostname="HOST"` (single unique value)

Note: the Source B branch applies, so the counting greps name only the two XML paths; no `analyzer-output.txt` exists for Source B. The greps were run with the file paths in absolute form because the Bash hook denies a leading `cd`; the printed file names were translated to the repository-relative paths above.
