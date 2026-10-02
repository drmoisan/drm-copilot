# P2-T15 Reduced-audit handoff (minor-audit evidence index, issue #741)

Timestamp: 2026-10-02T04-24
Command: `ls docs/features/active/2026-09-27-cleanup-worktrees-scan-roots-and-orphan-root-split-741/evidence/baseline docs/features/active/2026-09-27-cleanup-worktrees-scan-roots-and-orphan-root-split-741/evidence/regression-testing docs/features/active/2026-09-27-cleanup-worktrees-scan-roots-and-orphan-root-split-741/evidence/qa-gates docs/features/active/2026-09-27-cleanup-worktrees-scan-roots-and-orphan-root-split-741/evidence/other`
EXIT_CODE: 0
Output Summary:
- Every artifact path named below appears in the listing (verified after writing this file).
- AC source: docs/features/active/2026-09-27-cleanup-worktrees-scan-roots-and-orphan-root-split-741/issue.md `## Acceptance Criteria` (12 of 12 checked; FEATURE/evidence/other/ac-checkoff.2026-10-02T04-23.md).
- Plan: docs/features/active/2026-09-27-cleanup-worktrees-scan-roots-and-orphan-root-split-741/plan.2026-09-29T22-26.md; deviations DEV-1..DEV-8 in `## Plan deviations`. BASE_SHA df5eb303129a30289a7d81775fdadaa40631be63; production change commit 598691e72e2e9c0ee180c55e9678798bdbdaaf37; FINAL_SHA (CI-measured) 10c6ac2951786a80327d0fff4041d6d8bb06885b.

## Evidence index (paths relative to FEATURE/evidence/)

| AC | Evidence artifacts |
| --- | --- |
| AC-1 | regression-testing/expect-fail-scan-roots.2026-10-02T03-47.md; regression-testing/pass-after-scan-roots.2026-10-02T04-06.md; qa-gates/bats-targeted.2026-10-02T04-07.md; qa-gates/shell-coverage-ci.2026-10-02T04-21.md |
| AC-2 | regression-testing/expect-fail-scan-roots.2026-10-02T03-47.md; regression-testing/pass-after-scan-roots.2026-10-02T04-06.md; qa-gates/bats-targeted.2026-10-02T04-07.md |
| AC-3 | other/p1-t6.2026-10-02T03-52.md; qa-gates/bats-targeted.2026-10-02T04-07.md; qa-gates/ac12-boundary.2026-10-02T04-07.md |
| AC-4 | regression-testing/pass-after-scan-roots.2026-10-02T04-06.md; qa-gates/bats-targeted.2026-10-02T04-07.md |
| AC-5 | regression-testing/expect-fail-scan-roots.2026-10-02T03-47.md; regression-testing/pass-after-scan-roots.2026-10-02T04-06.md; qa-gates/bats-targeted.2026-10-02T04-07.md |
| AC-6 | regression-testing/expect-fail-scan-roots.2026-10-02T03-47.md; regression-testing/pass-after-scan-roots.2026-10-02T04-06.md; qa-gates/bats-targeted.2026-10-02T04-07.md |
| AC-7 | qa-gates/structural-checks.2026-10-02T04-07.md; regression-testing/pass-after-scan-roots.2026-10-02T04-06.md; qa-gates/bats-targeted.2026-10-02T04-07.md |
| AC-8 | other/p1-t9.2026-10-02T03-55.md; qa-gates/structural-checks.2026-10-02T04-07.md |
| AC-9 | qa-gates/mirror-identity.2026-10-02T04-07.md; qa-gates/bundle-parity-pytest.2026-10-02T04-07.md |
| AC-10 | qa-gates/doc-contract.2026-10-02T04-07.md |
| AC-11 | qa-gates/shfmt.2026-10-02T04-07.md; qa-gates/shellcheck.2026-10-02T04-07.md; qa-gates/line-counts.2026-10-02T04-07.md; qa-gates/shell-coverage-ci.2026-10-02T04-21.md; qa-gates/coverage-delta.2026-10-02T04-22.md |
| AC-12 | qa-gates/ac12-boundary.2026-10-02T04-07.md; qa-gates/scope.2026-10-02T04-07.md |

## Supporting artifacts

- Phase 0: baseline/phase0-instructions-read.md; baseline/phase0-mode-check.2026-10-02T03-29.md; baseline/base-sha.2026-10-02T03-34.md; baseline/shell-coverage-ci.2026-10-02T03-47.md (BASELINE_AGGREGATE 93.7); baseline/bats-targeted.2026-10-02T03-34.md.
- Commit and push: other/commit-push.2026-10-02T04-11.md.

## Notes for the reviewer

- DEV-2 (operator decision, Option A): bats ran only in CI; scratch scripts A1/A2 were replaced by plain git plus Read/Grep derivations.
- Coverage: FINAL_AGGREGATE 93.8 (DELTA +0.1). Changed-line coverage 82/83 (98.8%); the one missed line is enumerate_lib line 370, the `done < <(...)` terminator of a loop whose body ran, most likely a kcov attribution effect. report_records_lib (0.890 -> 0.879) and scan_helper (0.875 -> 0.873) dropped slightly because covered lines were removed; neither has an uncovered changed line.
- DEV-6/DEV-8: `grep -rn load_helper tests` prints two lines in an out-of-scope fixture (`tests/fixtures/shell_qc/stub-bin/bats-nounset-source-reset`); AC-8's scoped count is 0.
