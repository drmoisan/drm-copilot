# Feature Audit: cleanup-report registration-lost false positive (#706)

---

**Audit Date:** 2026-09-27
**Feature Folder:** `docs/features/active/cleanup-report-registration-lost-false-positive-706`
**Base Branch:** `main`
**Head Branch:** `bug/cleanup-report-registration-lost-false-positive-706`
**Work Mode:** `full-bug`
**Audit Type:** Initial acceptance review

---

## Scope and Baseline

- **Base branch:** `main` (`origin/main` @ `849aae609787172240c1ae7c33d10d6dd337d497`)
- **Head branch/commit:** `bug/cleanup-report-registration-lost-false-positive-706` (commit `81d4e16b109525a2f965b7353cd2f9492f6225ef`)
- **Merge base:** `849aae609787172240c1ae7c33d10d6dd337d497`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt` (generated 2026-09-27 14:40:22 UTC at head 81d4e16b)
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`
  - Feature evidence: `docs/features/active/cleanup-report-registration-lost-false-positive-706/evidence/**`
  - Additional evidence: `evidence/qa-gates/reviewer-verification.2026-09-27T10-48.md` (this review: local toolchain re-run, hash check, real-host pre-fix vs post-fix comparison)
- **Feature folder used:** `docs/features/active/cleanup-report-registration-lost-false-positive-706`
- **Requirements source:** `spec.md` only
- **Work mode resolution note:** `issue.md` carries the explicit marker `- Work Mode: full-bug`. Under `full-bug`, `spec.md` is the sole AC source. `issue.md` also lists AC-1 to AC-4 and notes that the GitHub issue body says `minor-audit`; the persisted marker governs, so `issue.md` checkboxes are not authoritative for this run.
- **Scope note:** full `origin/main...HEAD` diff (58 files: 1 bash production file, 1 bats file, 1 fixture, 55 Markdown files). The post-change CI coverage run (36326020967) was at 3bcaee4d; the two later commits change only feature-folder Markdown, so the measured code equals the head.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/cleanup-report-registration-lost-false-positive-706/spec.md` — only source (`## Acceptance Criteria`)

### Acceptance criteria

