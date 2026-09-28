# Remediation Inputs: Planner Self-Review Enforcement

Timestamp: 2026-08-29T14-41

## Authoritative Finding

`Test-HasPlannerInternalReview` in `.claude/hooks/validate-planner-output.ps1:113-120` returns true when the output contains only `PLANNER-INTERNAL-REVIEW:` and the labels `citation-to-tree`, `acceptance-criterion-to-implementation`, and `scope-boundary`. It does not require recorded results, citation enumeration, acceptance-criterion mappings, scope-boundary outcome, or unresolved-gap disposition.

The original plan’s P2-T3 requires rejection of output missing a required dimension, citation enumeration, or traceability record. AC2 requires an internal review that is completed and recorded before executor preflight. This is a blocker.

## Required Fixes

1. Update `.claude/hooks/validate-planner-output.ps1` to parse and require a complete `PLANNER-INTERNAL-REVIEW` record with passing outcomes for citation-to-tree, AC-to-implementation traceability, and scope-boundary consistency; current-tree citation enumeration; per-AC implementation/test/evidence mapping; and an explicit resolved/no-unresolved-gaps disposition. Reject missing, blank, blocked, or partial components.
2. Extend `tests/scripts/claude-hooks/validate-planner-output.Tests.ps1` with isolated in-memory fixtures for a bare-token declaration, each omitted record component, blocked results, and a complete valid record. Retain valid plan-path and preflight signal when isolating each review failure.
3. Extend `tests/scripts/dev_tools/test_claude_planning_integrity_contracts.py` to assert the parser and required record fields, not merely keyword presence.
4. Mirror every changed `.claude/**` runtime resource exactly under `extensions/drm-copilot/resources/claude-customizations/.claude/**`, then prove byte parity.
5. Re-run the applicable ordered PowerShell and Python QA loop, record canonical evidence, and restore AC2 only after this review passes.

## Do Not Do

- Do not weaken AC2, treat a keyword-only declaration as evidence, or create a second executor preflight loop.
- Do not modify Codex runtime surfaces, the generic plan-progress counter, unrelated settings, or issue #586 convergence and iteration controls.
- Do not use temporary files in tests, stage, commit, push, publish, create a PR, or merge as part of remediation execution.

## Verification Commands

```powershell
Invoke-Pester -Path tests/scripts/claude-hooks/validate-planner-output.Tests.ps1,tests/scripts/claude-runtime/claude-settings.Tests.ps1 -PassThru
poetry run pytest tests/scripts/dev_tools/test_claude_planning_integrity_contracts.py tests/scripts/dev_tools/test_parallel_planner_surface_contracts.py tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -p no:cacheprovider -q
```
