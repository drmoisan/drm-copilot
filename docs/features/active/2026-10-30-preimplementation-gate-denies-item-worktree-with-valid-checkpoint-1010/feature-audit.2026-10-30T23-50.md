# Feature Audit: Preimplementation gate resolves the target worktree checkpoint (#1010)

---

**Audit Date:** 2026-10-30
**Feature Folder:** `docs/features/active/2026-10-30-preimplementation-gate-denies-item-worktree-with-valid-checkpoint-1010`
**Base Branch:** `main`
**Head Branch:** `bug/preimplementation-gate-item-worktree-1010`
**Work Mode:** `full-bug`
**Audit Type:** Post-remediation acceptance review (remediation cycle 1)

---

## Scope and Baseline

- **Base branch:** `main` (resolved `origin/main` @ `0c0027faefff4231a129579b2a850fe4c377f4e8`)
- **Head branch/commit:** `bug/preimplementation-gate-item-worktree-1010` (commit `54b2b77b1db84a616493e05d6f5d01811823520c`)
- **Merge base:** `0c0027faefff4231a129579b2a850fe4c377f4e8`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt` (refreshed against `main` at the head above)
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`
  - Feature evidence: `docs/features/active/2026-10-30-preimplementation-gate-denies-item-worktree-with-valid-checkpoint-1010/evidence/**`
  - Additional evidence: direct inspection by this review of commit `54b2b77b1`, the LINE counters in `artifacts/pester/powershell-coverage.xml`, `cmp` of each source/bundle pair, logical line counts, `validate_evidence_locations.py` (exit 0), the five push-down contract pytests (45 passed), the Codex generator `--check` (exit 0), and an `Invoke-Pester` re-run of seven suites (323 passed, 0 failed)