1. AC-1: Report mode does not emit `WARN|registration-lost|<path>` for a worktree whose `.git` pointer names a `gitdir:` target that exists, including when the target is written in a Windows drive-letter form. Verified by the bats tests `scan-dirs reports target_exists 1 for an existing drive-letter gitdir target without prefixing the worktree directory` and `scan_helper_is_absolute_path returns 0 for slash-leading and drive-letter paths` passing in `tests/shell/test_cleanup_worktrees_scan_helper.bats`, and by the existing test `scan-dirs emits has_gitfile/target_exists/size for each candidate directory` continuing to pass unchanged.
2. AC-2: Report mode still emits `WARN|registration-lost|<path>` for a worktree whose `.git` pointer names a `gitdir:` target that does not exist. Verified by the bats tests `scan-dirs reports target_exists 0 for a drive-letter gitdir target that does not exist` and `scan_helper_is_absolute_path returns non-zero for relative, drive-relative, and empty paths` passing, by the existing `broken_wt|1|0|` assertion continuing to pass, and by `tests/shell/test_cleanup_worktrees_report_records.bats` passing without modification.
3. AC-3: The root cause of the false positive is identified and documented in this `spec.md` (Root Cause Analysis, with file and line citations), and the regression test `scan-dirs reports target_exists 1 for an existing drive-letter gitdir target without prefixing the worktree directory` is shown to fail against the pre-fix helper and to pass after the fix, with both outcomes recorded under `docs/features/active/cleanup-report-registration-lost-false-positive-706/evidence/<kind>/`.
4. AC-4: The shell toolchain passes for the changed files: `bash scripts/bash/shell-qc.sh format` makes no changes, `bash scripts/bash/shell-qc.sh check` reports no shfmt diff and no shellcheck finding, and `bash scripts/bash/shell-qc.sh test --coverage` passes in CI; overall bash line coverage and the per-file line coverage of `scripts/bash/cleanup_worktrees_scan_helper.sh` are each at or above 85%, and every new or modified line in that file has non-zero hits in `cov.xml`.

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| 1 | AC-1: no WARN for an existing target, including drive-letter form | PASS | Named tests ok in CI run 36326020967 (tests 427, 429) and in this review's local run (tests 2, 4); existing test ok (CI 426, local 1) and unchanged (numstat `67 0`, append-only). Real host: fixed helper reports `target_exists 1` for 32 of 33 pointer-bearing worktrees, versus 0 of 33 with the pre-fix logic. | `npx --yes bats tests/shell/test_cleanup_worktrees_scan_helper.bats tests/shell/test_cleanup_worktrees_report_records.bats tests/shell/test_cleanup_worktrees_scan_seam.bats`; `bash scripts/bash/cleanup_worktrees_scan_helper.sh scan-dirs <main>/.claude/worktrees <main>-wt` | Report mode itself was not run end to end; the WARN line is derived from `target_exists 0` by the unchanged `scan_registration_loss`, whose behavior is pinned by the report-records suite. |
| 2 | AC-2: WARN still emitted for a missing target | PASS | Tests 428 and 430 ok in CI; local tests 3 and 5 ok; existing `broken_wt|1|0|` assertion ok; `test_cleanup_worktrees_report_records.bats` unmodified (scope check) and 9/9 ok locally, including `scan_registration_loss emits WARN|registration-lost for a broken gitdir pointer`. Real host: the one worktree whose target directory is absent (`<main>-wt/2026-08-25T14-46`) is still reported `target_exists 0`. | Same bats command; `git diff --exit-code --stat 849aae60 HEAD -- tests/shell/test_cleanup_worktrees_report_records.bats` (executor); `ls -d <target>` | Genuine-loss detection preserved on real data. |
| 3 | AC-3: root cause documented; regression test fail-before and pass-after recorded | PASS | `spec.md` Root Cause Analysis cites `cleanup_worktrees_scan_helper.sh:72-99`, line 91 (`!= /*`), line 92 (prefix), line 94 (`-e`), and consumer lines 254-304 and 296-298. `evidence/regression-testing/fail-before.2026-09-27T10-17.md`: test not ok against the unmodified helper, record `wt_drive|1|0|1.0K`. `evidence/regression-testing/pass-after.2026-09-27T10-25.md`: ok after the fix. | `npx --yes bats --print-output-on-failure tests/shell/test_cleanup_worktrees_scan_helper.bats` (executor, both states) | The fail-before commit be344727 precedes the fix commit 3efc3ddf, consistent with the recorded order. |
| 4 | AC-4: toolchain clean; coverage >= 85% overall and per file; every changed line hit | PASS | Format: no rewrite (`qc-step1-format.2026-09-27T10-45.md`). Check: exit 0 locally (executor and this review) and CI check step success. CI `test --coverage` success, 0 not ok. Overall 93.3%; per file 87.5% (49/56); lines 83, 84, 94, 116, 117, 119 each hits >= 1 (`kcov-new-line-hits.2026-09-27T10-49.md`). | `sh scripts/bash/shell-qc.sh check`; `shfmt -d scripts/bash/cleanup_worktrees_scan_helper.sh`; `gh run view 36326020967 --log` (executor) | CI run head 3bcaee4d is code-identical to 81d4e16b. |

---

## Summary

**Overall Feature Readiness:** PASS

**Criteria summary:**
- **PASS:** 4 criteria
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 0 criteria
- **FAIL:** 0 criteria

**Top gaps preventing PASS:**

1. None.

**Recommended follow-up verification steps:**

1. After rebasing on `main`, confirm the PR-context CI run (including `_shell-coverage.yml`) is green at the final head SHA.
2. Optionally run `bash scripts/bash/cleanup-worktrees.sh` report mode on the Windows host and confirm only genuine losses (currently `<main>-wt/2026-08-25T14-46`) produce `WARN|registration-lost`.
3. File the two D7 follow-up candidates (unscanned worktree locations; `CLEANUP_WT_ORPHAN_ROOTS` colon splitting of drive-letter roots) if they are still wanted.

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules:
- Criteria evaluated as **PASS** may be checked off in the authoritative source file(s) if they are represented as markdown checkboxes and are not already checked.
- Criteria evaluated as **PARTIAL**, **FAIL**, or **UNVERIFIED** must remain unchecked.

All four AC items in `spec.md` were already checked (`- [x]`) by the executor (commit 91a8cec3). This review evaluated each as PASS, so no source-file change was needed and none was made. `issue.md` checkboxes are not authoritative under `full-bug` and were left unchanged.

### Acceptance Criteria Status

- Source: `docs/features/active/cleanup-report-registration-lost-false-positive-706/spec.md`
- Total AC items: 4
- Checked off (delivered): 4
- Remaining (unchecked): 0
- Items remaining: None.

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `docs/features/active/cleanup-report-registration-lost-false-positive-706/spec.md` | 4 | 4 | 0 | Checkbox-backed; authoritative (`full-bug`) |
| `docs/features/active/cleanup-report-registration-lost-false-positive-706/issue.md` | 4 | 0 | 4 | Checkbox-backed; not authoritative under `full-bug` |
