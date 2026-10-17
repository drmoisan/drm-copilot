# Feature Audit: cleanup-merged-worktrees scan roots and orphan-root split (#741)

**Audit Date:** 2026-10-02
**Feature Folder:** `docs/features/active/2026-09-27-cleanup-worktrees-scan-roots-and-orphan-root-split-741`
**Base Branch:** `origin/main`
**Head Branch:** `bug/cleanup-worktrees-scan-roots-and-orphan-root-split-741`
**Work Mode:** `minor-audit`
**Audit Type:** Initial acceptance review (review pass 1)

---

## Scope and Baseline

- **Base branch:** `origin/main` (commit `74e1d6741485aa38c28fecbbc77ea169f31df0ef` at review time)
- **Head branch/commit:** `bug/cleanup-worktrees-scan-roots-and-orphan-root-split-741` (commit `5c783c066abb505ade1b1e7902a679c74bced84b`, equal to `origin`)
- **Merge base:** `71f8dcb49d8ce5d1402ff441855a64be15b37f29` (merged into the branch as `df5eb303129a30289a7d81775fdadaa40631be63`, the plan's BASE_SHA)
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt` (regenerated 2026-10-02 08:29:59 UTC, Head SHA `5c783c06`)
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`
  - Feature evidence: `evidence/baseline/`, `evidence/regression-testing/`, `evidence/qa-gates/`, `evidence/other/` (index: `evidence/other/small-audit-handoff.2026-10-02T04-24.md`)
  - Additional evidence: CI runs 36978610292 (baseline, `df5eb303`, success), 36979697644 (fail-before, `48c6023d`, failure), 36981519472 (pass-after, `598691e7`, success), 36982722154 (final, `10c6ac29`, success); conclusions and head SHAs verified with `gh run view`; final log and both `shell-coverage` artifacts downloaded and inspected by this review.
- **Feature folder used:** `docs/features/active/2026-09-27-cleanup-worktrees-scan-roots-and-orphan-root-split-741`
- **Requirements source:** `issue.md` `## Acceptance Criteria` (AC-1..AC-12). `## Scope Decisions` in `issue.md` is treated as binding design input.
- **Work mode resolution note:** explicit marker `- Work Mode: minor-audit` in `issue.md`.
- **Scope note:** `origin/main` advanced to `74e1d674` after the merge base; `git diff --name-only 71f8dcb4 origin/main` over the skill, its mirror, `tests/shell`, and `tests/fixtures/cleanup_worktrees` is empty, so the newer main commits do not overlap this change. The commit after `10c6ac29` (`5c783c06`) changes only feature-folder documents, so CI results on `10c6ac29` apply to the current head's code. Bats and kcov ran only in CI under the binding operator decision of 2026-10-01 (Option A, DEV-2); cited CI results are accepted as evidence.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/2026-09-27-cleanup-worktrees-scan-roots-and-orphan-root-split-741/issue.md` — only source (`## Acceptance Criteria`)

### Acceptance criteria

1. AC-1: With `CLEANUP_WT_ORPHAN_ROOTS` unset, `cleanup_wt_scan_roots` emits `<main>/.claude/worktrees`, `<main>-wt`, and then the parent directory of every non-main registered worktree, deduplicated by `normalize_wt_path`, verified by a bats test against a `scan_roots_derived` scenario asserting exact ordered lines.
2. AC-2: A derived candidate root that equals the main worktree, is an ancestor of it (including the main worktree's parent directory), or is equal to or inside any registered worktree is not emitted; each exclusion class has a scenario entry asserted absent.
3. AC-3: When `parse_worktree_list` hard-fails and no override is set, no root is emitted, and the existing test at `tests/shell/test_cleanup_worktrees_report_records.bats` covering that case passes unchanged.
4. AC-4: When the override is set and `parse_worktree_list` hard-fails, exactly the override roots are emitted.
5. AC-5: `CLEANUP_WT_ORPHAN_ROOTS` is parsed per the separator contract above; bats cases cover `/a/one:/b/two`, `C:/a/one`, `C:/a/one:D:\b\two`, `C:/a/one;D:/b/two`, newline separation, empty segments, a glob character kept literally, and a relative segment dropped with a stderr diagnostic; the existing override test passes unchanged.
6. AC-6: A full `run_report` under the scan stub performs exactly one `scan-dirs` invocation, and its argv includes a registration-derived root.
7. AC-7: Exactly one bash definition of the drive-letter absolute-path predicate (`cleanup_wt_is_absolute_path`) exists under `.claude/skills/cleanup-merged-worktrees/scripts/`; `preserve_relative_path_reason` and the scan helper call it; `scan_helper_is_absolute_path` no longer exists; the #706 predicate cases pass against the shared function, and a drive-letter `source_path` is rejected as absolute by the preserve validator.
8. AC-8: The inline `load_helper` definition is removed from the three test bodies in `tests/shell/test_cleanup_worktrees_scan_helper.bats`; the source-then-`set +u` idiom appears in exactly one file-local helper with its kcov rationale stated once.
9. AC-9: Each changed canonical file is byte-identical to its bundle mirror, and `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` passes.
10. AC-10: The wrapper usage text for `CLEANUP_WT_ORPHAN_ROOTS` and the `SKILL.md` `ORPHAN_DIR` bullet state the separator contract, the override-replaces-default-pair rule, and the always-added derived roots with their exclusions.
11. AC-11: Every changed shell or bats file is at or below 500 lines; `shfmt -d` and `shellcheck` report no finding on changed files; the bats suite passes in the `_shell-coverage.yml` CI run on the branch head, with kcov line coverage at or above 85% for each changed production file.
12. AC-12: `classify_all_branches` and `run_report_scans` are byte-unchanged, and `tests/shell/test_cleanup_worktrees_report_records.bats` is unmodified, preserving the #756 boundary.

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| 1 | AC-1 default pair then derived parents, deduplicated, exact ordered lines | PASS | Test "cleanup_wt_scan_roots appends registration-derived parents after the default pair" asserts 4 exact ordered lines (`/repo/main/.claude/worktrees`, `/repo/main-wt`, `/repo/main-wt/a-wt`, `/scratch/planhome`); `/repo/main-wt` and `/Scratch/PlanHome` duplicates collapse. CI TAP 455 `ok`. Implementation `enumerate_lib:374-416`. | `gh run view 36982722154 --log`; Read of the bats file and fixture | Override variant (TAP 457) also asserts derived roots after override roots. |
| 2 | AC-2 exclusion classes asserted absent | PASS | Fixture registers `/repo/sibling-plan` (parent `/repo`, main's parent), `/repo/main/sub` (parent = main), `/repo/main/.claude/x` (inside main), `/scratch/planhome/ph1/d` (parent equal to registered `ph1`), `/scratch/planhome/ph1/inner/c` (inside registered `ph1`). TAP 456 asserts all five absent and line count 4. Implementation `enumerate_lib:353-362`. | Read of fixture and test; CI log | Prefix boundary (`a-wt` vs `a`) also covered. |
| 3 | AC-3 hard failure with no override emits no root; existing test unchanged | PASS | `cleanup_wt_scan_roots` sets `main_wt`/`derived` only when `rc == 0` and emits the default pair only when `main_wt` is non-empty. Existing test "emits no root when the worktree listing hard-fails" is CI TAP 450 `ok`. `git diff origin/main...HEAD -- tests/shell/test_cleanup_worktrees_report_records.bats` is empty. | `git diff --name-only origin/main...HEAD`; CI log | |
| 4 | AC-4 hard failure with override emits exactly override roots | PASS | TAP 458 `ok`: `worktree_list_error` scenario with `/a/one:/b/two` asserts exactly 2 lines. | CI log; Read of test | |
| 5 | AC-5 separator contract and listed cases; existing override test unchanged | PASS | `/a/one:/b/two` (TAP 457), `C:/a/one` (459), `C:/a/one:D:\b\two` (460), `C:/a/one;D:/b/two` (461), newline (462), empty segments (463), literal `/*` (464), relative segment dropped with exact stderr diagnostic (465). Existing "honors the CLEANUP_WT_ORPHAN_ROOTS override" is TAP 449 `ok` in an unmodified file. | CI log; Read of test | |
| 6 | AC-6 one `scan-dirs` invocation including a derived root | PASS | TAP 466 `ok`: counts exactly one `stub-scan: scan-dirs` line and matches argv `/repo/main/.claude/worktrees /repo/main-wt /repo/main-wt/a-wt /scratch/planhome`. | CI log; Read of test | |
| 7 | AC-7 single shared predicate; callers; old name gone; #706 cases; drive-letter source_path rejected | PASS | Grep: one definition `cleanup_wt_is_absolute_path()` at `enumerate_lib:257`; called at `preserve_lib:161` and `scan_helper:105`; `scan_helper_is_absolute_path` absent from canonical, mirror, and `tests/shell`. TAP 467-470 `ok` (positive and negative #706 cases, override-seam call-site proof, drive-letter `source_path` rejection). | Grep over `.claude/skills/cleanup-merged-worktrees/scripts`; `git diff` of preserve and scan helper; CI log | |
| 8 | AC-8 `load_helper` removed; one file-local helper with kcov rationale once | PASS | `test_cleanup_worktrees_scan_helper.bats` contains no `load_helper`; `run_helper_sourced` (lines 23-37) is the only place with `source ...; set +u`, with the kcov rationale in its header comment. The two predicate bodies moved to the new suite; the third body uses the helper. | Read of the file; diff | Two `load_helper` lines in `tests/fixtures/shell_qc/stub-bin/bats-nounset-source-reset` predate the branch (DEV-6) and are outside AC-8's named file. |
| 9 | AC-9 mirror byte identity and bundle contract test | PASS | `cmp` reported identical for all six changed files (SKILL.md and five scripts). Executor evidence: `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` -> 14 passed. | `cmp -- <canonical> <mirror>` (run by this review); `evidence/qa-gates/bundle-parity-pytest.2026-10-02T04-07.md` | The pytest result was not re-run by this review; its inputs (the mirrored files) are confirmed identical. |
| 10 | AC-10 usage text and SKILL.md state contract, override rule, derived roots and exclusions | PASS | Wrapper usage (`cleanup-worktrees.sh` lines 142-152) and `SKILL.md` `ORPHAN_DIR` bullet both state: `;`/newline/`:` separators with the drive-letter exception; empty and relative entries dropped; override replaces the default pair; parents of non-main registrations always added except main/ancestor/equal-or-inside-registered. | `git diff origin/main...HEAD -- .claude/skills/cleanup-merged-worktrees/` | |
| 11 | AC-11 500-line limit; shfmt/shellcheck clean; CI bats pass; >= 85% per changed production file | PASS | `wc -l`: 416, 439, 492, 171, 243 (production); 242, 77 (bats). `shfmt -d` and `shellcheck` re-run by this review: exit 0. CI run 36982722154 on `10c6ac29`: success, `1..521`, 0 `not ok`, `Bash coverage (lines): 93.8%`. Per-file line rates from the downloaded `cov.xml`: 95.3%, 87.9%, 90.6%, 87.3%, 97.6%. | `wc -l`; `shfmt -d`; `shellcheck`; `gh run view`; `gh run download` | Head `5c783c06` differs from `10c6ac29` only in feature-folder documents. |
| 12 | AC-12 #756 boundary preserved | PASS | `git diff origin/main...HEAD` on `cleanup_worktrees_report_records_lib.sh` has three hunks (header comment, removal of old `cleanup_wt_scan_roots`, one docstring line); none touches `run_report_scans` or `classify_all_branches`. `tests/shell/test_cleanup_worktrees_report_records.bats` is absent from the branch's changed-file list. | `git diff origin/main...HEAD -- .claude/skills/cleanup-merged-worktrees/`; `git diff --name-only origin/main...HEAD` | Consistent with executor evidence `evidence/qa-gates/ac12-boundary.2026-10-02T04-07.md` (function spans 39 and 131 lines, offset -37). |

---

## Summary

**Overall Feature Readiness:** PASS

**Criteria summary:**
- **PASS:** 12 criteria
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 0 criteria
- **FAIL:** 0 criteria

**Top gaps preventing PASS:**

1. None.

Non-blocking observations from the policy audit and code review (no AC impact): stale line reference in `cleanup_worktrees_detached_lib.sh:46` (Minor); SC1091 suppression without an inline reason in `cleanup_worktrees_scan_helper.sh:44` (Minor); derived candidates not validated as absolute (Minor); no backslash-path derivation fixture (Nit).

**Recommended follow-up verification steps:**

1. After merge, run report mode on a Windows checkout with worktrees outside the default pair and confirm the expected `ORPHAN_DIR` and `WARN|registration-lost` records (the issue's integration retest idea; not an AC).
2. Optionally address the four non-blocking observations in a follow-up change.

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules:
- Criteria evaluated as **PASS** may be checked off in the authoritative source file(s) if they are represented as markdown checkboxes and are not already checked.
- Criteria evaluated as **PARTIAL**, **FAIL**, or **UNVERIFIED** must remain unchecked.

All twelve criteria were already checked by the executor (`evidence/other/ac-checkoff.2026-10-02T04-23.md`) and all evaluate PASS here, so `issue.md` was not modified by this review. No item was unchecked.

### AC Status Summary

- Source: `docs/features/active/2026-09-27-cleanup-worktrees-scan-roots-and-orphan-root-split-741/issue.md`
- Total AC items: 12
- Checked off (delivered): 12
- Remaining (unchecked): 0
- Items remaining: None.

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `docs/features/active/2026-09-27-cleanup-worktrees-scan-roots-and-orphan-root-split-741/issue.md` | 12 | 12 | 0 | Checkbox-backed `## Acceptance Criteria` section; no change made by this review. |
