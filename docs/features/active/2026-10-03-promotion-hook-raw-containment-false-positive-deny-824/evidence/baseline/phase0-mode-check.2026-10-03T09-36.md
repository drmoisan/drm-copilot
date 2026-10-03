# P0-T1 Full-bug mode preconditions

Timestamp: 2026-10-03T09-36
Command: pwsh -NoProfile -File SCRATCH/steps/p0-t1.ps1 -Worktree WORKTREE (Get-ChildItem -Name FEATURE; Select-String counts for 'Work Mode: full-bug' in issue.md, '^## Acceptance Criteria$' in spec.md, '^- \[ \] AC-\d+:' in spec.md)
EXIT_CODE: 0
Output Summary:
- Listing: research, issue.md, plan.2026-10-03T08-09.md, spec.md (spec.md present)
- 'Work Mode: full-bug' count in issue.md: 1
- '## Acceptance Criteria' heading count in spec.md: 1
- Unchecked AC item count in spec.md: 29
- Result: PASS (expected 1, 1, 29)
