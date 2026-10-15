# TypeScript Adapter Coverage Delta (P7-T2)

Timestamp: 2026-10-10T08-30
Command: none (derived from recorded artifacts: evidence/baseline/adapter-coverage.2026-10-10T08-05.md, evidence/qa-gates/adapter-coverage.2026-10-10T08-29.md, evidence/qa-gates/jest-coverage.2026-10-10T08-28.md); threshold-entry presence confirmed by reading extensions/drm-copilot/jest.config.cjs
EXIT_CODE: 0
Output Summary:
- File: `extensions/drm-copilot/src/lib/push-down/claude-filesystem-adapter.ts`.
- BASELINE_ADAPTER_LINES = 94.39; FINAL_ADAPTER_LINES = 96.99; delta +2.60.
- BASELINE_ADAPTER_BRANCHES = 83.05; FINAL_ADAPTER_BRANCHES = 89.55; delta +6.50.
- Final values meet thresholds (96.99 >= 85; 89.55 >= 75).
- P6-T11 exited 0 with the threshold entry present: `jest.config.cjs` lines 331-334 carry `"./src/lib/push-down/claude-filesystem-adapter.ts": { lines: 85, branches: 75 }` (P4-T4).
- Result: PASS.
