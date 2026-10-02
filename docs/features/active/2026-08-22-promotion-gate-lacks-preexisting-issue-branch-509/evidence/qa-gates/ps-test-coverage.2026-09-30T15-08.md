# PowerShell Pester and Coverage Final QA (P8-T13)

Timestamp: 2026-09-30T15-08
Task: [P8-T13]
Location: worktree root
Inputs read: `evidence/qa-gates/poshqc-local/pester-junit.xml`, `evidence/qa-gates/poshqc-local/powershell-coverage.xml`, `evidence/qa-gates/poshqc-local/run-record.md` (all present). No PowerShell command ran in this task. The P8-T12 MCP run wrote only under `artifacts/pester/` and does not replace these copies.

## Copied test run (H1, Source B)

Command (quoted from `run-record.md`):
- `gh workflow run _poshqc.yml --ref bug/promotion-gate-lacks-preexisting-issue-branch-exec-509`
- `gh run list --workflow=_poshqc.yml --branch bug/promotion-gate-lacks-preexisting-issue-branch-exec-509 --limit 1 --json databaseId,headSha,conclusion`
- `gh run view 36732800820 --json jobs`
- `gh run download 36732800820 -n poshqc-test-results -D <session scratchpad outside the evidence tree>`

EXIT_CODE: 0 (quoted from `run-record.md`; each of the four commands records `EXIT_CODE: 0`, run conclusion `success`)

