# Final TypeScript Per-File, Changed-Line, and Repository-Wide Coverage (P8-T6)

Timestamp: 2026-10-16T06-49
Loop iteration: 1
Command: awk 'AWK_TOTALS' extensions/drm-copilot/coverage/lcov.info; for each stem/target/path (ts-core epic-planner-state-core.ts extensions/drm-copilot/src/lib/validate/epic-planner-state-core.ts; ts-lb epic-orchestrator-state-launch-binding.ts extensions/drm-copilot/src/lib/validate/epic-orchestrator-state-launch-binding.ts; ts-git epic-planner-git-integrity.ts extensions/drm-copilot/src/lib/validate/epic-planner-git-integrity.ts; ts-ready epic-planner-readiness-integrity.ts extensions/drm-copilot/src/lib/validate/epic-planner-readiness-integrity.ts): awk -v target=<target> 'AWK_FILE' extensions/drm-copilot/coverage/lcov.info; awk -v target=<target> 'AWK_ZERO' extensions/drm-copilot/coverage/lcov.info > SCRATCH/rc2/<stem>-zero-final.txt; grep -c -e '.' SCRATCH/rc2/<stem>-zero-final.txt; git diff -U0 afa951ac0207eae934ac695e7340f18b3cf77522 -- <path> > SCRATCH/rc2/<stem>-changed.diff; awk 'AWK_ADDED' SCRATCH/rc2/<stem>-changed.diff > SCRATCH/rc2/<stem>-added.txt; sort -u (both lists); comm -12 SCRATCH/rc2/<stem>-zero-sorted.txt SCRATCH/rc2/<stem>-added-sorted.txt > SCRATCH/rc2/<stem>-uncovered-added.txt; grep -c -e '.' SCRATCH/rc2/<stem>-uncovered-added.txt (MAIN_BASE_SHA substituted; one-line awk programs passed inline, verbatim)
EXIT_CODE: 0
Output Summary:
- FILES=212 LH=51271 LF=52679 LINE_PCT=97.33 BRH=7631 BRF=8251 BRANCH_PCT=92.49  (P0-T17: 97.28 / 92.34; +0.05 / +0.15)
- MATCHED=1 SF:src\lib\validate\epic-planner-state-core.ts LH=495 LF=495 LINE_PCT=100.00 BRH=123 BRF=127 BRANCH_PCT=96.85
- MATCHED=1 SF:src\lib\validate\epic-orchestrator-state-launch-binding.ts LH=338 LF=338 LINE_PCT=100.00 BRH=126 BRF=130 BRANCH_PCT=96.92
- MATCHED=1 SF:src\lib\validate\epic-planner-git-integrity.ts LH=369 LF=369 LINE_PCT=100.00 BRH=110 BRF=113 BRANCH_PCT=97.35
- MATCHED=1 SF:src\lib\validate\epic-planner-readiness-integrity.ts LH=327 LF=350 LINE_PCT=93.43 BRH=61 BRF=69 BRANCH_PCT=88.41
- Zero-line counts: ts-core 0, ts-lb 0, ts-git 0, ts-ready 23 (45 46 47 48 49 50 157 158 159 160 161 162 163 172 173 177 178 204 205 206 207 318 319; the pre-existing O-3 gaps renumbered after the 21-line removal; baseline lines 37-40 and 42-43 moved into the git-integrity module and are covered there)
- Added-line counts (vs MAIN_BASE_SHA): ts-core 65, ts-lb 6, ts-git 83, ts-ready 9
- Uncovered-added counts: ts-core 0, ts-lb 0, ts-git 0, ts-ready 0
- Python repository-wide: FILES=214 LH=16596 LF=17663 LINE_PCT=93.96 BRH=5644 BRF=6378 BRANCH_PCT=88.49 (from rc2-final-python-per-file-coverage.2026-10-16T06-44.md)
- Requirements met: per-file >= 85.00 / 75.00; zero-line count 0 for ts-core, ts-lb, ts-git (no line recorded unreachable); uncovered-added 0 for all four; repository-wide not lower than P0-T17.
