# python-batch-budget-hook-lacks-orchestration-awareness (Potential Bug)

- Date captured: 2026-09-29
- Author: Dan Moisan
- Status: Draft
- Related: #769

## Summary

The Python batch-budget hooks follow the session-keyed per-batch pattern that #769 replaced for PowerShell. They count production and test files per session, deny when a fixed cap is reached, and tell the caller to split the work, raise the cap, or delete the state file. They do not read the orchestrator checkpoint, so an orchestrated large-path Python change is capped the same way a direct-mode change is.

The deny messages are at `.claude/hooks/enforce-python-batch-budget.ps1:293` and `.codex/hooks/enforce-python-batch-budget.ps1:137`.

## Scope

- `.claude/hooks/enforce-python-batch-budget.ps1` and `.codex/hooks/enforce-python-batch-budget.ps1`, with both bundle copies under `extensions/drm-copilot/resources/`.
- `tests/scripts/claude-hooks/enforce-python-batch-budget.Tests.ps1`.
- The Python row of `tests/scripts/codex-hooks/codex-batch-budget-hooks.Tests.ps1`, including the Python-only cap Context added by #769.
- `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1:227-231`.
- Python text surfaces on every runtime, with their mirrors: `python-change-budget-router`, `invoke-python-engineer`, and `python-typed-engineer`.

## Acceptance Criteria (early draft)

- [ ] Both Python hooks read `<root>/artifacts/orchestration/orchestrator-state.json` through an injectable seam and allow every Python path, without writing state, on a non-terminal `large`, `remediation`, or `preparation` route (mirrors #769 AC-1 through AC-4).
- [ ] Route selection, terminal detection, and malformed-checkpoint handling match #769 AC-5 and AC-6.
- [ ] Direct mode counts only distinct production Python paths; test files are never counted (mirrors #769 AC-7).
- [ ] The runtime cap overrides are removed and legacy state keys load and are ignored (mirrors #769 AC-8).
- [ ] A case-insensitive search for the #769 AC-13 phrases returns no match in Python-scoped surfaces and their mirrors.

## Constraints & Risks

- The Python threshold differs from the PowerShell threshold and must be confirmed before the text surfaces are reconciled.
- The Codex topology resolver carries its own Python budget; any change must keep the resolver and the hook text consistent.

## Next Step

- [ ] Promote this entry through the MCP promotion tool.
- [ ] Create the active feature folder.
