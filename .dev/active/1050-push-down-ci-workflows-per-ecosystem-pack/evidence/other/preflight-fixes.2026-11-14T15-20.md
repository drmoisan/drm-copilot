# Preflight Fixes - Issue #1050

Timestamp: 2026-11-14T15-20
Plan: docs/features/active/2026-10-31-push-down-ci-workflows-per-ecosystem-pack-1050/plan.2026-11-14T09-31.md
Signal: PREFLIGHT: REVISIONS REQUIRED (substantive defects are returned to the planner; the fixes below are trivial and were made in task text only)

## Fixes

1. [P2-T4] | literal-formatting defect (ambiguous asserted path set) | The `caller, data file and consumers agree` case said "each pack's artifact path appears in the bundled `validate-feature-review-coverage-metrics.ps1`". That hook reads `artifacts/python/lcov.info`, `artifacts/pester/powershell-coverage.xml`, `coverage/lcov.info` and `artifacts/csharp/coverage.xml`. It does not read `artifacts/python/coverage.json` or `artifacts/pester/pester-junit.xml`, so the condition could not pass if it covered every artifact path in the spec's `## Template Contract` table. The task now names the four coverage paths the hook reads. This matches the singular "artifact path" of spec S12, so the meaning of the assertion is unchanged.
2. `## Existing Test Dispositions`, `ProcessReductionChain.Ledger.Tests.ps1` row | stale citation | The reason cited only the `Current` fences of `0002-concurrent-review.md` and `0003-light-remediation.md`. Other ledger entries also mention the execution-environment brief or `jest.config.cjs`, and P0-T2 already checks every fence. The reason now cites every `Current` fence under `docs/engineering/process-reductions/`. The disposition (unchanged) is the same.

## Validation

- Branch-current Python CLI `scripts/dev_tools/validate_orchestration_artifacts.py plan`: passed, with no warnings, before the fixes. It is re-run after the fixes and the result is recorded in the preflight return.
- Installed MCP `validate_orchestration_artifacts` (plan): ok before the fixes; re-run after the fixes.
