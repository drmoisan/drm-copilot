# Preflight Fixes

Timestamp: 2026-11-10T01-43
Plan: docs/features/active/2026-11-09-test-execution-policy-machine-lock-1158/plan.2026-11-09T16-31.md

## Fix 1

- Task: [P1-T5]
- Defect class: stale anchor (dangling reference)
- Finding: the Tests text cites "the eight D19 npm rows", but neither the plan nor spec.md enumerates them. An earlier plan revision listed them in P1-T1, and the enumeration was dropped when the runner matcher moved to P1-T5. P4-T1 cites the same rows.
- Change made: restored the eight rows from the earlier P1-T1 text after "the eight D19 npm rows": `npm test`, `npm t`, `npm run test`, `npm run test:unit`, `npm run test:unit:coverage`, `npm run-script test:unit`, `npm --prefix extensions/drm-copilot test`, `npm --prefix extensions/drm-copilot run test:coverage`. No row was added beyond the earlier enumeration, and the assertion keeps its meaning.
