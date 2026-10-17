# Remediation Cycle 2 Baseline Python Coverage (P0-T11)

Timestamp: 2026-10-16T06-19
Command: awk 'AWK_TOTALS' artifacts/python/lcov.info; for each target (validate_epic_planner_state.py, _epic_orchestrator_state_launch_binding.py, epic_planner_git_integrity.py, epic_planner_readiness.py): awk -v target=<target> 'AWK_FILE' artifacts/python/lcov.info and awk -v target=<target> 'AWK_ZERO' artifacts/python/lcov.info > SCRATCH/rc2/<stem>-zero-baseline.txt (the plan's one-line AWK_TOTALS, AWK_FILE, and AWK_ZERO program texts passed inline, verbatim)
EXIT_CODE: 0
Output Summary:
- FILES=214 LH=16580 LF=17665 LINE_PCT=93.86 BRH=5628 BRF=6380 BRANCH_PCT=88.21
- MATCHED=1 SF:scripts\dev_tools\validate_epic_planner_state.py LH=180 LF=191 LINE_PCT=94.24 BRH=88 BRF=100 BRANCH_PCT=88.00
- MATCHED=1 SF:scripts\dev_tools\_epic_orchestrator_state_launch_binding.py LH=117 LF=119 LINE_PCT=98.32 BRH=54 BRF=56 BRANCH_PCT=96.43
- MATCHED=1 SF:scripts\dev_tools\epic_planner_git_integrity.py LH=150 LF=151 LINE_PCT=99.34 BRH=85 BRF=86 BRANCH_PCT=98.84
- MATCHED=1 SF:scripts\dev_tools\epic_planner_readiness.py LH=178 LF=191 LINE_PCT=93.19 BRH=76 BRF=92 BRANCH_PCT=82.61
- py-validator zero lines: 121 127 151 152 154 156 158 194 277 286 356 (equals planning observation)
- py-lb zero lines: 188 299 (equals planning observation)
- py-git zero lines: 295 (equals planning observation)
- py-ready zero lines: 106 108 125 126 173 178 214 215 219 227 230 231 250 (not a CR-9 target; recorded)
- Repository-wide equals the policy-audit figure (93.86% / 88.21%). No CR-9 target list differs. Every per-file figure is at or above 85.00 line and 75.00 branch.
