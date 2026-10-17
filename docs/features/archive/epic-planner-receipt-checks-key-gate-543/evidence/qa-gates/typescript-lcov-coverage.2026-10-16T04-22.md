# TypeScript lcov Coverage, Artifact-Verified (P6-T6, R1)

Timestamp: 2026-10-16T04-22
Loop iteration: 1
Command: npm --prefix extensions/drm-copilot run test:coverage; awk '<lcov-totals.awk program>' extensions/drm-copilot/coverage/lcov.info; then for each (target, path, stem) in (epic-planner-state-core.ts, extensions/drm-copilot/src/lib/validate/epic-planner-state-core.ts, ts), (epic-orchestrator-state-launch-binding.ts, extensions/drm-copilot/src/lib/validate/epic-orchestrator-state-launch-binding.ts, ts-lb), (epic-planner-git-integrity.ts, extensions/drm-copilot/src/lib/validate/epic-planner-git-integrity.ts, ts-git): awk -v target=<target> '<lcov-file.awk program>' extensions/drm-copilot/coverage/lcov.info; awk -v target=<target> '<lcov-zero-lines.awk program>' extensions/drm-copilot/coverage/lcov.info > SCRATCH/rc1/<stem>-zero-lines-final.txt; git diff -U0 main -- <path> > SCRATCH/rc1/<stem>-changed.diff; awk '<diff-added-lines.awk program>' SCRATCH/rc1/<stem>-changed.diff > SCRATCH/rc1/<stem>-added-lines.txt; grep -c -x -F -f SCRATCH/rc1/<stem>-zero-lines-final.txt SCRATCH/rc1/<stem>-added-lines.txt (helper program text passed inline; the guard refuses awk -f)
EXIT_CODE: 0
Output Summary:
- lcov path: extensions/drm-copilot/coverage/lcov.info
- Repository-wide: FILES=212 LH=51226 LF=52661 LINE_PCT=97.28 BRH=7585 BRF=8214 BRANCH_PCT=92.34 (meets 85.00 / 75.00)
- MATCHED=1 SF:src\lib\validate\epic-planner-state-core.ts LH=487 LF=495 LINE_PCT=98.38 BRH=112 BRF=119 BRANCH_PCT=94.12
- MATCHED=1 SF:src\lib\validate\epic-orchestrator-state-launch-binding.ts LH=327 LF=338 LINE_PCT=96.75 BRH=113 BRF=120 BRANCH_PCT=94.17
- MATCHED=1 SF:src\lib\validate\epic-planner-git-integrity.ts LH=331 LF=331 LINE_PCT=100.00 BRH=92 BRF=95 BRANCH_PCT=96.84
- SCRATCH/rc1/ts-zero-lines-final.txt: 69, 70, 75, 76, 78, 79, 276, 277
- SCRATCH/rc1/ts-added-lines.txt: 161, 164, 165, 170, 171, 176, 183, 208, 213, 215, 219, 243, 278, 294-300, 302, 303, 306, 312, 339, 340, 342-345, 347, 349, 352-364, 367-374, 413, 437-440, 455-461
- SCRATCH/rc1/ts-lb-zero-lines-final.txt: 45, 46, 56, 57, 58, 59, 60, 61, 215, 216, 217
- SCRATCH/rc1/ts-lb-added-lines.txt: 295, 296, 297, 298, 299, 301
- SCRATCH/rc1/ts-git-zero-lines-final.txt: (empty, 0 bytes)
- SCRATCH/rc1/ts-git-added-lines.txt: 177-219, 248, 249
- Uncovered added lines, core: 0 (exit 1 by design)
- Uncovered added lines, launch binding: 0 (exit 1 by design)
- Uncovered added lines, git integrity: the grep -c command printed no output and exited 1 because its pattern file is empty (this grep build prints nothing for an empty -f file rather than 0). The zero-hit list is 0 bytes and LH equals LF (331/331), so the uncovered added-line count is 0. Recorded as a plan deviation.
- Python repository-wide (PA-N2): FILES=214 LH=16580 LF=17665 LINE_PCT=93.86 BRH=5628 BRF=6380 BRANCH_PCT=88.21 (from evidence/qa-gates/python-repo-wide-coverage.2026-10-16T04-18.md)
- Per-file and repository-wide figures all meet 85.00 line and 75.00 branch.
