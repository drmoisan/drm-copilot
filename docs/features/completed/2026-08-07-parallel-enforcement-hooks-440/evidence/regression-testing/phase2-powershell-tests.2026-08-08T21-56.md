# Phase 2 — PowerShell Tests and Coverage (PoshQC / Pester) — Issue #440 (F7)

Timestamp: 2026-08-08T21-56

Task: [P2-T7]

Branch: `feature/parallel-enforcement-hooks-440`

Command: `mcp__drm-copilot__run_poshqc_test` with `workspace_root = C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a0b28ae2f972ac0ee`

EXIT_CODE: 2

## Raw Result

```json
{
  "ok": false,
  "tool": "run_poshqc_test",
  "workspace_root": "C:\\Users\\DanMoisan\\repos\\drm-copilot\\.claude\\worktrees\\agent-a0b28ae2f972ac0ee",
  "summary": "Command exited with code 2."
}
```

EXIT_CODE 2 is driven entirely by two pre-existing, out-of-scope failures in `.codex` hook suites, both caused by the live gitignored orchestrator checkpoint currently being malformed JSON. No Phase 2 test failed. Attribution is proven below.

Artifact provenance: `artifacts/pester/pester-junit.xml` and `artifacts/pester/powershell-coverage.xml` were both produced by this run.

## Numeric Test Totals

Read from `artifacts/pester/pester-junit.xml` (`testsuites` root attributes):

| Metric | Value |
| --- | --- |
| tests | 2141 |
| failures | 2 |
| errors | 0 |
| time (s) | 108.025 |

Passing tests: 2139 of 2141.

## [P2-T7] Acceptance — Pre-Existing Invocation-Origin Tests Pass Unmodified

| Suite | tests | failures |
| --- | --- | --- |
| `tests/scripts/claude-hooks/enforce-epic-invocation-origin.Tests.ps1` | 27 | **0** |

All 27 tests pass: the 13 pre-existing tests (unmodified — proven by the append-only `git diff` recorded in the [P2-T2] artifact) alongside the 14 new tests in the four appended `Context` blocks. This satisfies the task's stated acceptance criterion.

Phase 1 suites remain green, confirming no regression from the Phase 2 edits:

| Suite | tests | failures |
| --- | --- | --- |
| `tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.Tests.ps1` | 56 | 0 |
| `tests/scripts/claude-hooks/enforce-parallel-worktree-removal-gate.Tests.ps1` | 40 | 0 |

## Baseline Comparison

| Metric | P0-T4 baseline (20-57) | P1-T7 (21-37) | P2-T7 (this run) | Delta vs P1-T7 |
| --- | --- | --- | --- | --- |
| tests | 2031 | 2127 | 2141 | +14 |
| failures | 1 | 1 | 2 | +1 |
| errors | 0 | 0 | 0 | 0 |
| passing | 2030 | 2126 | 2139 | +13 |

The test-count delta is exactly +14, matching the 14 tests [P2-T2] appended. No test was removed or renamed.

## Pre-Existing Failure Set Changed Identity — Full Disclosure

The execution directive anticipated exactly one pre-existing failure, `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1 :: allows gh pr create --body-file artifacts/pr_body_12.md when context exists`. **That test now PASSES (58 of 58, 0 failures), and two different tests now fail instead.** The count moved from 1 to 2. This is disclosed rather than reconciled to the expected number.

Both the old and the new failures are the same defect class: a test that reads the real, gitignored `artifacts/orchestration/orchestrator-state.json` instead of injecting checkpoint content through a mocked read seam. Such tests pass or fail according to the live checkpoint's momentary contents, independent of any code change. The checkpoint's condition changed between the [P1-T7] run and this run, so the membership of the environment-coupled failure set changed with it.

### The Two Failures

| # | Test file | Test case | Message |
| --- | --- | --- | --- |
| 1 | `tests/scripts/codex-hooks/codex-detached-head-transport.Tests.ps1` | `enforce-epic-planning-only.ps1 resolves the current branch on a detached HEAD (issue #415 A1) :: exits 0 with no stdout for a benign Bash payload` | `Expected 0, but got 2.` |
| 2 | `tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1` | `Every registered Codex PreToolUse handler accepts every tool name its matcher admits :: allows every registered handler for every tool name its own matcher admits` | `Expected $null or empty ... but got 'enforce-epic-planning-only.ps1 x Bash: exit=2 stdout=[] stderr=[EPIC_PLANNING_ONLY_BLOCKED: orchestrator checkpoint is malformed JSON: Conversion from JSON failed with error: After parsing a valu...` |

### Root Cause (verified)

The live checkpoint is currently invalid JSON:

```
artifacts/orchestration/orchestrator-state.json
exists: True  size: 9977
JSON: INVALID -> JSONDecodeError Expecting ',' delimiter: line 94 column 5 (char 5718)
```

