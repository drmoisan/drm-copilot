# Feature Audit - Issue #842

- Timestamp: 2026-10-10T10-10
- Branch: bug/cleanup-worktrees-scan-root-derivation-follow-ups-842

## Scope and Baseline

- Work mode: minor-audit
- AC source: docs/features/active/2026-10-08-cleanup-worktrees-scan-root-derivation-follow-ups-842/issue.md `## Acceptance Criteria`
- Diff base: 179c586676d0f942043e349f7666852c551f25fb..HEAD (996a010dc)
- Scope: the diff contains exactly the nine Write-list files (3 shell scripts, 3 bundle mirrors, 2 fixtures, 1 bats suite) plus feature documentation and evidence. No out-of-scope files. The issue.md assumption (drop a drive-relative candidate rather than emit `D:/`) is honored.

## Acceptance Criteria Inventory

| ID | Criterion (short) | Source |
|---|---|---|
| AC-1 | M-3: drive-relative parent is dropped during scan-root derivation | issue.md |
| AC-2 | N-1: backslash registration paths convert to forward-slash roots | issue.md |
| AC-3 | scan_roots / run_report do not emit or scan a drive-relative root | issue.md |
| AC-4 | M-2: SC1091 suppression states its reason | issue.md |
| AC-5 | M-1: stale line-range reference replaced by function reference | issue.md |
| AC-6 | Bundle mirrors are byte-identical to the source scripts | issue.md |
| AC-7 | shfmt, shellcheck, bats clean; bash line coverage not regressed | issue.md |

## Acceptance Criteria Evaluation

| AC | Verdict | Evidence |
|---|---|---|
| AC-1 (M-3) | PASS | enumerate_lib.sh:352 calls `cleanup_wt_is_absolute_path "$parent" \|\| continue`; bats test "cleanup_wt_derive_scan_roots drops a drive-relative parent..." (ok 17) fails before the fix and passes after. |
| AC-2 (N-1) | PASS | Test "cleanup_wt_derive_scan_roots converts a backslash registration path..." asserts `C:/repo/main-wt` and `C:/scratch/plan` from `C:\repo\main-wt\a` and `C:\scratch\plan\p1`; ok 20, plus ok 21 on the combined list. |
| AC-3 | PASS | Test "cleanup_wt_scan_roots does not emit a drive-relative root for a D:/wt registration" (ok 18) asserts 3 roots and no `D:`; ok 19 asserts the single scan argv. |
| AC-4 (M-2) | PASS | scan_helper.sh:43-44 inline reason; shellcheck exit 0. |
| AC-5 (M-1) | PASS | detached_lib.sh:46 names `emit_record` in `parse_worktree_list`; the stale `enumerate_lib.sh:115` string count is 0. |
| AC-6 | PASS | `cmp` identical for all three pairs (re-run in this review); bundle-parity pytest 14 passed. |
| AC-7 | PENDING-CI (not blocking) | Local shfmt and shellcheck: exit 0, no findings. Local bats: 85/85 ok (baseline 80 + 5). Bash line coverage non-regression requires the PR CI kcov run (P2-T17); baseline aggregate 94.2%, enumerate_lib 0.953. Intentionally left unchecked. |

## Summary

Delivered scope satisfies AC-1 through AC-6. Overall verdict: PASS with AC-7 pending CI. No blocking findings; no remediation-inputs artifact is required.

### Acceptance Criteria Status

- Source: docs/features/active/2026-10-08-cleanup-worktrees-scan-root-derivation-follow-ups-842/issue.md
- Total AC items: 7
- Checked off (delivered): 6
- Remaining (unchecked): 1
- Items remaining: AC-7 (shfmt/shellcheck/bats clean with bash line coverage not regressed; pending PR CI run, P2-T17 and P2-T18)

## Acceptance Criteria Check-off

- AC-1 through AC-6 are already checked in issue.md and match the PASS verdicts above; no further check-off is needed.
- AC-7 stays unchecked because its coverage evidence (P2-T17) requires the PR and a CI run.
- Newly checked off in this review: none.