- **Feature folder used:** `docs/features/active/2026-10-30-preimplementation-gate-denies-item-worktree-with-valid-checkpoint-1010`
- **Requirements source:** `spec.md` (`## Acceptance Criteria`)
- **Work mode resolution note:** `issue.md` carries the explicit marker `- Work Mode: full-bug` (line 12), so `spec.md` is the only AC source; no `user-story.md` exists or is required.
- **Scope note:** The audit covers the full branch diff against `main`. Remediation cycle 1 added no acceptance criterion; this audit re-verifies all 23 criteria against the new head and confirms that cycle 1 did not regress any of them. No criterion requires the PR-head CI result; the CI run remains owned by the orchestrator S9 gate.

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
| 1 | Phase 0 dependency check | PASS | `evidence/baseline/resolver-dependency.2026-10-30T20-36.md` (Status PRESENT; exports and twin recorded), preceding the production edits in commit `84a345c7d` | Read evidence; `git log` order | Unchanged by cycle 1. |
| 2 | Claude `-c k=v -C` commit leg | PASS | T4 passes; `fail-before-claude-target-worktree.2026-10-30T20-52.md` lists T4 failing before the fix | `Invoke-Pester` over the Claude TargetWorktree suite (this review: 43/43) | |
| 3 | Claude absolute `git add` operand | PASS | T5 passes; B11 adds `git add --pathspec-from-file <value> <abs>` | same | |
| 4 | Claude later-segment `-C` | PASS | T6 passes; B2 asserts extraction | same | |
| 5 | Claude Write/Edit ready/absent/not-ready | PASS | T1, T2, T3 pass; OperandResolution 11/11 including O1, O4, O5, O6 (this review) | `Invoke-Pester` over TargetWorktree and OperandResolution | |
| 6 | Codex Write/Edit leg | PASS | C1, C2, C3 pass; `fail-before-codex-target-worktree.2026-10-30T20-54.md` | `Invoke-Pester` over the Codex target-worktree suite (this review: 47/47) | |
| 7 | Codex Bash leg | PASS | C4, C5, C6 pass; C18 adds `git commit -m msg <abs file>` | same | |
| 8 | Codex `apply_patch` markers | PASS | C7 and C8 pass; fail-before recorded | same | |
| 9 | Ambiguous denial on both surfaces | PASS | T8 (Claude), C8 and C10 (Codex) pass | same | |
| 10 | Not-derivable denial on both surfaces | PASS | T9-T11 (Claude), C11-C13 (Codex) pass | same | |
| 11 | Session-root fallback cases | PASS | T7 and C9 pass; O5 passes; B13 pins the conservative stop at an unmodeled option | same | |
| 12 | Agent delegation unchanged | PASS | `WorktreeResolution.Tests.ps1` absent from the branch diff; 16/16 in `qa-gates/pester-coverage.2026-10-30T21-08.md`; full run 13427 passed, 0 failed (`isolation-single-process.2026-10-30T23-38.md`) | `git diff --name-only 0c0027fae..HEAD`; read evidence | |
| 13 | Strict `lifecycle_ready` | PASS | Both gates use `($Payload.lifecycle_ready -is [bool]) -and $Payload.lifecycle_ready`; gate files unchanged by cycle 1; bundle copies equal (`cmp`, this review); Parity 93/93 (`qa-gates/pester-coverage.2026-10-30T22-27.md`) | Diff inspection; `cmp`; read evidence | |
| 14 | Deny wording byte-identical | PASS | EpicScope (22), EpicScopeTargets (22), Codex `-epic-scope` (54), Codex `-epic-scope-targets` (23) pass in the cycle-1 run; none of those suites is in the diff | `qa-gates/pester-coverage.2026-10-30T22-27.md`; this review re-ran Codex `-epic-scope` (54/54) | |
| 15 | `target-mixed` unchanged | PASS | No `enforce-orchestration-preimplementation-gate-targets.ps1` in any copy appears in the branch diff; `-targets.Parity.Tests.ps1` passes in the full run | `git diff --name-only 0c0027fae..HEAD` | |
| 16 | Selector removed; Codex seam moved | PASS | Claude diff removes `Get-OrchestrationEpicScopeSelector`; Codex `Get-CheckpointContent` in `-epic-scope` with `ValidatePattern`; legacy contracts 43/43 (this review) | Diff inspection; `Invoke-Pester` | |
| 17 | Test isolation | PASS | `isolation-shuffle.2026-10-30T23-38.md` (three seeds, 1353/1353 each, after the last test edit); `isolation-single-process.2026-10-30T23-38.md` (13427 passed, 0 failed); new rows reuse the listing-wrapper mock; the F1 suite starts no process | Read evidence | Run 1 of the full suite found two guard failures caused by cycle-1 tests; both were fixed before run 2. |
| 18 | Bundle parity and resource contracts | PASS | `cmp` equal for all four pairs (this review); five contract pytests 45 passed (this review) | `cmp`; `poetry run pytest ...` | |
| 19 | Pack manifests, generator, guard completeness | PASS | Completeness and dependency-closure pytests pass; generator `--check` exit 0 (this review); `hook-dependency-guard-completeness.Tests.ps1` 671/671 (`qa-gates/pester-coverage.2026-10-30T22-27.md`) | same | No manifest change was needed. |
| 20 | Codex twin (E2) | PASS | `.codex/hooks/hook-target-worktree.ps1` delivered by #1009 exists on the base; consumed under a guard; no twin created | `git diff --name-only`; diff inspection | |
| 21 | File size | PASS | Codex gate 491 logical lines (bundle identical); Codex `-epic-scope` 447 (at or below its 500 pin); every edited file at or below 506 lines; `keeps <File> at or under 500 lines...` passes in the Codex `-epic-scope` suite (this review: 54/54) | Logical line count by this review | |
| 22 | Toolchain and per-file coverage | PASS | Cycle 1: format 0 changes, PSSA 0 findings, Pester 1353/1353; per-file line coverage Claude `-epic-scope` 89.57%, Codex `-epic-scope` 97.01%, Codex gate 88.17% (current artifact, parsed by this review); Claude gate 93.08% in the main-plan suite set (unchanged file; 80.50% in the cycle-1 subset artifact) | LINE counter parse by this review; read evidence | The Claude gate subset figure is a lower bound from a narrower suite set, not a regression; see `code-review.2026-10-30T23-50.md`. |
| 23 | Fail-before / pass-after evidence | PASS | Main plan: three fail-before files and `pass-after-target-worktree.2026-10-30T21-02.md`; cycle 1: `fail-before-claude-operand-options`, `fail-before-codex-operand-options`, `fail-before-exception`, `pass-after-operand-options`; each carries `Timestamp`, `Command`, `EXIT_CODE`, and `Output Summary` | Read evidence | |

### Remediation Findings Verification

| Finding | Status | Evidence |
|---|---|---|
| F1 — duplicated helpers have no enforced parity | RESOLVED | `EpicScopeHelperParity.Tests.ps1`: three parity rows and two negative rows pass (this review: 5/5); `fail-before-exception.2026-10-30T22-17.md` records why the parity rows could not fail on the unmodified tree. |
| F2 — pathspecs after value options not collected | RESOLVED | B10 (eleven cases), B11, B12, B14, B15, T15, and C18 pass on both surfaces; twelve rows per surface failed before the fix (`fail-before-claude-operand-options.2026-10-30T22-18.md`, `fail-before-codex-operand-options.2026-10-30T22-19.md`). |

---

## Summary

**Overall Feature Readiness:** PASS

**Criteria summary:**
- **PASS:** 23 criteria
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 0 criteria
- **FAIL:** 0 criteria

**Top gaps preventing PASS:**

1. None. Non-blocking code-review observations are recorded in `code-review.2026-10-30T23-50.md`.

**Recommended follow-up verification steps:**

1. At S9, confirm the PR-head CI run (including the Linux PowerShell hook-suite job and the Windows coverage shards) concludes `success`.
2. State known limitations R2 (epic `target-mixed`) and R4 (`cd <wt> && git commit`) in the PR description, as `spec.md` requires, together with the remaining parser scope (unmodeled options and clustered short flags stop pathspec collection).

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
| `spec.md` | 23 | 23 | 0 | Checkbox-backed; all 23 were already checked and are confirmed PASS at the post-remediation head. |

No source-file checkbox change was made by this review: every criterion evaluated PASS was already checked.
