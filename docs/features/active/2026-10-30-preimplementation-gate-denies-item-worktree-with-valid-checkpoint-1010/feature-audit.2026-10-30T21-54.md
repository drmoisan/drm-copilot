# Feature Audit: Preimplementation gate resolves the target worktree checkpoint (#1010)

---

**Audit Date:** 2026-10-30
**Feature Folder:** `docs/features/active/2026-10-30-preimplementation-gate-denies-item-worktree-with-valid-checkpoint-1010`
**Base Branch:** `main`
**Head Branch:** `bug/preimplementation-gate-item-worktree-1010`
**Work Mode:** `full-bug`
**Audit Type:** Initial acceptance review

---

## Scope and Baseline

- **Base branch:** `main` (resolved `origin/main` @ `0c0027faefff4231a129579b2a850fe4c377f4e8`)
- **Head branch/commit:** `bug/preimplementation-gate-item-worktree-1010` (commit `84a345c7dd8910b8c7a28ce2ffc5958aa3d73877`)
- **Merge base:** `0c0027faefff4231a129579b2a850fe4c377f4e8`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt` (generated 2026-10-30 21:49:46 UTC for the head SHA above)
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`
  - Feature evidence: `docs/features/active/2026-10-30-preimplementation-gate-denies-item-worktree-with-valid-checkpoint-1010/evidence/**`
  - Additional evidence: direct inspection by this review of `artifacts/pester/powershell-coverage.xml`, the production and test diffs, `cmp` of each source/bundle pair, logical line counts, `validate_evidence_locations.py`, the five push-down contract pytests (45 passed), the Codex generator `--check` (exit 0), and an `Invoke-Pester` re-run of seven suites (273 passed, 0 failed)
- **Feature folder used:** `docs/features/active/2026-10-30-preimplementation-gate-denies-item-worktree-with-valid-checkpoint-1010`
- **Requirements source:** `spec.md` (`## Acceptance Criteria`)
- **Work mode resolution note:** `issue.md` carries the explicit marker `- Work Mode: full-bug`, so `spec.md` is the only AC source; no `user-story.md` exists or is required.
- **Scope note:** The audit covers the full branch diff against `main`. No criterion in `spec.md` requires the PR-head CI result; the CI run remains owned by the orchestrator S9 gate.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/2026-10-30-preimplementation-gate-denies-item-worktree-with-valid-checkpoint-1010/spec.md` — only source

### Acceptance criteria

Criteria are numbered AC-1 to AC-23 in source order; full text is in `spec.md` `## Acceptance Criteria`.

