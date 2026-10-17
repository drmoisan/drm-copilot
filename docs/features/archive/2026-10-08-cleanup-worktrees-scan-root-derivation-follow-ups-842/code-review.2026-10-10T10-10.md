# Code Review - Issue #842

- Timestamp: 2026-10-10T10-10
- Branch: bug/cleanup-worktrees-scan-root-derivation-follow-ups-842
- Diff base: 179c586676d0f942043e349f7666852c551f25fb..HEAD (996a010dc)

## Executive Summary

The change is minimal and targeted: one guard line, two comment edits, five bats tests, two fixtures, and byte-identical bundle mirrors. No blocking findings. Three optional, non-blocking notes are recorded in the findings table. Verdict: approved; no remediation required.

### Production changes reviewed

1. `cleanup_worktrees_enumerate_lib.sh:351-352` adds a comment and `cleanup_wt_is_absolute_path "$parent" || continue` after the empty/self parent check and before `normalize_wt_path`. Placement is correct: the predicate (`/*` or `[A-Za-z]:[/\\]*`) rejects `D:` and accepts `D:/other`, so a drive-relative candidate is dropped before it reaches `seen`, main-ancestor, or inside-worktree logic. Behavior for POSIX roots and `C:/...` parents is unchanged. Rating: good.
2. `cleanup_worktrees_scan_helper.sh:43-44` adds the inline reason for SC1091. It sits above the `shellcheck source=` directive, which is acceptable because both directives apply to the following `source` line. Rating: good.
3. `cleanup_worktrees_detached_lib.sh:46` replaces a stale line range with the function reference `emit_record, nested in parse_worktree_list`. The reference is line-number-independent. Rating: good.

### Tests reviewed

- The `derive_run` helper (bats lines 58-63) discards stderr through a brace group so `$output` holds only emitted roots. It is consistent with the existing `roots_run` and `report_run` helpers.
- Five tests (bats lines 251-314) cover M-3 at three layers (derive, scan_roots, run_report single scan with exact argv) and N-1 at two layers. The negative loops (`D:` absent, no backslash) return 1 with a message, which gives actionable failures.
- Expect-fail evidence shows tests 17-19 failed before the fix and pass after. Tests 20-21 pass before and after; they characterize existing correct behavior, as documented.

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Note (non-blocking) | scripts/shell/cleanup_worktrees_enumerate_lib.sh | line 351 | The new comment is a single 130-character line, longer than neighboring comments. | None required; optionally wrap the comment. | shfmt and shellcheck accept the line; readability only. | evidence/qa-gates/shfmt.2026-10-10T09-52.md and shellcheck.2026-10-10T09-52.md: exit 0, no output. |
| Note (non-blocking) | tests/shell (scan_roots bats suite) | tests 20 and 21 | The backslash tests would pass without the fix, so they guard against regression and do not demonstrate a defect. | None required. | This is the stated purpose of N-1 (characterize existing correct behavior). | Expect-fail evidence in evidence/regression-testing: tests 20-21 pass before and after. |
| Note (non-blocking) | tests/shell (scan_roots bats suite) | third M-3 test | `grep -c ... \|\| true` is used to tolerate a zero count. | None required. | The construct is documented inline and correct. | Inline comment adjacent to the call; bats result 85/85 ok. |

## Verdict

Approved. No remediation required.
