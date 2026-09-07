# codex-deployment-allowlist-drift (Issue #646)

- Date captured: 2026-09-07
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/codex-deployment-allowlist-drift/ (Issue #646)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #646
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/646
- Last Updated: 2026-09-07
## Summary

The PowerShell mirror of the Codex deployment resolver, `.claude/lib/codex-routing/CodexDeployment.psm1`, omits `commit-steward` from `GENERATED_AGENT_FAMILIES`, while the Python authority `scripts/dev_tools/resolve_codex_deployment.py` includes it. Any orchestrator checkpoint that carries a genuine Codex `commit-steward` routing receipt passes the Python validator but is rejected by the pr-author hook's PowerShell preflight, blocking pull-request creation.

## Environment

- OS/version: Windows 11 Pro 10.0.26200; observed on the #614 orchestration worktree at branch head 2e67deb3
- Python version: Poetry-managed 3.13
- Command/flags used: `gh pr create --body-file artifacts/pr_body_614.md ...` issued by `Agent(pr-author)`, intercepted by `.claude/hooks/enforce-pr-author-skill.ps1`
- Data source or fixture: `artifacts/orchestration/orchestrator-state.json` converted from a Codex run (source checkpoint archived at `artifacts/orchestration/handoff/orchestrator-state.codex-source.2026-09-03T05-10.json`) carrying `codex_model_routing_receipts[]` entries with `logical_agent: "commit-steward"` and `profile_path: ".codex/agents/commit-steward-c4.toml`

## Steps to Reproduce

1. Take an orchestrator-state checkpoint whose `codex_model_routing_receipts[]` contains an entry with `logical_agent: "commit-steward"` (any real Codex run that delegated the commit-steward persona produces one; `.codex/agents/commit-steward*.toml` profiles exist).
2. Run `poetry run python scripts/dev_tools/validate_orchestration_artifacts.py orchestrator-state --require-pr-creation-ready artifacts/orchestration/orchestrator-state.json`; it exits 0.
3. Run `Import-Module .claude/lib/orchestrator-state/OrchestratorState.psm1; Invoke-OrchestratorStatePreflight -CheckpointPath artifacts/orchestration/orchestrator-state.json`, or attempt `gh pr create --body-file ...` through the pr-author agent.

## Expected Behavior

Both validators accept the same checkpoint. The PowerShell port is documented as a mirror of the Python validator, and `commit-steward` is a generated Codex agent family (`scripts/dev_tools/generate_codex_agent_variants.py` line 41, `resolve_codex_deployment.py` line 41, and the `.codex/agents/commit-steward-c{1..4}.toml` profiles).

## Actual Behavior

The PowerShell preflight fails and the hook denies the command:

```
ORCHESTRATOR_STATE_PREFLIGHT_FAILED: Checkpoint codex_model_routing_receipts[20] has invalid routing inputs: Unsupported Codex logical agent: 'commit-steward'.
Checkpoint codex_model_routing_receipts[29] has invalid routing inputs: Unsupported Codex logical agent: 'commit-steward'.
Checkpoint codex_model_routing_receipts[35] has invalid routing inputs: Unsupported Codex logical agent: 'commit-steward'.
```

The Python CLI accepts the identical file.

## Logs / Screenshots

- [x] Attached minimal logs or screenshot
- Snippet: `CodexDeployment.psm1` line 279 `throw [System.ArgumentException]::new("Unsupported Codex logical agent: '$LogicalAgent'.")` is reached because `$script:GENERATED_AGENT_FAMILIES` (lines 66-78) lists eleven families and `LOGICAL_AGENT_ALIASES` maps only `feature-review`; the Python `GENERATED_AGENT_FAMILIES` frozenset lists twelve, including `"commit-steward"`.

## Impact / Severity

- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low

Any Codex-originated or Codex-converted orchestration that used the commit-steward persona cannot open its pull request through the sanctioned pr-author path without editing the checkpoint. On #614 the workaround was to relocate the historical Codex receipt arrays verbatim under `provider_handoff.archived_*` keys, which both validators then accepted.

## Suspected Cause / Notes

`commit-steward` was added to the Python allowlist in commit 655ea922 (`feat(routing): add commit-steward deployment profiles`). The PowerShell module was rewritten in feca22fa (`fix(claude-hooks): remove Python invocations from enforcement-hook surface`) and never received the new family. There is a static config-parity test between the PowerShell and Python model-routing tables for `config/orchestration-routing.json`, but no parity test pins `GENERATED_AGENT_FAMILIES` across the two Codex deployment implementations. Also relevant: the PowerShell preflight validates every present Codex receipt even when no Codex requirement flag is set, so a Claude-destination checkpoint that keeps source-provider receipts opaque is still parsed by it.

## Proposed Fix / Validation Ideas

- [x] Unit coverage areas: add `commit-steward` to `$script:GENERATED_AGENT_FAMILIES` in `CodexDeployment.psm1` and its published copy under `extensions/drm-copilot/resources/claude-customizations/`; add a parity test that asserts the PowerShell family list equals the Python frozenset (mirroring the existing routing-table parity test).
- [x] Integration scenario to retest: run `Invoke-OrchestratorStatePreflight` against a checkpoint fixture carrying a `commit-steward` receipt and assert no error; run the Python CLI against the same fixture.
- [ ] Manual verification notes: confirm the pr-author hook allows `gh pr create --body-file` on such a checkpoint.

## Next Step

- [ ] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch
