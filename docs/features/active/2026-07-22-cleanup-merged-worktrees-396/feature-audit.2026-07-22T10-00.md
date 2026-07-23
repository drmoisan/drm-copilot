# Feature Audit: cleanup-merged-worktrees (#396) — Remediation Cycle 1 Re-audit

---

**Audit Date:** 2026-07-22
**Feature Folder:** `docs/features/active/2026-07-22-cleanup-merged-worktrees-396/`
**Base Branch:** `main`
**Head Branch:** `drm-copilot-wt-2026-07-21T21-57`
**Work Mode:** `full-feature`
**Audit Type:** Remediation cycle 1 acceptance re-audit (prior audit: `feature-audit.2026-07-22T09-23.md`)

---

## Scope and Baseline

- **Base branch:** `main` (commit `b2351cbc3fb3916f516d77567a1c9e40457c8981`)
- **Head branch/commit:** `drm-copilot-wt-2026-07-21T21-57` (commit `75aee760010d863a3a448766fe4b348440e58acb`)
- **Merge base:** `b2351cbc3fb3916f516d77567a1c9e40457c8981`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt` (fresh: resolved head matches current branch head `75aee760`)
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt` and direct `git diff b2351cbc..HEAD` inspection
  - Feature evidence: `docs/features/active/2026-07-22-cleanup-merged-worktrees-396/evidence/{baseline,qa-gates,remediation-baseline,regression-testing}/`
  - CI evidence: run 29924839016 (failure at `69188347` — the remediated defect), run 29925971964 (success at `9876def8`, 14/14 jobs), run 29926167798 (success at the exact head `75aee760`), run 29922832766 (shell-coverage green at `4851f3c9`); all verified via `gh run view`/`gh run list`
  - Reviewer re-runs this cycle: bundle contract tests (`poetry run pytest`, 9/9, exit 0), byte-identity check (`git diff --no-index`, exit 0), `core.json` parse/occurrence/position check, evidence-location validator (exit 0)