1. Phase 0 dependency check: `HookTargetWorktree.psm1` exists and exports `Resolve-HookTargetWorktree` with the required contract; result and Codex-twin status recorded before any production edit.
2. Claude git-commit leg: `git -c k=v -C <wt> commit` reads the item checkpoint and is allowed when ready, with fail-before evidence.
3. Claude git-add leg: `git add <wt>/file` with an absolute operand reads the item checkpoint.
4. Claude later-segment selector: `git -C <wt>` on a later segment reads the item checkpoint.
5. Claude Write/Edit into an item worktree: allowed when ready, denied when absent or not ready; O1 passes; O4, O5, O6 pass after re-mocking.
6. Codex Write/Edit leg reads the item checkpoint, with fail-before evidence.
7. Codex Bash leg (`-c k=v -C`, absolute `git add`, later-segment `-C`) reads the item checkpoint.
8. Codex `apply_patch` resolves each marker path; markers in two worktrees deny as `TARGET_WORKTREE_AMBIGUOUS`, with fail-before evidence.
9. Ambiguous denial on both surfaces.
10. Not-derivable denial (null `WorktreeRoot`) on both surfaces.
11. Outside every worktree, relative operand, or no operand evaluates the session-root checkpoint; O5 passes.
12. Agent delegation resolution unchanged: `WorktreeResolution.Tests.ps1` passes unmodified.
13. Strict `lifecycle_ready` in both gates and bundle copies.
14. Single-feature deny wording byte-identical: existing deny-text suites pass unchanged.
15. Epic-scope `target-mixed` unchanged: `-targets` files not edited; `-targets.Parity.Tests.ps1` passes.
16. `Get-OrchestrationEpicScopeSelector` removed (Claude and bundle); Codex `Get-CheckpointContent` moved with mandatory absolute `-Path`.
17. Test isolation: baseline helper registers the seam; no suite starts `git` or reads a host checkpoint; seeded shuffles and a single-process run pass.
18. Bundle parity; resource-contract pytests pass.
19. Pack-manifest pytests, Codex generator `--check`, and `hook-dependency-guard-completeness.Tests.ps1` pass.
20. Codex twin (E2): consumed if #1009 delivered it, otherwise created with its suite.
21. File size: Codex gate and bundle at or below 500 lines; every edited file at or below 800 lines.
22. Full PowerShell toolchain passes in one pass; each edited production file at or above 85% line coverage.
23. Fail-before and pass-after evidence recorded with `Timestamp`, `Command`, `EXIT_CODE`, and `Output Summary`.

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| 1 | Phase 0 dependency check | PASS | `evidence/baseline/resolver-dependency.2026-10-30T20-36.md` (Status PRESENT, module exports and twin recorded; 166/166 resolver tests); the earlier BLOCKED record `resolver-dependency.2026-10-30T19-49.md` is retained as history. Both precede the production-file modification times (about 20:54-20:57 UTC). | Read evidence; `git log` order | The contract has no `-Command`; the gate parses command text itself (recorded in the evidence). |
| 2 | Claude `-c k=v -C` commit leg | PASS | T4 passes; `fail-before-claude-target-worktree.2026-10-30T20-52.md` lists T4 failing before the fix | `Invoke-Pester` over the Claude TargetWorktree suite (this review: pass) | |
| 3 | Claude absolute `git add` operand | PASS | T5 passes | same | |
| 4 | Claude later-segment `-C` | PASS | T6 passes; B2 asserts extraction | same | |
| 5 | Claude Write/Edit ready/absent/not-ready | PASS | T1 (Write, Edit), T2, T3 pass; OperandResolution 11/11 including O1, O4, O5, O6 | `Invoke-Pester` over TargetWorktree and OperandResolution (this review: pass) | O4-O6 now use the listing-wrapper mock. |
| 6 | Codex Write/Edit leg | PASS | C1, C2, C3 pass; `fail-before-codex-target-worktree.2026-10-30T20-54.md` | `Invoke-Pester` over the Codex target-worktree suite (this review: pass) | |
| 7 | Codex Bash leg | PASS | C4, C5, C6 pass | same | |
| 8 | Codex `apply_patch` markers | PASS | C7 (absolute marker in a ready item worktree) and C8 (two worktrees deny `TARGET_WORKTREE_AMBIGUOUS`) pass; fail-before recorded | same | |
| 9 | Ambiguous denial on both surfaces | PASS | T8 (Claude), C8 and C10 (Codex) pass | same | |
| 10 | Not-derivable denial on both surfaces | PASS | T9-T11 (Claude), C11-C13 (Codex) pass | same | T11/C13 mock a null-root resolver result; T9/T10 and C11/C12 cover listing failure. |
| 11 | Session-root fallback cases | PASS | T7 and C9 (three labels each) pass; O5 passes | same | |
| 12 | Agent delegation unchanged | PASS | `WorktreeResolution.Tests.ps1` absent from the branch diff; 16/16 (`pester-coverage.2026-10-30T21-08.md`; re-run by this review: pass) | `git diff --name-only 0c0027fae..HEAD`; `Invoke-Pester` | |
| 13 | Strict `lifecycle_ready` | PASS | Both gates use `($Payload.lifecycle_ready -is [bool]) -and $Payload.lifecycle_ready`; bundle copies equal; four new Parity readiness rows pass on both surfaces (Parity 93/93, this review); T12 and C14 deny `"false"`; `fail-before-readiness-parity.2026-10-30T20-55.md` | Diff inspection; `cmp`; `Invoke-Pester` | |
| 14 | Deny wording byte-identical | PASS | EpicScope (22), EpicScopeTargets (22), Codex `-epic-scope` (54), Codex `-epic-scope-targets` (23) pass; none of those suites is in the diff; the Codex single-feature deny literal is unchanged in the diff | `pester-coverage.2026-10-30T21-08.md`; diff inspection | |
| 15 | `target-mixed` unchanged | PASS | No `enforce-orchestration-preimplementation-gate-targets.ps1` in any copy appears in the branch diff; `-targets.Parity.Tests.ps1` 3/3 | `git diff --name-only 0c0027fae..HEAD` | |
| 16 | Selector removed; Codex seam moved | PASS | Claude diff removes `Get-OrchestrationEpicScopeSelector`; Codex gate diff removes parameterless `Get-CheckpointContent`; Codex `-epic-scope` adds it with `ValidatePattern`; `$script:CodexOnlyGateFunction` updated; legacy contracts 43/43 | Diff inspection; `Invoke-Pester` (this review: pass) | |
| 17 | Test isolation | PASS | `EpicStateIsolation.Baseline.Helpers.ps1` registers a script-scope mock of `Get-OrchestrationGateWorktreeList` (T14, C17); `isolation-shuffle.2026-10-30T21-16.md` (three seeds, 1618/1618 each); `isolation-single-process.2026-10-30T21-29.md` (13387 passed, 0 failed) | Read evidence | The helper registers a script-scope mock rather than a `$script:EpicStateBaselineModuleSeam` entry, because the wrapper is a gate script function; recorded as a deviation and consistent with the criterion's intent. |
| 18 | Bundle parity and resource contracts | PASS | `cmp` equal for all four pairs (this review); resource-contract pytests pass (45 total over five modules, this review) | `cmp`; `poetry run pytest ...` | |
| 19 | Pack manifests, generator, guard completeness | PASS | Completeness and dependency-closure pytests pass; generator `--check` exit 0 (this review); `hook-dependency-guard-completeness.Tests.ps1` 671/671 | same; `pester-coverage.2026-10-30T21-08.md` | No manifest change was needed. |
| 20 | Codex twin (E2) | PASS | `.codex/hooks/hook-target-worktree.ps1` delivered by #1009 exists on the base; the Codex `-epic-scope` file dot-sources it under a guard; no twin file is created by this branch | `git diff --name-only`; diff inspection | Consumption branch of E2. |
| 21 | File size | PASS | Codex gate 491 logical lines (bundle identical); `keeps <File> at or under 500 lines...` row in the Codex `-epic-scope` suite passes (54/54); all edited files at or below 506 lines | Logical line count by this review | |
| 22 | Toolchain and per-file coverage | PASS | Format 0 changes, PSSA 0 findings, Pester 1618/1618; per-file line coverage 93.08%, 96.74%, 88.17%, 96.40% (re-read from `artifacts/pester/powershell-coverage.xml`) | JaCoCo parse by this review | |
| 23 | Fail-before / pass-after evidence | PASS | Three fail-before files and `pass-after-target-worktree.2026-10-30T21-02.md` under `evidence/regression-testing/`, each with `Timestamp`, `Command`, `EXIT_CODE`, and `Output Summary` | Read evidence | |

