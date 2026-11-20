# Feature Audit: cleanup-merged-worktrees (#396)

---

**Audit Date:** 2026-07-22
**Feature Folder:** `docs/features/active/2026-07-22-cleanup-merged-worktrees-396/`
**Base Branch:** `main`
**Head Branch:** `drm-copilot-wt-2026-07-21T21-57`
**Work Mode:** `full-feature`
**Audit Type:** Initial acceptance review

---

## Scope and Baseline

- **Base branch:** `main` (commit `b2351cbc3fb3916f516d77567a1c9e40457c8981`)
- **Head branch/commit:** `drm-copilot-wt-2026-07-21T21-57` (commit `691883474ef76e89f94551f5bbdcbe3436514893`)
- **Merge base:** `b2351cbc3fb3916f516d77567a1c9e40457c8981`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt`
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt` and direct `git diff b2351cbc..HEAD` inspection
  - Feature evidence: `docs/features/active/2026-07-22-cleanup-merged-worktrees-396/evidence/{baseline,qa-gates}/`
  - Additional evidence: CI run 29922832766 (green, `headSha 4851f3c9`, this branch; verified via `gh run view`), downloaded coverage artifact `artifacts/pester/kcov-ci/cov.xml`, reviewer check-only shfmt/shellcheck re-runs
