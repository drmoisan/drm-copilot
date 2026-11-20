# R1 Coverage Note ([P1-T6])

Plan: remediation-plan.2026-11-19T12-09.md
Timestamp: 2026-11-19T14-19
Command: git diff --name-status SYNC-MERGE HEAD; git status --porcelain; figures read from the r1 baseline and final gate artifacts
EXIT_CODE: 0
Output Summary: 19 files changed since SYNC-MERGE (3 data, 16 documents), `git status --porcelain` empty; no production code file changed; no `*.py` file added; repository-wide and per-file coverage of `agentic_sync.py` and `copilot-customizations-engine.ts` equal the Phase 0 baseline (no drop).

no production code file changed

## Changed Files

| File | Status | Class |
| --- | --- | --- |
| `extensions/drm-copilot/resources/customizations/pack-manifests/core.json` | M | data |
| `extensions/drm-copilot/resources/customizations/pack-manifests/csharp.json` | M | data |
| `extensions/drm-copilot/resources/customizations/pack-manifests/powershell.json` | M | data |
| `<FEATURE>/remediation-inputs.2026-11-19T12-09.md` | A | document |
| `<FEATURE>/remediation-plan.2026-11-19T12-09.md` | A | document |
| `<FEATURE>/evidence/baseline/r1-manifest-inventory.2026-11-19T12-24.md` | A | document |
| `<FEATURE>/evidence/baseline/r1-merge-inventory.2026-11-19T12-25.md` | A | document |
| `<FEATURE>/evidence/baseline/r1-pytest-baseline.2026-11-19T12-37.md` | A | document |
| `<FEATURE>/evidence/baseline/r1-jest-baseline.2026-11-19T12-37.md` | A | document |
| `<FEATURE>/evidence/baseline/r1-pester-baseline.2026-11-19T12-52.md` | A | document |
| `<FEATURE>/evidence/other/task-check.P1-T1.2026-11-19T13-45.md` | A | document |
| `<FEATURE>/evidence/other/task-check.P1-T2.2026-11-19T13-46.md` | A | document |
| `<FEATURE>/evidence/other/stale-reference-classification.2026-11-19T13-50.md` | A | document |
| `<FEATURE>/evidence/qa-gates/r1-final-static.2026-11-19T13-47.md` | A | document |
| `<FEATURE>/evidence/qa-gates/r1-contract-checks.2026-11-19T13-47.md` | A | document |
| `<FEATURE>/evidence/qa-gates/r1-brief-copy-facts.2026-11-19T13-50.md` | A | document |
| `<FEATURE>/evidence/regression-testing/r1-pytest-final.2026-11-19T14-02.md` | A | document |
| `<FEATURE>/evidence/regression-testing/r1-jest-final.2026-11-19T14-02.md` | A | document |
| `<FEATURE>/evidence/regression-testing/r1-pester-final.2026-11-19T14-17.md` | A | document |

## Coverage Comparison (Phase 0 baseline against final gate)

| Scope | Phase 0 baseline | Final | Change |
| --- | --- | --- | --- |
| Python repository-wide | line 98.00% (35359/36079), branch 95.46% (13091/13714) | line 98.00% (35359/36079), branch 95.46% (13091/13714) | none |
| `scripts/dev_tools/agentic_sync.py` | line 98.02% (99/101), branch 94.12% (32/34) | line 98.02% (99/101), branch 94.12% (32/34) | none |
| Jest `extensions/drm-copilot` overall | lines 97.42% (68430/70240), branches 94.63% (10597/11198) | lines 97.42% (68430/70240), branches 94.63% (10597/11198) | none |
| `src/lib/push-down/copilot-customizations-engine.ts` | lines 100% (314/314), branches 100% (34/34) | lines 100% (314/314), branches 100% (34/34) | none |
| PowerShell repository-wide (line only) | 96.77% (47184/48759) | 96.77% (47184/48759) | none |

Added `*.py` files: none.
