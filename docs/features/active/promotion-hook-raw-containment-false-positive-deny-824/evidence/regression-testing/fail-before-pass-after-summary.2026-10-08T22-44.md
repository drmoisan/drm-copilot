# Fail-Before / Pass-After Summary per Named Reproduction ([P8-T3])

Timestamp: 2026-10-08T22-44

Sources:
- Fail-before: `evidence/regression-testing/fail-before.2026-10-08T17-50.md` ([P1-T2], `sh <SCRATCHPAD>/s-pester.sh REG`, EXIT_CODE 1, ExpectedExitCode 1, 23 executions failed against the unchanged production tree at BASE_SHA).
- Pass-after: `evidence/regression-testing/pass-after.2026-10-08T22-42.md` ([P8-T1], `sh <SCRATCHPAD>/s-pester.sh REG`, EXIT_CODE 0, 23 executions passed at HEAD 8c1b4892).

| Named reproduction | REG row IDs | [P1-T2] result | [P8-T1] result |
|---|---|---|---|
| R-824-MAIN | REG-01 (claude, codex) | Failed | Passed |
| R-824-ADD1 | REG-02, REG-04, REG-06 | Failed | Passed |
| R-742-1 | REG-03, REG-05, REG-07, REG-08 (claude, codex) | Failed | Passed |
| R-733-714 | REG-09 | Failed | Passed |
| R-733-GREP | REG-10 (G1), REG-11 (G2), REG-12 (G3) | Failed | Passed |
| R-733-715 | REG-13..REG-17 (S1-S5) | Failed | Passed |
| R-733-712 | REG-18 (chain), REG-19, REG-20, REG-21 (singles) | Failed | Passed |

Row count: 7 named reproductions; every row is Failed before and Passed after. Every REG row of each reproduction failed in [P1-T2] and passed in [P8-T1].
