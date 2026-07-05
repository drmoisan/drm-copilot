# Cross-Language Regression Baseline (Issue #305)

Timestamp: 2026-07-04T14-58

## Python

Command: python -m pytest --cov=src --cov=scripts/dev_tools -q
EXIT_CODE: 0
Output Summary: 1294 passed in 4.19s. Coverage LCOV written to artifacts/python/lcov.info.
No failures. Suite green at baseline.

## PowerShell (PoshQC / Pester)

Command: mcp__drm-copilot__run_poshqc_test (bundled PoshQC Pester suite) against workspace root
EXIT_CODE: 0 (tool returned {"ok":true, "tool":"run_poshqc_test"})
Output Summary: PoshQC/Pester test run completed successfully (ok:true). The tracked
`testResults.xml` (NUnit) shape reference: total=124, failures=0, errors=0, skipped=0.
Suite green at baseline.

## Purpose

These baselines let Phase 3 confirm no cross-language regression is introduced by the
TypeScript-only extraction and coverage-wiring changes in Phases 1-2.
