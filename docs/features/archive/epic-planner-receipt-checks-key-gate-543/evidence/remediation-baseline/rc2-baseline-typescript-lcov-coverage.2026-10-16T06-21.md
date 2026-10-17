# Remediation Cycle 2 Baseline TypeScript lcov Coverage (P0-T17)

Timestamp: 2026-10-16T06-21
Command: awk 'AWK_TOTALS' extensions/drm-copilot/coverage/lcov.info; for each target (epic-planner-state-core.ts, epic-orchestrator-state-launch-binding.ts, epic-planner-git-integrity.ts, epic-planner-readiness-integrity.ts): awk -v target=<target> 'AWK_FILE' extensions/drm-copilot/coverage/lcov.info and awk -v target=<target> 'AWK_ZERO' extensions/drm-copilot/coverage/lcov.info > SCRATCH/rc2/<stem>-zero-baseline.txt (the plan's one-line program texts passed inline, verbatim)
EXIT_CODE: 0
Output Summary:
- FILES=212 LH=51226 LF=52661 LINE_PCT=97.28 BRH=7585 BRF=8214 BRANCH_PCT=92.34
- MATCHED=1 SF:src\lib\validate\epic-planner-state-core.ts LH=487 LF=495 LINE_PCT=98.38 BRH=112 BRF=119 BRANCH_PCT=94.12
- MATCHED=1 SF:src\lib\validate\epic-orchestrator-state-launch-binding.ts LH=327 LF=338 LINE_PCT=96.75 BRH=113 BRF=120 BRANCH_PCT=94.17
- MATCHED=1 SF:src\lib\validate\epic-planner-git-integrity.ts LH=331 LF=331 LINE_PCT=100.00 BRH=92 BRF=95 BRANCH_PCT=96.84
- MATCHED=1 SF:src\lib\validate\epic-planner-readiness-integrity.ts LH=339 LF=370 LINE_PCT=91.62 BRH=59 BRF=70 BRANCH_PCT=84.29
- ts-core zero lines: 69 70 75 76 78 79 276 277 (equals planning observation)
- ts-lb zero lines: 45 46 56 57 58 59 60 61 215 216 217 (equals planning observation)
- ts-git zero lines: (empty file)
- ts-ready zero lines (31): 37 38 39 40 42 43 68 69 70 71 72 73 131 132 177 178 179 180 181 182 183 192 193 197 198 224 225 226 227 338 339 (equals the O-3 list)
- No list differs from the planning observation. Every per-file figure is at or above 85.00 line and 75.00 branch.
