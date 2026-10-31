# extension.ts Threshold Decision (Issue #1003)

Timestamp: 2026-10-31T12-57
Command: rule from plan `## Assumptions and Resolved Questions` applied to evidence/baseline/jest-coverage.2026-10-31T12-56.md
EXIT_CODE: 0
Output Summary: baseline src/extension.ts lines 97.38% (LH/LF 483/496 = 0.9738 >= 0.85) and branches 90.91% (BRH/BRF 60/66 = 0.9091 >= 0.75); decision ADD-ENTRY.

Baseline line percentage: 97.38% (483/496)
Baseline branch percentage: 90.91% (60/66)

Comparison:
- LH/LF = 0.9738 >= 0.85: true
- BRH/BRF = 0.9091 >= 0.75: true

Decision: ADD-ENTRY

[P2-T3] adds `"./src/extension.ts": { lines: 85, branches: 75 }` to `coverageThreshold` in `extensions/drm-copilot/jest.config.cjs`.
