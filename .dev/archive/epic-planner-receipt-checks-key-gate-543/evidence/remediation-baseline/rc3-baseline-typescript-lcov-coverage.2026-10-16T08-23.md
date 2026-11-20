# Remediation Cycle 3 Baseline TypeScript Lcov Coverage (P0-T17)

Timestamp: 2026-10-16T08-23
Command: awk 'AWK_TOTALS' extensions/drm-copilot/coverage/lcov.info; for each target (epic-planner-git-integrity.ts, epic-planner-readiness-integrity.ts): awk -v target=<target> 'AWK_FILE' extensions/drm-copilot/coverage/lcov.info and awk -v target=<target> 'AWK_ZERO' extensions/drm-copilot/coverage/lcov.info > SCRATCH/rc3/<stem>-zero-baseline.txt; tr '\n' ' ' < SCRATCH/rc3/<stem>-zero-baseline.txt (program texts passed inline, verbatim; one invocation per target)
EXIT_CODE: 0
Output Summary:
- FILES=212 LH=51271 LF=52679 LINE_PCT=97.33 BRH=7631 BRF=8251 BRANCH_PCT=92.49
- MATCHED=1 SF:src\lib\validate\epic-planner-git-integrity.ts LH=369 LF=369 LINE_PCT=100.00 BRH=110 BRF=113 BRANCH_PCT=97.35
- MATCHED=1 SF:src\lib\validate\epic-planner-readiness-integrity.ts LH=327 LF=350 LINE_PCT=93.43 BRH=61 BRF=69 BRANCH_PCT=88.41
- ts-git zero lines: (empty; LH equals LF; equals planning observation)
- ts-ready zero lines: 45 46 47 48 49 50 157 158 159 160 161 162 163 172 173 177 178 204 205 206 207 318 319 (equals planning observation; CR-15 TypeScript targets unchanged)
- Every per-file figure is at or above 85.00 line and 75.00 branch.
