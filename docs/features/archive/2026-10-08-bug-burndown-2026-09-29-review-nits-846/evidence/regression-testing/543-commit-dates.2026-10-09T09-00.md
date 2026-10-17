# Regression: #543 commit dates for the timestamp correction ([P7-T19], AC-27)

Timestamp: 2026-10-09T21-40
Command: git log -1 --format="%H %ad %cd" 0c6abb95
EXIT_CODE: 0
Output Summary: `0c6abb952153b38726ae65a5c0b438adc37e6e8b Fri Oct 2 05:14:57 2026 -0400 Fri Oct 2 05:14:57 2026 -0400`. Author and committer time are both 2026-10-02 05:14:57 -04:00, matching the research expectation; [P7-T20] uses 2026-10-02T05-14 as planned.

## Block 2 (assumption A6)

Command: git log --format="%h %ad" -S"### Reset 1 (P2-T4)" -- docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/evidence/other/python-batch-budget.2026-10-02T05-01.md
EXIT_CODE: 0
Output Summary: one commit listed: `af88dd585 Fri Oct 2 05:19:12 2026 -0400`.

Reset1-First-Commit: 2026-10-02T05-19 (af88dd585, author time 2026-10-02 05:19:12 -04:00)
Decision: A6-SKIP (the first commit containing the Reset 1 section is later than 2026-10-02 05:18 -04:00, so the recorded Reset 1 value 2026-10-02T05-18 is not later than that commit; lines 32-33 stay unchanged and the observation is carried to the closure-dispositions record).

Acceptance: first block prints the full SHA with author and committer dates; second block lists at least one commit; Reset1-First-Commit and decision recorded. PASS.
