# TypeScript lcov Per-File Coverage (Remediation Cycle 1, R1)

Timestamp: 2026-10-02T06-54
Task: P1-T3 of remediation-plan.2026-10-02T05-58.md
Command: poetry run python <scratchpad>/ts_coverage_543.py per-file (run from the worktree root; script written verbatim from the plan's "Scratchpad scripts" section)
EXIT_CODE: 0
Output Summary:
- Source: the `SF:` records for the five files below in `extensions/drm-copilot/coverage/lcov.info` (written 2026-10-02T06-53-09 by the P1-T1 run). Percentages are `LH/LF` and `BRH/BRF` floored to two decimals; the floors are checked with integer arithmetic (`LH*100 >= 85*LF`, `BRH*100 >= 75*BRF`).
- Verbatim output:
  - `src/lib/validate/epic-orchestrator-state-launch-binding.ts LF=334 LH=321 BRF=119 BRH=111 line=96.10 branch=93.27 floors=PASS`
  - `src/lib/validate/epic-planner-launch-evidence.ts LF=469 LH=435 BRF=116 BRH=98 line=92.75 branch=84.48 floors=PASS`
  - `src/lib/validate/epic-planner-readiness-integrity.ts LF=370 LH=339 BRF=70 BRH=59 line=91.62 branch=84.28 floors=PASS`
  - `src/lib/validate/epic-planner-state-core.ts LF=471 LH=463 BRF=109 BRH=102 line=98.30 branch=93.57 floors=PASS`
  - `src/lib/validate/orchestration-artifacts.ts LF=369 LH=369 BRF=82 BRH=80 line=100.00 branch=97.56 floors=PASS`
  - `SUMMARY files=5 failures=0`
- No `MISSING-RECORD` line and no `floors=FAIL`.
