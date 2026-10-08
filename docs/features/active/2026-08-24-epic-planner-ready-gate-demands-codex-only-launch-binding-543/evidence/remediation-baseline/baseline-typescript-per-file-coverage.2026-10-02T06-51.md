# Baseline TypeScript Per-File Coverage (Remediation Cycle 1)

Timestamp: 2026-10-02T06-51
Task: P0-T3 of remediation-plan.2026-10-02T05-58.md
Command: grep -nF '.ts |' docs/features/active/2026-08-24-epic-planner-ready-gate-demands-codex-only-launch-binding-543/evidence/baseline/baseline-typescript-test-coverage.2026-10-02T05-01.md
EXIT_CODE: 0
Output Summary:
- Five matched lines (lines 13-17), verbatim:
  - `13:  - \`epic-orchestrator-state-launch-binding.ts | 96 | 92.79 | 100 | 96 | 45-46,56-61,215-217,256-257\``
  - `14:  - \`epic-planner-launch-evidence.ts | 91.64 | 80.61 | 100 | 91.64 | 34-37,52-55,78-83,88-96,190-191,202-203,212,223-224,269-270,383-384,399-400,406-407\``
  - `15:  - \`epic-planner-readiness-integrity.ts | 91.48 | 82.81 | 100 | 91.48 | 36-39,41-42,67-72,130-131,176-182,191-192,196-197,223-226,332-333\``
  - `16:  - \`epic-planner-state-core.ts | 98.26 | 93.51 | 100 | 98.26 | 65-66,71-72,74-75,269-270\``
  - `17:  - \`orchestration-artifacts.ts | 100 | 97.43 | 100 | 100 | 308,358\``
- Column order is the Istanbul `text` table order (% Stmts | % Branch | % Funcs | % Lines | Uncovered Line #s).
- Baseline `% Lines` / `% Branch` per file:
  - `epic-orchestrator-state-launch-binding.ts`: 96 / 92.79
  - `epic-planner-launch-evidence.ts`: 91.64 / 80.61
  - `epic-planner-readiness-integrity.ts`: 91.48 / 82.81
  - `epic-planner-state-core.ts`: 98.26 / 93.51
  - `orchestration-artifacts.ts`: 100 / 97.43
- These are `text`-table values from the original pre-change run recorded in the baseline artifact. No baseline `lcov.info` exists (plan decision 3), so the lcov-derived post-change values in Phase 1 are compared against these text-table values with a no-decrease rule.
- Stop condition not triggered: match count is 5 and every value equals the plan's list.
