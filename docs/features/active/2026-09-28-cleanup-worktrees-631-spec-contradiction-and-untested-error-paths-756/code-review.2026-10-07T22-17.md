# Code Review - Issue #756

- Branch: bug/cleanup-worktrees-631-spec-contradiction-and-untested-error-paths-756
- Base: origin/main @ 08ee030d9584bf15882fbb3654c8e38f34c7c359; head c9d082f1385177d7a8c47c1f0556d2e7e293ed0d
- Scope: `tests/shell/test_cleanup_worktrees_report_records.bats` (+93 lines), 29 new fixture files, and the `spec.md` edit in the completed #631 feature folder. No production code changed.

## Executive Summary

The change is small, readable, and targets the two gaps accurately. I read `cleanup_worktrees_report_records_lib.sh` lines 270-307 and 399-432 and confirmed each new test drives the statement it claims. There are no blocking or major findings. Four advisory items are recorded below. Overall verdict: PASS; no remediation is required for correctness.

## Positive Observations

- The pairwise test design is sound: `child_of_pairwise_probe_error` differs from `child_of_not_merged` by exactly one file (`merge-base.feature-child.feature-parent.rc = 128`), documented in the test comment, so the rc 2 result is attributable to the pairwise probe alone (`pairwise-scenario-diff`).
- The second pairwise test compares driver output against `classify_branch` output for the same scenario and branch, so the "verdict unchanged" assertion can fail, and it also pins the literal `NOT_MERGED` value.
- The `run_report_scans` tests cover every return path: scan failure (rc 3, no records), scan failure with a larger stale-ref rc (5), stale-ref failure after a successful scan (rc 4, orphan record retained), and three rc-maximization orderings (7/0, 7/9, 9/7).
- Helpers (`classify_all_rr`, `ladder_rr`, `rs_override`) each carry a comment explaining how they differ from `rr`; the file stays at 225 lines.
- No temp files, scratch repositories, or timing dependencies.
- The spec rewrite is consistent with the library comment at lines 422-423 and with the spec's invariant section (lines 202-212). Remaining `ANCESTRY_ERROR` mentions (lines 179, 211, 283) refer to the ladder rung-2 case or the verdict list; confirmed by searching the spec.

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
| --- | --- | --- | --- | --- | --- | --- |
| Advisory | `tests/shell/test_cleanup_worktrees_report_records.bats` | helper `rs_override` | CR-756-01: `$2` and `$3` are interpolated unquoted into a `bash -c` string as function return values. Safe for the numeric literals used; a non-numeric argument would produce a syntax error instead of a test failure. | Add a short comment stating the numeric-only contract. | Prevents a future caller from misreading a syntax error as a behavior failure. | Read of the helper definition and its call sites; all call sites pass integer literals. |
| Advisory | `tests/shell/test_cleanup_worktrees_report_records.bats` | helper `rs_override`, three maximization tests | CR-756-02: `scan_orphan_dirs` and `scan_registration_loss` are replaced with stubs, so the maximization tests verify `run_report_scans` logic in isolation and not the real record scans' failure returns. | None required; intentional and stated in the helper comment. | Acceptable isolation for a unit test of the rc-maximization logic. | Helper comment; the scan-failure tests use real `report_scans_*` fixtures. |
| Advisory | `.claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_report_records_lib.sh` | line 424 | CR-756-03: the guard `((mrc > 1)) && ((rc < 2))` has a second-operand false outcome (rc already >= 2) that no test drives. | Optional: add a test where the stale-ref rc is already >= 2 and the maximum is 1. | Branch-level completeness; kcov does not measure bash branches, so this is not a policy gap. | Library read at lines 424-426; kcov line hits recorded in `final-ci-kcov-line-hits`. |
| Advisory | `docs/features/active/2026-09-28-cleanup-worktrees-631-spec-contradiction-and-untested-error-paths-756/issue.md` | header `Status:` line | CR-756-04: the line cites `docs/features/active/cleanup-worktrees-631-spec-contradiction-and-untested-error-paths/`, which omits the date prefix of the actual folder. | Correct the path in a documentation-only follow-up. | Documentation accuracy only; no behavior impact. | Comparison of the cited path with the actual folder name. |

## Verdict

PASS. No remediation is required for correctness; advisory items only.
