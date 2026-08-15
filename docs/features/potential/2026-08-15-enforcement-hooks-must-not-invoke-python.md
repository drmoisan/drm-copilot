# enforcement-hooks-must-not-invoke-python (Potential Feature)

- Date captured: 2026-08-15
- Author: Dan Moisan
- Status: Draft

## Summary

Nine enforcement hooks under `.claude/hooks/` invoke Python, and the orchestrator-state PowerShell library defers to a Python validator whenever one is importable. Per the owner directive of 2026-08-15, no enforcement hook may use Python: every hook must be implemented in bash or PowerShell, with bash preferred because the hook surface is migrating to bash long-term.

## Problem Statement

An enforcement hook that shells out to Python inherits a second implementation of the rule it enforces, and the implementations drift. This already produced an observed defect: the MCP TypeScript validator reported `ok: true` under `require_pr_creation_ready` for a checkpoint the Python validator rejected on `step8_status`, so an orchestrator recorded a passing preflight that the hook then blocked. Recorded separately at `docs/features/potential/2026-08-15-mcp-pr-creation-ready-parity-divergence.md`.

The portability failure is more serious than the drift. `.claude/lib/orchestrator-state/OrchestratorState.psm1` carries a complete PowerShell mirror of the readiness logic, but `Test-PythonOrchestratorValidatorAvailable` causes it to defer to the Python CLI whenever Python is importable. The mirror therefore runs only where Python is absent. The consequence is that **the same hook enforces via a different implementation depending on the repository**: the Python leg in drm-copilot, the PowerShell mirror in a destination workspace that has no Poetry environment. A hook whose behavior depends on whether an unrelated toolchain happens to be installed is not a dependable gate.

A pushed-down governance payload is expected to run in destination repositories of arbitrary stacks. A C# or TypeScript destination has no reason to carry a Python environment, so a Python-dependent hook either silently degrades to a different code path or fails outright.

## Current State (verified 2026-08-15)

Hooks invoking `python` or `poetry run`:

- `.claude/hooks/check-python-test-purity.ps1`
- `.claude/hooks/enforce-discovery-artifact-gate.ps1`
- `.claude/hooks/enforce-evidence-locations.ps1`
- `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1`
- `.claude/hooks/enforce-python-batch-budget.ps1`
- `.claude/hooks/validate-discovery-artifact-gate.ps1`
- `.claude/hooks/validate-executor-output.ps1`
- `.claude/hooks/validate-feature-review-coverage.ps1`
- `.claude/hooks/validate-orchestrator-output.ps1`

Plus the indirect path: `.claude/hooks/enforce-pr-author-skill.ps1` reaches Python through `Invoke-OrchestratorStatePreflight` in `.claude/lib/orchestrator-state/OrchestratorState.psm1`.

An existing bash library root is already established at `.claude/lib/bash/`, carrying the parallel-surface helpers, so the target pattern exists and does not need inventing.

Note that two of the nine — `check-python-test-purity.ps1` and `enforce-python-batch-budget.ps1` — are *about* Python code but need not be *implemented* in Python. Enforcing a rule against Python source does not require a Python interpreter.

## Proposed Direction

1. Remove the Python-deference branch from `OrchestratorState.psm1` so one implementation runs everywhere. This is the highest-value single change: it closes the observed divergence and the portability gap at once, and the PowerShell mirror it falls back to already exists and is tested.
2. Port hook logic to bash libraries under `.claude/lib/bash/`, following the established parallel-surface pattern, and reduce each hook to thin dispatch.
3. Add a repository guard asserting that no file under `.claude/hooks/**` contains a `python` or `poetry run` invocation, so the class of defect cannot reappear. This is the durable fix; without it the rule is prose only.
4. Add a test asserting each migrated hook returns the same verdict with and without a Python environment on PATH.

## Sequencing Note

This is a governance-surface change touching the enforcement layer that gates the orchestration workflow itself. Migrating a hook while that hook is gating in-flight work risks blocking the very run performing the migration. Sequence the orchestrator-state hook deliberately, and prefer landing the guard (item 3) early so newly authored hooks cannot add to the backlog while the existing nine are worked through.

## Open Questions

- Whether the nine hooks migrate in one change or in batches by subsystem.
- Whether PowerShell hooks that carry no Python invocation are also in scope for a bash port, or whether the immediate objective is only Python removal with the bash migration following separately.
- Whether the MCP TypeScript validator surface remains as a non-enforcement convenience for orchestrators, given that only the hook's verdict is binding.

## Next Step

- [ ] Promote to GitHub issue
- [ ] Move to active feature folder / branch
