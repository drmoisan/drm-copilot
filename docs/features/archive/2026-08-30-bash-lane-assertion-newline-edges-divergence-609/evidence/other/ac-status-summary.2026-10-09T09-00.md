# AC status summary (superseding; written under #846)

Timestamp: 2026-10-09T21-39
Command: git grep -c -e "^- \[x\] " -- docs/features/active/2026-08-30-bash-lane-assertion-newline-edges-divergence-609/spec.md
EXIT_CODE: 0
Output Summary: `docs/features/active/2026-08-30-bash-lane-assertion-newline-edges-divergence-609/spec.md:17` (17 checked acceptance criteria).

## Total

Command: git grep -c -e "^- \[[ x]\] " -- docs/features/active/2026-08-30-bash-lane-assertion-newline-edges-divergence-609/spec.md
EXIT_CODE: 0
Output Summary: `docs/features/active/2026-08-30-bash-lane-assertion-newline-edges-divergence-609/spec.md:17` (17 acceptance criteria in total).

Neither command was denied by the worktree command-text guard, so the quoted-pathspec fallback form was not used.

Supersedes: evidence/other/ac-gaps.2026-09-29T18-45.md, evidence/other/ac-status-summary.2026-09-29T18-45.md, evidence/qa-gates/coverage-comparison.2026-09-29T18-45.md, evidence/regression-testing/fail-before-exception.2026-09-29T18-45.md. Those four files are retained unchanged as point-in-time records.

### Acceptance Criteria Status

- Source: docs/features/active/2026-08-30-bash-lane-assertion-newline-edges-divergence-609/spec.md
- Total AC items: 17
- Checked off (delivered): 17
- Remaining (unchecked): 0
- Items remaining: none

| AC | Resolved by | Detail |
| --- | --- | --- |
| AC-6 | evidence/regression-testing/bats-unit-before.2026-10-02T03-53.md | fail-first CI run 36961456506; pass-after run 36960736942 |
| AC-14 | evidence/qa-gates/ci-per-file-coverage.2026-10-02T03-44.md | per-file line-rate 0.989 on the PR head and on main |
