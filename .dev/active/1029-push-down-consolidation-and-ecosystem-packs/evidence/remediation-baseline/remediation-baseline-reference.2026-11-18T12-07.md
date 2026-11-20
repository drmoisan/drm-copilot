# Remediation Baseline Reference (cycle 1)

Timestamp: 2026-11-18T12-07
Command: reference only, no re-run (plan decision D3): `evidence/baseline/baseline-pester.2026-11-18T08-22.md` is the `Phase 0 baseline` of the Pester gate for remediation cycle 1. That run was `sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pester` (one `Invoke-PoshQCParallelTest` through the launcher, integration and golden lanes excluded).
EXIT_CODE: 1
Output Summary: Counts restated from the cited baseline file: 29032 tests, 1 failure, 0 errors. Failing case: `tests/scripts/harness-generation/HarnessGeneration.RepoGate.Tests.ps1` :: `reports no drift for any generated target in the working tree` (drift in `.claude/rules/orchestrator-state.md` and its bundle copy). Repo-wide line coverage: not recorded, because no merged coverage file exists for a run with a failing shard.

## Static-baseline disposition

The remediation file set (`scripts/harness-generation/sources/rules/orchestrator-state.md`, `scripts/harness-generation/sources/rules/orchestrator-state.json`, and files under the feature folder) holds no PowerShell, Python, or TypeScript file, so no format, lint, or type-check baseline applies to this cycle.