Output Summary:
- Source used: B. P0-T19 source: B. Equal.
- SourceB-Dispatched: 2026-09-30T14:55:30Z. P8-T10 completion time: 2026-09-30T14:54:01Z. The dispatch value is later than the P8-T10 completion time.
- Limit (c) headSha equality: run 36732800820 headSha `ca655902a441e6be0d1749f91440d07c38dbe941`; `git rev-parse HEAD` at 2026-09-30T15:01Z = `ca655902a441e6be0d1749f91440d07c38dbe941`. Equal.
- Sanitization line quoted from `run-record.md`: `sanitized: root, absolute-paths, properties, hostname`
- Sanitization check results (commands below): each of the three counting greps printed `:0` for both XML files and exited 1; the hostname extraction printed only `hostname="HOST"`. Pass.
- Junit root (repository-wide scope under limit (b)): `tests="6183"`, `failures="0"`, `errors="0"`, `disabled="10"`. Search for `<failure` in the file: count 0.
- Orchestrator-state folder (16 `testsuite` elements whose `name` contains `tests\scripts\claude-lib\orchestrator-state\`):

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

  - Sum tests: 6+46+2+47+29+31+20+41+32+42+31+15+40+37+31+19 = 469; sum failures 0; passed 469.
  - Required: `PS_BASELINE_PASSED` (395) + `PS_UNIT_PASSED` (42) + 32 = 469. Observed 469. Equal.
- Required per-file values: `OrchestratorStateIssueAdoption.Parity.Tests.ps1` (32, 0) observed (32, 0); `OrchestratorStateIssueAdoption.Tests.ps1` (`PS_UNIT_PASSED` = 42 passed, 0 failures) observed (42, 0); `OrchestratorState.Manifest.Tests.ps1` 0 failures observed (6, 0).
- Five transitive-consumer files named in P0-T19:
  - `tests/scripts/claude-hooks/validate-orchestrator-output.Tests.ps1`: tests 27, failures 0 (baseline 27, 0)
  - `tests/scripts/claude-hooks/validate-orchestrator-output.model-routing.Tests.ps1`: tests 6, failures 0 (baseline 6, 0)
  - `tests/scripts/claude-hooks/validate-orchestrator-output.artifact-type-dispatch.Tests.ps1`: tests 17, failures 0 (baseline 17, 0)
  - `tests/scripts/claude-runtime/checkpoint-hygiene-skill-contract.Tests.ps1`: tests 11, failures 0 (baseline 11, 0)
  - `tests/scripts/codex-hooks/codex-epic-runtime-contracts.Tests.ps1`: tests 10, failures 0 (baseline 10, 0)
- Failed-test set across all four folders: empty. `PS_BASELINE_FAILED`: empty. Equal. (The two files that failed in the local P8-T12 MCP run report 0 failures here: `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1` tests 43, failures 0; `tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1` tests 7, failures 0.)
- Line coverage, package `WORKTREE_ROOT/.claude/lib/orchestrator-state` (package element at line 9190, closed at line 10823):
  - `OrchestratorStateIssueAdoption.psm1` (`sourcefile` at line 10253): `<counter type="LINE" missed="0" covered="112" />`. 112 / (0 + 112) = 112 / 112 = 100.0%. Floor 85.0. Pass.
  - `OrchestratorStateRoutingContract.psm1` (`sourcefile` at line 10587, counter at line 10700): `<counter type="LINE" missed="1" covered="110" />`. 110 / (1 + 110) = 110 / 111 = 0.99099 = 99.1%. `PS_ROUTING_BASELINE_LINE` = 99.1% (106 / 107 = 0.99065). 0.99099 >= 0.99065. Pass.
- Changed-line coverage of `OrchestratorStateRoutingContract.psm1`:
  - Diff ref: `origin/epic/orchestrator-state-contract-correctness-integration`. `git log --oneline HEAD..origin/epic/orchestrator-state-contract-correctness-integration -- .claude/lib/orchestrator-state/OrchestratorStateRoutingContract.psm1` printed nothing, so the merge-base fallback was not needed.
  - Added line numbers from the hunk headers (`@@ -8 +8,2 @@`, `@@ -23,0 +25 @@`, `@@ -58,0 +61 @@`, `@@ -412,0 +416,3 @@`, `@@ -413,0 +420 @@`, `@@ -417,0 +425 @@`): 8, 9, 25, 61, 416, 417, 418, 420, 425.
  - Present as `line` elements: 61 (`ci="2"`), 418 (`ci="3"`), 420 (`ci="2"`), 425 (`ci="2"`). Lines 8, 9, 25 (comment-based help) and 416, 417 (comments) are not instrumented.
  - Covered 4, instrumented 4. Changed-line coverage 4 / 4 = 100.0%. Floor 85.0. Pass.
- No PowerShell branch figure exists (Pester does not measure branch coverage).

Result: PASS.

## Sanitization check commands

Timestamp: 2026-09-30T15:07Z

Command: grep -c -E -e "(^|[^A-Za-z])[A-Za-z]:[\\/]" docs/features/active/2026-08-22-promotion-gate-lacks-preexisting-issue-branch-509/evidence/qa-gates/poshqc-local/pester-junit.xml docs/features/active/2026-08-22-promotion-gate-lacks-preexisting-issue-branch-509/evidence/qa-gates/poshqc-local/powershell-coverage.xml
EXIT_CODE: 1
Output Summary: `pester-junit.xml:0`, `powershell-coverage.xml:0`

Command: grep -c -F -e "/home/runner" docs/features/active/2026-08-22-promotion-gate-lacks-preexisting-issue-branch-509/evidence/qa-gates/poshqc-local/pester-junit.xml docs/features/active/2026-08-22-promotion-gate-lacks-preexisting-issue-branch-509/evidence/qa-gates/poshqc-local/powershell-coverage.xml
EXIT_CODE: 1
Output Summary: `pester-junit.xml:0`, `powershell-coverage.xml:0`

Command: grep -c -F -e "<property " docs/features/active/2026-08-22-promotion-gate-lacks-preexisting-issue-branch-509/evidence/qa-gates/poshqc-local/pester-junit.xml docs/features/active/2026-08-22-promotion-gate-lacks-preexisting-issue-branch-509/evidence/qa-gates/poshqc-local/powershell-coverage.xml
EXIT_CODE: 1
Output Summary: `pester-junit.xml:0`, `powershell-coverage.xml:0`

Command: grep -o -h -E -e "hostname=\"[^\"]*\"" docs/features/active/2026-08-22-promotion-gate-lacks-preexisting-issue-branch-509/evidence/qa-gates/poshqc-local/pester-junit.xml | sort -u
EXIT_CODE: 0
Output Summary: `hostname="HOST"` (single unique value)

Note: the Source B branch applies, so the counting greps name only the two XML paths; no `analyzer-output.txt` exists for Source B.

## Git commands

Command: git log --oneline HEAD..origin/epic/orchestrator-state-contract-correctness-integration -- .claude/lib/orchestrator-state/OrchestratorStateRoutingContract.psm1
EXIT_CODE: 0
Output Summary: empty output (no integration-branch change to the file after the merge base).

Command: git diff -U0 origin/epic/orchestrator-state-contract-correctness-integration -- .claude/lib/orchestrator-state/OrchestratorStateRoutingContract.psm1
EXIT_CODE: 0
Output Summary: six hunks; added lines 8, 9, 25, 61, 416, 417, 418, 420, 425 (listed above).
