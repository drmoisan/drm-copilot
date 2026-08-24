# enforcement-hooks-must-not-invoke-python (Issue #475)

- Date captured: 2026-08-15
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/enforcement-hooks-must-not-invoke-python/ (Issue #475)

- Issue: #475
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/475
- Last Updated: 2026-08-15
- Work Mode: full-feature

## Summary

Enforcement hooks under `.claude/hooks/` invoke Python, and the orchestrator-state PowerShell library defers to a Python validator whenever one is importable. Per the owner directive of 2026-08-15, no enforcement hook may use Python: every hook must be implemented in bash or PowerShell, with bash preferred because the hook surface is migrating to bash long-term. This change removes Python and keeps the hooks in PowerShell; a full bash port is explicitly out of scope and is separate later work.

## Problem Statement

An enforcement hook that shells out to Python inherits a second implementation of the rule it enforces, and the implementations drift. This already produced an observed defect: the MCP TypeScript validator reported `ok: true` under `require_pr_creation_ready` for a checkpoint the Python validator rejected on `step8_status`, so an orchestrator recorded a passing preflight that the hook then blocked. Recorded separately at `docs/features/potential/2026-08-15-mcp-pr-creation-ready-parity-divergence.md`.

The portability failure is more serious than the drift. `.claude/lib/orchestrator-state/OrchestratorState.psm1` carries a complete PowerShell mirror of the readiness logic, but `Test-PythonOrchestratorValidatorAvailable` causes it to defer to the Python CLI whenever Python is importable. The mirror therefore runs only where Python is absent. The consequence is that **the same hook enforces via a different implementation depending on the repository**: the Python leg in drm-copilot, the PowerShell mirror in a destination workspace that has no Poetry environment. A hook whose behavior depends on whether an unrelated toolchain happens to be installed is not a dependable gate.

A pushed-down governance payload is expected to run in destination repositories of arbitrary stacks. A C# or TypeScript destination has no reason to carry a Python environment, so a Python-dependent hook either silently degrades to a different code path or fails outright.

## Current State (re-verified 2026-08-15 at HEAD b1a86fd3)

The original inventory in this record was produced by a naive grep for the word `python`. Re-verification distinguishes actual invocations from incidental mentions. This distinction is load-bearing for the guard design.

**Actual Python invocation sites (4):**

| Location | Invocation |
| --- | --- |
| `.claude/hooks/enforce-discovery-artifact-gate.ps1:50` | `& python -m scripts.dev_tools.validate_discovery_artifacts` |
| `.claude/hooks/validate-discovery-artifact-gate.ps1:53` | `& python -m scripts.dev_tools.validate_discovery_artifacts` |
| `.claude/hooks/validate-orchestrator-output.ps1:196` | `& python -m scripts.dev_tools.validate_orchestration_artifacts` |
| `.claude/lib/orchestrator-state/OrchestratorState.psm1:367,451` | `& python -c 'import ...'` capability probe, then `& python -m scripts.dev_tools.validate_orchestration_artifacts` |

Doc-comment mentions of the same commands appear at `enforce-discovery-artifact-gate.ps1:39`, `validate-discovery-artifact-gate.ps1:42`, and `validate-orchestrator-output.ps1:160`; these disappear with the code they document.

**Incidental mentions only — no invocation (6 hooks):**

- `.claude/hooks/check-python-test-purity.ps1` — the word appears in a violation message and in the rule path `.claude/rules/python.md`.
- `.claude/hooks/enforce-evidence-locations.ps1` — the permitted artifact path `artifacts/python/`.
- `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` — the agent name `python-typed-engineer` inside a regex.
- `.claude/hooks/enforce-python-batch-budget.ps1` — the state-file name `python-batch-budget.<session_id>.json`.
- `.claude/hooks/validate-executor-output.ps1` — the language label `Python` and a regex literal matching `poetry run ` in *agent output text*, not a shell invocation.
- `.claude/hooks/validate-feature-review-coverage.ps1` — the coverage path `artifacts/python/lcov.info` and the language label.

These six require no Python removal. The two hooks that are *about* Python source (`check-python-test-purity.ps1`, `enforce-python-batch-budget.ps1`) already enforce their rules without an interpreter, which confirms the directive's observation that enforcing a rule against Python code does not require Python.

An existing bash library root is established at `.claude/lib/bash/`, carrying the parallel-surface helpers, so the eventual bash target pattern exists. It is not used in this change.

## Proposed Direction

1. Remove the Python-deference branch from `OrchestratorState.psm1` so one implementation runs everywhere. This is the highest-value single change: it closes the observed divergence and the portability gap at once, and the PowerShell mirror it falls back to already exists and is tested. Land this early.
2. Replace the three direct `& python -m ...` hook invocations with PowerShell implementations, keeping the hooks in PowerShell. Do not port to `.claude/lib/bash/` in this change.
3. Add a repository guard asserting that no file under `.claude/hooks/**` contains a Python or `poetry run` **invocation**, so the class of defect cannot reappear. Land the guard early so newly authored hooks cannot add to the backlog. The guard must match invocation syntax, not the substring `python`; a substring guard produces six false positives against the hooks listed above and would be disabled on first contact.
4. Add tests asserting each migrated hook returns the same verdict with and without a Python environment on PATH. That is the assertion which would have caught the originating defect.

## Sequencing Note

This is a governance-surface change touching the enforcement layer that gates the orchestration workflow itself. Migrating a hook while that hook is gating in-flight work risks blocking the very run performing the migration. `validate-orchestrator-output.ps1` is the orchestrator's own completion gate and `OrchestratorState.psm1` backs the PR-author gate, so both must be verified working immediately after modification.

## Resolved Questions (owner directive, 2026-08-15)

- **Batching:** the hooks migrate in this single change, not in batches by subsystem.
- **Non-Python PowerShell hooks:** hooks carrying no Python invocation are NOT in scope. The immediate objective is Python removal only; the bash migration follows separately.
- **MCP TypeScript validator surface:** it stays, as a non-enforcement convenience for orchestrators. Only the hook's verdict is binding, so the TypeScript surface is not a third parity obligation.

## Next Step

- [x] Promote to GitHub issue
- [ ] Move to active feature folder / branch
