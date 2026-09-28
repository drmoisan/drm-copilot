# Code Review: Gate-suite epic-state isolation (#709)

---

**Review Date:** 2026-09-27
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/gate-suites-read-unmocked-local-epic-state-709`
**Feature Folder Selection Rule:** The only active feature folder changed on the branch; its suffix matches issue 709 in the branch name.
**Base Branch:** `origin/main` (`849aae609787172240c1ae7c33d10d6dd337d497`, also the merge base)
**Head Branch:** `bug/gate-suites-read-unmocked-local-epic-state-709` (`52212212be05b6012d13eacec8198f27d12d9242`)
**Review Type:** Initial review

---

## Executive Summary

The branch fixes a test-hermeticity defect. Seven Pester suites for the gate-1 (`enforce-pr-author-skill`), gate-3 (`enforce-model-routing-receipt`), and gate-4 (`enforce-orchestration-preimplementation-gate`) hooks reached `Resolve-EpicScopeCheckpoint` without mocking `Get-EpicScopeCheckpointText`, so a gitignored `artifacts/orchestration/epic-orchestrator-state.json` at the checkout root could change their outcomes. The diff is 44 files: 36 Markdown files in the feature folder, 7 suites with 2 inserted lines each, and 1 new 432-line test file. No production file, hook, library, push-down mirror, workflow, or settings file is touched. The branch is current with `origin/main` (0 commits behind after `git fetch origin main`), and the sibling items #707, #708, #710, and #713 are already merged into `origin/main`, so the D6 merge-conflict risk no longer applies.

Evidence reviewed: the full branch diff, the new file line by line, the three hooks' module-import sites, `EpicScopeResolution.psm1` lines 110-369, the executor's fail-before, pass-after, before/after count, QA-loop, coverage, scope, and hermeticity records, and the coverage report `artifacts/pester/powershell-coverage.xml`. The implementation matches the spec (D1-D10) and is clean. The guard can fail: the fail-before record shows exactly seven failing structural rows, each naming its suite, and six predicate rows show that each non-compliant shape is rejected.

**What changed:**
Each of the seven suites gets `Import-Module <.claude>/lib/worktree-resolution/EpicScopeResolution.psm1` (no `-Force`) and `Mock Get-EpicScopeCheckpointText -ModuleName EpicScopeResolution { $null }` in its outermost `BeforeAll`, directly after the hook dot-source (gate-4 and gate-1 TargetResolution) or after the library imports that follow the hook dot-source (the two WorktreeResolution suites). The new file `tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Tests.ps1` parses those suites with `Parser::ParseFile` and checks mock target, module scope, `$null` body, placement in the outermost `BeforeAll`, no `-Force` on the import, and dot-source/import/mock order. It also shows at the resolver level, with a hostile in-memory payload, that the `$null` mock blocks the checkpoint read and the HEAD and `MERGE_HEAD` probes for all four gate call shapes.

**Top 3 risks:**
1. Whether the mock binds correctly inside the seven suites is shown only indirectly. The guard checks structure, and the seam proof imports its own module instance with `-Force`. No row in any edited suite asserts that the mock intercepts the call (CR-1).
2. A future suite that reaches `Resolve-EpicScopeCheckpoint` is not covered by the explicit seven-path list (D9, approved).
3. A few guard edge cases could pass incorrectly: the ordering check uses the first dot-source rather than the hook dot-source, and the search descends into nested script blocks (CR-2).

**PR readiness recommendation:** **Go**: no Blocking or Major finding. Toolchain and regression evidence are complete, and the only open acceptance item (the AC4 CI half) runs after the PR opens.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Minor | `tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Tests.ps1` | lines 190-205, 369-432 | CR-1: No test shows that the mock is effective inside the seven edited suites. The structural rows check placement, and the seam rows prove sufficiency against a module instance that this file imports with `-Force`. By inspection, binding is correct: each hook imports `EpicScopeResolution.psm1` with `-Force` only at dot-source time, each suite's import follows that dot-source, and no suite re-imports or re-dot-sources the hook later. | Optional follow-up: add one assertion per gate family, for example `Should -Invoke Get-EpicScopeCheckpointText -ModuleName EpicScopeResolution` in an existing reaching row, or record one manual run with a hostile local epic checkpoint whose `integration_branch` equals HEAD. | Placement without binding would leave the defect in place while the guard passes. The spec (Risks) acknowledges that this is only detected indirectly. | `.claude/hooks/enforce-pr-author-skill-helpers.ps1:48`, `.claude/hooks/enforce-model-routing-receipt.ps1:55`, `.claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1:30`; reviewer grep of the seven suites for later `Import-Module`/`UnderTest` dot-sources found none; `evidence/baseline/pester-root-beforeall-mock-probe.2026-09-27T09-59.md` |
| Minor | `tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Tests.ps1` | lines 130, 146, 159-164 | CR-2: The guard orders against the first dot-source anywhere in the outermost `BeforeAll`, not the hook dot-source, and `FindAll(..., $true)` also finds `Mock`/`Import-Module` inside nested script blocks, such as a function body defined in the `BeforeAll` that never runs. Either case would pass the guard incorrectly. | Optional hardening: limit the search to direct statements of the `BeforeAll` script block, and match the dot-source target text against the hook name or `$script:UnderTest`/`hooks/` form. | Low likelihood in practice, but the guard is the regression barrier for this defect. | Code inspection of `Get-EpicStateIsolationFinding` |
| Info | `tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Tests.ps1` | lines 108-165 | CR-3: The guard branches for "no outermost BeforeAll", parse error (lines 180-183), and "Import-Module absent while the mock is present" have no dedicated predicate row. The fail-before run exercises the import-absent message together with the mock-absent message. | Optional: add three predicate rows. | Test-helper branches are outside the coverage denominator, so this is not a coverage-policy gap. | `evidence/regression-testing/fail-before.2026-09-27T10-09.md` |
| Info | `tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Tests.ps1` | lines 190-199 | CR-4: The D9 explicit seven-path list does not guard a future suite that reaches the resolver. This is a known, approved limit, stated in the file header and in `evidence/other/follow-ups.md`. | Extend the list when a new gate-1/3/4 suite is added (deferred follow-up). | The guard detects removal or corruption of the mock in the seven listed suites, but not omission in new suites. | `spec.md` D9; file header lines 19-21 |
| Info | `tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Tests.ps1` | line 372 | CR-5: `Import-Module ... -Force` replaces the global `EpicScopeResolution` instance for the rest of the Pester session. Later suites re-import it through their hook dot-sources, and the full configured run (5452 passed, 0 failed) shows no ordering interference. | None required. | Recorded so that a future ordering-dependent failure can be traced here. | `evidence/qa-gates/pester-full.2026-09-27T10-20.md` |
| Info | `tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Tests.ps1` | lines 359-367 | CR-6: `BeforeDiscovery` comes after the first `Describe`. It is valid in Pester 5, but readers usually expect discovery data at the top of the file. | Optional: move `BeforeDiscovery` above the first `Describe` in a later touch. | Readability only. | Code inspection |
| Info | `tests/scripts/claude-hooks/enforce-pr-author-skill.WorktreeResolution.Tests.ps1`, `tests/scripts/claude-hooks/enforce-model-routing-receipt.WorktreeResolution.Tests.ps1` | `BeforeAll` comment above the imports | CR-7: The existing comment says the suite imports "the three library modules" without `-Force`. It now imports four. The spec forbids changing existing lines. | Update the comment in a later change to either suite. | Comment accuracy. | `enforce-pr-author-skill.WorktreeResolution.Tests.ps1:43-51` |
| Info | seven edited suites | `BeforeAll` | CR-8: The suites still run the `Find-WorktreeResolutionRoot` ascent against the real filesystem (it reads `.git` entries, not gitignored state). With the text seam returning `$null`, the outcome cannot change (D10). | None required. | This confirms the residual filesystem access has no effect on outcomes. | `EpicScopeResolution.psm1:318-326`; `spec.md` D10 |
| Info | process (no file in diff) | `evidence/regression-testing/batch-b2-suites.2026-09-27T10-11.md`, `batch-b3-suites.2026-09-27T10-13.md` | CR-9: The executor deleted the batch-budget state file `.claude/state/powershell-batch-budget.*.json` twice to clear denials that carried over from the previous batch, and retried each write once. The plan's Batch Budget section sanctions this. No hook file changed, the cap was not raised, and each batch held at most three test files. | Follow-up: give `.claude/hooks/enforce-powershell-batch-budget.ps1` a batch-boundary reset so plans do not need to delete state files. | This is a process workaround, not a code-level hook bypass. It is recorded because it is a recurring pattern. | Plan section "Batch Budget" (line 219) |
| Info | feature evidence | `evidence/other/artifact-timestamp-correction.2026-09-27T10-12.md`; `evidence/baseline/phase0-instructions-read.md` | CR-10: Eleven artifacts first carried estimated timestamps and were renamed to their file modification times, with the correction recorded. One baseline artifact has no timestamp in its file name. | None required for merge. | Evidence integrity: the correction is documented and the run order is preserved. | Cited artifacts |

No Blocking or Major findings.

---

## Implementation Audit

### PowerShell implementation audit

#### What changed well

- The seven suite edits are minimal, additive, and identical in form. Each is one contiguous two-line hunk anchored after the hook load, with 0 deletions (numstat `2 0` for all seven).
- `$null` reproduces the CI condition (no file present) and short-circuits at `EpicScopeResolution.psm1:324-326`, before the HEAD and `MERGE_HEAD` probes, so the unchanged suite counts are expected by design.
- The seam proof has non-vacuity controls. Each control row asserts `IsEpicScope = $true` and exactly one read of `*epic-orchestrator-state.json`, so the treatment assertions cannot pass without the mock doing its job.
- The guard binds `Mock` arguments both by name and by position, which covers both compliant forms used in the repository.
- The file follows its own hermeticity contract. It reads only committed files located from `$PSScriptRoot`, and every synthetic root uses the `/synthetic-worktrees/` form.

#### API and safety notes

- No production API or hook contract is changed, so no enforcement surface is weakened. The spec rejected the production-seam alternative (D1c) specifically to avoid adding a bypass surface to T1-class enforcement code.
- Helper functions use approved verbs, `[OutputType]`, and `Mandatory` parameters. The one analyzer suppression (`PSUseShouldProcessForStateChangingFunctions` on `Set-HostileEpicSeam`) has a written justification. PSScriptAnalyzer reports 0 findings.

#### Error handling and logging

- An absent suite file or a parse error becomes a named finding instead of a thrown exception, so the failing row identifies the suite and the cause.

---

## Test Quality Audit

The regression design is sound and the evidence chain is complete: baseline counts, fail-before (7 failed, 17 passed), pass-after (24 passed), per-suite before/after equality for all ten listed suites, the full configured run, and a coverage comparison. The reviewer read the coverage values directly from the report.

### Reviewed test and QA artifacts

- `tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Tests.ps1`: structural guard (7 rows), predicate discrimination (9 rows), seam sufficiency (4 control and 4 treatment rows). All 24 pass.
- `evidence/regression-testing/fail-before.2026-09-27T10-09.md`: before any suite edit, exactly the seven structural rows failed, each naming its suite and "missing from outermost BeforeAll". This shows the guard can fail.
- `evidence/regression-testing/pester-targeted-after.2026-09-27T10-14.md`: Passed/Failed/Skipped equal for S1-S7 and the three EpicScope suites.
- `evidence/qa-gates/pester-full.2026-09-27T10-20.md`: 5452 passed, 0 failed, 9 skipped (baseline 5428/0/9; +24 from the new file).
- `evidence/qa-gates/coverage-epic-scope.2026-09-27T10-20.md` and `artifacts/pester/powershell-coverage.xml`: `EpicScopeResolution.psm1` 90.38% to 91.35% lines; repo-wide 96.04% lines (10224 of 10646).
- `evidence/qa-gates/hermeticity-scan.2026-09-27T10-20.md`: 0 matches. The reviewer repeated the scan with a wider pattern set and found only payload strings and the header comment.

### Quality assessment prompts

- **Determinism:** Every filesystem seam is mocked in the seam proof, and the structural guard reads committed files only. No clock, RNG, or sleep.
- **Isolation:** One behavior per row. Hostile mocks are registered inside each `It`.
- **Speed:** The full run took 176.68 s, compared with 174.28 s at baseline, for 24 additional rows.
- **Diagnostics:** Messages carry the suite path and the specific missing property.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | Test files hold only synthetic payloads. |
| No unsafe subprocess or command construction | ✅ PASS | No process spawn. The `git`/`gh` strings are resolver input text only. |
| Input validation at boundaries | ✅ PASS | Guard helpers validate AST node types before they use them. |
| Error handling remains explicit | ✅ PASS | Parse errors and absent files become findings. |
| Configuration / path handling is safe | ✅ PASS | Paths are built from `$PSScriptRoot` with `Resolve-Path`/`Join-Path`. There are no drive letters or backslash literals. |
| No enforcement-hook weakening or bypass | ✅ PASS | No file under `.claude/hooks/`, `.claude/lib/`, `.codex/`, or `extensions/` changed. The batch-budget state resets are a sanctioned process step (CR-9), not a code change. |

---

## Research Log

No external research was required. Pester 5 behavior (a `BeforeAll`-scoped mock applying to child blocks, and `-ModuleName` injection) was confirmed from the executor's in-memory probe (`evidence/baseline/pester-root-beforeall-mock-probe.2026-09-27T09-59.md`, Pester 5.6.1) and from the existing precedent suites.

---

## Verdict

The change is ready for the normal PR flow. It delivers the spec's design exactly, with minimal diffs in the seven suites and a regression file whose ability to fail is demonstrated. It changes no production or enforcement code. The two Minor findings (CR-1, indirect proof that the mock binds; CR-2, guard edge cases that could pass incorrectly) do not block merge and are listed as optional follow-ups. AC4's CI half is pending the PR-head `windows-latest` PoshQC job.

### Deferred and out-of-scope items (for follow-up recording)

1. AC4 second half: CI `windows-latest` PoshQC job on the PR head, depth-1 checkout (plan tasks P5-T19, P5-T20). Pending CI; non-blocking.
2. D8: verify and, if needed, isolate the relative-path epic-checkpoint reads in the suites for `.claude/hooks/enforce-epic-merge-gate.ps1`, `.claude/hooks/enforce-epic-worktree-removal-gate.ps1`, `.claude/hooks/enforce-epic-wave-barrier.ps1`, and `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1`.
3. D9 / CR-4: extend the structural guard's path list when a new gate-1/3/4 suite that reaches `Resolve-EpicScopeCheckpoint` is added, or replace the list with discovery-based reach detection.
4. CR-1: optional in-suite assertion (or recorded manual run) proving that the mock intercepts inside the seven suites.
5. CR-2: optional guard hardening (direct-statement search; match against the hook dot-source).
6. CR-3: optional predicate rows for the no-`BeforeAll`, parse-error, and import-only-absent branches.
7. CR-7: update the stale "three library modules" comment in the two WorktreeResolution suites.
8. CR-9: batch-boundary reset for `.claude/hooks/enforce-powershell-batch-budget.ps1` so plans do not need to delete state files.
9. D5 (out of scope): Codex hook suites. No `.codex` hook uses `EpicScopeResolution`; epic scope for Codex gates 4 and 5 was handled by #707.
