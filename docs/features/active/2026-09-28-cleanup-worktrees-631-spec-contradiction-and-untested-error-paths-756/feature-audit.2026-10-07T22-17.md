# Feature Audit - Issue #756

## Scope and Baseline

- Work mode: minor-audit (marker `- Work Mode: minor-audit` in issue.md)
- AC source: `## Acceptance Criteria` section of `issue.md`
- Baseline: origin/main 08ee030d9584bf15882fbb3654c8e38f34c7c359 (merge-base); head c9d082f1385177d7a8c47c1f0556d2e7e293ed0d
- Plan: `plan.2026-09-30T03-38.md` (87 tasks checked, 0 unchecked)
- Scope check: no out-of-scope production change. The diff is limited to the stated spec, test, and fixture surfaces plus feature documentation.

## Acceptance Criteria Inventory

| AC | Criterion (short form) |
|---|---|
| AC-1 | The #631 spec states one consistent contract for a pairwise hard failure |
| AC-2 | A pairwise hard-failure test with a dedicated fixture exists |
| AC-3 | A `run_report_scans` failing-scan test exists |
| AC-4 | New tests pass with the whole suite; toolchain is clean |
| AC-5 | kcov coverage does not regress and meets the threshold |
| AC-6 | Mirror parity holds; #741 scope is not absorbed |

Source: `docs/features/active/2026-09-28-cleanup-worktrees-631-spec-contradiction-and-untested-error-paths-756/issue.md`. Total AC items: 6.

## Acceptance Criteria Evaluation

| AC | Verdict | Evidence |
|---|---|---|
| AC-1 spec consistent contract | PASS | The spec diff rewrites the former lines 280 and 411 to the invariant-section contract (no `CHILD_OF` record, `BRANCH|` unchanged, rc raised to 2). Independent search of the spec: `ANCESTRY_ERROR` appears 3 times (lines 179, 211, 283), all ladder rung-2 or verdict-list contexts; evidence records `probe maps to` count 0 (baseline 2). |
| AC-2 pairwise hard-failure test with dedicated fixture | PASS | Two bats tests plus the `child_of_pairwise_probe_error` fixture (`merge-base.feature-child.feature-parent.rc = 128`, both branches `NOT_MERGED`); they assert rc 2, unchanged `BRANCH|` records, and no `CHILD_OF|`. CI TAP ok 452-453. |
| AC-3 `run_report_scans` failing scan test | PASS | Tests assert rc 3, rc 5, rc 4 and maximization rc 7/9/9 using `report_scans_*` fixtures. CI TAP ok 454-459. |
| AC-4 new tests pass with the whole suite; toolchain clean | PASS (CI-based) | Run 37716284664 success (confirmed with `gh run view`), zero `not ok`, shell-qc check step success. No local run (operator decision); equivalence rests on CI at head 4f960432. |
| AC-5 kcov coverage | PASS | Re-read from the downloaded artifact: library 95.2% (baseline 87.9%), overall 94.2% (baseline 93.8%); six target lines hit 1 in kcov data. |
| AC-6 mirror parity; #741 not absorbed | PASS | No `.claude/` or `extensions/` path in the diff; `cleanup_wt_scan_roots` reference count unchanged. |

## Summary

All six acceptance criteria are supported by evidence. No blocking findings. Advisory items are recorded in `code-review.2026-10-07T22-17.md`.

### Residual Risks

1. The CI evidence run is a `workflow_dispatch` on head 4f960432, not on the final head c9d082f1 and not a `pull_request` run; a PR-triggered run is still expected at PR time.
2. Local bats and shell-qc were not executed (operator decision); AC-4 depends on CI evidence.
3. The fail-before requirement is met by an exception dossier with an analytic mutation argument; mutations were not executed.

## Acceptance Criteria Check-off

### Acceptance Criteria Status
- Source: docs/features/active/2026-09-28-cleanup-worktrees-631-spec-contradiction-and-untested-error-paths-756/issue.md
- Total AC items: 6
- Checked off (delivered): 6 (all were already checked; this review made no new check-offs)
- Remaining (unchecked): 0
- Items remaining: none

## Overall Verdict

PASS. All six acceptance criteria are supported by evidence.
