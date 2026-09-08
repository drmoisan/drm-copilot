Timestamp: 2026-09-07T21:20

# Remediation Closure — issue #631, remediation cycle 1

## R-01 — CHILD_OF short-circuit produced a wrong verdict (blocking)

- Implementing tasks: P5-T1, P5-T2, P5-T3 (`scripts/bash/cleanup_worktrees_report_records_lib.sh`:
  `classify_all_branches` rewritten to remove verdict inheritance entirely; the dead
  `cleanup_wt_protected_branches` carve-out removed; header/docstring corrected).
- Verifying tests: P2-T1 through P2-T12, P2-T15 (rewritten/renamed `child_of_not_merged`,
  `child_of_merged_equivalent`, and three new counterexample fixtures —
  `child_of_subject_merged_clean`, `child_of_subject_content_neutral`,
  `child_of_subject_merged_equivalent` — each pinning one delete-eligible state that must survive
  being an ancestor of a `NOT_MERGED` branch).
- Passing-run evidence: `evidence/qa-gates/final-test.2026-09-07T14-40.md` (343/343 passed, run
  https://github.com/drmoisan/drm-copilot/actions/runs/34161820865); fail-before evidence at
  `evidence/regression-testing/fail-before-r01-r02-r04.2026-09-07T14-40.md` (8 of the 12 new/renamed
  tests failed before Phases 3-6 landed, confirming they are not vacuous).

## R-02 — duplicate filesystem scan per report (major)

- Implementing tasks: P4-T1 through P4-T4 (`run_report_scans` performs exactly one
  `cleanup_wt_scan_records` call and passes the same records to `scan_orphan_dirs` and
  `scan_registration_loss`).
- Verifying tests: P2-T5, P2-T13, P2-T14 (`run_report performs exactly one filesystem scan`, and the
  scan-stub argv-log audit confirming a single `stub-scan: scan-dirs` invocation).
- Passing-run evidence: `evidence/qa-gates/final-test.2026-09-07T14-40.md`.

## R-04 — `.claude/worktrees` scan root was CWD-relative (major)

- Implementing tasks: P3-T1 (`cleanup_wt_scan_roots` derives both roots from the main worktree path
  read via `parse_worktree_list`, replacing the bare `.claude/worktrees` literal).
- Verifying tests: P2-T14 (`cleanup_wt_scan_roots derives both roots from the main worktree path`,
  `cleanup_wt_scan_roots emits no root when the worktree listing hard-fails`).
- Passing-run evidence: `evidence/qa-gates/final-test.2026-09-07T14-40.md`. A downstream regression
  this fix exposed in two pre-existing `scan_registration_loss` tests (their fixtures lacked the
  `worktree-list.out` this fix newly requires) was caught by the post-Phase-6 CI dispatch and fixed
  in commit 1f702f68; see `evidence/qa-gates/final-test.2026-09-07T14-40.md`'s Output Summary for
  detail.

## Acceptance Criteria Status

- Source: `docs/features/active/2026-09-06-cleanup-worktrees-report-mode-visibility-gaps-631/spec.md`
- Total AC items: 11
- Checked off (delivered): 10
- Remaining (unchecked): 1
- Items remaining: AC6 (`for-each-ref` stub key-specificity edit backward compatible, verified
  *immediately after* the edit and before any new fixtures) — deferred per R-07 (minor, evidence
  sequencing only; the substantive backward-compatibility property is verified on the final tree,
  just not isolated to the moment immediately after the stub edit).

## Deferred (out of scope for this remediation cycle)

- R-05 — coverage evidence lacks per-file rows.
- R-06 — production `.git` default of the scan seam is untested (the seam itself is correct; only
  the fallback-literal branch lacks a dedicated test).
- R-07 — AC6 sequencing evidence (see above).
- R-08 — documentation corrections (`usage()` report-mode/apply-mode labeling, missing
  `CLEANUP_WT_SCAN_GITFILE_NAME` in the environment-overrides list, `run_report`'s stale
  never-blocking docstring claim).
