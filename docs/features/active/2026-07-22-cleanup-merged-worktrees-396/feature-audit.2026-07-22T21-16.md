# Feature Audit: cleanup-merged-worktrees (#396) — Remediation Cycle 2 Re-audit

---

**Audit Date:** 2026-07-22
**Auditor:** feature-review agent (Claude Code)
**Audit Type:** Remediation cycle 2 re-audit (prior audits: `feature-audit.2026-07-22T09-23.md`, `feature-audit.2026-07-22T10-00.md`)

---

## Scope and Baseline

- **Base branch (resolved):** `main` (`origin/main @ a9cea834`; caller-supplied and confirmed by PR-context artifacts)
- **Merge base:** `b2351cbc3fb3916f516d77567a1c9e40457c8981`
- **Head:** `drm-copilot-wt-2026-07-21T21-57 @ 921b5c401e5049b69a45544285daeb91d137ea84`
- **Range:** `b2351cbc..921b5c40` — 178 files, +5078/-0
- **PR-context artifacts:** `artifacts/pr_context.summary.txt`, `artifacts/pr_context.appendix.txt` (fresh: head ref in the summary matches the current branch head)
- **Work mode:** `full-feature` (persisted marker in `issue.md`) — acceptance-criteria sources are `spec.md` and `user-story.md`
- **Cycle-2 delta:** commits `a71ab00e` (docs), `e09c0e92` (split + hard-failure fixtures/tests), `8ba4fb79` (CR-1 fix), `921b5c40` (QA evidence, docs)

## Acceptance Criteria Inventory

Both AC source files carry the identical eight criteria, all currently checked `[x]` (checked off during the cycle-0 review and re-verified in cycle 1):

- AC1 — deterministic MERGED_CLEAN classification via merge-base ancestry over for-each-ref branches and porcelain worktrees
- AC2 — residual-commit classification ladder distinguishing content-on-main from unique content; no commit-message text matching
- AC3 — dual current-worktree/branch exclusion; main worktree always excluded
- AC4 — exactly two CLI modes: dry-run report (default, no mutation) and explicit apply
- AC5 — fixed apply-mode deletion order with same-process re-verification, no-force worktree removal, post-merge-gated consolidation-branch deletion
- AC6 — consolidation cherry-picks onto a single `documentationandmemories` branch in a dedicated worktree; conflicts abort-and-surface; pre-existing branch stops the run
- AC7 — skill documents the end-to-end workflow with PR creation delegated exclusively to Agent(pr-author)
- AC8 — bats unit tests over the git-stub seam covering the six required scenarios; no temp files; no scratch git repos

## Acceptance Criteria Evaluation

| AC | Source(s) | Verdict | Evidence |
|---|---|---|---|
| AC1 | spec.md, user-story.md | PASS | Implementation unchanged in mechanics; cycle-2 hardening strengthened it (worktree-list hard failure now maps to ANCESTRY_ERROR instead of silently weakening classification). Tests `merged_no_worktree`, `merged_with_worktree`, `ancestry_error` green in run 29970805348. |
| AC2 | spec.md, user-story.md | PASS | Ladder implemented as specified (diff --quiet short-circuit, cherry patch-id, rename-aware blob comparison); no commit-message input anywhere. Scenario tests `content_neutral`, `residual_on_main`, `residual_unique_doc` green. Caveat (does not fail the criterion as written, blocks merge via code review): under a hard `git diff-tree` failure the ladder misclassifies unique content as droppable (finding NEW-1, Blocking, `code-review.2026-07-22T21-16.md`). |
| AC3 | spec.md, user-story.md | PASS | Dual exclusion implemented via the two specified rev-parse checks against the porcelain list; main worktree always protected; `current_exclusion` tests green. Cycle 2 closed the worktree-list fail-open. Caveat: hard rev-parse failures degrade the protection silently (finding NEW-2, Major; bounded by git-native refusals). |
| AC4 | spec.md, user-story.md | PASS | Wrapper dispatches report (default, no mutation) and `--apply` only; usage errors exit 2. CLI suite green. Unchanged since cycle 0. |
| AC5 | spec.md, user-story.md | PASS | `delete_candidate` order: re-verify, no-force `git worktree remove` (dirty blocks, reported as DIRTY lines), `git branch -D`; consolidation-branch deletion gated on `verify_consolidation_merged` returning MERGED_CLEAN after fetch. Deletion suite green. Re-verification is now robust to worktree-list/cherry/rev-list hard failures (cycle-2 fix); the NEW-1 diff-tree gap also bypasses re-verification and is the blocking remediation item. |
| AC6 | spec.md, user-story.md | PASS | Consolidation targets a dedicated worktree via `git -C`, one cherry-pick -x per commit, LC_ALL=C branch order, conflict abort-and-surface, now-empty skip-and-reclassify, pre-existing-branch refusal. Consolidation suite green. Unchanged since cycle 0. |
| AC7 | spec.md, user-story.md | PASS | Skill documents classify -> consolidate -> PR (Agent(pr-author) only) -> verify-merged -> delete; no `gh pr create` in skill or scripts (reviewer grep). Unchanged since cycle 0; bundled mirror byte-identical (cycle-1 verification). |
| AC8 | spec.md, user-story.md | PASS | All six required scenarios covered by the stub-seam bats suites, plus the five cycle-2 hard-failure tests; 85/85 green in CI run 29970805348; checked-in fixtures only, no temp files, no scratch repos. |

## Summary

All eight acceptance criteria remain PASS at head content, and the cycle-2 remediation strengthened the safety-relevant criteria (AC1/AC3/AC5) by closing the CR-1 fail-open paths with regression tests and genuine fail-before/pass-after CI evidence. Toolchain gates: shfmt/shellcheck clean (executor evidence plus reviewer-local corroboration), 85/85 bats tests green in CI at head code content, bash line coverage 90.4% repo-wide with all four production files at or above 85% and no regression (independently re-parsed from the downloaded Cobertura artifact), all files within the 500-line cap, evidence locations canonical.

The feature is nevertheless **not merge-ready**: the caller-directed generalized hard-failure check found a reproduced residual fail-open path at the diff-tree rung (NEW-1, Blocking — a hard git failure resolves to a delete-eligible MERGED_EQUIVALENT verdict that survives pre-deletion re-verification) plus a bounded protection-degrade path (NEW-2, Major). These are code-review blockers, not acceptance-criteria failures as written; they route through `remediation-inputs.2026-07-22T21-16.md` to remediation cycle 3.

### Acceptance Criteria Status
- Source: `docs/features/active/2026-07-22-cleanup-merged-worktrees-396/spec.md` and `docs/features/active/2026-07-22-cleanup-merged-worktrees-396/user-story.md`
- Total AC items: 8 (identical set in each source file)
- Checked off (delivered): 8
- Remaining (unchecked): 0
- Items remaining: none

## Acceptance Criteria Check-off

No check-off action required in this cycle: all eight criteria were already `[x]` in both source files (checked during the cycle-0 review, re-verified in cycle 1 and again in this re-audit). No criterion was downgraded; per the tracking protocol, PASS items remain checked and no new items were added.
