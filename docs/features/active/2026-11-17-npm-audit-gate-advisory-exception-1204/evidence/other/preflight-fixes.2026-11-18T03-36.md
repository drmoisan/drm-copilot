# Preflight fixes

Timestamp: 2026-11-18T03-36
Plan: docs/features/active/2026-11-17-npm-audit-gate-advisory-exception-1204/plan.2026-11-17T22-23.md

1. P0-T1 | unsatisfiable check-mode formatter | replaced "format in check mode" with a non-writing -WriteFile seam on Invoke-PoshQCFormat, drift count from Formatted: lines, before/after hashes.
2. P1-T1 | AC "failing-then-passing test" had no evidence route | added fail-before-exception dossier requirement under evidence/regression-testing/.
3. P1-T5 | INA-NPM-ARGS did not assert that the full audit omits no dev dependencies | added the full call argv assertion (audit --json, no --omit).
4. P2-T1 | acceptance referenced a later task; test dispositions incomplete | acceptance now names P2-T2 tests run in P2-T2; added dispositions for CiRequiredGate.Tests.ps1 and test_execution_environment_brief_contracts.py (both unchanged, unaffected).
