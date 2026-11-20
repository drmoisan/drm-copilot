# Phase 0 Commit and Push (P0-T35)

Timestamp: 2026-09-27T15-02

Command: git add docs/features/active/2026-08-07-blast-radius-under-reporting-gaps-452/v2
EXIT_CODE: 0

Command: git status --porcelain
EXIT_CODE: 0
Output: 18 added evidence files under v2/evidence/baseline plus modified v2/plan.2026-09-27T12-15.md and v2/spec.md; every listed path is under the v2 folder.

Command: git commit -F `<scratchpad>`/commit-phase0.txt
EXIT_CODE: 0
Output: [bug/blast-radius-under-reporting-regression-452 04ffb8ce] test(452): record v2 phase 0 baselines and runtime verification; 20 files changed, 628 insertions(+), 36 deletions(-)

Command: git push -u origin HEAD
EXIT_CODE: 0
Output: 2b5c34de..04ffb8ce  HEAD -> bug/blast-radius-under-reporting-regression-452

Pushed SHA: 04ffb8ce6adb502e164321f6e7519b8cd6bf1c4e

git rev-parse HEAD = 04ffb8ce6adb502e164321f6e7519b8cd6bf1c4e; git rev-parse @{upstream} = 04ffb8ce6adb502e164321f6e7519b8cd6bf1c4e (equal).

Output Summary: All four commands exited 0; the pre-commit porcelain capture listed only v2-folder paths; HEAD equals upstream after the push. The 36 changed plan/spec lines are the 34 P0 checkbox markers and the AC-6 and AC-7 markers.
