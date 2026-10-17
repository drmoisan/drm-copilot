# Remediation Cycle 1 Baseline TypeScript lcov Coverage (P0-T20)

Timestamp: 2026-10-16T03-51
Command: awk '<lcov-totals.awk program>' extensions/drm-copilot/coverage/lcov.info; awk -v target=epic-planner-state-core.ts '<lcov-file.awk program>' extensions/drm-copilot/coverage/lcov.info; awk -v target=epic-planner-state-core.ts '<lcov-zero-lines.awk program>' extensions/drm-copilot/coverage/lcov.info > SCRATCH/rc1/ts-zero-lines-baseline.txt; awk -v target=epic-orchestrator-state-launch-binding.ts '<lcov-file.awk program>' extensions/drm-copilot/coverage/lcov.info; awk -v target=epic-orchestrator-state-launch-binding.ts '<lcov-zero-lines.awk program>' extensions/drm-copilot/coverage/lcov.info > SCRATCH/rc1/ts-lb-zero-lines-baseline.txt; awk -v target=epic-planner-git-integrity.ts '<lcov-file.awk program>' extensions/drm-copilot/coverage/lcov.info; awk -v target=epic-planner-git-integrity.ts '<lcov-zero-lines.awk program>' extensions/drm-copilot/coverage/lcov.info > SCRATCH/rc1/ts-git-zero-lines-baseline.txt (helper program text passed inline; the guard refuses awk -f)
EXIT_CODE: 0
Output Summary:
- Repository-wide: FILES=212 LH=51173 LF=52610 LINE_PCT=97.27 BRH=7568 BRF=8200 BRANCH_PCT=92.29
- MATCHED=1 SF:src\lib\validate\epic-planner-state-core.ts LH=480 LF=488 LINE_PCT=98.36 BRH=111 BRF=118 BRANCH_PCT=94.07
- MATCHED=1 SF:src\lib\validate\epic-orchestrator-state-launch-binding.ts LH=321 LF=334 LINE_PCT=96.11 BRH=111 BRF=119 BRANCH_PCT=93.28
- MATCHED=1 SF:src\lib\validate\epic-planner-git-integrity.ts LH=291 LF=291 LINE_PCT=100.00 BRH=78 BRF=83 BRANCH_PCT=93.98
- SCRATCH/rc1/ts-zero-lines-baseline.txt: 69, 70, 75, 76, 78, 79, 273, 274 (matches the prior text run 69-70,75-76,78-79,273-274)
- SCRATCH/rc1/ts-lb-zero-lines-baseline.txt: 45, 46, 56, 57, 58, 59, 60, 61, 215, 216, 217, 258, 259
- SCRATCH/rc1/ts-git-zero-lines-baseline.txt: (empty)
- All three files meet 85.00 line and 75.00 branch; the plan continues.
