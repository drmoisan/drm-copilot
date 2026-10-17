# Final Python Per-File, Changed-Line, and Repository-Wide Coverage (P7-T6)

Timestamp: 2026-10-16T06-43
Loop iteration: 1
Command: awk 'AWK_TOTALS' artifacts/python/lcov.info; for each stem/target/path (py-validator validate_epic_planner_state.py scripts/dev_tools/validate_epic_planner_state.py; py-lb _epic_orchestrator_state_launch_binding.py scripts/dev_tools/_epic_orchestrator_state_launch_binding.py; py-git epic_planner_git_integrity.py scripts/dev_tools/epic_planner_git_integrity.py; py-ready epic_planner_readiness.py scripts/dev_tools/epic_planner_readiness.py): awk -v target=<target> 'AWK_FILE' artifacts/python/lcov.info; awk -v target=<target> 'AWK_ZERO' artifacts/python/lcov.info > SCRATCH/rc2/<stem>-zero-final.txt; grep -c -e '.' SCRATCH/rc2/<stem>-zero-final.txt; git diff -U0 afa951ac0207eae934ac695e7340f18b3cf77522 -- <path> > SCRATCH/rc2/<stem>-changed.diff; awk 'AWK_ADDED' SCRATCH/rc2/<stem>-changed.diff > SCRATCH/rc2/<stem>-added.txt; sort -u SCRATCH/rc2/<stem>-zero-final.txt > SCRATCH/rc2/<stem>-zero-sorted.txt; sort -u SCRATCH/rc2/<stem>-added.txt > SCRATCH/rc2/<stem>-added-sorted.txt; comm -12 SCRATCH/rc2/<stem>-zero-sorted.txt SCRATCH/rc2/<stem>-added-sorted.txt > SCRATCH/rc2/<stem>-uncovered-added.txt; grep -c -e '.' SCRATCH/rc2/<stem>-uncovered-added.txt (MAIN_BASE_SHA substituted; the plan's one-line awk programs passed inline, verbatim; each stem's commands were run with its literal values)
EXIT_CODE: 0
Output Summary:
- FILES=214 LH=16596 LF=17663 LINE_PCT=93.96 BRH=5644 BRF=6378 BRANCH_PCT=88.49  (P0-T11: 93.86 / 88.21; +0.10 / +0.28)
- MATCHED=1 SF:scripts\dev_tools\validate_epic_planner_state.py LH=191 LF=191 LINE_PCT=100.00 BRH=99 BRF=100 BRANCH_PCT=99.00
- MATCHED=1 SF:scripts\dev_tools\_epic_orchestrator_state_launch_binding.py LH=119 LF=119 LINE_PCT=100.00 BRH=56 BRF=56 BRANCH_PCT=100.00
- MATCHED=1 SF:scripts\dev_tools\epic_planner_git_integrity.py LH=158 LF=158 LINE_PCT=100.00 BRH=90 BRF=90 BRANCH_PCT=100.00
- MATCHED=1 SF:scripts\dev_tools\epic_planner_readiness.py LH=173 LF=182 LINE_PCT=95.05 BRH=74 BRF=86 BRANCH_PCT=86.05
- Zero-line counts: py-validator 0, py-lb 0, py-git 0, py-ready 9 (113 114 202 203 207 215 218 219 238; pre-existing readiness gaps, O-3, not a CR-9 target)
- Added-line counts (vs MAIN_BASE_SHA): py-validator 88, py-lb 7, py-git 66, py-ready 6
- Uncovered-added counts: py-validator 0, py-lb 0, py-git 0, py-ready 0
- Requirements met: every per-file LINE_PCT >= 85.00 and BRANCH_PCT >= 75.00; zero-line count 0 for py-validator, py-lb, py-git (no line recorded unreachable); uncovered-added 0 for all four; repository-wide >= 85.00 / 75.00 and not lower than P0-T11.