- **Feature folder used:** `docs/features/active/2026-07-22-cleanup-merged-worktrees-396/` (single active folder matching issue #396)
- **Requirements source:** `spec.md` and `user-story.md` (both authoritative for `full-feature` per the explicit `- Work Mode: full-feature` marker in `issue.md`)
- **Scope note:** Full branch diff versus `main` (133 files, +3780/-0). Remediation cycle 1 delta (`69188347..75aee760`): the bundled skill mirror, one `core.json` manifest line, and docs/evidence. No shell, Python, TypeScript, PowerShell, or C# source changed in the remediation delta, so the prior audit's per-criterion code evidence remains current; this re-audit re-verifies the remediated defect and re-confirms each criterion's standing.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/2026-07-22-cleanup-merged-worktrees-396/spec.md` — primary source (`## Acceptance Criteria`)
- `docs/features/active/2026-07-22-cleanup-merged-worktrees-396/user-story.md` — co-authoritative source (`## Acceptance Criteria`, identical AC1-AC8 text)

### Acceptance criteria

1. AC1: The bash script deterministically classifies and lists worktrees/branches merged into `main` with no residual commits (`MERGED_CLEAN`) as safe to auto-delete, using `git merge-base --is-ancestor` exit-code semantics (0 merged, 1 not merged, >1 error) over branches enumerated with `git for-each-ref refs/heads/` and worktrees enumerated with `git worktree list --porcelain`.
2. AC2: The bash script deterministically classifies merged branches with residual commits, distinguishing content-already-on-main (droppable via the ladder: branch-level `git diff --quiet main...<branch>` short-circuit, `git cherry` patch-id equivalence, rename-aware blob-OID comparison) from unique content (emitted as CHERRY_PICK_CANDIDATE entries with SHA, paths, author, date). Commit-message text matching is never a classification input.
3. AC3: The script never selects the current worktree or current branch for any destructive action, verified through both `git rev-parse --abbrev-ref HEAD` (branch) and `git rev-parse --show-toplevel` (path) against the porcelain worktree list; the main worktree is always excluded.
4. AC4: The CLI supports exactly two modes: a dry-run/report mode as the default (no mutation, deterministic machine-parseable output) and an explicit apply mode that performs deletion/consolidation for delete-eligible states only.
5. AC5: Deletion in apply mode follows the fixed order — same-process ancestry/equivalence re-verification, then `git worktree remove` without `--force` (dirty worktrees block deletion and are reported, never forced), then `git branch -D` — and deletion of branches with consolidated unique content occurs only after the consolidation PR is verified merged via a git-native ancestry re-check.
6. AC6: Consolidation cherry-picks all flagged unique documentation/memory commits, across an arbitrary number of stranded branches, onto a single `documentationandmemories` branch created off `main` in a dedicated worktree (never the caller's worktree), oldest-first per branch with `git cherry-pick -x`, branches in `LC_ALL=C` order; conflicts abort-and-surface rather than auto-resolve; a pre-existing `documentationandmemories` branch stops the run with a report.
7. AC7: The skill documents the cherry-pick-to-`documentationandmemories`-then-PR-then-delete workflow end to end, delegating PR creation exclusively to `Agent(pr-author)` (no direct `gh pr create` anywhere in the skill or script).
8. AC8: Unit tests (bats, `tests/shell/`, git-binary stub seam, no temp files, no scratch git repos) cover at minimum: merged branch without a worktree, merged branch with a worktree, unmerged branch (excluded), merged branch with a residual commit whose content already exists on `main`, merged branch with a residual unique documentation commit, and current-worktree/branch exclusion.

---

## Acceptance Criteria Evaluation

The implementation files backing every criterion are byte-identical to those evaluated in `feature-audit.2026-07-22T09-23.md` (no shell or skill source changed in the remediation delta; verified with `git diff 69188347..HEAD --name-only`). Each criterion's detailed code-and-test evidence in the prior audit therefore remains valid; the table below records the re-audit disposition, including the remediation-relevant re-verification.

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| 1 | AC1 — MERGED_CLEAN classification via ancestry exit codes over plumbing enumeration | PASS | Implementation unchanged since prior PASS evaluation (`cleanup_worktrees_lib.sh` untouched in remediation delta); bats scenarios `merged_no_worktree`, `merged_with_worktree`, `ancestry_error` green in CI runs 29922832766 and 29925971964 (`shell-coverage` job). | `git diff 69188347..HEAD --name-only` (no shell files); `gh run view 29925971964 --json jobs` | Prior audit's detailed line-level evidence stands. |
| 2 | AC2 — residual-commit ladder; no message matching | PASS | Implementation unchanged; ladder tests (`content_neutral`, `residual_on_main`, `residual_unique_doc`) green in the same CI runs; prior grep verification (no `git log`/`--grep`) still applies to identical file content. | Same as AC1 | Prior audit evidence stands. |
| 3 | AC3 — dual current-exclusion; main worktree always excluded | PASS | Implementation unchanged; `current_exclusion` and protection tests green. | Same as AC1 | Prior audit evidence stands. |
| 4 | AC4 — exactly two modes; report default no-mutation; apply eligible-only | PASS | Implementation unchanged; CLI suite (5 tests) green. | Same as AC1 | Prior audit evidence stands. |
| 5 | AC5 — fixed deletion order, no-force, dirty block, consolidation merge gate | PASS | Implementation unchanged; deletion suite (6 tests) green. CR-1 (Major, non-blocking robustness follow-up) carried forward unchanged. | Same as AC1 | Prior audit evidence stands. |
| 6 | AC6 — consolidation onto single branch in dedicated worktree; -x, ordering, conflict abort, pre-existing-branch stop | PASS | Implementation unchanged; consolidation suite (6 tests) green. | Same as AC1 | Prior audit evidence stands. |
| 7 | AC7 — skill documents end-to-end workflow; PR creation exclusively via Agent(pr-author) | PASS | Repo SKILL.md unchanged since prior PASS. Remediation cycle 1 additionally mirrored the skill byte-identically into the bundled payload (`extensions/drm-copilot/resources/claude-customizations/.claude/skills/cleanup-merged-worktrees/SKILL.md`) and registered it in `pack-manifests/core.json`, making the skill deliverable through the extension bundle — the missing mirror was the cycle-1 Blocking CI failure, now resolved. | `git diff --no-index <repo skill> <bundled skill>` -> exit 0; `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py` -> 9 passed | The mirror inherits the prior content review; identical prohibition text and narrow `allowed-tools`. |
| 8 | AC8 — bats unit tests covering the six mandated scenarios; no temp files; no scratch repos | PASS | Test suites and fixtures unchanged; 80/80 green in CI runs 29922832766 and 29925971964; bash line coverage 89.0% (measurement current — no shell delta). | `gh run view 29925971964 --json jobs` (shell-coverage: success) | Prior audit evidence stands. |

**Remediated defect re-verification (not an AC, but the cycle-1 exit condition):** the CI required check `quality-checks7 / Code Quality & Tests (3.12)` that failed at `69188347` (run 29924839016) is green in run 29925971964 at `9876def8` alongside the full 3.10–3.13 matrix, and the full CI run at the exact head `75aee760` (run 29926167798) completed with conclusion success during this re-audit. The previously failing test `test_bundled_claude_payload_contains_all_repo_runtime_contracts` passes locally (reviewer re-run, exit 0). **RESOLVED.**

---

## Summary

**Overall Feature Readiness:** PASS

**Criteria summary:**
- **PASS:** 8 criteria
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 0 criteria
- **FAIL:** 0 criteria

**Remediation cycle 1 outcome:** the single Blocking finding (missing bundled-payload mirror) is resolved and verified through byte-identity inspection, local contract-test re-run, and green CI at both branch-head content (`9876def8`, run 29925971964) and the exact head (`75aee760`, run 29926167798). No new blockers were introduced; the remediation delta is scope-disciplined (two payload files plus docs/evidence).

**Top gaps preventing PASS:**

1. None.

**Recommended follow-up verification steps:**

1. File a follow-up hardening issue for code-review finding CR-1 (dead or-capture assignments inside process substitutions in `cleanup_worktrees_lib.sh`; add a fixture simulating a `git cherry` hard failure and propagate a hard-error verdict). Carried forward from the prior audit; unchanged.
2. On the first real-world run, execute report mode against the live repository (a known `MERGED_CLEAN` candidate exists: branch `drm-copilot-wt-2026-07-21T17-20`, PR #394 merged) and confirm the report matches manual ancestry checks before any `--apply`. Carried forward from the prior audit.
3. Optional process improvement (code-review RR-1): add an authoring-time check for the `.claude/**` to bundled-payload mirror so future skill additions do not repeat this cycle's CI failure.

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules:
- Criteria evaluated as **PASS** may be checked off in the authoritative source file(s) if not already checked.
- All eight criteria were already checked (`- [x]`) in both `spec.md` and `user-story.md` (checked by the executor during plan execution and independently confirmed by the prior audit). This re-audit re-verified the checkbox state (`grep -n "\- \["` over both files: all eight AC items `[x]` in each) and re-confirmed each criterion as PASS. No source-file changes were required or made by this re-audit.

### AC Status Summary

- Source: `docs/features/active/2026-07-22-cleanup-merged-worktrees-396/spec.md`, `docs/features/active/2026-07-22-cleanup-merged-worktrees-396/user-story.md`
- Total AC items: 16 (8 per source file; identical text)
- Checked off (delivered): 16
- Remaining (unchecked): 0
- Items remaining: None.

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `spec.md` | 8 | 8 | 0 | Checkbox-backed; all pre-checked, re-confirmed PASS by this re-audit |
| `user-story.md` | 8 | 8 | 0 | Checkbox-backed; all pre-checked, re-confirmed PASS by this re-audit |

No source-file checkbox change was made because every PASS criterion was already checked; this re-audit's role was independent re-confirmation after remediation cycle 1.