`.codex/hooks/enforce-epic-planning-only.ps1` line 277 resolves `Join-Path $repositoryRoot 'artifacts/orchestration/orchestrator-state.json'` and line 40 throws `EPIC_PLANNING_ONLY_BLOCKED: $Name is malformed JSON: $_`, exiting 2. Both failing tests invoke that hook while mocking only its git seam (`Invoke-EpicPlanningGit`, `Invoke-CodexChildGuardGit`) and not the checkpoint read, so they inherit the malformed live file. The file is gitignored and is the parent orchestration run's own state; it is not part of this feature's diff and was not written or modified by this task.

### Non-Attribution Proof

1. **No `.codex` file is touched by this feature.** `git status --porcelain | grep -c codex` returns `0`. The complete change set is 5 tracked files (`.claude/hooks/enforce-epic-invocation-origin.ps1`, the two `pester.runsettings.psd1` copies, the invocation-origin test file, and the plan) plus 4 untracked files (the two Phase 1 hooks, their two test files) plus the evidence folder.
2. **Neither failing suite loads anything this feature changed.** The only production files they reference are `.codex/hooks/enforce-epic-child-worktree-binding.ps1` and `.codex/hooks/enforce-epic-planning-only.ps1`. A grep for `invocation-origin` and `runsettings` across both files returns `0` matches each.
3. **The failure is a JSON-parse error on an external gitignored file**, not an assertion about any behavior this feature implements.
4. **Every suite this feature owns or modified passes**: 27/27, 56/56, 40/40, all with 0 failures.

### Disposition

Recorded, not fixed, not treated as a blocker, per the execution directive and the standing project record on these environment-coupled suites. No test file was edited to repair its isolation, and the live checkpoint was not modified to make the tests pass.

## Numeric Coverage Headline

Read from `artifacts/pester/powershell-coverage.xml` (top-level `counter` elements):

| Counter type | covered | missed | total | percentage |
| --- | --- | --- | --- | --- |
| LINE | 3148 | 189 | 3337 | **94.34%** |
| INSTRUCTION (commands) | 4316 | 278 | 4594 | **93.95%** |
| METHOD | 240 | 26 | 266 | 90.23% |
| CLASS | 39 | 2 | 41 | 95.12% |

LINE/COMMAND coverage headline: **94.34% line / 93.95% command**, identical to both the P0-T4 baseline and the P1-T7 run. No coverage regression. Both figures exceed the 85% threshold.

BRANCH: not emitted by PoshQC/Pester coverage output

The document carries exactly four top-level `counter` elements — `INSTRUCTION`, `LINE`, `METHOD`, `CLASS` — and no `BRANCH` counter, verified programmatically (`BRANCH counter present: False`). Line/command coverage is therefore the authoritative PowerShell numeric, and this explicit absence note is the required substitute rather than a placeholder for an available metric (plan Binding Constraint 7).

### Why the Headline Is Unchanged After [P2-T4]

[P2-T4] added the three production hook paths to the two in-repo `pester.runsettings.psd1` copies, but `mcp__drm-copilot__run_poshqc_test` executes the installed extension bundle's `resources/templates/run-poshqc-test.ps1`, which imports the installed bundle's `PoshQC` module and its module-root-relative settings file. The registration therefore takes effect only for runs made from a republished bundle and does not change this run's coverage denominator. Per-file numbers for the three hooks come from [P5-T8]'s dedicated repo-local Pester run, exactly as the plan specifies.

Output Summary: PASS for Phase 2, with a disclosed change in the pre-existing failure set. 2141 tests executed, 2139 passed, 2 failed, 0 errors, 108.025 s. EXIT_CODE 2 is attributable entirely to two pre-existing, out-of-scope failures in `.codex` hook suites (`codex-detached-head-transport.Tests.ps1` and `codex-pretooluse-integration.Tests.ps1`), both caused by `.codex/hooks/enforce-epic-planning-only.ps1` reading the live gitignored `artifacts/orchestration/orchestrator-state.json`, which is currently malformed JSON (JSONDecodeError at line 94, char 5718) and makes the hook exit 2. The directive expected one pre-existing failure in `enforce-pr-author-skill.Tests.ps1`; that test now passes 58 of 58 and two different environment-coupled tests fail instead, so the count moved 1 -> 2. This is the same live-checkpoint isolation defect class, with different membership because the checkpoint's contents changed between runs; it is disclosed rather than reconciled. Non-attribution is proven: zero `.codex` files are touched by this feature, neither failing suite references the invocation-origin hook or the runsettings files, and the failure is a JSON-parse error on an external gitignored file. The [P2-T7] acceptance criterion is met — `enforce-epic-invocation-origin.Tests.ps1` passes 27 of 27, meaning all 13 pre-existing tests pass unmodified alongside the 14 new appended tests — and the Phase 1 suites remain green at 56 of 56 and 40 of 40. Test count rose by exactly the 14 appended tests. Coverage headline: 94.34% line / 93.95% command (LINE covered 3148 / missed 189; INSTRUCTION covered 4316 / missed 278), unchanged from baseline and above the 85% threshold. BRANCH: not emitted by PoshQC/Pester coverage output.