- **Feature folder used:** `docs/features/active/2026-07-22-cleanup-merged-worktrees-396/`
- **Requirements source:** `spec.md` and `user-story.md` (both authoritative for `full-feature`)
- **Work mode resolution note:** `issue.md` carries the explicit marker `- Work Mode: full-feature`, so per the acceptance-criteria tracking rules the AC sources are `spec.md` **and** `user-story.md`. The two files carry an identical set of eight criteria (AC1-AC8); they are evaluated once and tracked in each file independently.
- **Scope note:** Full branch diff versus `main` (123 added files; purely additive). The green CI verification run sits at commit `4851f3c9`; the head `69188347` differs from it only by `docs/features/**` documentation files (verified with `git diff --name-only 4851f3c9..HEAD`), so the run's bats/coverage results are representative of the head's shell code. The bash toolchain cannot execute in this Windows review environment; per the spec's Constraints section and `.claude/rules/shell.md`, CI dispatch is the sanctioned verification path.

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

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| 1 | AC1 — MERGED_CLEAN classification via ancestry exit codes over plumbing enumeration | PASS | `classify_ancestry` maps merge-base exit 0/1/>1 to MERGED_CLEAN / continue / ANCESTRY_ERROR (`cleanup_worktrees_lib.sh` lines 192-213); `enumerate_branches` uses `for-each-ref --format='%(refname:short) %(objectname)' refs/heads/` with `LC_ALL=C sort` (lines 54-68); `parse_worktree_list` parses porcelain stanza-wise (lines 70-120). Tests: `merged_no_worktree`, `merged_with_worktree`, `ancestry_error` (exit >1 is a hard failure, asserted never classified NOT_MERGED). | `gh run view 29922832766` (80/80 green); file inspection | Deterministic: no `git branch` parsing anywhere. |
| 2 | AC2 — residual-commit ladder distinguishing content-on-main from unique content; no message matching | PASS | Ladder implemented in order: `classify_content_neutral` (`diff --quiet main...<branch>`), `classify_cherry_equivalent` (`git cherry` markers + empty-diff handling), `classify_residual_commit` (rename-aware `diff-tree --name-status -r -M` + blob-OID comparison, deletions droppable iff absent on main, renames compared at new path). UNIQUE residuals emitted as `COMMIT\|<branch>\|<sha>\|UNIQUE\|<paths>\|<author>\|<author-date>` (`select_cherry_pick_candidates`). `grep -rn "git log\|--grep"` over both libraries: no matches. | Tests `content_neutral`, `residual_on_main`, `residual_unique_doc`; grep verification | The `residual_unique_doc` test asserts the full COMMIT record including SHA, path, author, and ISO date. |
| 3 | AC3 — dual current-exclusion; main worktree always excluded | PASS | `compute_protected` checks branch name via `rev-parse --abbrev-ref HEAD` (detached HEAD protects only the path) and normalized path via `rev-parse --show-toplevel` against each porcelain path; the first stanza is always protected (`cleanup_worktrees_lib.sh` lines 138-173). `classify_branch` short-circuits to PROTECTED_CURRENT before any ladder rung. | Tests: `compute_protected` (2), `current_exclusion` classification (current branch and `main` both PROTECTED_CURRENT), deletion suite `non-eligible states produce no destructive argv` | Path normalization handles Windows/WSL slash and case differences. |
| 4 | AC4 — exactly two modes; report default, no mutation; apply explicit, eligible states only | PASS | Wrapper dispatch: no args or `report` -> `run_report`; `--apply`/`apply` -> `run_apply`; `--help` 0; unknown 2. CLI test asserts report mode emits no `worktree remove` / `branch -D` / `cherry-pick` / `worktree add` argv; apply test asserts destructive argv only for eligible states and never `branch -D main`. `run_apply` gates on the explicit allowlist MERGED_CLEAN / MERGED_CONTENT_NEUTRAL / MERGED_EQUIVALENT. | `test_cleanup_worktrees_cli.bats` (5 tests) | Report-line contract documented in usage text and both library headers. |
| 5 | AC5 — fixed deletion order with re-verification, no-force, dirty block, and consolidation merge gate | PASS | `delete_candidate` enforces reverify -> `remove_worktree_safe` (no `--force`; dirty worktree emits DIRTY lines and blocks) -> `delete_branch` (`-D`). `run_apply` blocks the consolidation branch with `BLOCKED-CONSOLIDATION-UNMERGED` unless `verify_consolidation_merged` (post-`fetch` `merge-base --is-ancestor documentationandmemories main`) returns MERGED_CLEAN; once merged, source branches' unique content is reachable from main and re-classification resolves them via the same git-native primitives. | Deletion suite: dirty block (asserts no `--force` token anywhere), reverify flip block, remove-before-delete ordering, consolidation gate both ways | The reviewer notes the re-verification path shares finding CR-1's narrow fail-open (code review, Major, follow-up); the AC's specified mechanics are implemented and test-verified as written. |
| 6 | AC6 — consolidation onto a single branch in a dedicated worktree; -x, oldest-first, LC_ALL=C; conflicts abort; pre-existing branch stops | PASS | `create_consolidation_worktree` requires `refs/heads/documentationandmemories` absent (stops with a specific stderr report otherwise) and runs `worktree add <path> -b documentationandmemories main` at a derived dedicated path (never the caller's tree; all consolidation git commands use `-C <wt>`). `cherry_pick_candidates` picks one commit per invocation with `-x`, preserves fed order (LC_ALL=C by branch from `enumerate_branches`, oldest-first per branch from `rev-list --reverse --no-merges`), aborts conflicts via `cherry-pick --abort` + CONFLICT record + intra-branch skip, and `--skip`s now-empty picks with reclassification. `cleanup_consolidation_on_abort` removes worktree and branch with ACTION reporting. | Consolidation suite (6 tests) | Arbitrary branch count supported: candidates stream via stdin records, no fixed-arity assumptions. |
| 7 | AC7 — skill documents the end-to-end workflow; PR creation exclusively via Agent(pr-author) | PASS | `.claude/skills/cleanup-merged-worktrees/SKILL.md` documents all six steps (detect/report -> editorial triage -> consolidate -> pr-author handoff with PR-context refresh and `--require-pr-creation-ready` checkpoint validation -> git-native merge verification -> apply deletion) plus the nothing-to-consolidate short path and a Prohibited Shortcuts section. `grep -rn "gh pr create\|gh pr edit"` over skill + scripts matches only the prohibition sentence. `allowed-tools` frontmatter grants only the wrapper and narrow git commands. | grep verification; SKILL.md inspection | Cross-references pr-author, pr-context-artifacts, and shell.md rather than re-specifying them. |
| 8 | AC8 — bats unit tests covering the six mandated scenarios; no temp files; no scratch repos | PASS | Six named scenarios map one-to-one to fixtures/tests: `merged_no_worktree`, `merged_with_worktree`, `unmerged`, `residual_on_main`, `residual_unique_doc`, `current_exclusion`. All fixtures checked in under `tests/fixtures/cleanup_worktrees/`; the stub writes nothing to disk; no temp files created by any test (the only real-binary call is `git --version`). CI run 29922832766: TAP `1..80`, 0 failures, including all 36 new tests; bash line coverage 89.0%. | `gh run view 29922832766 --json headSha,conclusion` -> success at `4851f3c9` on this branch; docs-only delta to head verified | Suites additionally cover ancestry-error, content-neutral, dirty-worktree, pre-existing-branch, and consolidation-gate scenarios beyond the AC minimum. |

---

## Summary

**Overall Feature Readiness:** PASS

**Criteria summary:**
- **PASS:** 8 criteria
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 0 criteria
- **FAIL:** 0 criteria

**Top gaps preventing PASS:**

1. None.

**Recommended follow-up verification steps:**

1. File a follow-up hardening issue for code-review finding CR-1 (dead or-capture assignments inside process substitutions in `cleanup_worktrees_lib.sh`; add a fixture simulating a `git cherry` hard failure and propagate a hard-error verdict).
2. On the first real-world run, execute report mode against the live repository (a known `MERGED_CLEAN` candidate exists: branch `drm-copilot-wt-2026-07-21T17-20`, PR #394 merged) and confirm the report matches manual ancestry checks before any `--apply`.

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules:
- Criteria evaluated as **PASS** may be checked off in the authoritative source file(s) if not already checked.
- All eight criteria were already checked (`- [x]`) in both `spec.md` and `user-story.md` by the executor during plan execution, with per-task verification recorded in the plan and evidence artifacts. This reviewer independently evaluated each criterion as PASS (table above), confirming the existing check-offs. No source-file changes were required or made by this audit.

### AC Status Summary

- Source: `docs/features/active/2026-07-22-cleanup-merged-worktrees-396/spec.md`, `docs/features/active/2026-07-22-cleanup-merged-worktrees-396/user-story.md`
- Total AC items: 16 (8 per source file; identical text)
- Checked off (delivered): 16
- Remaining (unchecked): 0
- Items remaining: None.

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `spec.md` | 8 | 8 | 0 | Checkbox-backed; all pre-checked by executor, confirmed PASS by this audit |
| `user-story.md` | 8 | 8 | 0 | Checkbox-backed; all pre-checked by executor, confirmed PASS by this audit |

No source-file checkbox change was made because every PASS criterion was already checked; the audit's role here was independent confirmation.
