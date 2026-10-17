# B1 Baseline: Host Paths and Encoded Host Names (P0-T5, Issue #934, remediation cycle 1)

Timestamp: 2026-10-16T02-42
Command: git grep --untracked -n -i -E -e '[[:alpha:]]:[^[:alnum:][:space:]]{1,2}users[^[:alnum:][:space:]]{1,2}[[:alpha:]]|[[:alpha:]]--users-[[:alpha:]]' -- docs/features/active/2026-10-15-workspace-encoding-test-host-specific-paths-934/issue.md docs/features/active/2026-10-15-workspace-encoding-test-host-specific-paths-934/plan.2026-10-15T17-44.md docs/features/active/2026-10-15-workspace-encoding-test-host-specific-paths-934/remediation-plan.2026-10-16T01-25.md docs/features/active/2026-10-15-workspace-encoding-test-host-specific-paths-934/research docs/features/active/2026-10-15-workspace-encoding-test-host-specific-paths-934/evidence   (raw output redirected to SCRATCH/issue-934/b1-baseline.log)
EXIT_CODE: 0
Output Summary:
- Matched lines (path:line-number only, per redaction rule item 2; no matched content recorded):
  - `RESEARCH:55`
  - `RESEARCH:107`
  - `RESEARCH:108`
  - `RESEARCH:109`
  - `RESEARCH:110`
  - `RESEARCH:111`
- `RESEARCH` = `docs/features/active/2026-10-15-workspace-encoding-test-host-specific-paths-934/research/2026-10-15T17-50-workspace-encoding-host-paths-research.md`.
- Six lines in one file; no match in `issue.md`, the cycle-0 plan, this remediation plan, or `evidence/` (tracked and untracked). Matches the planner expectation exactly.
