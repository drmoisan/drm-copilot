# TypeScript Coverage Delta (P17-T5)

Timestamp: 2026-09-27T18-13
Command: poetry run python SCRATCH/changed-lines-cov.py lcov extensions/drm-copilot/coverage/lcov.info beae3f021674e64fa6662097fe48a332d8da62b8 extensions/drm-copilot/src/lib/push-down/claude-blast-radius-derive-core.ts
EXIT_CODE: 0
Output Summary: PASS. Derivation core claude-blast-radius-derive-core.ts: % Lines baseline 100 (P0-T31) and final 100 (P17-T4), delta 0; % Branch baseline 97.5 and final 97.5, delta 0. Both final values are at least their baseline. Script changed-lines-cov (B42), reading the lcov file written by the P17-T4 run (file time equal to the end of that run) and anchored to FINAL_BASE beae3f021674e64fa6662097fe48a332d8da62b8, printed Found=True and ChangedLinePercent=100.00 (23 of 23 changed executable lines covered).

## Baseline vs final vs changed lines

| File | Baseline % Lines / % Branch (P0-T31) | Final % Lines / % Branch (P17-T4) | Delta | Changed executable | Covered | ChangedLinePercent |
| --- | --- | --- | --- | --- | --- | --- |
| extensions/drm-copilot/src/lib/push-down/claude-blast-radius-derive-core.ts | 100 / 97.5 | 100 / 97.5 | 0 / 0 | 23 | 23 | 100.00 |

## Script B42 output

```text
CHANGED file=extensions/drm-copilot/src/lib/push-down/claude-blast-radius-derive-core.ts Found=True ExecutableLines=394 ChangedExecutable=23 Covered=23 ChangedLinePercent=100.00
(exit 0)
```

SCRATCH denotes the executor session scratchpad directory (outside the repository).