---

## Summary

**Overall Feature Readiness:** PASS

**Criteria summary:**
- **PASS:** 23 criteria
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 0 criteria
- **FAIL:** 0 criteria

**Top gaps preventing PASS:**

1. None. Non-blocking code-review observations are recorded in `code-review.2026-10-30T21-54.md`.

**Recommended follow-up verification steps:**

1. At S9, confirm the PR-head CI run (including the Linux PowerShell hook-suite job) concludes `success`.
2. State known limitations R2 (epic `target-mixed`) and R4 (`cd <wt> && git commit`) in the PR description, as `spec.md` requires.

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules:
- Criteria evaluated as **PASS** may be checked off in the authoritative source file(s) if they are represented as markdown checkboxes and are not already checked.
- Criteria evaluated as **PARTIAL**, **FAIL**, or **UNVERIFIED** must remain unchecked.
- If the source uses prose or numbered requirements instead of checkbox items, do not rewrite the source file; record status only in this audit.

### AC Status Summary

- Source: `docs/features/active/2026-10-30-preimplementation-gate-denies-item-worktree-with-valid-checkpoint-1010/spec.md`
- Total AC items: 23
- Checked off (delivered): 23
- Remaining (unchecked): 0
- Items remaining: none

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `spec.md` | 23 | 23 | 0 | Checkbox-backed; all 23 were already checked by the executor and are confirmed PASS here. |

No source-file checkbox change was made by this review: every criterion evaluated PASS was already checked.
