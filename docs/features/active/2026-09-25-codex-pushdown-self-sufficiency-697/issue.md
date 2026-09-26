# codex-pushdown-self-sufficiency (Issue #697)

- Date captured: 2026-09-25
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/codex-pushdown-self-sufficiency/ (Issue #697)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #697
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/697
- Last Updated: 2026-09-25
- Work Mode: full-bug

## Summary

The Codex customization payload published by `push_down_codex_and_agents_customizations` is not self-sufficient in a destination repository. A destination checkout receives hooks that fire on every tool call, an agent role Codex refuses to load, and an orchestration skill whose canonical topology and deployment resolvers are not delivered, so `$orchestrate` cannot start.

## Environment

- OS/version: Windows 11 Pro 10.0.26200
- Python version: n/a (defect is in the published payload, not the interpreter)
- Command/flags used: `codex` v0.154.0 in a destination checkout; `$orchestrate <objective>`
- Data source or fixture: destination checkout `TaskMaster-wt/2026-09-17T18-33`, populated by an earlier `push_down_codex_and_agents_customizations` run

## Steps to Reproduce

1. Run `push_down_codex_and_agents_customizations` into a destination repository that is not `drm-copilot`.
2. Start Codex v0.154.0 in that destination checkout.
3. Observe the startup banner and the per-tool-call hook results.
4. Issue any request that routes through `$orchestrate`.

## Expected Behavior

Every hook registered by the published `.codex/config.toml` loads and returns a valid PreToolUse result. Every agent role in the published `.codex/agents/` deserializes. `$orchestrate` resolves Codex topology and deployment and proceeds to delegation.

## Actual Behavior

Four distinct failures, all reproduced:

1. **`hook exited with code 1` on every tool call.** `.codex/hooks/enforce-epic-planning-only.ps1` calls `Get-EpicPlanningRegisteredMcpTool` at script scope (line 86), outside any `try`/`catch`. It throws `EPIC_PLANNING_ONLY_BLOCKED: semantic MCP registry '<root>/config/orchestration-handoff-registry.json' does not exist.` when that file is absent, and an uncaught throw makes `pwsh -File` exit 1. The hook is registered under the `^(Bash|shell_command|apply_patch|Edit|Write|mcp__.*)$` matcher, so it fires on every tool call regardless of relevance.

2. **`hook returned invalid pre-tool-use JSON output`, 2-4 times per tool call.** Five hooks in an older published payload print `{"decision":"allow"}` on the allow path. Codex 0.154.0 accepts empty stdout or a `hookSpecificOutput` object and rejects the legacy shape. Current source hooks already emit nothing on allow, so this leg is staleness rather than a live source defect.

3. **`Ignoring malformed agent role definition: unknown field 'variant'`.** `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex-variants/csharp-legacy/agents/csharp-typed-engineer.toml` carries `variant = "legacy"` in place of the `model` / `model_reasoning_effort` pair the canonical agent file declares. Codex's role deserializer rejects the unknown key and drops the role entirely, so the legacy C# engineer persona is unavailable and its model pinning is lost. This is a live defect in the current bundle, not staleness.

4. **`$orchestrate` halts at `CODEX_TOPOLOGY_RESOLVER_UNAVAILABLE`.** `.agents/skills/codex-model-routing/SKILL.md` prescribes `poetry run python -m scripts.dev_tools.resolve_codex_topology` and `resolve_codex_deployment`. Those modules exist only under `drm-copilot/scripts/dev_tools/`; the push-down publishes `.codex/`, `.agents/`, and three `config/` files, with no `scripts/` tree and no `pyproject.toml`. No MCP substitute is exposed: `.codex/config.toml` `enabled_tools` omits `resolve_orchestration_topology`, `resolve_provider_routing`, and `transition_prepared_orchestration`, and those three resolve portable-handoff topology from a prepared envelope, which is a different contract from file-count-to-logical-agent topology.

## Logs / Screenshots

- [x] Attached minimal logs or snippet
- Snippet (Codex, destination checkout):

```
⚠ Ignoring malformed agent role definition: failed to deserialize agent role file at
  .codex\agents\csharp-typed-engineer.toml: unknown field `variant`

• Hook failed
  └ hook returned invalid pre-tool-use JSON output
• Hook failed
  └ hook returned invalid pre-tool-use JSON output
• Hook failed
  └ hook exited with code 1
```

- Probe of the published hooks under a synthetic `PreToolUse` payload, destination vs. current source:

```
EXIT-1         enforce-epic-planning-only.ps1
   STDERR: EPIC_PLANNING_ONLY_BLOCKED: semantic MCP registry '...' does not exist.
OUTPUT         enforce-promotion-mcp-only.ps1              STDOUT: {"decision":"allow"}
OUTPUT         enforce-orchestration-preimplementation-gate.ps1  STDOUT: {"decision":"allow"}
OUTPUT         enforce-evidence-locations.ps1             STDOUT: {"decision":"allow"}
OUTPUT         enforce-checkpoint-monotonic.ps1           STDOUT: {"decision":"allow"}
OUTPUT         enforce-completion-consistency.ps1         STDOUT: {"decision":"allow"}
```

The failure counts match the observed transcript exactly. For a shell command, matcher group 1 contributes 2 invalid-JSON hooks and matcher group 2 contributes the 1 exit-1, giving 3 failures. For an `apply_patch`, matcher group 2 contributes the exit-1 and matcher group 3 contributes 4 invalid-JSON hooks, giving 1 + 4.

## Impact / Severity

- [x] Blocker
- [ ] High
- [ ] Medium
- [ ] Low

The Codex orchestration surface is currently only usable inside `drm-copilot` itself. In any destination repository it emits hook failures on every tool call and cannot begin orchestration.

## Suspected Cause / Notes

The published payload and the runtime contract it assumes have drifted apart in four independent places:

- `.codex/hooks/enforce-epic-planning-only.ps1` treats an optional published artifact as a load-time invariant, converting a missing file into a session-wide hook failure.
- The `csharp-legacy` variant agent file was hand-maintained and never validated against Codex's role schema. `generate_codex_agent_variants.py` renders only the canonical `.codex/agents/` family and never touches `.codex-variants/`, so nothing catches the divergence. `push_down_codex_filesystem.py` `CSHARP_CANONICAL_PATHS` redirects exactly this one agent file to the variant tree; the `-c1`..`-c4` profiles come from the canonical tree and are unaffected.
- A faithful PowerShell port of both resolvers already exists at `.claude/lib/codex-routing/CodexTopology.psm1` (`Resolve-CodexTopology`, `Get-CodexForcedRootPersona`) and `.claude/lib/codex-routing/CodexDeployment.psm1` (`Resolve-CodexDeployment`), with parity against the Python modules already enforced by `tests/scripts/claude-lib/codex-routing/`. It ships only in the Claude pack manifest. The Codex pack ships nothing from `.claude/`, and the Codex hooks do not import it (the `codex-routing` matches in `.codex/hooks/*.ps1` are the attestation filename `codex-routing-attestation.*.json`, not module imports).
- `pack-manifests/core.json` omits 11 hooks that `.codex/config.toml` registers unconditionally, plus `enforce-completion-helpers.ps1` as a transitive dot-source dependency of `enforce-completion-consistency.ps1`. The language packs carry no hooks and no config at all. This is latent only because the default push-down runs in full-tree mode (`packs=None`); any `--packs`-scoped push registers hooks that were never delivered.

## Proposed Fix / Validation Ideas

- [x] Unit coverage areas
  - A hook-contract test asserting `enforce-epic-planning-only.ps1` exits 0 and allows silently when `config/orchestration-handoff-registry.json` is absent.
  - A role-schema test asserting every published `.codex/agents/*.toml` and every `.codex-variants/**/agents/*.toml` declares only fields Codex accepts, and that each declares `model` and `model_reasoning_effort`.
  - Parity coverage proving the new PowerShell resolver CLI wrappers emit the same JSON as the Python CLIs for the same arguments.
  - A manifest guard test asserting every hook path referenced by `.codex/config.toml`, plus each hook's transitive dot-source dependencies, is present in the published pack set.
- [x] Integration scenario to retest
  - Re-run the push-down into a destination checkout and confirm Codex starts with zero hook failures, loads every agent role, and resolves topology and deployment without a Python toolchain.
- [x] Manual verification notes
  - Re-probe the published hooks with the synthetic `PreToolUse` payload and confirm every hook reports allow-silent.

## Next Step

- [x] Promote to GitHub issue (bug-report template)
- [x] Move to active fix folder / branch
