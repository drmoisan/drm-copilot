# orchestrator-completion-hook-false-block (Issue #413)

- Date captured: 2026-07-25
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/orchestrator-completion-hook-false-block/ (Issue #413)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #413
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/413
- Last Updated: 2026-07-25
## Summary

The orchestrator completion hook `.claude/hooks/validate-orchestrator-output.ps1` blocks DONE on a *successful* validation. It is broken closed: no checkpoint can satisfy the documented DONE gate whenever the Python validator CLI is importable, because the hook treats the validator's stdout success line as error text.

## Environment

- OS/version: Windows 11 Pro 10.0.26200
- Python version: repository `.venv` interpreter resolved by bare `python`
- Command/flags used: `.claude/hooks/validate-orchestrator-output.ps1` with a DONE-claiming `CLAUDE_HOOK_INPUT` payload
- Data source or fixture: a fully valid, completion-passing `artifacts/orchestration/orchestrator-state.json`

## Steps to Reproduce

1. Produce an `artifacts/orchestration/orchestrator-state.json` that passes `python -m scripts.dev_tools.validate_orchestration_artifacts orchestrator-state <path> --require-complete --require-model-routing` with exit code 0.
2. Set `CLAUDE_HOOK_INPUT` to a well-formed hook payload whose `output` field is a non-empty DONE completion summary.
3. Run `pwsh -File .claude/hooks/validate-orchestrator-output.ps1`.

## Expected Behavior

The hook exits 0 and allows termination, because the authoritative validator reported success.

## Actual Behavior

The hook exits 1 and blocks with the validator's own success message quoted as the block reason:

`ROUTING_CONTRACT_BLOCKED: orchestrator-state validation passed: artifacts/orchestration/orchestrator-state.json`

## Logs / Screenshots

- [x] Attached minimal logs or screenshot
- Snippet: `ROUTING_CONTRACT_BLOCKED: orchestrator-state validation passed: artifacts/orchestration/orchestrator-state.json`

## Impact / Severity

- [x] Blocker
- [ ] High
- [ ] Medium
- [ ] Low

The documented completion gate for every orchestration run is unusable as completion evidence. The gate cannot produce a false *allow*, so the failure direction is safe, but it is unconditionally false-blocking.

## Suspected Cause / Notes

In `Invoke-RoutingContractValidation` the default `$Invoker` runs the validator CLI with `2>&1`, folding stdout into the captured text, and the decision is:

```powershell
$hasErrors = ($exitCode -ne 0) -or (-not [string]::IsNullOrWhiteSpace($outputText))
```

On a clean pass the CLI exits 0 but prints `orchestrator-state validation passed: <path>` to stdout. The second disjunct therefore fires and `HasErrors` becomes `$true`.

Files to inspect:

- `.claude/hooks/validate-orchestrator-output.ps1` (`Invoke-RoutingContractValidation`)
- `.claude/lib/orchestrator-state/OrchestratorStateCompletion.psm1` (`Test-OrchestratorStateCompletionReadiness`, the portable fallback branch)
- `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/validate-orchestrator-output.ps1` (bundled pushed-down copy, currently byte-identical)
- `extensions/drm-copilot/resources/claude-customizations/.claude/lib/orchestrator-state/OrchestratorStateCompletion.psm1`

## Proposed Fix / Validation Ideas

- [x] Unit coverage areas: `tests/scripts/claude-hooks/validate-orchestrator-output.Tests.ps1` and siblings; `tests/scripts/claude-lib/orchestrator-state/OrchestratorStateCompletion.Tests.ps1`
- [x] Integration scenario to retest: run the hook itself against a passing checkpoint and confirm exit 0
- [x] Manual verification notes: the fix must keep the gate failing closed on a genuine validator failure and must not weaken it

## Next Step

- [x] Promote to GitHub issue (bug-report template)
- [x] Move to active fix folder / branch
